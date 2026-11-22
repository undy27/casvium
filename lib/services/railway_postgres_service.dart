import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'local_household_storage.dart';
import 'pg_connector_stub.dart' if (dart.library.io) 'pg_connector_io.dart';

enum CasviumDataSource { example, railway }

/// Estado local del hogar y sincronización con PostgreSQL en Railway.
class CasviumStore extends ChangeNotifier {
  static const _demoHouseholdId = 'home-villa-olivo';
  static const _exampleKey = 'casvium.household.v1';
  static const _railwayKey = 'casvium.railway.household.v1';
  static const _sourceKey = 'casvium.dataSource';
  static const _ids = Uuid();

  final String _railwayDatabaseUrl;
  String railwayAccessKey = '';

  CasviumDataSource _dataSource = CasviumDataSource.example;
  CasviumDataSource get dataSource => _dataSource;
  bool get hasHousehold => currentHousehold.id.isNotEmpty;

  bool isConnectedToRailway = false;
  bool isSyncing = false;
  bool _hasPendingRailwayChanges = false;
  bool get hasPendingRailwayChanges => _hasPendingRailwayChanges;
  String? lastSyncMessage;

  late Household currentHousehold;
  final List<Household> households = [];
  final List<HouseholdMember> members = [];
  final List<Room> rooms = [];
  final List<ChoreTask> tasks = [];
  final List<WorkSession> sessions = [];

  String activeLoggedUser = 'Lucía';

  List<Room> get currentRooms =>
      rooms.where((room) => room.householdId == currentHousehold.id).toList();

  List<ChoreTask> get currentTasks =>
      tasks.where((task) => task.householdId == currentHousehold.id).toList();

  List<WorkSession> get currentSessions => sessions
      .where((session) => session.householdId == currentHousehold.id)
      .toList();

  final SharedPreferences? _preferences;
  final Future<HouseholdSnapshot?> Function(String, String) _loadRailway;
  final Future<void> Function(String, HouseholdSnapshot) _saveRailway;
  Future<void> _pendingSave = Future.value();

  HouseholdSnapshot? _exampleSnapshot;
  HouseholdSnapshot? _railwaySnapshot;

  CasviumStore({
    SharedPreferences? preferences,
    String railwayDatabaseUrl = configuredRailwayDatabaseUrl,
    Future<HouseholdSnapshot?> Function(String, String) loadRailway =
        loadRailwayHousehold,
    Future<void> Function(String, HouseholdSnapshot) saveRailway =
        saveRailwayHousehold,
  })  : _preferences = preferences,
        _railwayDatabaseUrl = railwayDatabaseUrl.trim(),
        _loadRailway = loadRailway,
        _saveRailway = saveRailway {
    _exampleSnapshot = _readSnapshot(_exampleKey);
    _restoreRailwaySnapshot();
    if (preferences?.getString(_sourceKey) == CasviumDataSource.railway.name) {
      _dataSource = CasviumDataSource.railway;
    }
    _applySource();
    if (_dataSource == CasviumDataSource.railway &&
        hasHousehold &&
        !_hasPendingRailwayChanges) {
      lastSyncMessage = 'Mostrando la última copia de Railway.';
    }
  }

  void _restoreRailwaySnapshot() {
    final saved = _preferences?.getString(_railwayKey);
    if (saved == null) return;
    try {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      final snapshot = HouseholdSnapshot.decode(data['snapshot'] as String);
      if (snapshot.household.id == _demoHouseholdId) return;
      final pending = data['pending'] as bool;
      _railwaySnapshot = snapshot;
      _hasPendingRailwayChanges = pending;
    } on FormatException {
      debugPrint('No se pudo leer la copia local de Railway.');
    } on TypeError {
      debugPrint('Formato de la copia de Railway incompatible.');
    }
  }

  HouseholdSnapshot? _readSnapshot(String key) {
    try {
      final saved = _preferences?.getString(key);
      return saved == null ? null : HouseholdSnapshot.decode(saved);
    } on FormatException {
      debugPrint('No se pudo leer el hogar guardado.');
    } on TypeError {
      debugPrint('Formato de hogar guardado incompatible.');
    }
    return null;
  }

  void _applySource() {
    final snapshot = _dataSource == CasviumDataSource.example
        ? _exampleSnapshot
        : _railwaySnapshot;
    households.clear();
    members.clear();
    rooms.clear();
    tasks.clear();
    sessions.clear();
    activeLoggedUser = '';

    if (snapshot != null) {
      currentHousehold = snapshot.household;
      households.addAll(snapshot.households);
      members.addAll(snapshot.members
          .where((member) => member.householdId == currentHousehold.id));
      rooms.addAll(snapshot.rooms);
      tasks.addAll(snapshot.tasks);
      sessions.addAll(snapshot.sessions);
      activeLoggedUser = snapshot.activeLoggedUser;
    } else if (_dataSource == CasviumDataSource.example) {
      _seedInitialHousehold();
    } else {
      currentHousehold = Household(
        id: '',
        name: 'Sin hogar',
        inviteCode: '',
        createdAt: DateTime.now(),
      );
    }
  }

  HouseholdSnapshot? _captureSnapshot() {
    if (!hasHousehold) return null;
    return HouseholdSnapshot(
      household: currentHousehold,
      households: List.of(households),
      members: List.of(members),
      rooms: List.of(rooms),
      tasks: List.of(tasks),
      sessions: List.of(sessions),
      activeLoggedUser: activeLoggedUser,
    );
  }

  void _rememberSource() {
    if (_dataSource == CasviumDataSource.example) {
      _exampleSnapshot = _captureSnapshot();
    } else {
      _railwaySnapshot = _captureSnapshot();
    }
  }

  void _persistState() {
    final preferences = _preferences;
    if (preferences == null) return;
    final example = _exampleSnapshot?.encode();
    final snapshot = _railwaySnapshot;
    final railway = snapshot == null
        ? null
        : jsonEncode({
            'snapshot': snapshot.encode(),
            'pending': _hasPendingRailwayChanges,
          });
    final source = _dataSource.name;
    _pendingSave = _pendingSave.then((_) async {
      try {
        if (railway == null) {
          await preferences.remove(_railwayKey);
        } else {
          await preferences.setString(_railwayKey, railway);
        }
        if (example != null) await preferences.setString(_exampleKey, example);
        await preferences.setString(_sourceKey, source);
      } catch (error) {
        debugPrint('No se pudo guardar el hogar: $error');
      }
    });
  }

  void _saveChanges({bool householdChanged = true}) {
    if (_dataSource == CasviumDataSource.railway && householdChanged) {
      _hasPendingRailwayChanges = true;
    }
    _rememberSource();
    _persistState();
    notifyListeners();
  }

  static const _exampleMembers = [
    HouseholdMember(
      id: 'mem-1',
      householdId: _demoHouseholdId,
      name: 'Lucía',
      role: 'Chef & Orden',
      avatarColorHex: '#E06D53',
      streakDays: 6,
    ),
    HouseholdMember(
      id: 'mem-2',
      householdId: _demoHouseholdId,
      name: 'Mateo',
      role: 'Maestro de Suelos',
      avatarColorHex: '#4A7C59',
      streakDays: 5,
    ),
    HouseholdMember(
      id: 'mem-3',
      householdId: _demoHouseholdId,
      name: 'Clara',
      role: 'Jardín & Colada',
      avatarColorHex: '#3B7097',
      streakDays: 4,
    ),
  ];

  void _seedInitialHousehold() {
    final now = DateTime.now();
    const hId = _demoHouseholdId;
    activeLoggedUser = 'Lucía';
    currentHousehold = Household(
      id: hId,
      name: 'Casa Los Olivos 4B',
      inviteCode: 'CASV-842',
      mascotName: 'Don Mocho',
      createdAt: now.subtract(const Duration(days: 30)),
    );
    households.add(currentHousehold);

    members.addAll(_exampleMembers);

    // Estancias por defecto (típicas de un hogar)
    rooms.addAll(const [
      Room(
        id: 'room-cocina',
        householdId: hId,
        name: 'Cocina',
        iconKey: 'cooking_pot',
        colorHex: '#E06D53',
        isDefault: true,
      ),
      Room(
        id: 'room-bano',
        householdId: hId,
        name: 'Baño Principal',
        iconKey: 'shower_head',
        colorHex: '#68B0AB',
        isDefault: true,
      ),
      Room(
        id: 'room-salon',
        householdId: hId,
        name: 'Salón-Comedor',
        iconKey: 'vacuum',
        colorHex: '#E5A93C',
        isDefault: true,
      ),
      Room(
        id: 'room-dormitorio',
        householdId: hId,
        name: 'Dormitorio',
        iconKey: 'bed_pillow',
        colorHex: '#845EC2',
        isDefault: true,
      ),
      Room(
        id: 'room-lavadero',
        householdId: hId,
        name: 'Lavadero y Colada',
        iconKey: 'washing_machine',
        colorHex: '#3B7097',
        isDefault: true,
      ),
      Room(
        id: 'room-terraza',
        householdId: hId,
        name: 'Terraza y Plantas',
        iconKey: 'watering_can',
        colorHex: '#4A7C59',
        isDefault: true,
      ),
      Room(
        id: 'room-recibidor',
        householdId: hId,
        name: 'Recibidor y Pasillo',
        iconKey: 'shoe_rack',
        colorHex: '#C85A32',
        isDefault: true,
      ),
    ]);

    // Tareas de ejemplo frecuentes (asociadas a una o varias estancias)
    tasks.addAll([
      ChoreTask(
        id: 'task-1',
        householdId: hId,
        title: 'Fregar suelos con jabón neutro',
        description:
            'Repaso completo con Don Mocho en zonas de paso y baldosas.',
        iconKey: 'mop_bucket',
        roomIds: ['room-cocina', 'room-bano', 'room-salon', 'room-recibidor'],
        estimatedMinutes: 25,
        isShared: true,
        frequency: TaskFrequency.twiceWeekly,
        createdAt: currentHousehold.createdAt,
        intensity: 2,
      ),
      ChoreTask(
        id: 'task-2',
        householdId: hId,
        title: 'Vaciar y cargar el lavavajillas',
        description:
            'Guardar vajilla limpia, aclarar restos y programar ciclo eco.',
        iconKey: 'dishwasher',
        roomIds: ['room-cocina'],
        estimatedMinutes: 12,
        isShared: true,
        frequency: TaskFrequency.daily,
        createdAt: currentHousehold.createdAt,
        intensity: 1,
      ),
      ChoreTask(
        id: 'task-3',
        householdId: hId,
        title: 'Desinfectar ducha, mampara y lavabo',
        description: 'Aplicar antical en mampara, grifería e inodoro.',
        iconKey: 'shower_head',
        roomIds: ['room-bano'],
        estimatedMinutes: 20,
        isShared: true,
        frequency: TaskFrequency.weekly,
        createdAt: currentHousehold.createdAt,
        intensity: 3,
      ),
      ChoreTask(
        id: 'task-4',
        householdId: hId,
        title: 'Pasar aspiradora a alfombras y sofá',
        description: 'Aspirado profundo de pelusas, cojines y esquinas.',
        iconKey: 'vacuum',
        roomIds: ['room-salon', 'room-dormitorio', 'room-recibidor'],
        estimatedMinutes: 20,
        isShared: true,
        frequency: TaskFrequency.weekly,
        createdAt: currentHousehold.createdAt,
        intensity: 2,
      ),
      ChoreTask(
        id: 'task-5',
        householdId: hId,
        title: 'Poner lavadora y tender colada al sol',
        description: 'Separar colores, programar centrifugado y colgar sin arrugas.',
        iconKey: 'clothesline',
        roomIds: ['room-lavadero', 'room-terraza'],
        estimatedMinutes: 18,
        isShared: true,
        frequency: TaskFrequency.threeTimesWeekly,
        createdAt: currentHousehold.createdAt,
        intensity: 1,
      ),
      ChoreTask(
        id: 'task-6',
        householdId: hId,
        title: 'Cambiar sábanas y ventilar colchón',
        description: 'Retirar juego usado, airear 15 min y colocar sábanas frescas.',
        iconKey: 'fresh_sheets',
        roomIds: ['room-dormitorio'],
        estimatedMinutes: 15,
        isShared: false,
        frequency: TaskFrequency.weekly,
        createdAt: currentHousehold.createdAt,
        intensity: 2,
      ),
      ChoreTask(
        id: 'task-7',
        householdId: hId,
        title: 'Limpiar vitrocerámica y campana',
        description: 'Quitar grasa acumulada tras cocinar y abrillantar acero.',
        iconKey: 'stove_flame',
        roomIds: ['room-cocina'],
        estimatedMinutes: 15,
        isShared: true,
        frequency: TaskFrequency.daily,
        createdAt: currentHousehold.createdAt,
        intensity: 2,
      ),
      ChoreTask(
        id: 'task-8',
        householdId: hId,
        title: 'Bajar basura orgánica y reciclaje',
        description: 'Cerrar bolsas de envases, papel, vidrio y reponer bolsas nuevas.',
        iconKey: 'recycle_loop',
        roomIds: ['room-cocina', 'room-recibidor'],
        estimatedMinutes: 10,
        isShared: true,
        frequency: TaskFrequency.daily,
        createdAt: currentHousehold.createdAt,
        intensity: 1,
      ),
      ChoreTask(
        id: 'task-9',
        householdId: hId,
        title: 'Regar macetas y barrer terraza',
        description: 'Comprobar humedad del sustrato y retirar hojas secas.',
        iconKey: 'watering_can',
        roomIds: ['room-terraza', 'room-salon'],
        estimatedMinutes: 15,
        isShared: false,
        frequency: TaskFrequency.twiceWeekly,
        createdAt: currentHousehold.createdAt,
        intensity: 1,
      ),
    ]);

    // Sesiones de trabajo de ejemplo en los últimos 7 días
    sessions.addAll([
      WorkSession(
        id: 'sess-1',
        householdId: hId,
        taskId: 'task-1',
        memberId: 'mem-2',
        loggedByUser: 'Mateo',
        roomId: 'room-cocina',
        performedAt: now.subtract(const Duration(hours: 3)),
        durationMinutes: 28,
        coWorkerIds: const ['mem-1'],
        energyLevel: 5,
        notes: 'Suelo impecable con aroma a pino.',
      ),
      WorkSession(
        id: 'sess-2',
        householdId: hId,
        taskId: 'task-2',
        memberId: 'mem-1',
        loggedByUser: 'Lucía',
        roomId: 'room-cocina',
        performedAt: now.subtract(const Duration(hours: 6)),
        durationMinutes: 14,
        energyLevel: 4,
        notes: 'Ollas grandes lavadas a mano.',
      ),
      WorkSession(
        id: 'sess-3',
        householdId: hId,
        taskId: 'task-3',
        memberId: 'mem-3',
        loggedByUser: 'Clara',
        roomId: 'room-bano',
        performedAt: now.subtract(const Duration(days: 1, hours: 2)),
        durationMinutes: 22,
        energyLevel: 4,
        notes: 'Mampara sin una sola gota de cal.',
      ),
      WorkSession(
        id: 'sess-4',
        householdId: hId,
        taskId: 'task-4',
        memberId: 'mem-2',
        loggedByUser: 'Mateo',
        roomId: 'room-salon',
        performedAt: now.subtract(const Duration(days: 2, hours: 4)),
        durationMinutes: 20,
        energyLevel: 5,
        notes: 'Sofá y alfombra aspirados a fondo.',
      ),
      WorkSession(
        id: 'sess-5',
        householdId: hId,
        taskId: 'task-5',
        memberId: 'mem-3',
        loggedByUser: 'Clara',
        roomId: 'room-lavadero',
        performedAt: now.subtract(const Duration(days: 3, hours: 1)),
        durationMinutes: 19,
        coWorkerIds: const ['mem-1'],
        energyLevel: 4,
        notes: 'Dos tandas de ropa blanca y sábanas.',
      ),
      WorkSession(
        id: 'sess-6',
        householdId: hId,
        taskId: 'task-7',
        memberId: 'mem-1',
        loggedByUser: 'Lucía',
        roomId: 'room-cocina',
        performedAt: now.subtract(const Duration(days: 4, hours: 3)),
        durationMinutes: 16,
        energyLevel: 5,
        notes: 'Batch cooking dominical + desengrasado.',
      ),
      WorkSession(
        id: 'sess-7',
        householdId: hId,
        taskId: 'task-9',
        memberId: 'mem-3',
        loggedByUser: 'Clara',
        roomId: 'room-terraza',
        performedAt: now.subtract(const Duration(days: 5, hours: 2)),
        durationMinutes: 15,
        energyLevel: 5,
        notes: 'Monstera y olivos abonados.',
      ),
    ]);
  }

  // --- Operaciones de Hogar, Miembros, Estancias, Tareas y Sesiones ---

  void updateHouseholdInfo({required String name, required String mascotName}) {
    currentHousehold = currentHousehold.copyWith(
      name: name,
      mascotName: mascotName,
    );
    final index = households.indexWhere(
      (household) => household.id == currentHousehold.id,
    );
    households[index] = currentHousehold;
    _saveChanges();
  }

  void createNewHousehold({
    required String name,
    required String mascotName,
    required List<String> initialMemberNames,
  }) {
    final newId = _ids.v4();
    final code =
        'CASV-${newId.substring(0, 10).replaceAll('-', '').toUpperCase()}';
    currentHousehold = Household(
      id: newId,
      name: name,
      inviteCode: code,
      mascotName: mascotName,
      createdAt: DateTime.now(),
    );
    households.add(currentHousehold);

    members.clear();
    final palette = [
      '#E06D53',
      '#4A7C59',
      '#3B7097',
      '#E5A93C',
      '#845EC2',
      '#68B0AB',
    ];
    for (int i = 0; i < initialMemberNames.length; i++) {
      members.add(
        HouseholdMember(
          id: _ids.v4(),
          householdId: newId,
          name: initialMemberNames[i],
          role: i == 0 ? 'Anfitrión' : 'Miembro',
          avatarColorHex: palette[i % palette.length],
          streakDays: 1,
        ),
      );
    }
    if (members.isNotEmpty) {
      activeLoggedUser = members.first.name;
    }
    _saveChanges();
  }

  void setActiveLoggedUser(String userName) {
    activeLoggedUser = userName;
    _saveChanges(householdChanged: false);
  }

  void addMember({
    required String name,
    required String role,
    required String colorHex,
  }) {
    final member = HouseholdMember(
      id: _ids.v4(),
      householdId: currentHousehold.id,
      name: name,
      role: role,
      avatarColorHex: colorHex,
      streakDays: 1,
    );
    members.add(member);
    if (activeLoggedUser.isEmpty) activeLoggedUser = name;
    _saveChanges();
  }

  void addRoom({
    required String name,
    required String iconKey,
    required String colorHex,
  }) {
    final room = Room(
      id: _ids.v4(),
      householdId: currentHousehold.id,
      name: name,
      iconKey: iconKey,
      colorHex: colorHex,
      isDefault: false,
    );
    rooms.add(room);
    _saveChanges();
  }

  void addChoreTask({
    required String title,
    required String description,
    required String iconKey,
    required List<String> roomIds,
    required int estimatedMinutes,
    required bool isShared,
    required TaskFrequency frequency,
    required int intensity,
  }) {
    final now = DateTime.now();
    final task = ChoreTask(
      id: _ids.v4(),
      householdId: currentHousehold.id,
      title: title,
      description: description,
      iconKey: iconKey,
      roomIds: roomIds,
      estimatedMinutes: estimatedMinutes,
      isShared: isShared,
      frequency: frequency,
      createdAt: now,
      intensity: intensity,
    );
    tasks.insert(0, task);
    _saveChanges();
  }

  void updateChoreTaskFrequency(String taskId, TaskFrequency frequency) {
    final index = tasks.indexWhere(
      (task) => task.id == taskId && task.householdId == currentHousehold.id,
    );
    if (index == -1 || tasks[index].frequency == frequency) return;
    tasks[index] = tasks[index].copyWith(frequency: frequency);
    _saveChanges();
  }

  Map<String, TaskDeadline> taskDeadlines({required DateTime now}) {
    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    final latestSessions = <String, DateTime>{};
    for (final session in currentSessions) {
      if (session.performedAt.isAfter(now)) continue;
      final previous = latestSessions[session.taskId];
      if (previous == null || session.performedAt.isAfter(previous)) {
        latestSessions[session.taskId] = session.performedAt;
      }
    }

    final deadlines = <String, TaskDeadline>{};
    for (final task in currentTasks) {
      final date = task.frequency.nextAfter(
        latestSessions[task.id] ?? task.createdAt,
      );
      if (date == null) continue;
      final status = switch (date.compareTo(today)) {
        < 0 => TaskDeadlineStatus.overdue,
        0 => TaskDeadlineStatus.today,
        _ => TaskDeadlineStatus.upcoming,
      };
      deadlines[task.id] = TaskDeadline(task: task, date: date, status: status);
    }
    return deadlines;
  }

  void logWorkSession({
    required String taskId,
    required String memberId,
    required String loggedByUser,
    String? roomId,
    required DateTime performedAt,
    required int durationMinutes,
    List<String> coWorkerIds = const [],
    int energyLevel = 5,
    String notes = '',
  }) {
    final session = WorkSession(
      id: _ids.v4(),
      householdId: currentHousehold.id,
      taskId: taskId,
      memberId: memberId,
      loggedByUser: loggedByUser,
      roomId: roomId,
      performedAt: performedAt,
      durationMinutes: durationMinutes,
      coWorkerIds: coWorkerIds,
      energyLevel: energyLevel,
      notes: notes,
    );
    sessions.insert(0, session);
    _saveChanges();
  }

  Room? roomById(String? id) {
    if (id == null) return null;
    for (final r in rooms) {
      if (r.id == id) return r;
    }
    return null;
  }

  ChoreTask? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  HouseholdMember? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> selectDataSource(CasviumDataSource source) async {
    if (isSyncing || source == _dataSource) return;

    _rememberSource();
    _dataSource = source;
    isConnectedToRailway = false;
    lastSyncMessage = null;
    _applySource();
    _persistState();

    if (source == CasviumDataSource.railway && !_hasPendingRailwayChanges) {
      await syncWithRailwayPostgres();
    } else {
      notifyListeners();
    }
  }

  Future<void> syncWithRailwayPostgres() async {
    if (isSyncing || _dataSource != CasviumDataSource.railway) return;

    await _connectToRailway((connection) async {
      if (_hasPendingRailwayChanges && hasHousehold) {
        await _saveRailway(
          connection,
          HouseholdSnapshot(
            household: currentHousehold,
            households: [currentHousehold],
            members: List.of(members),
            rooms: currentRooms,
            tasks: currentTasks,
            sessions: currentSessions,
            activeLoggedUser: activeLoggedUser,
          ),
        );
        _hasPendingRailwayChanges = false;
        lastSyncMessage = 'Cambios guardados en Railway.';
      } else {
        _railwaySnapshot = await _fetchRailway(connection, _railwaySnapshot);
        _applySource();
        lastSyncMessage =
            hasHousehold ? 'Datos actualizados desde Railway.' : null;
      }
      _saveChanges(householdChanged: false);
    });
  }

  Future<HouseholdSnapshot?> _fetchRailway(
    String connection,
    HouseholdSnapshot? previous,
  ) async {
    final snapshot = await _loadRailway(
      connection,
      previous?.household.id ?? '',
    );
    if (snapshot?.household.id == _demoHouseholdId) return null;
    if (snapshot == null ||
        previous == null ||
        snapshot.household.id != previous.household.id ||
        !snapshot.members.any(
          (member) => member.name == previous.activeLoggedUser,
        )) {
      return snapshot;
    }
    return HouseholdSnapshot(
      household: snapshot.household,
      households: snapshot.households,
      members: snapshot.members,
      rooms: snapshot.rooms,
      tasks: snapshot.tasks,
      sessions: snapshot.sessions,
      activeLoggedUser: previous.activeLoggedUser,
    );
  }

  Future<void> _connectToRailway(
    Future<void> Function(String) operation,
  ) async {
    final connection = kIsWeb ? railwayAccessKey.trim() : _railwayDatabaseUrl;
    if (connection.isEmpty) {
      isConnectedToRailway = false;
      lastSyncMessage = kIsWeb
          ? 'Introduce la clave de acceso de Railway.'
          : 'Falta configurar el acceso a Railway en esta compilación.';
      notifyListeners();
      return;
    }
    isSyncing = true;
    lastSyncMessage = null;
    notifyListeners();
    try {
      await operation(connection);
      isConnectedToRailway = true;
    } on FormatException catch (e) {
      isConnectedToRailway = false;
      lastSyncMessage = e.message;
    } catch (_) {
      isConnectedToRailway = false;
      lastSyncMessage =
          'No se pudo acceder a Railway. Comprueba la conexión y vuelve a intentarlo.';
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }
}
