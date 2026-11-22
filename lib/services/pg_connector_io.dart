import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:postgres/postgres.dart';

import 'local_household_storage.dart';

const configuredRailwayDatabaseUrl = String.fromEnvironment(
  'DATABASE_PUBLIC_URL',
  defaultValue: String.fromEnvironment('DATABASE_URL'),
);

Future<Connection> _openDatabase(String connectionUrl) {
  final uri = Uri.parse(connectionUrl);
  if (!const ['postgres', 'postgresql'].contains(uri.scheme) ||
      uri.host.isEmpty) {
    throw const FormatException('URL PostgreSQL no válida.');
  }

  final userInfo = uri.userInfo.split(':');
  return Connection.open(
    Endpoint(
      host: uri.host,
      port: uri.hasPort ? uri.port : 5432,
      database: uri.pathSegments.isEmpty ? 'railway' : uri.pathSegments.first,
      username: Uri.decodeComponent(userInfo.first),
      password: Uri.decodeComponent(userInfo.skip(1).join(':')),
    ),
    settings: const ConnectionSettings(
      sslMode: SslMode.require,
      connectTimeout: Duration(seconds: 10),
      queryTimeout: Duration(seconds: 10),
    ),
  );
}

Future<HouseholdSnapshot?> loadRailwayHousehold(
  String connectionUrl,
  String householdId,
) async {
  final query = await rootBundle.loadString('sql/household_snapshot.sql');
  final conn = await _openDatabase(connectionUrl);
  try {
    final rows = await conn.execute(
      Sql(query, types: [Type.text]),
      parameters: [householdId],
    );
    return rows.isEmpty
        ? null
        : HouseholdSnapshot.decode(jsonEncode(rows.single.first));
  } on ServerException catch (e) {
    if (e.code == '42P01') return null; // Base de datos sin inicializar.
    rethrow;
  } finally {
    await conn.close();
  }
}

Future<void> saveRailwayHousehold(
  String connectionUrl,
  HouseholdSnapshot snapshot,
) async {
  final schema = await rootBundle.loadString('sql/railway_compatibility.sql');
  final conn = await _openDatabase(connectionUrl);
  final household = snapshot.household;
  try {
    await conn.runTx((tx) async {
      for (final statement in schema.split(';')) {
        if (statement.trim().isNotEmpty) await tx.execute(statement);
      }

      await tx.execute(
        Sql.named('''
          INSERT INTO households (id, name, invite_code, mascot_name, created_at)
          VALUES (@id, @name, @code, @mascot, @created)
          ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            mascot_name = EXCLUDED.mascot_name;
        '''),
        parameters: {
          'id': household.id,
          'name': household.name,
          'code': household.inviteCode,
          'mascot': household.mascotName,
          'created': household.createdAt.toUtc(),
        },
      );

      for (final m in snapshot.members) {
        await tx.execute(
          Sql.named('''
            INSERT INTO household_members (id, household_id, name, role, avatar_color, streak_days)
            VALUES (@id, @hid, @name, @role, @color, @streak)
            ON CONFLICT (id) DO UPDATE SET
              name = EXCLUDED.name,
              role = EXCLUDED.role,
              avatar_color = EXCLUDED.avatar_color,
              streak_days = EXCLUDED.streak_days;
          '''),
          parameters: {
            'id': m.id,
            'hid': m.householdId,
            'name': m.name,
            'role': m.role,
            'color': m.avatarColorHex,
            'streak': m.streakDays,
          },
        );
      }

      for (final r in snapshot.rooms) {
        await tx.execute(
          Sql.named('''
            INSERT INTO rooms (id, household_id, name, icon_key, color_hex, is_default)
            VALUES (@id, @hid, @name, @icon, @color, @def)
            ON CONFLICT (id) DO UPDATE SET
              name = EXCLUDED.name,
              icon_key = EXCLUDED.icon_key,
              color_hex = EXCLUDED.color_hex,
              is_default = EXCLUDED.is_default;
          '''),
          parameters: {
            'id': r.id,
            'hid': r.householdId,
            'name': r.name,
            'icon': r.iconKey,
            'color': r.colorHex,
            'def': r.isDefault,
          },
        );
      }

      for (final t in snapshot.tasks) {
        await tx.execute(
          Sql.named('''
            INSERT INTO chore_tasks (id, household_id, title, description, icon_key, estimated_minutes, is_shared, frequency_label, created_at, intensity)
            VALUES (@id, @hid, @title, @desc, @icon, @mins, @shared, @freq, @created, @intensity)
            ON CONFLICT (id) DO UPDATE SET
              title = EXCLUDED.title,
              description = EXCLUDED.description,
              icon_key = EXCLUDED.icon_key,
              estimated_minutes = EXCLUDED.estimated_minutes,
              is_shared = EXCLUDED.is_shared,
              frequency_label = EXCLUDED.frequency_label,
              intensity = EXCLUDED.intensity;
          '''),
          parameters: {
            'id': t.id,
            'hid': t.householdId,
            'title': t.title,
            'desc': t.description,
            'icon': t.iconKey,
            'mins': t.estimatedMinutes,
            'shared': t.isShared,
            'freq': t.frequency.storageLabel,
            'intensity': t.intensity,
            'created': t.createdAt.toUtc(),
          },
        );

        for (final rId in t.roomIds) {
          await tx.execute(
            Sql.named('''
              INSERT INTO task_rooms (task_id, room_id)
              VALUES (@tid, @rid)
              ON CONFLICT DO NOTHING;
            '''),
            parameters: {'tid': t.id, 'rid': rId},
          );
        }
      }

      for (final s in snapshot.sessions) {
        await tx.execute(
          Sql.named('''
            INSERT INTO work_sessions (id, household_id, task_id, member_id, logged_by_user, room_id, performed_at, duration_minutes, co_workers, energy_level, notes)
            VALUES (@id, @hid, @tid, @mid, @user, @rid, @at, @mins, @coworkers, @energy, @notes)
            ON CONFLICT (id) DO NOTHING;
          '''),
          parameters: {
            'id': s.id,
            'hid': s.householdId,
            'tid': s.taskId,
            'mid': s.memberId,
            'user': s.loggedByUser,
            'rid': s.roomId,
            'at': s.performedAt.toUtc(),
            'mins': s.durationMinutes,
            'coworkers': s.coWorkerIds,
            'energy': s.energyLevel,
            'notes': s.notes,
          },
        );
      }
    });
  } finally {
    await conn.close();
  }
}
