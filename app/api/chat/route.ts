import { NextRequest, NextResponse } from 'next/server';

export const runtime = 'nodejs';

const RAH_API = 'https://ra-hos-production.up.railway.app/api';

interface RahNode {
  id: number;
  title: string;
  description?: string;
  notes?: string;
  dimensions?: string;
}

interface ActionTaken {
  type: 'node' | 'edge';
  data: unknown;
  result?: unknown;
  error?: string;
}

async function fetchRelevantNodes(query: string): Promise<RahNode[]> {
  try {
    const res = await fetch(
      `${RAH_API}/nodes/search?q=${encodeURIComponent(query.slice(0, 200))}&limit=10`,
      { next: { revalidate: 0 } }
    );
    if (!res.ok) return [];
    const data = await res.json();
    return (data.data as RahNode[]) || [];
  } catch {
    return [];
  }
}

function buildSystemPrompt(nodes: RahNode[]): string {
  const nodeContext =
    nodes.length > 0
      ? nodes
          .map(
            (n) =>
              `[Node ${n.id}] ${n.title}\n${n.description || ''}${n.notes ? '\n' + n.notes.slice(0, 400) : ''}`
          )
          .join('\n\n---\n\n')
      : 'No relevant nodes found for this query.';

  return `You are RA-H, an AI assistant with access to the user's personal knowledge graph. Answer concisely using the knowledge context below when relevant.

## Relevant Knowledge Context

${nodeContext}

## Actions
When the user explicitly asks to save something or connect nodes, include ONE action per line at the END of your response in exactly this format (single-line JSON only):

CREATE_NODE: {"title":"...","description":"...","notes":"...","dimensions":["projects"]}
CREATE_EDGE: {"from_node_id":1,"to_node_id":2,"relationship":"relates_to","description":"..."}

Only emit action lines when explicitly asked. Never emit them for normal conversation.`;
}

async function parseAndExecuteActions(text: string): Promise<ActionTaken[]> {
  const actions: ActionTaken[] = [];

  const nodeRegex = /^CREATE_NODE:\s*(\{.+\})$/gm;
  for (const match of text.matchAll(nodeRegex)) {
    try {
      const data = JSON.parse(match[1]);
      const res = await fetch(`${RAH_API}/nodes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      const result = await res.json();
      actions.push({ type: 'node', data, result });
    } catch (e) {
      actions.push({ type: 'node', data: match[1], error: String(e) });
    }
  }

  const edgeRegex = /^CREATE_EDGE:\s*(\{.+\})$/gm;
  for (const match of text.matchAll(edgeRegex)) {
    try {
      const data = JSON.parse(match[1]);
      const res = await fetch(`${RAH_API}/edges`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      const result = await res.json();
      actions.push({ type: 'edge', data, result });
    } catch (e) {
      actions.push({ type: 'edge', data: match[1], error: String(e) });
    }
  }

  return actions;
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { messages, query } = body as {
      messages: Array<{ role: string; content: string }>;
      query?: string;
    };

    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return NextResponse.json(
        { success: false, error: 'messages array is required' },
        { status: 400 }
      );
    }

    const lastUserMsg = [...messages].reverse().find((m) => m.role === 'user')?.content || '';
    const searchQuery = query || lastUserMsg;

    const nodes = await fetchRelevantNodes(searchQuery);
    const systemPrompt = buildSystemPrompt(nodes);

    const anthropicRes = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': process.env.ANTHROPIC_API_KEY ?? '',
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 1024,
        system: systemPrompt,
        messages: messages.map((m) => ({
          role: m.role as 'user' | 'assistant',
          content: m.content,
        })),
      }),
    });

    if (!anthropicRes.ok) {
      const err = await anthropicRes.text();
      throw new Error(`Anthropic API error: ${err}`);
    }

    const anthropicData = await anthropicRes.json() as {
      content: Array<{ type: string; text: string }>;
    };
    const text = anthropicData.content.find((b) => b.type === 'text')?.text ?? '';

    const actions_taken = await parseAndExecuteActions(text);

    const reply = text
      .replace(/^CREATE_NODE:\s*\{.+\}$/gm, '')
      .replace(/^CREATE_EDGE:\s*\{.+\}$/gm, '')
      .trim();

    return NextResponse.json({ success: true, reply, actions_taken });
  } catch (error) {
    console.error('[Chat API] Error:', error);
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Failed to generate response',
      },
      { status: 500 }
    );
  }
}
