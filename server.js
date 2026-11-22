const http = require('http');
const { createHash, timingSafeEqual } = require('crypto');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const PORT = process.env.PORT || 8080;
const WEB_ROOT = path.join(__dirname, 'web_build');

const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
      connectionTimeoutMillis: 10000,
      statement_timeout: 10000,
    })
  : null;

const schema = fs.readFileSync(path.join(__dirname, 'sql', 'railway_compatibility.sql'), 'utf8');
const householdQuery = fs.readFileSync(path.join(__dirname, 'sql', 'household_snapshot.sql'), 'utf8');
const accessKey = process.env.CASVIUM_DATA_ACCESS_KEY?.trim();
const hash = (value) => createHash('sha256').update(value).digest();
const expectedAuthorization = accessKey && hash(`Bearer ${accessKey}`);

function sendJson(res, status, body) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
  });
  res.end(JSON.stringify(body));
}

function authorizeDataAccess(req, res) {
  if (!pool || !expectedAuthorization) {
    sendJson(res, 503, { ok: false });
    return false;
  }
  if (!timingSafeEqual(hash(req.headers.authorization || ''), expectedAuthorization)) {
    sendJson(res, 401, { ok: false });
    return false;
  }
  return true;
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

  const url = new URL(req.url, 'http://localhost');
  if (url.pathname === '/api/household' && req.method === 'GET') {
    if (!authorizeDataAccess(req, res)) return;
    try {
      const { rows } = await pool.query(householdQuery, [url.searchParams.get('id') || '']);
      sendJson(res, 200, { ok: true, snapshot: rows[0]?.snapshot ?? null });
    } catch (error) {
      if (error.code === '42P01') {
        sendJson(res, 200, { ok: true, snapshot: null });
      } else {
        console.error('Railway household load failed:', error.message);
        sendJson(res, 500, { ok: false });
      }
    }
    return;
  }

  if (url.pathname === '/api/sync' && req.method === 'POST') {
    if (!authorizeDataAccess(req, res)) return;
    let client;
    try {
      const chunks = [];
      let size = 0;
      for await (const chunk of req) {
        size += chunk.length;
        if (size > 10 * 1024 * 1024) {
          sendJson(res, 413, { ok: false });
          return;
        }
        chunks.push(chunk);
      }
      let data;
      try {
        data = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      } catch {
        sendJson(res, 400, { ok: false });
        return;
      }
      if (!data?.household?.id || data.household.id === 'home-villa-olivo') {
        sendJson(res, 400, { ok: false });
        return;
      }
      client = await pool.connect();
      await client.query('BEGIN');
      await client.query(schema);
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
           ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, role = EXCLUDED.role, avatar_color = EXCLUDED.avatar_color,
             streak_days = EXCLUDED.streak_days`,
          [m.id, m.householdId, m.name, m.role, m.avatarColorHex, m.streakDays]
        );
      }
      for (const r of data.rooms || []) {
        await client.query(
          `INSERT INTO rooms (id, household_id, name, icon_key, color_hex, is_default)
           VALUES ($1, $2, $3, $4, $5, $6)
           ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, icon_key = EXCLUDED.icon_key, color_hex = EXCLUDED.color_hex,
             is_default = EXCLUDED.is_default`,
          [r.id, r.householdId, r.name, r.iconKey, r.colorHex, r.isDefault]
        );
      }
      for (const t of data.tasks || []) {
        await client.query(
          `INSERT INTO chore_tasks (id, household_id, title, description, icon_key, estimated_minutes, is_shared, frequency_label, created_at, intensity)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, COALESCE($9::timestamptz, NOW()), $10)
           ON CONFLICT (id) DO UPDATE SET
             title = EXCLUDED.title,
             description = EXCLUDED.description,
             icon_key = EXCLUDED.icon_key,
             estimated_minutes = EXCLUDED.estimated_minutes,
             is_shared = EXCLUDED.is_shared,
             frequency_label = EXCLUDED.frequency_label,
             intensity = EXCLUDED.intensity`,
          [t.id, t.householdId, t.title, t.description, t.iconKey, t.estimatedMinutes, t.isShared, t.frequencyLabel, t.createdAt ?? null, t.intensity ?? 2]
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
          `INSERT INTO work_sessions (id, household_id, task_id, member_id, logged_by_user, room_id, performed_at, duration_minutes, co_workers, energy_level, notes)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
           ON CONFLICT (id) DO NOTHING`,
          [s.id, s.householdId, s.taskId, s.memberId, s.loggedByUser, s.roomId, s.performedAt, s.durationMinutes, s.coWorkerIds ?? [], s.energyLevel, s.notes]
        );
      }
      await client.query('COMMIT');
      sendJson(res, 200, { ok: true });
    } catch (error) {
      if (client) {
        await client.query('ROLLBACK').catch(() => {});
      }
      console.error('Railway household sync failed:', error.message);
      sendJson(res, 500, { ok: false });
    } finally {
      client?.release();
    }
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

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Casvium Web + Railway Postgres gateway listening on port ${PORT}`);
});
