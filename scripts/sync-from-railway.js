// Sync nodes from Railway production → local RA-H SQLite
// Run: node scripts/sync-from-railway.js
//
// Fetches all nodes from the deployed Railway instance and upserts them
// into the local SQLite so Claude Code MCP and Claude AI desktop can see them.

const Database = require('better-sqlite3');
const path = require('path');
const os = require('os');

const RAILWAY_API = 'https://ra-hos-production.up.railway.app/api';
const PAGE_SIZE = 100;

function getLocalDbPath() {
  if (process.env.SQLITE_DB_PATH) return process.env.SQLITE_DB_PATH;
  const home = os.homedir();
  // Try paths in order, return first that exists
  const candidates = [
    path.join(home, 'Library', 'Application Support', 'RA-H', 'db', 'rah.sqlite'),
    path.join(home, 'AppData', 'Roaming', 'RA-H', 'db', 'rah.sqlite'),
  ];
  const fs = require('fs');
  for (const p of candidates) {
    if (fs.existsSync(p)) return p;
  }
  return candidates[0]; // fallback with useful error message
}

async function fetchAllNodes() {
  const nodes = [];
  let offset = 0;
  while (true) {
    const res = await fetch(`${RAILWAY_API}/nodes?limit=${PAGE_SIZE}&offset=${offset}`);
    if (!res.ok) throw new Error(`Fetch failed: ${res.status} ${res.statusText}`);
    const data = await res.json();
    const page = data.data || [];
    nodes.push(...page);
    if (page.length < PAGE_SIZE) break;
    offset += PAGE_SIZE;
  }
  return nodes;
}

async function main() {
  const dbPath = getLocalDbPath();
  console.log(`Local DB: ${dbPath}`);

  let db;
  try {
    db = new Database(dbPath);
  } catch (err) {
    console.error(`Cannot open local DB at ${dbPath}`);
    console.error('Set SQLITE_DB_PATH env var to override the path.');
    console.error(err.message);
    process.exit(1);
  }

  db.pragma('foreign_keys = ON');
  db.pragma('journal_mode = WAL');

  const upsertNode = db.prepare(`
    INSERT INTO nodes (id, title, description, notes, link, created_at, updated_at)
    VALUES (@id, @title, @description, @notes, @link, @created_at, @updated_at)
    ON CONFLICT(id) DO UPDATE SET
      title       = excluded.title,
      description = excluded.description,
      notes       = excluded.notes,
      link        = excluded.link,
      updated_at  = excluded.updated_at
  `);

  const deleteDims = db.prepare('DELETE FROM node_dimensions WHERE node_id = ?');
  const insertDim  = db.prepare('INSERT OR IGNORE INTO node_dimensions (node_id, dimension) VALUES (?, ?)');

  console.log('Fetching nodes from Railway…');
  const nodes = await fetchAllNodes();
  console.log(`Found ${nodes.length} nodes`);

  let inserted = 0;
  let updated  = 0;

  const sync = db.transaction((nodes) => {
    for (const node of nodes) {
      const existing = db.prepare('SELECT id FROM nodes WHERE id = ?').get(node.id);

      upsertNode.run({
        id:          node.id,
        title:       node.title       || '',
        description: node.description || null,
        notes:       node.notes       || null,
        link:        node.link        || null,
        created_at:  node.created_at  || new Date().toISOString(),
        updated_at:  node.updated_at  || new Date().toISOString(),
      });

      // Sync dimensions — API returns array or comma-string
      const rawDims = node.dimensions;
      const dims = Array.isArray(rawDims)
        ? rawDims
        : (rawDims || '').split(',').map((d) => d.trim()).filter(Boolean);

      deleteDims.run(node.id);
      for (const dim of dims) {
        insertDim.run(node.id, dim);
      }

      if (existing) updated++; else inserted++;
    }
  });

  sync(nodes);

  console.log(`Done — ${inserted} inserted, ${updated} updated`);
  db.close();
}

main().catch((err) => {
  console.error('Sync failed:', err.message);
  process.exit(1);
});
