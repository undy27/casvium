import 'dart:convert';

import 'package:casvium/models/models.dart';
import 'package:casvium/services/local_household_storage.dart';
import 'package:casvium/services/railway_postgres_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('La periodicidad usa días del calendario y ajusta el fin de mes', () {
    expect(
      TaskFrequency.daily.nextAfter(DateTime(2026, 3, 28, 23, 59)),
      DateTime(2026, 3, 29),
    );
    expect(
      TaskFrequency.monthly.nextAfter(DateTime(2028, 1, 31)),
      DateTime(2028, 2, 29),
    );
    expect(
      TaskFrequency.monthly.nextAfter(DateTime(2026, 12, 31)),
      DateTime(2027, 1, 31),
    );
    expect(
      TaskFrequency.fromLabel('2 veces/sem').nextAfter(DateTime(2026, 11, 12)),
      DateTime(2026, 11, 16),
    );
    expect(
      TaskFrequency.fromLabel('3 veces/sem').nextAfter(DateTime(2026, 11, 11)),
      DateTime(2026, 11, 13),
    );
  });

  test('La última sesión válida recalcula el vencimiento de su tarea', () {
    final store = CasviumStore();
    final householdId = store.currentHousehold.id;
    final task = ChoreTask(
      id: 'task-deadline',
      householdId: householdId,
      title: 'Limpiar horno',
      description: '',
      iconKey: 'oven_sparkle',
      roomIds: const [],
      estimatedMinutes: 20,
      frequency: TaskFrequency.weekly,
      createdAt: DateTime(2026, 11, 1, 19),
    );
    store.tasks.add(task);

    final now = DateTime(2026, 11, 11, 18);
    TaskDeadline? deadlineAt(DateTime date) =>
        store.taskDeadlines(now: date)[task.id];

    expect(deadlineAt(DateTime(2026, 11, 8, 23, 59))!.status,
        TaskDeadlineStatus.today);
    expect(
        deadlineAt(DateTime(2026, 11, 9))!.status, TaskDeadlineStatus.overdue);

    void log(DateTime performedAt, {String? otherHouseholdId}) {
      store.sessions.insert(
        0,
        WorkSession(
          id: performedAt.toIso8601String(),
          householdId: otherHouseholdId ?? householdId,
          taskId: task.id,
          memberId: store.members.first.id,
          loggedByUser: store.activeLoggedUser,
          performedAt: performedAt,
          durationMinutes: 20,
        ),
      );
    }

    log(DateTime(2026, 11, 10, 8));
    log(DateTime(2026, 11, 7, 15));
    log(DateTime(2026, 11, 11, 19));
    log(DateTime(2026, 11, 11, 10), otherHouseholdId: 'otro-hogar');
    expect(deadlineAt(now)!.date, DateTime(2026, 11, 17));
    expect(deadlineAt(now)!.status, TaskDeadlineStatus.upcoming);

    store.updateChoreTaskFrequency(task.id, TaskFrequency.daily);
    expect(deadlineAt(now)!.status, TaskDeadlineStatus.today);
    store.updateChoreTaskFrequency(task.id, TaskFrequency.none);
    expect(deadlineAt(now), isNull);

    store.createNewHousehold(
      name: 'Otro hogar',
      mascotName: 'Don Mocho',
      initialMemberNames: ['Clara'],
    );
    expect(store.taskDeadlines(now: now), isEmpty);
  });

  test('La periodicidad editada y la última sesión sobreviven al reinicio',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = CasviumStore(preferences: preferences);
    final task = store.currentTasks.first;
    final performedAt = DateTime.now();

    store.updateChoreTaskFrequency(task.id, TaskFrequency.monthly);
    store.logWorkSession(
      taskId: task.id,
      memberId: store.members.first.id,
      loggedByUser: store.activeLoggedUser,
      performedAt: performedAt,
      durationMinutes: 12,
    );

    await Future<void>.delayed(Duration.zero);
    await preferences.reload();
    final restored = CasviumStore(preferences: preferences);
    final deadline = restored.taskDeadlines(now: performedAt)[task.id]!;
    expect(deadline.task.frequency, TaskFrequency.monthly);
    expect(deadline.task.createdAt, task.createdAt);
    expect(restored.currentSessions.first.performedAt, performedAt);
    expect(deadline.date, TaskFrequency.monthly.nextAfter(performedAt));
  });

  test('Los cambios de ejemplo y Railway se conservan en su propio origen',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final household = Household(
      id: 'real-home',
      name: 'Hogar de Railway',
      inviteCode: 'CASV-RAILWAY',
      createdAt: DateTime(2026, 11, 1),
    );
    var reads = 0;
    HouseholdSnapshot? uploaded;
    final store = CasviumStore(
      preferences: preferences,
      loadRailway: (_, id) async {
        expect(id, reads == 0 ? '' : household.id);
        reads++;
        return HouseholdSnapshot(
          household: household,
          households: [household],
          members: [],
          rooms: [],
          tasks: [],
          sessions: [],
          activeLoggedUser: '',
        );
      },
      saveRailway: (_, snapshot) async => uploaded = snapshot,
    )..railwayConnection = 'conexión de prueba';

    final exampleTask = store.currentTasks.first;
    store.updateChoreTaskFrequency(exampleTask.id, TaskFrequency.none);
    await store.syncWithRailwayPostgres();
    expect(uploaded, isNull);

    await store.selectDataSource(CasviumDataSource.railway);
    expect(store.currentHousehold.id, household.id);
    expect(store.currentTasks, isEmpty);
    store.addRoom(
        name: 'Cuarto real', iconKey: 'mop_bucket', colorHex: '#4A7C59');

    await store.selectDataSource(CasviumDataSource.example);
    expect(store.currentTasks.first.frequency, TaskFrequency.none);
    expect(
        store.currentRooms.any((room) => room.name == 'Cuarto real'), isFalse);

    await store.selectDataSource(CasviumDataSource.railway);
    expect(reads, 1);
    expect(store.currentRooms.single.name, 'Cuarto real');
    expect(store.hasPendingRailwayChanges, isTrue);

    await Future<void>.delayed(Duration.zero);
    await preferences.reload();
    final restored = CasviumStore(preferences: preferences);
    expect(restored.dataSource, CasviumDataSource.railway);
    expect(restored.hasPendingRailwayChanges, isTrue);
    expect(restored.currentRooms.single.name, 'Cuarto real');

    await store.syncWithRailwayPostgres();
    expect(uploaded!.household.id, household.id);
    expect(uploaded!.rooms.single.name, 'Cuarto real');
    expect(store.hasPendingRailwayChanges, isFalse);
  });

  test('El hogar de ejemplo se excluye de los datos reales, incluida la caché',
      () async {
    final example = CasviumStore();
    final snapshot = HouseholdSnapshot(
      household: example.currentHousehold,
      households: example.households,
      members: example.members,
      rooms: example.rooms,
      tasks: example.tasks,
      sessions: example.sessions,
      activeLoggedUser: example.activeLoggedUser,
    );
    SharedPreferences.setMockInitialValues({
      'casvium.dataSource': 'railway',
      'casvium.railway.household.v1': jsonEncode({
        'snapshot': snapshot.encode(),
        'pending': true,
      }),
    });

    final preferences = await SharedPreferences.getInstance();
    final store = CasviumStore(
      preferences: preferences,
      loadRailway: (_, id) async {
        expect(id, isEmpty);
        return snapshot;
      },
      saveRailway: (_, __) async =>
          fail('Se intentó subir el hogar de ejemplo'),
    )..railwayConnection = 'conexión de prueba';
    expect(store.dataSource, CasviumDataSource.railway);
    expect(store.hasHousehold, isFalse);
    expect(store.hasPendingRailwayChanges, isFalse);

    await store.syncWithRailwayPostgres();
    expect(store.isConnectedToRailway, isTrue);
    expect(store.hasHousehold, isFalse);
    expect(store.members, isEmpty);
    expect(store.currentRooms, isEmpty);
    expect(store.currentTasks, isEmpty);
    expect(store.currentSessions, isEmpty);

    await store.selectDataSource(CasviumDataSource.example);
    expect(store.currentHousehold.id, snapshot.household.id);
    expect(store.currentTasks, isNotEmpty);
  });
}
