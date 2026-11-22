WITH home AS (
  SELECT id, name, invite_code, mascot_name, created_at
  FROM households
  WHERE id::text <> 'home-villa-olivo'
  ORDER BY (id::text = $1::text) DESC, created_at DESC, id
  LIMIT 1
)
SELECT jsonb_build_object(
  'household', jsonb_build_object(
    'id', h.id, 'name', h.name, 'inviteCode', h.invite_code,
    'mascotName', h.mascot_name, 'createdAt', h.created_at
  ),
  'members', COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', m.id, 'householdId', m.household_id, 'name', m.name,
      'role', m.role, 'avatarColorHex', m.avatar_color, 'streakDays', m.streak_days
    ) ORDER BY m.name, m.id)
    FROM household_members m WHERE m.household_id = h.id
  ), '[]'::jsonb),
  'rooms', COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', r.id, 'householdId', r.household_id, 'name', r.name,
      'iconKey', r.icon_key, 'colorHex', r.color_hex, 'isDefault', r.is_default
    ) ORDER BY r.name, r.id)
    FROM rooms r WHERE r.household_id = h.id
  ), '[]'::jsonb),
  'tasks', COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', t.id, 'householdId', t.household_id, 'title', t.title,
      'description', t.description, 'iconKey', t.icon_key,
      'estimatedMinutes', t.estimated_minutes, 'isShared', t.is_shared,
      'frequencyLabel', t.frequency_label, 'createdAt', t.created_at,
      'intensity', COALESCE((to_jsonb(t)->>'intensity')::int, 2),
      'roomIds', COALESCE((
        SELECT jsonb_agg(tr.room_id ORDER BY tr.room_id)
        FROM task_rooms tr WHERE tr.task_id = t.id
      ), '[]'::jsonb)
    ) ORDER BY t.created_at DESC, t.id)
    FROM chore_tasks t WHERE t.household_id = h.id
  ), '[]'::jsonb),
  'sessions', COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', s.id, 'householdId', s.household_id, 'taskId', s.task_id,
      'memberId', s.member_id, 'loggedByUser', s.logged_by_user, 'roomId', s.room_id,
      'performedAt', s.performed_at, 'durationMinutes', s.duration_minutes,
      'coWorkerIds', COALESCE((to_jsonb(s)->>'co_workers')::jsonb, '[]'::jsonb),
      'energyLevel', s.energy_level, 'notes', s.notes
    ) ORDER BY s.performed_at DESC, s.id)
    FROM work_sessions s WHERE s.household_id = h.id
  ), '[]'::jsonb),
  'households', jsonb_build_array(jsonb_build_object(
    'id', h.id, 'name', h.name, 'inviteCode', h.invite_code,
    'mascotName', h.mascot_name, 'createdAt', h.created_at
  )),
  'activeLoggedUser', COALESCE((
    SELECT m.name FROM household_members m WHERE m.household_id = h.id
    ORDER BY m.name, m.id LIMIT 1
  ), '')
) AS snapshot
FROM home h;
