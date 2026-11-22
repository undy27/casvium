CREATE TABLE IF NOT EXISTS households (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  invite_code TEXT NOT NULL,
  mascot_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS household_members (
  id TEXT PRIMARY KEY,
  household_id TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  avatar_color TEXT NOT NULL,
  streak_days INT NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS rooms (
  id TEXT PRIMARY KEY,
  household_id TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon_key TEXT NOT NULL,
  color_hex TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS chore_tasks (
  id TEXT PRIMARY KEY,
  household_id TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_key TEXT NOT NULL,
  estimated_minutes INT NOT NULL,
  is_shared BOOLEAN NOT NULL DEFAULT TRUE,
  frequency_label TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE chore_tasks
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE TABLE IF NOT EXISTS task_rooms (
  task_id TEXT NOT NULL REFERENCES chore_tasks(id) ON DELETE CASCADE,
  room_id TEXT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  PRIMARY KEY (task_id, room_id)
);

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
ALTER TABLE chore_tasks
  ADD COLUMN IF NOT EXISTS intensity INT NOT NULL DEFAULT 2;
ALTER TABLE work_sessions
  ADD COLUMN IF NOT EXISTS co_workers TEXT[] NOT NULL DEFAULT '{}';
