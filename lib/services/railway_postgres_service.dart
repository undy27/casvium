import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'pg_connector_stub.dart'
    if (dart.library.io) 'pg_connector_io.dart';

/// Servicio de estado y persistencia en PostgreSQL alojado en Railway.
/// Permite trabajar en tiempo real y sincronizar contra cualquier instancia
/// PostgreSQL de Railway mediante su cadena `DATABASE_URL`.
class CasviumStore extends ChangeNotifier {
  static const String railwayPublicAppUrl =
      'https://casvium-app-production.up.railway.app';
  static const String railwayPostgresPublicProxy =
      'tramway.proxy.rlwy.net:39687';

  String railwayDatabaseUrl =
      const String.fromEnvironment('DATABASE_URL', defaultValue: '');

  bool isConnectedToRailway = true;
  bool isSyncing = false;
  String lastSyncMessage =
      'Proyecto Casvium desplegado en Railway · App: https://casvium-app-production.up.railway.app · Postgres TCP: tramway.proxy.rlwy.net:39687';

  late Household currentHousehold;
  final List<Household> households = [];
  final List<HouseholdMember> members = [];
  final List<Room> rooms = [];
  final List<ChoreTask> tasks = [];
  final List<WorkSession> sessions = [];

  String activeLoggedUser = 'Lucía';

  CasviumStore() {
    _seedInitialHousehold();
  }

  void _seedInitialHousehold() {
    const hId = 'home-villa-olivo';
    currentHousehold = Household(
      id: hId,
      name: 'Casa Los Olivos 4B',
      inviteCode: 'CASV-842',
      mascotName: 'Don Mocho',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    households.add(currentHousehold);

    // Miembros de ejemplo
    members.addAll(const [
      HouseholdMember(
        id: 'mem-1',
        householdId: hId,
        name: 'Lucía',
        role: 'Chef & Orden',
        avatarColorHex: '#E06D53',
        streakDays: 6,
      ),
      HouseholdMember(
        id: 'mem-2',
        householdId: hId,
        name: 'Mateo',
        role: 'Maestro de Suelos',
        avatarColorHex: '#4A7C59',
        streakDays: 5,
      ),
      HouseholdMember(
        id: 'mem-3',
        householdId: hId,
        name: 'Clara',
        role: 'Jardín & Colada',
        avatarColorHex: '#3B7097',
        streakDays: 4,
      ),
    ]);

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
    tasks.addAll(const [
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
        frequencyLabel: '2 veces/sem',
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
        frequencyLabel: 'Diaria',
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
        frequencyLabel: 'Semanal',
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
        frequencyLabel: 'Semanal',
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
        frequencyLabel: '3 veces/sem',
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
        frequencyLabel: 'Semanal',
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
        frequencyLabel: 'Diaria',
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
        frequencyLabel: 'Diaria',
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
        frequencyLabel: '2 veces/sem',
        intensity: 1,
      ),
    ]);

    // Sesiones de trabajo de ejemplo en los últimos 7 días
    final now = DateTime.now();
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
    notifyListeners();
  }

  void createNewHousehold({
    required String name,
    required String mascotName,
    required List<String> initialMemberNames,
  }) {
    final newId = 'home-${DateTime.now().millisecondsSinceEpoch}';
    final code =
        'CASV-${(100 + DateTime.now().millisecond % 899)}';
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
          id: 'mem-$newId-$i',
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
    notifyListeners();
  }

  void setActiveLoggedUser(String userName) {
    activeLoggedUser = userName;
    notifyListeners();
  }

  void addMember({
    required String name,
    required String role,
    required String colorHex,
  }) {
    final member = HouseholdMember(
      id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
      householdId: currentHousehold.id,
      name: name,
      role: role,
      avatarColorHex: colorHex,
      streakDays: 1,
    );
    members.add(member);
    notifyListeners();
  }

  void addRoom({
    required String name,
    required String iconKey,
    required String colorHex,
  }) {
    final room = Room(
      id: 'room-${DateTime.now().millisecondsSinceEpoch}',
      householdId: currentHousehold.id,
      name: name,
      iconKey: iconKey,
      colorHex: colorHex,
      isDefault: false,
    );
    rooms.add(room);
    notifyListeners();
  }

  void addChoreTask({
    required String title,
    required String description,
    required String iconKey,
    required List<String> roomIds,
    required int estimatedMinutes,
    required bool isShared,
    required String frequencyLabel,
    required int intensity,
  }) {
    final task = ChoreTask(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      householdId: currentHousehold.id,
      title: title,
      description: description,
      iconKey: iconKey,
      roomIds: roomIds,
      estimatedMinutes: estimatedMinutes,
      isShared: isShared,
      frequencyLabel: frequencyLabel,
      intensity: intensity,
    );
    tasks.insert(0, task);
    notifyListeners();
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
      id: 'sess-${DateTime.now().millisecondsSinceEpoch}',
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
    notifyListeners();
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

  /// Conexión y sincronización directa con PostgreSQL en Railway.
  Future<void> syncWithRailwayPostgres(String connectionUrl) async {
    railwayDatabaseUrl = connectionUrl.trim();
    if (railwayDatabaseUrl.isEmpty) {
      lastSyncMessage = 'Introduce una URL postgresql:// válida de Railway.';
      notifyListeners();
      return;
    }

    isSyncing = true;
    lastSyncMessage = 'Conectando a PostgreSQL en Railway...';
    notifyListeners();

    try {
      lastSyncMessage = await syncHouseholdToPostgresImpl(
        connectionUrl: railwayDatabaseUrl,
        household: currentHousehold,
        members: members,
        rooms: rooms,
        tasks: tasks,
        sessions: sessions,
      );
      isConnectedToRailway = true;
    } catch (e) {
      isConnectedToRailway = false;
      lastSyncMessage = 'Error al conectar con Railway: $e';
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }
}
