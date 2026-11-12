import 'dart:convert';

import '../models/models.dart';

class HouseholdSnapshot {
  final Household household;
  final List<Household> households;
  final List<HouseholdMember> members;
  final List<Room> rooms;
  final List<ChoreTask> tasks;
  final List<WorkSession> sessions;
  final String activeLoggedUser;

  const HouseholdSnapshot({
    required this.household,
    required this.households,
    required this.members,
    required this.rooms,
    required this.tasks,
    required this.sessions,
    required this.activeLoggedUser,
  });

  String encode() => jsonEncode({
        'household': _encodeHousehold(household),
        'households': households.map(_encodeHousehold).toList(),
        'members': members
            .map((member) => {
                  'id': member.id,
                  'householdId': member.householdId,
                  'name': member.name,
                  'role': member.role,
                  'avatarColorHex': member.avatarColorHex,
                  'streakDays': member.streakDays,
                })
            .toList(),
        'rooms': rooms
            .map((room) => {
                  'id': room.id,
                  'householdId': room.householdId,
                  'name': room.name,
                  'iconKey': room.iconKey,
                  'colorHex': room.colorHex,
                  'isDefault': room.isDefault,
                })
            .toList(),
        'tasks': tasks
            .map((task) => {
                  'id': task.id,
                  'householdId': task.householdId,
                  'title': task.title,
                  'description': task.description,
                  'iconKey': task.iconKey,
                  'roomIds': task.roomIds,
                  'estimatedMinutes': task.estimatedMinutes,
                  'isShared': task.isShared,
                  'frequencyLabel': task.frequency.storageLabel,
                  'createdAt': task.createdAt.toUtc().toIso8601String(),
                  'intensity': task.intensity,
                })
            .toList(),
        'sessions': sessions
            .map((session) => {
                  'id': session.id,
                  'householdId': session.householdId,
                  'taskId': session.taskId,
                  'memberId': session.memberId,
                  'loggedByUser': session.loggedByUser,
                  'roomId': session.roomId,
                  'performedAt': session.performedAt.toUtc().toIso8601String(),
                  'durationMinutes': session.durationMinutes,
                  'coWorkerIds': session.coWorkerIds,
                  'energyLevel': session.energyLevel,
                  'notes': session.notes,
                })
            .toList(),
        'activeLoggedUser': activeLoggedUser,
      });

  factory HouseholdSnapshot.decode(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return HouseholdSnapshot(
      household: _decodeHousehold(data['household'] as Map<String, dynamic>),
      households: _items(data, 'households').map(_decodeHousehold).toList(),
      members: _items(data, 'members')
          .map((member) => HouseholdMember(
                id: member['id'] as String,
                householdId: member['householdId'] as String,
                name: member['name'] as String,
                role: member['role'] as String,
                avatarColorHex: member['avatarColorHex'] as String,
                streakDays: member['streakDays'] as int,
              ))
          .toList(),
      rooms: _items(data, 'rooms')
          .map((room) => Room(
                id: room['id'] as String,
                householdId: room['householdId'] as String,
                name: room['name'] as String,
                iconKey: room['iconKey'] as String,
                colorHex: room['colorHex'] as String,
                isDefault: room['isDefault'] as bool,
              ))
          .toList(),
      tasks: _items(data, 'tasks')
          .map((task) => ChoreTask(
                id: task['id'] as String,
                householdId: task['householdId'] as String,
                title: task['title'] as String,
                description: task['description'] as String,
                iconKey: task['iconKey'] as String,
                roomIds: (task['roomIds'] as List).cast<String>(),
                estimatedMinutes: task['estimatedMinutes'] as int,
                isShared: task['isShared'] as bool,
                frequency: TaskFrequency.fromLabel(
                  task['frequencyLabel'] as String,
                ),
                createdAt:
                    DateTime.parse(task['createdAt'] as String).toLocal(),
                intensity: task['intensity'] as int,
              ))
          .toList(),
      sessions: _items(data, 'sessions')
          .map((session) => WorkSession(
                id: session['id'] as String,
                householdId: session['householdId'] as String,
                taskId: session['taskId'] as String,
                memberId: session['memberId'] as String,
                loggedByUser: session['loggedByUser'] as String,
                roomId: session['roomId'] as String?,
                performedAt:
                    DateTime.parse(session['performedAt'] as String).toLocal(),
                durationMinutes: session['durationMinutes'] as int,
                coWorkerIds: (session['coWorkerIds'] as List).cast<String>(),
                energyLevel: session['energyLevel'] as int,
                notes: session['notes'] as String,
              ))
          .toList(),
      activeLoggedUser: data['activeLoggedUser'] as String,
    );
  }

  static List<Map<String, dynamic>> _items(
    Map<String, dynamic> data,
    String key,
  ) =>
      (data[key] as List).cast<Map<String, dynamic>>();

  static Map<String, dynamic> _encodeHousehold(Household household) => {
        'id': household.id,
        'name': household.name,
        'inviteCode': household.inviteCode,
        'mascotName': household.mascotName,
        'createdAt': household.createdAt.toUtc().toIso8601String(),
      };

  static Household _decodeHousehold(Map<String, dynamic> household) =>
      Household(
        id: household['id'] as String,
        name: household['name'] as String,
        inviteCode: household['inviteCode'] as String,
        mascotName: household['mascotName'] as String,
        createdAt: DateTime.parse(household['createdAt'] as String).toLocal(),
      );
}
