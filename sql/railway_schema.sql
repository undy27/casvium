-- ============================================================================
-- CASVIUM - Esquema PostgreSQL para Railway (Hogar, Miembros, Estancias, Tareas y Sesiones)
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Hogares
CREATE TABLE IF NOT EXISTS households (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    invite_code VARCHAR(16) UNIQUE NOT NULL,
    mascot_name VARCHAR(60) NOT NULL DEFAULT 'Mocho',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Miembros del hogar
CREATE TABLE IF NOT EXISTS household_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    name VARCHAR(80) NOT NULL,
    role VARCHAR(40) NOT NULL DEFAULT 'Miembro',
    avatar_color VARCHAR(9) NOT NULL DEFAULT '#E06D53',
    streak_days INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Estancias (por defecto: cocina, baño, salón, etc., más las creadas por el usuario)
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    name VARCHAR(80) NOT NULL,
    icon_key VARCHAR(40) NOT NULL DEFAULT 'mop_bucket',
    color_hex VARCHAR(9) NOT NULL DEFAULT '#4A7C59',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Tareas domésticas (pueden ser compartidas y tienen icono + duración estimada)
CREATE TABLE IF NOT EXISTS chore_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    title VARCHAR(140) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    icon_key VARCHAR(40) NOT NULL,
    estimated_minutes INT NOT NULL CHECK (estimated_minutes > 0),
    is_shared BOOLEAN NOT NULL DEFAULT TRUE,
    frequency_label VARCHAR(40) NOT NULL DEFAULT 'Semanal',
    intensity INT NOT NULL DEFAULT 2 CHECK (intensity BETWEEN 1 AND 3),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Relación N:M entre Tareas y Estancias (una tarea puede asociarse a una o varias estancias)
CREATE TABLE IF NOT EXISTS task_rooms (
    task_id UUID NOT NULL REFERENCES chore_tasks(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, room_id)
);

-- 6. Registro de sesiones de trabajo realizadas
CREATE TABLE IF NOT EXISTS work_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    task_id UUID NOT NULL REFERENCES chore_tasks(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES household_members(id) ON DELETE CASCADE,
    logged_by_user VARCHAR(80) NOT NULL,
    room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    co_workers TEXT[] DEFAULT '{}',
    energy_level INT NOT NULL DEFAULT 3 CHECK (energy_level BETWEEN 1 AND 5),
    notes TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_work_sessions_household_date
    ON work_sessions(household_id, performed_at DESC);
