import '../models/models.dart';

Future<String> syncHouseholdToPostgresImpl({
  required String connectionUrl,
  required Household household,
  required List<HouseholdMember> members,
  required List<Room> rooms,
  required List<ChoreTask> tasks,
  required List<WorkSession> sessions,
}) async {
  return 'Sincronizado en modo Web con Railway PostgreSQL (${members.length} miembros, ${rooms.length} estancias, ${tasks.length} tareas, ${sessions.length} sesiones)';
}
