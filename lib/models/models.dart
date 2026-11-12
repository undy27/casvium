import 'package:flutter/material.dart';
import '../theme/casvium_theme.dart';

class Household {
  final String id;
  final String name;
  final String inviteCode;
  final String mascotName;
  final DateTime createdAt;

  const Household({
    required this.id,
    required this.name,
    required this.inviteCode,
    this.mascotName = 'Don Mocho',
    required this.createdAt,
  });

  Household copyWith({
    String? name,
    String? inviteCode,
    String? mascotName,
  }) {
    return Household(
      id: id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      mascotName: mascotName ?? this.mascotName,
      createdAt: createdAt,
    );
  }
}

class HouseholdMember {
  final String id;
  final String householdId;
  final String name;
  final String role;
  final String avatarColorHex;
  final int streakDays;

  const HouseholdMember({
    required this.id,
    required this.householdId,
    required this.name,
    required this.role,
    required this.avatarColorHex,
    this.streakDays = 1,
  });

  Color get color => CasviumColors.fromHex(avatarColorHex);

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class Room {
  final String id;
  final String householdId;
  final String name;
  final String iconKey;
  final String colorHex;
  final bool isDefault;

  const Room({
    required this.id,
    required this.householdId,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    this.isDefault = false,
  });

  Color get color => CasviumColors.fromHex(colorHex);
}

enum TaskFrequency {
  none('Sin periodicidad'),
  daily('Diaria'),
  threeTimesWeekly('3 veces/sem', '3 veces por semana (lun., mié. y vie.)'),
  twiceWeekly('2 veces/sem', '2 veces por semana (lun. y jue.)'),
  weekly('Semanal'),
  fortnightly('Quincenal'),
  monthly('Mensual');

  const TaskFrequency(this.storageLabel, [String? label])
      : label = label ?? storageLabel;

  final String storageLabel;
  final String label;

  static TaskFrequency fromLabel(String label) {
    final normalized = label.trim().toLowerCase();
    return values.firstWhere(
      (frequency) => frequency.storageLabel.toLowerCase() == normalized,
      orElse: () => none,
    );
  }

  DateTime? nextAfter(DateTime reference) {
    final day = reference.toLocal();
    return switch (this) {
      none => null,
      daily => _addDays(day, 1),
      threeTimesWeekly => _nextWeekday(day, const {
          DateTime.monday,
          DateTime.wednesday,
          DateTime.friday,
        }),
      twiceWeekly => _nextWeekday(day, const {
          DateTime.monday,
          DateTime.thursday,
        }),
      weekly => _addDays(day, 7),
      fortnightly => _addDays(day, 14),
      monthly => _nextMonth(day),
    };
  }

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  static DateTime _nextWeekday(DateTime date, Set<int> weekdays) {
    var next = _addDays(date, 1);
    while (!weekdays.contains(next.weekday)) {
      next = _addDays(next, 1);
    }
    return next;
  }

  static DateTime _nextMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 2, 0).day;
    return DateTime(date.year, date.month + 1, date.day.clamp(1, lastDay));
  }
}

enum TaskDeadlineStatus { overdue, today, upcoming }

class TaskDeadline {
  final ChoreTask task;
  final DateTime date;
  final TaskDeadlineStatus status;

  const TaskDeadline({
    required this.task,
    required this.date,
    required this.status,
  });
}

class ChoreTask {
  final String id;
  final String householdId;
  final String title;
  final String description;
  final String iconKey;
  final List<String> roomIds; // Puede asociarse a una o varias estancias
  final int estimatedMinutes; // Duración estimada establecida por el usuario
  final bool isShared; // Tarea compartida entre miembros
  final TaskFrequency frequency;
  final DateTime createdAt;
  final int intensity; // 1 = Suave, 2 = Media, 3 = Intensa

  const ChoreTask({
    required this.id,
    required this.householdId,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.roomIds,
    required this.estimatedMinutes,
    this.isShared = true,
    this.frequency = TaskFrequency.weekly,
    required this.createdAt,
    this.intensity = 2,
  });

  ChoreTask copyWith({
    String? title,
    String? description,
    String? iconKey,
    List<String>? roomIds,
    int? estimatedMinutes,
    bool? isShared,
    TaskFrequency? frequency,
    int? intensity,
  }) {
    return ChoreTask(
      id: id,
      householdId: householdId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      roomIds: roomIds ?? this.roomIds,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isShared: isShared ?? this.isShared,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt,
      intensity: intensity ?? this.intensity,
    );
  }
}

class WorkSession {
  final String id;
  final String householdId;
  final String taskId;
  final String memberId; // Miembro ejecutor principal
  final String loggedByUser; // Usuario que registra la sesión
  final String? roomId; // Estancia concreta donde se realizó
  final DateTime performedAt; // Fecha y hora
  final int durationMinutes; // Duración real invertida
  final List<String> coWorkerIds; // Otros miembros si se hizo en equipo
  final int energyLevel; // 1..5 satisfacción/energía
  final String notes;

  const WorkSession({
    required this.id,
    required this.householdId,
    required this.taskId,
    required this.memberId,
    required this.loggedByUser,
    this.roomId,
    required this.performedAt,
    required this.durationMinutes,
    this.coWorkerIds = const [],
    this.energyLevel = 4,
    this.notes = '',
  });
}
