const http = require('http');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const PORT = process.env.PORT || 8080;
const WEB_ROOT = path.join(__dirname, 'web_build');

const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    })
  : null;

async function ensureSchema() {
  if (!pool) return;
  const client = await pool.connect();
  try {
    await client.query(`
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
        frequency_label TEXT NOT NULL
      );
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
    `);
    console.log('Railway PostgreSQL schema ready.');
  } catch (err) {
    console.error('Schema init warning:', err.message);
  } finally {
    client.release();
  }
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

const server = http.createServer(async (req, res) => {
  if (req.url === '/api/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, postgresConfigured: Boolean(pool) }));
    return;
  }

  if (req.url === '/api/sync' && req.method === 'POST') {
    let body = '';
    req.on('data', (chunk) => (body += chunk));
    req.on('end', async () => {
      if (!pool) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: false, error: 'DATABASE_URL not set' }));
        return;
      }
      const client = await pool.connect();
      try {
        await ensureSchema();
        const data = JSON.parse(body || '{}');
        const h = data.household;
        if (h) {
          await client.query(
            `INSERT INTO households (id, name, invite_code, mascot_name, created_at)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, mascot_name = EXCLUDED.mascot_name`,
            [h.id, h.name, h.inviteCode, h.mascotName, h.createdAt]
          );
        }
        for (const m of data.members || []) {
          await client.query(
            `INSERT INTO household_members (id, household_id, name, role, avatar_color, streak_days)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, role = EXCLUDED.role, avatar_color = EXCLUDED.avatar_color`,
            [m.id, m.householdId, m.name, m.role, m.avatarColorHex, m.streakDays]
          );
        }
        for (const r of data.rooms || []) {
          await client.query(
            `INSERT INTO rooms (id, household_id, name, icon_key, color_hex, is_default)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, icon_key = EXCLUDED.icon_key, color_hex = EXCLUDED.color_hex`,
            [r.id, r.householdId, r.name, r.iconKey, r.colorHex, r.isDefault]
          );
        }
        for (const t of data.tasks || []) {
          await client.query(
            `INSERT INTO chore_tasks (id, household_id, title, description, icon_key, estimated_minutes, is_shared, frequency_label)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
             ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, estimated_minutes = EXCLUDED.estimated_minutes, is_shared = EXCLUDED.is_shared`,
            [t.id, t.householdId, t.title, t.description, t.iconKey, t.estimatedMinutes, t.isShared, t.frequencyLabel]
          );
          for (const rId of t.roomIds || []) {
            await client.query(
              `INSERT INTO task_rooms (task_id, room_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
              [t.id, rId]
            );
          }
        }
        for (const s of data.sessions || []) {
          await client.query(
            `INSERT INTO work_sessions (id, household_id, task_id, member_id, logged_by_user, room_id, performed_at, duration_minutes, energy_level, notes)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
             ON CONFLICT (id) DO NOTHING`,
            [s.id, s.householdId, s.taskId, s.memberId, s.loggedByUser, s.roomId, s.performedAt, s.durationMinutes, s.energyLevel, s.notes]
          );
        }
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: true }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: false, error: err.message }));
      } finally {
        client.release();
      }
    });
    return;
  }

  const safePath = path.normalize(req.url.split('?')[0]).replace(/^(\.\.[\/\\])+/, '');
  let filePath = path.join(WEB_ROOT, safePath === '/' ? 'index.html' : safePath);
  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    filePath = path.join(WEB_ROOT, 'index.html');
  }
  const ext = path.extname(filePath).toLowerCase();
  res.writeHead(200, { 'Content-Type': MIME_TYPES[ext] || 'application/octet-stream' });
  fs.createReadStream(filePath).pipe(res);
});

ensureSchema().then(() => {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`Casvium Web + Railway Postgres gateway listening on port ${PORT}`);
  });
});
