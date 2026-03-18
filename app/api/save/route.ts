import { NextRequest, NextResponse } from 'next/server';

export const runtime = 'nodejs';

const RAH_API = 'https://ra-hos-production.up.railway.app/api';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { title, description, content, url, type } = body as {
      title?: string;
      description?: string;
      content?: string;
      url?: string;
      type?: string;
    };

    if (!title || !title.trim()) {
      return NextResponse.json(
        { success: false, error: 'title is required' },
        { status: 400 }
      );
    }

    const dimensions = type ? [type] : ['research'];

    const payload: Record<string, unknown> = {
      title: title.trim(),
      dimensions,
    };
    if (description?.trim()) payload.description = description.trim();
    if (content?.trim()) payload.notes = content.trim();
    if (url?.trim()) payload.link = url.trim();

    const res = await fetch(`${RAH_API}/nodes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    const data = await res.json();

    if (!res.ok || !data.success) {
      return NextResponse.json(
        { success: false, error: data.error || 'Failed to create node' },
        { status: res.status || 500 }
      );
    }

    return NextResponse.json(
      { success: true, id: data.data?.id, node: data.data },
      { status: 201 }
    );
  } catch (error) {
    console.error('[Save API] Error:', error);
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Failed to save node',
      },
      { status: 500 }
    );
  }
}
