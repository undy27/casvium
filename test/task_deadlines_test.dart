import 'package:casvium/models/models.dart';
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
}
