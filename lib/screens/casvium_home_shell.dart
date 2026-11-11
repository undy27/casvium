import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/chore_icons.dart';
import '../models/models.dart';
import '../services/railway_postgres_service.dart';
import '../theme/casvium_theme.dart';
import '../widgets/custom_charts.dart';
import '../widgets/custom_components.dart';
import '../widgets/fregona_mascot.dart';

class CasviumHomeShell extends StatefulWidget {
  final CasviumStore store;

  const CasviumHomeShell({
    super.key,
    required this.store,
  });

  @override
  State<CasviumHomeShell> createState() => _CasviumHomeShellState();
}

class _CasviumHomeShellState extends State<CasviumHomeShell> {
  int _selectedTab = 0;
  String? _selectedRoomFilterId;
  MascotMood _mascotMood = MascotMood.happy;
  String _mascotMessage =
      '¡Hola! Soy Don Mocho. Hoy la cocina y el salón brillan, ¿registramos una sesión rápida?';

  // Cronómetro en vivo para sesiones de trabajo
  Timer? _liveTimer;
  int _liveSeconds = 0;
  bool _isTimerRunning = false;
  String? _activeTimerTaskId;

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  void _toggleLiveTimer(String taskId) {
    if (_isTimerRunning && _activeTimerTaskId == taskId) {
      _liveTimer?.cancel();
      setState(() {
        _isTimerRunning = false;
        _mascotMood = MascotMood.celebrating;
        _mascotMessage =
            '¡Gran trabajo en equipo! Ya puedes guardar los minutos de tu sesión.';
      });
      final task = widget.store.taskById(taskId);
      if (task != null) {
        final mins = (_liveSeconds / 60).ceil().clamp(1, 240);
        _openLogSessionSheet(context, initialTask: task, initialMinutes: mins);
      }
      _liveSeconds = 0;
    } else {
      _liveTimer?.cancel();
      setState(() {
        _activeTimerTaskId = taskId;
        _liveSeconds = 0;
        _isTimerRunning = true;
        _mascotMood = MascotMood.scrubbing;
        _mascotMessage =
            '¡Fregona en marcha! Estoy contando el tiempo de la sesión contigo 🫧';
      });
      _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _liveSeconds++);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: CasviumColors.canvas,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildEditorialHeader(context),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildDashboardTab(context),
                      _buildTasksAndIconsTab(context),
                      _buildWorkSessionsTab(context),
                      _buildInfographicsTab(context),
                      _buildHouseholdAndRailwayTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CasviumFloatingDock(
            currentIndex: _selectedTab,
            onChanged: (index) => setState(() => _selectedTab = index),
          ),
        );
      },
    );
  }

  Widget _buildEditorialHeader(BuildContext context) {
    final store = widget.store;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: CasviumColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CASVIUM',
                  style: TextStyle(
                    color: CasviumColors.surface,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.1,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: store.isConnectedToRailway
                        ? CasviumColors.mint
                        : CasviumColors.mustard,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              store.currentHousehold.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: CasviumColors.ink,
              ),
            ),
          ),
          // Selector rápido de usuario activo que registra sesiones
          PopupMenuButton<String>(
            onSelected: store.setActiveLoggedUser,
            color: CasviumColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: CasviumColors.ink, width: 2),
            ),
            itemBuilder: (context) => store.members
                .map(
                  (m) => PopupMenuItem<String>(
                    value: m.name,
                    child: Row(
                      children: [
                         CircleAvatar(
                          radius: 11,
                          backgroundColor: m.color,
                          child: Text(
                            m.initials,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Usuario: ${m.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: CasviumColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: CasviumColors.ink, width: 1.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline,
                      size: 15, color: CasviumColors.ink),
                  const SizedBox(width: 4),
                  Text(
                    store.activeLoggedUser,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: CasviumColors.ink,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: MI HOGAR (Mascota Don Mocho + Resumen Bento + Estancias + Tareas)
  // =========================================================================
  Widget _buildDashboardTab(BuildContext context) {
    final store = widget.store;
    final totalMinutes =
        store.sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final sharedCount = store.tasks.where((t) => t.isShared).length;

    final filteredTasks = _selectedRoomFilterId == null
        ? store.tasks
        : store.tasks
            .where((t) => t.roomIds.contains(_selectedRoomFilterId))
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
      children: [
        // 1. Mascota humanizada Don Mocho
        CasviumBentoCard(
          backgroundColor: const Color(0xFFEAF2F5),
          child: FregonaMascotWidget(
            mood: _mascotMood,
            mascotName: store.currentHousehold.mascotName,
            speechBubble: _mascotMessage,
            onTap: () {
              final tips = [
                '¡Fregar en equipo reduce el tiempo a la mitad! Prueba a marcar un colaborador al registrar sesión.',
                '¡Lleváis $totalMinutes minutos acumulados cuidando "${store.currentHousehold.name}"!',
                'Consejo de Don Mocho: ventilar 10 minutos antes de cambiar sábanas multiplica la frescura.',
              ];
              setState(() {
                _mascotMood = MascotMood.celebrating;
                _mascotMessage =
                    tips[DateTime.now().second % tips.length];
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // 2. Tarjetas Bento de métricas rápidas
        Row(
          children: [
            Expanded(
              child: CasviumBentoCard(
                backgroundColor: CasviumColors.terracotta,
                padding: const EdgeInsets.all(14),
                onTap: () => setState(() => _selectedTab = 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TIEMPO INVERTIDO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: CasviumColors.surface,
                        letterSpacing: 0.7,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalMinutes min',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: CasviumColors.surface,
                      ),
                    ),
                    Text(
                      '${store.sessions.length} sesiones registradas',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: CasviumColors.surface,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CasviumBentoCard(
                backgroundColor: CasviumColors.sage,
                padding: const EdgeInsets.all(14),
                onTap: () => setState(() => _selectedTab = 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TAREAS COMPARTIDAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: CasviumColors.surface,
                        letterSpacing: 0.7,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sharedCount de ${store.tasks.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: CasviumColors.surface,
                      ),
                    ),
                    Text(
                      '${store.rooms.length} estancias activas',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: CasviumColors.surface,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Miembros del hogar y racha
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Equipo del Hogar',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            CasviumActionPill(
              label: '+ Miembro',
              compact: true,
              color: CasviumColors.mustard,
              textColor: CasviumColors.ink,
              onPressed: () => _openAddMemberDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: store.members.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final m = store.members[i];
              final memberSessions = store.sessions
                  .where((s) =>
                      s.memberId == m.id || s.coWorkerIds.contains(m.id))
                  .length;
              return CasviumBentoCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shadowOffset: 3,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: m.color,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: CasviumColors.ink, width: 1.8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        m.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                            color: CasviumColors.ink,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                        Text(
                          '${m.role} · $memberSessions sesiones',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: CasviumColors.inkMuted,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // 4. Filtro por Estancias (por defecto: cocina, baño, salón, etc.)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Estancias del Hogar',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            CasviumActionPill(
              label: '+ Estancia',
              compact: true,
              color: CasviumColors.surface,
              textColor: CasviumColors.ink,
              onPressed: () => _openAddRoomDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRoomFilterChip(
                label: 'Todas (${store.tasks.length})',
                iconKey: 'mop_bucket',
                selected: _selectedRoomFilterId == null,
                onTap: () => setState(() => _selectedRoomFilterId = null),
              ),
              const SizedBox(width: 8),
              ...store.rooms.map((room) {
                final count = store.tasks
                    .where((t) => t.roomIds.contains(room.id))
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildRoomFilterChip(
                    label: '${room.name} ($count)',
                    iconKey: room.iconKey,
                    selected: _selectedRoomFilterId == room.id,
                    onTap: () => setState(() {
                      _selectedRoomFilterId =
                          _selectedRoomFilterId == room.id ? null : room.id;
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. Lista de tareas frecuentes con ejecución rápida o registro de sesión
        ...filteredTasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildChoreTaskCard(context, task),
            )),
      ],
    );
  }

  Widget _buildRoomFilterChip({
    required String label,
    required String iconKey,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? CasviumColors.ink : CasviumColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: CasviumColors.ink, width: 1.8),
          boxShadow: selected
              ? null
              : const [
                  BoxShadow(
                    color: CasviumColors.ink,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChoreCustomIcon(
              iconKey: iconKey,
              size: 22,
              showBadgeBorder: false,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected ? CasviumColors.surface : CasviumColors.ink,
                fontFamily: 'Segoe UI',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoreTaskCard(BuildContext context, ChoreTask task) {
    final store = widget.store;
    final taskRooms = task.roomIds
        .map((id) => store.roomById(id))
        .whereType<Room>()
        .toList();
    final isTimingThis = _isTimerRunning && _activeTimerTaskId == task.id;

    return CasviumBentoCard(
      backgroundColor:
          isTimingThis ? const Color(0xFFFFF3D6) : CasviumColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChoreCustomIcon(
                iconKey: task.iconKey,
                size: 52,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: task.isShared
                                ? CasviumColors.sage.withOpacity(0.2)
                                : CasviumColors.mustard.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: CasviumColors.ink, width: 1.2),
                          ),
                          child: Text(
                            task.isShared
                                ? '🤝 COMPARTIDA'
                                : '👤 INDIVIDUAL',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: CasviumColors.ink,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CasviumColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: CasviumColors.ink, width: 1.2),
                          ),
                          child: Text(
                            '⏱ ${task.estimatedMinutes} min est.',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: CasviumColors.ink,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: CasviumColors.ink,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: CasviumColors.inkMuted,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Etiquetas de una o varias estancias asociadas
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: taskRooms.map((room) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: room.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: CasviumColors.ink, width: 1.3),
                ),
                child: Text(
                  '📍 ${room.name}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: CasviumColors.ink,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CasviumActionPill(
                  label: isTimingThis
                      ? 'Detener (${_liveSeconds ~/ 60}:${(_liveSeconds % 60).toString().padLeft(2, '0')})'
                      : 'Cronometrar',
                  icon: isTimingThis
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  color: isTimingThis
                      ? CasviumColors.coral
                      : CasviumColors.surfaceAlt,
                  textColor:
                      isTimingThis ? CasviumColors.surface : CasviumColors.ink,
                  compact: true,
                  onPressed: () => _toggleLiveTimer(task.id),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CasviumActionPill(
                  label: 'Registrar Sesión',
                  icon: Icons.check_circle_outline,
                  color: CasviumColors.terracotta,
                  textColor: CasviumColors.surface,
                  compact: true,
                  onPressed: () => _openLogSessionSheet(
                    context,
                    initialTask: task,
                    initialMinutes: task.estimatedMinutes,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: CATÁLOGO DE TAREAS + GALERÍA DE LOS 30 ICONOS VECTORIALES
  // =========================================================================
  Widget _buildTasksAndIconsTab(BuildContext context) {
    final store = widget.store;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tareas y 30 Iconos',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text(
                    'Crea tareas multi-estancia con duración estimada y elige entre los 30 iconos.',
                    style: TextStyle(
                      fontSize: 13,
                      color: CasviumColors.inkMuted,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CasviumActionPill(
              label: '+ Nueva Tarea',
              color: CasviumColors.terracotta,
              onPressed: () => _openCreateTaskSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Galería interactiva de los 30 iconos generados para tareas típicas
        CasviumBentoCard(
          backgroundColor: CasviumColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'COLECCIÓN DE 30 ICONOS DE TAREAS TÍPICAS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: CasviumColors.inkMuted,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: CasviumColors.mustard,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: CasviumColors.ink, width: 1.3),
                    ),
                    child: Text(
                      '${ChoreIconsCatalog.all.length} iconos',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Pulsa cualquier icono para crear directamente una tarea doméstica con esa ilustración:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ChoreIconsCatalog.all.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.76,
                ),
                itemBuilder: (context, index) {
                  final item = ChoreIconsCatalog.all[index];
                  return GestureDetector(
                    onTap: () => _openCreateTaskSheet(
                      context,
                      preselectedIconKey: item.key,
                      suggestedTitle: item.label,
                    ),
                    child: Column(
                      children: [
                        ChoreCustomIcon(
                          iconKey: item.key,
                          size: 44,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: CasviumColors.ink,
                            height: 1.1,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Catálogo Activo (${store.tasks.length} tareas)',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        ...store.tasks.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildChoreTaskCard(context, t),
            )),
      ],
    );
  }

  // =========================================================================
  // TAB 3: REGISTRO DE SESIONES DE TRABAJO (Fecha, Miembro, Usuario, Tarea, Duración...)
  // =========================================================================
  Widget _buildWorkSessionsTab(BuildContext context) {
    final store = widget.store;
    final dateFmt = DateFormat('dd/MM/yyyy · HH:mm');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bitácora de Sesiones',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text(
                    'Historial detallado de quién hizo cada tarea, cuándo, quién la registró y cuánto duró.',
                    style: TextStyle(
                      fontSize: 13,
                      color: CasviumColors.inkMuted,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CasviumActionPill(
              label: '+ Registrar',
              color: CasviumColors.terracotta,
              onPressed: () => _openLogSessionSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...store.sessions.map((session) {
          final task = store.taskById(session.taskId);
          final member = store.memberById(session.memberId);
          final room = store.roomById(session.roomId);
          final coWorkers = session.coWorkerIds
              .map((id) => store.memberById(id)?.name)
              .whereType<String>()
              .toList();

          final estMins = task?.estimatedMinutes ?? session.durationMinutes;
          final diff = session.durationMinutes - estMins;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CasviumBentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChoreCustomIcon(
                        iconKey: task?.iconKey ?? 'mop_bucket',
                        size: 46,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task?.title ?? 'Tarea doméstica',
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: CasviumColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '📅 ${dateFmt.format(session.performedAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CasviumColors.inkMuted,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: CasviumColors.mustard,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: CasviumColors.ink, width: 1.5),
                        ),
                        child: Text(
                          '${session.durationMinutes} min',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            color: CasviumColors.ink,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildSessionMetaBadge(
                        '👤 Realizada por: ${member?.name ?? "Miembro"}'
                        '${coWorkers.isNotEmpty ? " + ${coWorkers.join(", ")}" : ""}',
                        member?.color.withOpacity(0.22) ??
                            CasviumColors.surfaceAlt,
                      ),
                      _buildSessionMetaBadge(
                        '✍️ Registrado por: ${session.loggedByUser}',
                        CasviumColors.surfaceAlt,
                      ),
                      if (room != null)
                        _buildSessionMetaBadge(
                          '🏠 Estancia: ${room.name}',
                          room.color.withOpacity(0.2),
                        ),
                      _buildSessionMetaBadge(
                        diff <= 0
                            ? '⚡ ${diff.abs()}m más rápido que lo estimado (${estMins}m)'
                            : '⏳ +${diff}m sobre estimado (${estMins}m)',
                        diff <= 0
                            ? CasviumColors.mint.withOpacity(0.25)
                            : CasviumColors.terracotta.withOpacity(0.2),
                      ),
                    ],
                  ),
                  if (session.notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CasviumColors.canvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CasviumColors.ink.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        '“${session.notes}”',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: CasviumColors.ink,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSessionMetaBadge(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CasviumColors.ink, width: 1.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: CasviumColors.ink,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 4: INFOGRAFÍAS Y GRÁFICAS PERSONALIZADAS
  // =========================================================================
  Widget _buildInfographicsTab(BuildContext context) {
    final store = widget.store;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        Text(
          'Infografías del Hogar',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text(
          'Visualización de equidad entre miembros, esfuerzo por estancia y pulso semanal.',
          style: TextStyle(
            fontSize: 13,
            color: CasviumColors.inkMuted,
            fontFamily: 'Segoe UI',
          ),
        ),
        const SizedBox(height: 16),

        // 1. Anillo de Equidad entre Miembros
        CasviumBentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EQUIDAD Y REPARTO ENTRE MIEMBROS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Distribución de minutos reales trabajados (incluye bonificación por tareas compartidas)',
                style: TextStyle(
                  fontSize: 12.5,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 16),
              MemberEquityRingChart(
                members: store.members,
                sessions: store.sessions,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Curva Semanal de Pulso Doméstico
        CasviumBentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PULSO SEMANAL DE ENERGÍA DOMÉSTICA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Minutos diarios registrados en los últimos 7 días',
                style: TextStyle(
                  fontSize: 12.5,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 14),
              WeeklyPulseWaveChart(sessions: store.sessions),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Esfuerzo por Estancia
        CasviumBentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MAPA DE DEDICACIÓN POR ESTANCIA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 14),
              RoomEffortInfographic(
                rooms: store.rooms,
                tasks: store.tasks,
                sessions: store.sessions,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 5: CONFIGURACIÓN DE HOGAR, MIEMBROS Y POSTGRESQL EN RAILWAY
  // =========================================================================
  Widget _buildHouseholdAndRailwayTab(BuildContext context) {
    final store = widget.store;
    final urlController =
        TextEditingController(text: store.railwayDatabaseUrl);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        Text(
          'Hogar y Base de Datos Railway',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text(
          'Configura tu conexión directa a PostgreSQL en Railway o crea un nuevo hogar compartido.',
          style: TextStyle(
            fontSize: 13,
            color: CasviumColors.inkMuted,
            fontFamily: 'Segoe UI',
          ),
        ),
        const SizedBox(height: 16),

        // Tarjeta de conexión PostgreSQL Railway
        CasviumBentoCard(
          backgroundColor: const Color(0xFFEEE8F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CasviumColors.plum,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: CasviumColors.ink, width: 1.5),
                    ),
                    child: const Text(
                      'POSTGRESQL · RAILWAY CLOUD',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    store.isConnectedToRailway
                        ? Icons.cloud_done
                        : Icons.cloud_queue,
                    color: CasviumColors.ink,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                store.lastSyncMessage,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CasviumColors.ink,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText:
                      'postgresql://postgres:PASS@tramway.proxy.rlwy.net:39687/railway',
                  filled: true,
                  fillColor: CasviumColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: CasviumColors.ink, width: 1.8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: CasviumColors.ink, width: 1.8),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontFamily: 'Consolas',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CasviumActionPill(
                      label: store.isSyncing
                          ? 'Sincronizando...'
                          : 'Crear Tablas y Sincronizar con Railway',
                      icon: Icons.sync,
                      color: CasviumColors.plum,
                      textColor: Colors.white,
                      onPressed: () {
                        store.syncWithRailwayPostgres(urlController.text);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Crear un nuevo hogar desde cero
        CasviumBentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GESTIÓN DEL HOGAR ACTUAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hogar: ${store.currentHousehold.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Código de invitación: ${store.currentHousehold.inviteCode} · Mascota: ${store.currentHousehold.mascotName}',
                style: const TextStyle(
                  fontSize: 13,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  CasviumActionPill(
                    label: 'Crear Nuevo Hogar',
                    icon: Icons.home_work_outlined,
                    color: CasviumColors.terracotta,
                    onPressed: () => _openCreateHouseholdDialog(context),
                  ),
                  CasviumActionPill(
                    label: 'Añadir Miembro',
                    icon: Icons.person_add_alt_1,
                    color: CasviumColors.sage,
                    onPressed: () => _openAddMemberDialog(context),
                  ),
                  CasviumActionPill(
                    label: 'Añadir Estancia',
                    icon: Icons.meeting_room_outlined,
                    color: CasviumColors.cobalt,
                    onPressed: () => _openAddRoomDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // MODALES PERSONALIZADOS: CREAR TAREA, REGISTRAR SESIÓN, HOGAR, MIEMBRO, ESTANCIA
  // =========================================================================

  void _openCreateTaskSheet(
    BuildContext context, {
    String preselectedIconKey = 'mop_bucket',
    String suggestedTitle = '',
  }) {
    final store = widget.store;
    final titleCtrl = TextEditingController(text: suggestedTitle);
    final descCtrl = TextEditingController();
    String selectedIcon = preselectedIconKey;
    int estimatedMins = 20;
    bool isShared = true;
    String frequency = 'Semanal';
    final Set<String> selectedRooms = {
      if (store.rooms.isNotEmpty) store.rooms.first.id,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: CasviumColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: CasviumColors.ink, width: 2.5),
                ),
              ),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nueva Tarea Doméstica',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: _inputDecoration('Nombre de la tarea (ej. Limpiar horno)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    decoration:
                        _inputDecoration('Descripción o truco de limpieza (opcional)'),
                  ),
                  const SizedBox(height: 14),

                  // Selector de una o varias estancias
                  const Text(
                    'ESTANCIAS ASOCIADAS (PUEDES ELEGIR UNA O VARIAS)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                      color: CasviumColors.inkMuted,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: store.rooms.map((room) {
                      final active = selectedRooms.contains(room.id);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (active && selectedRooms.length > 1) {
                              selectedRooms.remove(room.id);
                            } else {
                              selectedRooms.add(room.id);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? room.color : CasviumColors.surface,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: CasviumColors.ink, width: 1.6),
                          ),
                          child: Text(
                            '${active ? "✓ " : ""}${room.name}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: active ? Colors.white : CasviumColors.ink,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Selector personalizado de duración estimada
                  DurationCustomSelector(
                    minutes: estimatedMins,
                    onChanged: (v) => setModalState(() => estimatedMins = v),
                  ),
                  const SizedBox(height: 14),

                  // Toggle de tarea compartida
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Tarea compartida entre miembros del hogar',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    subtitle: const Text(
                      'Permite rotarla o realizarla en pareja sumando puntos a ambos',
                      style: TextStyle(fontSize: 12, fontFamily: 'Segoe UI'),
                    ),
                    activeColor: CasviumColors.sage,
                    value: isShared,
                    onChanged: (v) => setModalState(() => isShared = v),
                  ),
                  const SizedBox(height: 10),

                  // Selector de los 30 iconos
                  const Text(
                    'ELIGE UN ICONO (30 ICONOS DISPONIBLES)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                      color: CasviumColors.inkMuted,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ChoreIconsCatalog.all.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final iconDef = ChoreIconsCatalog.all[index];
                      final isChosen = iconDef.key == selectedIcon;
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedIcon = iconDef.key),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isChosen
                                ? CasviumColors.mustard.withOpacity(0.45)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isChosen
                                ? Border.all(
                                    color: CasviumColors.ink, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ChoreCustomIcon(
                                iconKey: iconDef.key,
                                size: 38,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                iconDef.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Segoe UI',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  CasviumActionPill(
                    label: 'Guardar Tarea en el Hogar',
                    icon: Icons.check,
                    color: CasviumColors.terracotta,
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      store.addChoreTask(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        iconKey: selectedIcon,
                        roomIds: selectedRooms.toList(),
                        estimatedMinutes: estimatedMins,
                        isShared: isShared,
                        frequencyLabel: frequency,
                        intensity: 2,
                      );
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openLogSessionSheet(
    BuildContext context, {
    ChoreTask? initialTask,
    int? initialMinutes,
  }) {
    final store = widget.store;
    if (store.tasks.isEmpty || store.members.isEmpty) return;

    ChoreTask selectedTask = initialTask ?? store.tasks.first;
    String selectedMemberId = store.members.first.id;
    String loggedByUser = store.activeLoggedUser;
    String? selectedRoomId = selectedTask.roomIds.isNotEmpty
        ? selectedTask.roomIds.first
        : (store.rooms.isNotEmpty ? store.rooms.first.id : null);
    int durationMinutes = initialMinutes ?? selectedTask.estimatedMinutes;
    DateTime sessionDate = DateTime.now();
    final Set<String> coWorkerIds = {};
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: CasviumColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: CasviumColors.ink, width: 2.5),
                ),
              ),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Registrar Sesión de Trabajo',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 1. Tarea realizada
                  const Text(
                    'TAREA REALIZADA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: CasviumColors.inkMuted,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedTask.id,
                    decoration: _inputDecoration('Tarea'),
                    items: store.tasks
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(
                              '${t.title} (${t.estimatedMinutes}m est.)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      final found = store.taskById(val);
                      if (found != null) {
                        setModalState(() {
                          selectedTask = found;
                          durationMinutes = found.estimatedMinutes;
                          if (found.roomIds.isNotEmpty) {
                            selectedRoomId = found.roomIds.first;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // 2. Miembro ejecutor y Usuario que registra
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MIEMBRO EJECUTOR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: CasviumColors.inkMuted,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedMemberId,
                              decoration: _inputDecoration('Miembro'),
                              items: store.members
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m.id,
                                      child: Text(m.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() => selectedMemberId = v);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REGISTRADO POR (USUARIO)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: CasviumColors.inkMuted,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: loggedByUser,
                              decoration: _inputDecoration('Usuario'),
                              items: store.members
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m.name,
                                      child: Text(m.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() => loggedByUser = v);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Estancia y Fecha
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ESTANCIA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: CasviumColors.inkMuted,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedRoomId,
                              decoration: _inputDecoration('Estancia'),
                              items: store.rooms
                                  .map(
                                    (r) => DropdownMenuItem(
                                      value: r.id,
                                      child: Text(r.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setModalState(() => selectedRoomId = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FECHA DE SESIÓN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: CasviumColors.inkMuted,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                            const SizedBox(height: 6),
                            CasviumActionPill(
                              label: DateFormat('dd/MM/yyyy')
                                  .format(sessionDate),
                              icon: Icons.calendar_today,
                              color: CasviumColors.surface,
                              textColor: CasviumColors.ink,
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: sessionDate,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setModalState(() => sessionDate = picked);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Duración real de la sesión
                  DurationCustomSelector(
                    minutes: durationMinutes,
                    onChanged: (v) => setModalState(() => durationMinutes = v),
                  ),
                  const SizedBox(height: 14),

                  // 5. Notas
                  TextField(
                    controller: notesCtrl,
                    decoration: _inputDecoration(
                        'Notas de la sesión (ej. Quedó impecable, faltan bolsas...)'),
                  ),
                  const SizedBox(height: 18),
                  CasviumActionPill(
                    label: 'Guardar Sesión de Trabajo',
                    icon: Icons.verified_outlined,
                    color: CasviumColors.sage,
                    onPressed: () {
                      store.logWorkSession(
                        taskId: selectedTask.id,
                        memberId: selectedMemberId,
                        loggedByUser: loggedByUser,
                        roomId: selectedRoomId,
                        performedAt: sessionDate,
                        durationMinutes: durationMinutes,
                        coWorkerIds: coWorkerIds.toList(),
                        notes: notesCtrl.text.trim(),
                      );
                      setState(() {
                        _mascotMood = MascotMood.celebrating;
                        _mascotMessage =
                            '¡Sesión registrada por $loggedByUser! "${selectedTask.title}" (${durationMinutes}m) completada 🎉';
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Miembro');
    Color chosenColor = CasviumColors.terracotta;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: CasviumColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: CasviumColors.ink, width: 2),
          ),
          title: const Text('Añadir Miembro al Hogar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: _inputDecoration('Nombre (ej. Sofía)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roleCtrl,
                decoration: _inputDecoration('Rol o especialidad (ej. Repostería & Orden)'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: CasviumColors.memberPalette.map((c) {
                  final sel = c.value == chosenColor.value;
                  return GestureDetector(
                    onTap: () => setDState(() => chosenColor = c),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CasviumColors.ink,
                          width: sel ? 3 : 1.2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            CasviumActionPill(
              label: 'Añadir',
              compact: true,
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                widget.store.addMember(
                  name: nameCtrl.text.trim(),
                  role: roleCtrl.text.trim(),
                  colorHex: CasviumColors.toHex(chosenColor),
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openAddRoomDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedIcon = 'broom_dustpan';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: CasviumColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: CasviumColors.ink, width: 2),
          ),
          title: const Text('Nueva Estancia del Hogar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: _inputDecoration('Nombre (ej. Estudio, Ático, Garaje)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedIcon,
                decoration: _inputDecoration('Icono de la estancia'),
                items: ChoreIconsCatalog.all
                    .map(
                      (i) => DropdownMenuItem(
                        value: i.key,
                        child: Text(i.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDState(() => selectedIcon = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            CasviumActionPill(
              label: 'Crear Estancia',
              compact: true,
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                widget.store.addRoom(
                  name: nameCtrl.text.trim(),
                  iconKey: selectedIcon,
                  colorHex: '#4A7C59',
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateHouseholdDialog(BuildContext context) {
    final homeNameCtrl = TextEditingController();
    final mascotCtrl = TextEditingController(text: 'Don Mocho');
    final membersCtrl = TextEditingController(text: 'Ana, Carlos, Elena');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CasviumColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: CasviumColors.ink, width: 2),
        ),
        title: const Text('Crear Nuevo Hogar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: homeNameCtrl,
              decoration: _inputDecoration('Nombre del hogar (ej. Piso Centro)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mascotCtrl,
              decoration: _inputDecoration('Nombre de la mascota fregona'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: membersCtrl,
              decoration:
                  _inputDecoration('Miembros iniciales (separados por coma)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          CasviumActionPill(
            label: 'Crear Hogar',
            compact: true,
            onPressed: () {
              if (homeNameCtrl.text.trim().isEmpty) return;
              final list = membersCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              widget.store.createNewHousehold(
                name: homeNameCtrl.text.trim(),
                mascotName: mascotCtrl.text.trim().isEmpty
                    ? 'Don Mocho'
                    : mascotCtrl.text.trim(),
                initialMemberNames: list.isEmpty ? ['Anfitrión'] : list,
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: CasviumColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CasviumColors.ink, width: 1.6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CasviumColors.ink, width: 1.6),
      ),
    );
  }
}
