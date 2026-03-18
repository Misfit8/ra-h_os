// Sync nodes from Railway production → local RA-H SQLite
// Run: node scripts/sync-from-railway.js
//
// Uses railway_id stored in metadata to track synced nodes — never
// conflicts with local node IDs. Safe to run repeatedly.

const Database = require('better-sqlite3');
const path = require('path');
const os = require('os');
const fs = require('fs');

const RAILWAY_API = 'https://ra-hos-production.up.railway.app/api';
const PAGE_SIZE = 100;

function getLocalDbPath() {
  if (process.env.SQLITE_DB_PATH) return process.env.SQLITE_DB_PATH;
  const home = os.homedir();
  const candidates = [
    path.join(home, 'Library', 'Application Support', 'RA-H', 'db', 'rah.sqlite'),
    path.join(home, 'AppData', 'Roaming', 'RA-H', 'db', 'rah.sqlite'),
  ];
  for (const p of candidates) {
    if (fs.existsSync(p)) return p;
  }
  return candidates[0];
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

  // Find existing synced node by its Railway ID stored in metadata
  const findByRailwayId = db.prepare(
    `SELECT id FROM nodes WHERE json_extract(metadata, '$.railway_id') = ?`
  );

  // Insert new node without specifying ID — let SQLite auto-assign
  const insertNode = db.prepare(`
    INSERT INTO nodes (title, description, notes, link, metadata, created_at, updated_at)
    VALUES (@title, @description, @notes, @link, @metadata, @created_at, @updated_at)
  `);

  // Update existing synced node
  const updateNode = db.prepare(`
    UPDATE nodes SET
      title       = @title,
      description = @description,
      notes       = @notes,
      link        = @link,
      updated_at  = @updated_at
    WHERE id = @localId
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
      const existing = findByRailwayId.get(node.id);

      const rawDims = node.dimensions;
      const dims = Array.isArray(rawDims)
        ? rawDims
        : (rawDims || '').split(',').map((d) => d.trim()).filter(Boolean);

      const fields = {
        title:       node.title       || '',
        description: node.description || null,
        notes:       node.notes       || null,
        link:        node.link        || null,
        created_at:  node.created_at  || new Date().toISOString(),
        updated_at:  node.updated_at  || new Date().toISOString(),
      };

      let localId;
      if (existing) {
        localId = existing.id;
        updateNode.run({ ...fields, localId });
        updated++;
      } else {
        const result = insertNode.run({
          ...fields,
          metadata: JSON.stringify({ railway_id: node.id, source: 'railway-sync' }),
        });
        localId = result.lastInsertRowid;
        inserted++;
      }

      deleteDims.run(localId);
      for (const dim of dims) {
        insertDim.run(localId, dim);
      }
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
