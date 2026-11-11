import 'package:postgres/postgres.dart';
import '../models/models.dart';

Future<String> syncHouseholdToPostgresImpl({
  required String connectionUrl,
  required Household household,
  required List<HouseholdMember> members,
  required List<Room> rooms,
  required List<ChoreTask> tasks,
  required List<WorkSession> sessions,
}) async {
  Connection? conn;
  try {
    final uri = Uri.parse(connectionUrl);
    final userInfo = uri.userInfo.split(':');
    final username = userInfo.isNotEmpty ? userInfo.first : 'postgres';
    final password = userInfo.length > 1 ? userInfo.sublist(1).join(':') : '';
    final databaseName =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'railway';

    conn = await Connection.open(
      Endpoint(
        host: uri.host,
        port: uri.port > 0 ? uri.port : 5432,
        database: databaseName,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS households (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        invite_code TEXT NOT NULL,
        mascot_name TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS household_members (
        id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        avatar_color TEXT NOT NULL,
        streak_days INT NOT NULL DEFAULT 1
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS rooms (
        id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        is_default BOOLEAN NOT NULL DEFAULT FALSE
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS chore_tasks (
        id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        estimated_minutes INT NOT NULL,
        is_shared BOOLEAN NOT NULL DEFAULT TRUE,
        frequency_label TEXT NOT NULL
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS task_rooms (
        task_id TEXT NOT NULL REFERENCES chore_tasks(id) ON DELETE CASCADE,
        room_id TEXT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
        PRIMARY KEY (task_id, room_id)
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS work_sessions (
        id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
        task_id TEXT NOT NULL REFERENCES chore_tasks(id) ON DELETE CASCADE,
        member_id TEXT NOT NULL REFERENCES household_members(id) ON DELETE CASCADE,
        logged_by_user TEXT NOT NULL,
        room_id TEXT,
        performed_at TIMESTAMPTZ NOT NULL,
        duration_minutes INT NOT NULL,
        energy_level INT NOT NULL,
        notes TEXT NOT NULL
      );
    ''');

    await conn.execute(
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

    for (final m in members) {
      await conn.execute(
        Sql.named('''
          INSERT INTO household_members (id, household_id, name, role, avatar_color, streak_days)
          VALUES (@id, @hid, @name, @role, @color, @streak)
          ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            role = EXCLUDED.role,
            avatar_color = EXCLUDED.avatar_color;
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

    for (final r in rooms) {
      await conn.execute(
        Sql.named('''
          INSERT INTO rooms (id, household_id, name, icon_key, color_hex, is_default)
          VALUES (@id, @hid, @name, @icon, @color, @def)
          ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            icon_key = EXCLUDED.icon_key,
            color_hex = EXCLUDED.color_hex;
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

    for (final t in tasks) {
      await conn.execute(
        Sql.named('''
          INSERT INTO chore_tasks (id, household_id, title, description, icon_key, estimated_minutes, is_shared, frequency_label)
          VALUES (@id, @hid, @title, @desc, @icon, @mins, @shared, @freq)
          ON CONFLICT (id) DO UPDATE SET
            title = EXCLUDED.title,
            estimated_minutes = EXCLUDED.estimated_minutes,
            is_shared = EXCLUDED.is_shared;
        '''),
        parameters: {
          'id': t.id,
          'hid': t.householdId,
          'title': t.title,
          'desc': t.description,
          'icon': t.iconKey,
          'mins': t.estimatedMinutes,
          'shared': t.isShared,
          'freq': t.frequencyLabel,
        },
      );

      for (final rId in t.roomIds) {
        await conn.execute(
          Sql.named('''
            INSERT INTO task_rooms (task_id, room_id)
            VALUES (@tid, @rid)
            ON CONFLICT DO NOTHING;
          '''),
          parameters: {'tid': t.id, 'rid': rId},
        );
      }
    }

    for (final s in sessions) {
      await conn.execute(
        Sql.named('''
          INSERT INTO work_sessions (id, household_id, task_id, member_id, logged_by_user, room_id, performed_at, duration_minutes, energy_level, notes)
          VALUES (@id, @hid, @tid, @mid, @user, @rid, @at, @mins, @energy, @notes)
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
          'energy': s.energyLevel,
          'notes': s.notes,
        },
      );
    }

    return 'Sincronizado con Railway Postgres (${members.length} miembros, ${rooms.length} estancias, ${tasks.length} tareas, ${sessions.length} sesiones)';
  } finally {
    await conn?.close();
  }
}
