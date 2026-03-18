# RA-H OS — Developer Reference

> Senior-level technical reference. Keep this file updated whenever new features, routes, or architecture decisions are added.

---

## Overview

RA-H OS is an open-source, local-first personal knowledge graph PWA. Deployed on Railway, backed by SQLite + sqlite-vec, with a 4-tab UI and MCP integration for Claude Code / Claude Desktop.

**Production**: https://ra-hos-production.up.railway.app
**Repo**: https://github.com/bradwmorris/ra-h_os
**Local**: `C:/Users/bradd/ra-h_os`

---

## Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 15, React 19, TypeScript, Tailwind CSS |
| Backend | Next.js API Routes (Node.js 20) |
| Database | SQLite 3 + sqlite-vec (vector search) |
| AI | Anthropic Claude Sonnet 4.6 (primary), OpenAI (optional embeddings) |
| MCP | @modelcontextprotocol/sdk v1.25.3 |
| Deployment | Railway (Docker, standalone output) |
| PWA | Web App Manifest + Service Worker v3 |

**Key deps**: better-sqlite3, @ai-sdk/anthropic, @ai-sdk/openai, voyageai, youtube-transcript, pdf-parse, cheerio, zod, lucide-react

---

## Environment Variables

| Variable | Required | Purpose |
|---|---|---|
| `ANTHROPIC_API_KEY` | Yes | Chat, descriptions, node actions |
| `OPENAI_API_KEY` | No | Embeddings, semantic search |
| `SQLITE_DB_PATH` | No | DB location (defaults to OS-specific path) |
| `SQLITE_VEC_EXTENSION_PATH` | No | Vector extension `.so`/`.dylib` path |
| `NEXT_PUBLIC_RAH_API_URL` | No | Client-side API base URL |
| `RAH_API_URL` | No | Server-side API base URL |
| `ALLOWED_ORIGINS` | No | Comma-separated origins for server actions |
| `NEXT_PUBLIC_DEPLOYMENT_MODE` | No | `local` or `cloud` |
| `MCP_ALLOW_WRITES` | No | Enables MCP write tools |

**Default DB paths**:
- macOS: `~/Library/Application Support/RA-H/db/rah.sqlite`
- Windows: `~/AppData/Roaming/RA-H/db/rah.sqlite`
- Railway: `/data/rah.sqlite` (persistent volume)

---

## API Routes (32 endpoints)

### Nodes
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/nodes` | List with pagination, sort, dimension filter |
| POST | `/api/nodes` | Create node (triggers auto-description + embedding queue) |
| GET | `/api/nodes/[id]` | Get single node |
| POST | `/api/nodes/[id]` | Update node |
| DELETE | `/api/nodes/[id]` | Delete node |
| GET | `/api/nodes/[id]/chunks` | Source text chunks |
| GET | `/api/nodes/[id]/edges` | Connected edges |
| POST | `/api/nodes/[id]/regenerate-description` | AI-regenerate description |
| GET | `/api/nodes/search?q=&limit=` | Full-text + semantic search |

### Edges
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/edges` | List all edges |
| POST | `/api/edges` | Create edge (idempotent, explanation validated) |
| GET | `/api/edges/[id]` | Get edge |
| PUT | `/api/edges/[id]` | Update edge |
| DELETE | `/api/edges/[id]` | Delete edge |

### Dimensions
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/dimensions` | List with node counts |
| POST | `/api/dimensions` | Create/upsert dimension |
| GET | `/api/dimensions/[name]` | Get dimension |
| GET | `/api/dimensions/[name]/context` | Sample nodes |
| GET | `/api/dimensions/popular` | Top by count |
| GET | `/api/dimensions/search?q=` | Search |

### System & AI
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/health` | Full system status |
| GET | `/api/health/ping` | Railway health check |
| GET | `/api/health/db` | DB health |
| GET | `/api/health/vectors` | Vector extension health |
| GET | `/api/mcp` | MCP server (HTTP transport) |
| POST | `/api/chat` | Chat with graph context + action parsing |
| POST | `/api/save` | Save web content as node |
| POST | `/api/ingestion` | Embed content + broadcast NODE_UPDATED |
| POST | `/api/extract/pdf/upload` | PDF text extraction |
| GET | `/api/guides` | List guides/skills |
| GET | `/api/guides/[name]` | Get guide content |
| POST | `/api/quick-add` | Queue background task |

---

## Four-Tab UI (`app/chat/ChatClient.tsx`)

### Chat
- Multi-turn Claude Sonnet 4.6 conversation
- Auto-fetches relevant nodes before each response (injected as system prompt context)
- Server-side action parsing: `CREATE_NODE: {...}` and `CREATE_EDGE: {...}` executed on graph
- Actions stripped from displayed reply

### Save
- Form: title* (160 char max), description, content/notes, URL, dimension type
- **Web Share Target**: accepts `?tab=save&title=&text=&url=` from Android share sheet
- **Bookmarklet**: `javascript:(function(){...})()` — saves current page in one click
- Validated: title required, length enforced

### Search
- Full-text + semantic search via `/api/nodes/search`
- Results: title, description, dimension badges
- Expand card to view notes + link

### Graph
- Lazy-loaded once per session (useRef guard)
- Fetches: hub nodes (`?sortBy=edges&limit=20`), all nodes (`?limit=200`), all edges
- Click hub node → neighbors with edge explanations
- Navigate graph by clicking neighbor nodes
- State: `Record<number, SearchNode>` — NOT Map (Map breaks React serialization)

---

## PWA

### manifest.json
```json
{
  "name": "RA-H Command Center",
  "start_url": "/chat",
  "display": "standalone",
  "icons": [
    {"src": "/icon-192.png", "sizes": "192x192", "purpose": "any"},
    {"src": "/icon-512.png", "sizes": "512x512", "purpose": "any maskable"}
  ],
  "share_target": {
    "action": "/chat?tab=save",
    "method": "GET",
    "params": {"title": "title", "text": "text", "url": "url"}
  }
}
```

### Service Worker (`public/sw.js`) — Cache v3
- **Network First**: `/api/*` (offline fallback: `{success:false, error:"offline"}`)
- **Cache First**: all static assets
- **Navigation fallback**: serves `/chat` from cache when offline
- `self.skipWaiting()` + `self.clients.claim()` for immediate SW activation
- `controllerchange` listener in ChatClient → `window.location.reload()`

> **Critical**: The `controllerchange` reload is required. `skipWaiting` activates the new SW but doesn't update already-loaded JS. Without the reload, phones run stale code indefinitely.
>
> **Cache bump rule**: Every SW update MUST use a new `CACHE_NAME` string. If the name is unchanged, the activate handler won't delete old caches (it only deletes caches with *different* names).

---

## Security Headers (`next.config.js`)

```
Content-Security-Policy:
  default-src 'self'
  script-src 'self' 'unsafe-inline' 'unsafe-eval'
  style-src 'self' 'unsafe-inline'
  connect-src 'self' https://api.anthropic.com {RAH_API_ORIGIN}
  img-src 'self' data: https:
  font-src 'self'
  worker-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
```

---

## Railway → Local Sync (`scripts/sync-from-railway.js`)

One-way sync from Railway production → local SQLite. Run via Windows Task Scheduler (on login + hourly).

**Design**:
- Dedup via `json_extract(metadata, '$.railway_id')` — avoids ID collision between two separate DBs
- INSERT without specifying ID (SQLite auto-assigns local ID)
- Stores `{railway_id, source: "railway-sync"}` in node metadata
- Paginates: 100 nodes/page
- Wrapped in `db.transaction()` for atomicity
- Handles `dimensions` as `string[]` or comma-string

**Run manually**:
```bash
node scripts/sync-from-railway.js
# Override DB path:
SQLITE_DB_PATH=/path/to/rah.sqlite node scripts/sync-from-railway.js
```

---

## MCP Integration

**Endpoint**: `https://ra-hos-production.up.railway.app/api/mcp`
**Transport**: HTTP (WebStandardStreamableHTTPServerTransport)

**Setup**:
```bash
claude mcp add --transport http my-rah https://ra-hos-production.up.railway.app/api/mcp
```

### Read Tools (always enabled)
| Tool | Purpose |
|---|---|
| `rah_search_nodes` | Full-text search with dimension filter |
| `rah_get_nodes` | Load node content by ID (batch) |
| `rah_query_edges` | Explore connections |
| `rah_list_dimensions` | List categories |

### Write Tools (`MCP_ALLOW_WRITES=true`)
| Tool | Purpose |
|---|---|
| `rah_add_node` | Create nodes |
| `rah_create_edge` | Create connections |
| `rah_update_node` | Modify existing nodes |

**Validation**: Zod schema on all inputs. Edge explanations reject weak verbs ("discusses", "explores"). Dimensions normalized to lowercase.

---

## Docker Deployment (Multi-stage)

```dockerfile
# Stage 1: deps — npm install + rebuild better-sqlite3
# Stage 2: builder — next build → .next/standalone
# Stage 3: runner — copy app + sqlite3 CLI + vec extensions + seed script

EXPOSE 3000
ENV SQLITE_DB_PATH=/data/rah.sqlite
CMD ["./scripts/railway-start.sh"]
```

**railway-start.sh**: Checks if DB exists → seeds from `seed.sql` if not → sets `SQLITE_VEC_EXTENSION_PATH` → `node server.js`

> **Critical**: The Dockerfile MUST include:
> ```dockerfile
> COPY --from=builder /app/public ./public
> ```
> Without this line, all PWA assets (icons, manifest.json, sw.js) are missing from the container.

---

## Known Gotchas & Architecture Decisions

| Decision | Reason |
|---|---|
| `Record<number,SearchNode>` not `Map` | Map is not React serialization-safe — causes client-side exceptions |
| `parseDims()` helper | API returns `dimensions: string[]` but TypeScript interface typed as `string`. parseDims handles both |
| `useRef` guard for graph loading | Prevents re-fetch cascade from `useCallback` dep changes |
| Metadata-based sync dedup | `railway_id` in metadata avoids ID collision between two separate SQLite DBs |
| `controllerchange` reload | SW `skipWaiting` activates new SW but doesn't update loaded JS; page reload required |
| CSP `connect-src` includes RAH_API_ORIGIN | Must include both `api.anthropic.com` AND Railway origin or fetches are CSP-blocked |

---

## Local Development

```bash
git clone https://github.com/bradwmorris/ra-h_os.git
cd ra-h_os
npm install
npm rebuild better-sqlite3
cp .env.example .env.local
# Add ANTHROPIC_API_KEY to .env.local
npm run dev
# → http://localhost:3000/chat
```
