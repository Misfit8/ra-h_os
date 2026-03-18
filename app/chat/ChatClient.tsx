'use client';

import { useState, useEffect, useRef, useCallback, FormEvent } from 'react';
import { useSearchParams } from 'next/navigation';

// ─── PWA helpers ─────────────────────────────────────────────────────────────

function registerServiceWorker() {
  if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js').catch((err) => {
      console.error('[SW] Registration failed:', err);
    });
    // When a new SW activates and takes control, reload to get fresh JS bundle
    navigator.serviceWorker.addEventListener('controllerchange', () => {
      window.location.reload();
    });
  }
}

function isIOS() {
  return (
    typeof window !== 'undefined' &&
    /iphone|ipad|ipod/i.test(navigator.userAgent) &&
    !(window.navigator as { standalone?: boolean }).standalone
  );
}

// Typed BeforeInstallPromptEvent (not yet in TS lib)
interface BeforeInstallPromptEvent extends Event {
  prompt(): Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
}

function canShare(data: ShareData) {
  return typeof navigator !== 'undefined' && !!navigator.share && navigator.canShare?.(data);
}

// ─── Types ───────────────────────────────────────────────────────────────────

type Tab = 'chat' | 'save' | 'search' | 'graph';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

interface ActionTaken {
  type: 'node' | 'edge';
  data: unknown;
  result?: unknown;
  error?: string;
}

interface SaveForm {
  title: string;
  description: string;
  content: string;
  url: string;
  type: string;
}

interface SearchNode {
  id: number;
  title: string;
  description?: string;
  notes?: string;
  dimensions?: string;
  link?: string;
}

interface GraphEdge {
  id: number;
  from_node_id: number;
  to_node_id: number;
  context?: {
    type?: string;
    explanation?: string;
  };
}

// ─── Constants ────────────────────────────────────────────────────────────────

const RAH_BASE = process.env.NEXT_PUBLIC_RAH_API_URL ?? 'https://ra-hos-production.up.railway.app/api';

function parseDims(dimensions?: string | string[]): string[] {
  if (!dimensions) return [];
  if (Array.isArray(dimensions)) return dimensions.filter(Boolean);
  return dimensions.split(',').map((d) => d.trim()).filter(Boolean);
}
const RAH_ORIGIN = RAH_BASE.replace(/\/api$/, '');

const BOOKMARKLET_URL =
  `javascript:(function(){var p=new URLSearchParams({tab:'save',url:window.location.href,title:document.title});window.open('${RAH_ORIGIN}/chat?'+p.toString(),'_blank');})();`;

const TABS: { id: Tab; label: string; icon: string }[] = [
  { id: 'chat', label: 'Chat', icon: '💬' },
  { id: 'save', label: 'Save', icon: '💾' },
  { id: 'search', label: 'Search', icon: '🔍' },
  { id: 'graph', label: 'Graph', icon: '🕸️' },
];

const NODE_TYPES = [
  { value: 'projects', label: 'Project' },
  { value: 'research', label: 'Research' },
  { value: 'ideas', label: 'Idea' },
  { value: 'memory', label: 'Memory' },
  { value: 'health', label: 'Health' },
  { value: 'preferences', label: 'Preference' },
];

// ─── Styles ───────────────────────────────────────────────────────────────────

const S = {
  root: {
    display: 'flex',
    height: '100dvh',
    background: '#0a0a0a',
    color: '#e5e5e5',
    fontFamily: "'Geist', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
    fontSize: '16px',
    lineHeight: '1.5',
    overflow: 'hidden',
  } as React.CSSProperties,

  nav: (isDesktop: boolean): React.CSSProperties => ({
    display: 'flex',
    flexDirection: isDesktop ? 'column' : 'row',
    flexShrink: 0,
    width: isDesktop ? '180px' : '100%',
    // On mobile: 60px tab bar + gesture bar clearance
    height: isDesktop ? '100%' : 'calc(60px + env(safe-area-inset-bottom))',
    borderRight: isDesktop ? '1px solid #1a1a1a' : 'none',
    borderTop: isDesktop ? 'none' : '1px solid #1a1a1a',
    background: '#0a0a0a',
    order: isDesktop ? 0 : 2,
    paddingTop: isDesktop ? '16px' : 0,
    paddingBottom: isDesktop ? 0 : 'env(safe-area-inset-bottom)',
  }),

  navBrand: {
    padding: '0 16px 20px',
    fontSize: '13px',
    color: '#6b6b6b',
    letterSpacing: '0.08em',
    textTransform: 'uppercase' as const,
    fontWeight: 600,
  },

  navTab: (active: boolean, isDesktop: boolean): React.CSSProperties => ({
    display: 'flex',
    alignItems: 'center',
    justifyContent: isDesktop ? 'flex-start' : 'center',
    gap: '8px',
    flex: isDesktop ? undefined : 1,
    padding: isDesktop ? '10px 16px' : '0 8px',
    height: isDesktop ? 'auto' : '100%',
    minHeight: '44px',
    background: active ? '#151515' : 'transparent',
    color: active ? '#e5e5e5' : '#6b6b6b',
    border: 'none',
    borderLeft: isDesktop ? `2px solid ${active ? '#e5e5e5' : 'transparent'}` : 'none',
    borderTop: isDesktop ? 'none' : `2px solid ${active ? '#e5e5e5' : 'transparent'}`,
    cursor: 'pointer',
    fontSize: '16px',
    fontFamily: 'inherit',
    textAlign: isDesktop ? 'left' : 'center',
    flexDirection: isDesktop ? 'row' : 'column',
    transition: 'background 0.1s, color 0.1s',
  }),

  navTabLabel: (isDesktop: boolean): React.CSSProperties => ({
    fontSize: isDesktop ? '14px' : '10px',
    fontWeight: 500,
  }),

  main: (isDesktop: boolean): React.CSSProperties => ({
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    overflow: 'hidden',
    order: isDesktop ? 1 : 1,
  }),

  // Chat tab
  messages: {
    flex: 1,
    overflowY: 'auto' as const,
    padding: '16px',
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '12px',
  },

  messageBubble: (role: 'user' | 'assistant'): React.CSSProperties => ({
    maxWidth: '80%',
    alignSelf: role === 'user' ? 'flex-end' : 'flex-start',
    background: role === 'user' ? '#151515' : '#111111',
    border: '1px solid #1a1a1a',
    borderRadius: '12px',
    padding: '10px 14px',
    fontSize: '16px',
    lineHeight: '1.6',
    whiteSpace: 'pre-wrap',
    wordBreak: 'break-word' as const,
  }),

  messageRole: (role: 'user' | 'assistant'): React.CSSProperties => ({
    fontSize: '11px',
    color: '#6b6b6b',
    marginBottom: '4px',
    textAlign: role === 'user' ? 'right' : 'left',
  }),

  actionsBar: {
    fontSize: '12px',
    color: '#6b6b6b',
    padding: '4px 0 0',
    borderTop: '1px solid #1a1a1a',
    marginTop: '6px',
  },

  inputRow: {
    display: 'flex',
    gap: '8px',
    padding: '12px 16px',
    borderTop: '1px solid #1a1a1a',
    background: '#0a0a0a',
    alignItems: 'flex-end',
  },

  textarea: {
    flex: 1,
    background: '#111111',
    border: '1px solid #1a1a1a',
    borderRadius: '8px',
    color: '#e5e5e5',
    fontFamily: 'inherit',
    fontSize: '16px',
    lineHeight: '1.5',
    padding: '10px 12px',
    resize: 'none' as const,
    outline: 'none',
    minHeight: '44px',
    maxHeight: '120px',
  },

  sendBtn: (disabled: boolean): React.CSSProperties => ({
    background: disabled ? '#1a1a1a' : '#e5e5e5',
    color: disabled ? '#6b6b6b' : '#0a0a0a',
    border: 'none',
    borderRadius: '8px',
    padding: '10px 16px',
    cursor: disabled ? 'not-allowed' : 'pointer',
    fontFamily: 'inherit',
    fontSize: '16px',
    fontWeight: 600,
    minHeight: '44px',
    minWidth: '60px',
    transition: 'background 0.1s, color 0.1s',
  }),

  // Save tab
  form: {
    flex: 1,
    overflowY: 'auto' as const,
    padding: '20px 16px',
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '16px',
  },

  formGroup: {
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '6px',
  },

  label: {
    fontSize: '13px',
    fontWeight: 500,
    color: '#6b6b6b',
    letterSpacing: '0.02em',
  },

  input: {
    background: '#111111',
    border: '1px solid #1a1a1a',
    borderRadius: '8px',
    color: '#e5e5e5',
    fontFamily: 'inherit',
    fontSize: '16px',
    padding: '10px 12px',
    outline: 'none',
    width: '100%',
  },

  select: {
    background: '#111111',
    border: '1px solid #1a1a1a',
    borderRadius: '8px',
    color: '#e5e5e5',
    fontFamily: 'inherit',
    fontSize: '16px',
    padding: '10px 12px',
    outline: 'none',
    width: '100%',
    cursor: 'pointer',
  },

  textareaField: {
    background: '#111111',
    border: '1px solid #1a1a1a',
    borderRadius: '8px',
    color: '#e5e5e5',
    fontFamily: 'inherit',
    fontSize: '16px',
    padding: '10px 12px',
    outline: 'none',
    resize: 'vertical' as const,
    minHeight: '80px',
    width: '100%',
  },

  submitBtn: (disabled: boolean): React.CSSProperties => ({
    background: disabled ? '#1a1a1a' : '#e5e5e5',
    color: disabled ? '#6b6b6b' : '#0a0a0a',
    border: 'none',
    borderRadius: '8px',
    padding: '12px 20px',
    cursor: disabled ? 'not-allowed' : 'pointer',
    fontFamily: 'inherit',
    fontSize: '16px',
    fontWeight: 600,
    minHeight: '44px',
    width: '100%',
    transition: 'background 0.1s, color 0.1s',
  }),

  // Search tab
  searchPanel: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column' as const,
    overflow: 'hidden',
  },

  searchInputRow: {
    display: 'flex',
    gap: '8px',
    padding: '12px 16px',
    borderBottom: '1px solid #1a1a1a',
  },

  searchResults: {
    flex: 1,
    overflowY: 'auto' as const,
    padding: '12px 16px',
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '10px',
  },

  nodeCard: (expanded: boolean): React.CSSProperties => ({
    background: '#111111',
    border: '1px solid #1a1a1a',
    borderRadius: '10px',
    padding: '12px 14px',
    cursor: 'pointer',
    transition: 'border-color 0.1s',
    borderColor: expanded ? '#353535' : '#1a1a1a',
  }),

  nodeTitle: {
    fontSize: '15px',
    fontWeight: 600,
    color: '#e5e5e5',
    lineHeight: '1.4',
    marginBottom: '4px',
  },

  nodeDescription: {
    fontSize: '13px',
    color: '#9b9b9b',
    lineHeight: '1.5',
    marginBottom: '8px',
  },

  nodeNotes: {
    fontSize: '13px',
    color: '#6b6b6b',
    lineHeight: '1.6',
    marginTop: '8px',
    paddingTop: '8px',
    borderTop: '1px solid #1a1a1a',
    whiteSpace: 'pre-wrap' as const,
    wordBreak: 'break-word' as const,
  },

  dimBadges: {
    display: 'flex',
    flexWrap: 'wrap' as const,
    gap: '4px',
  },

  dimBadge: {
    fontSize: '11px',
    color: '#6b6b6b',
    background: '#1a1a1a',
    borderRadius: '4px',
    padding: '2px 6px',
    fontWeight: 500,
  },

  // Graph tab
  graphPanel: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column' as const,
    overflow: 'hidden',
  },

  graphHeader: {
    padding: '12px 16px',
    borderBottom: '1px solid #1a1a1a',
    fontSize: '13px',
    color: '#6b6b6b',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
  },

  graphList: {
    flex: 1,
    overflowY: 'auto' as const,
    padding: '12px 16px',
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '8px',
  },

  hubCard: (selected: boolean): React.CSSProperties => ({
    background: selected ? '#151515' : '#111111',
    border: `1px solid ${selected ? '#353535' : '#1a1a1a'}`,
    borderRadius: '10px',
    padding: '12px 14px',
    cursor: 'pointer',
  }),

  hubTitle: {
    fontSize: '15px',
    fontWeight: 600,
    color: '#e5e5e5',
    lineHeight: '1.4',
    marginBottom: '4px',
  },

  hubMeta: {
    fontSize: '12px',
    color: '#6b6b6b',
    display: 'flex',
    gap: '10px',
    alignItems: 'center',
    marginBottom: '4px',
  },

  edgeDot: {
    display: 'inline-block',
    width: '6px',
    height: '6px',
    borderRadius: '50%',
    background: '#353535',
    marginRight: '4px',
  },

  connectionList: {
    marginTop: '10px',
    paddingTop: '10px',
    borderTop: '1px solid #1a1a1a',
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '6px',
  },

  connectionItem: {
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '2px',
    padding: '8px 10px',
    background: '#0d0d0d',
    borderRadius: '6px',
    cursor: 'pointer',
  },

  connectionTitle: {
    fontSize: '13px',
    fontWeight: 500,
    color: '#e5e5e5',
  },

  connectionRel: {
    fontSize: '11px',
    color: '#6b6b6b',
    fontStyle: 'italic' as const,
  },

  backBtn: {
    background: 'transparent',
    border: 'none',
    color: '#6b6b6b',
    cursor: 'pointer',
    fontSize: '13px',
    padding: '0',
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
  },

  // Stub tabs
  stub: {
    flex: 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'column' as const,
    gap: '12px',
    color: '#6b6b6b',
  },

  stubIcon: {
    fontSize: '40px',
  },

  stubText: {
    fontSize: '16px',
    color: '#6b6b6b',
  },

  // Bookmarklet section
  bookmarkletBox: {
    background: '#111111',
    border: '1px solid #1a1a1a',
    borderRadius: '8px',
    padding: '12px',
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '8px',
  },

  bookmarkletLink: {
    color: '#e5e5e5',
    background: '#1a1a1a',
    border: '1px solid #353535',
    borderRadius: '6px',
    padding: '8px 12px',
    textDecoration: 'none',
    fontSize: '14px',
    fontWeight: 600,
    display: 'inline-block',
    cursor: 'grab',
    alignSelf: 'flex-start',
    minHeight: '44px',
    lineHeight: '28px',
  },

  successBanner: {
    background: '#0d1f0d',
    border: '1px solid #1a3d1a',
    borderRadius: '8px',
    padding: '12px',
    color: '#4caf50',
    fontSize: '14px',
  },

  errorBanner: {
    background: '#1f0d0d',
    border: '1px solid #3d1a1a',
    borderRadius: '8px',
    padding: '12px',
    color: '#f44336',
    fontSize: '14px',
  },

  sectionTitle: {
    fontSize: '11px',
    fontWeight: 600,
    color: '#6b6b6b',
    letterSpacing: '0.1em',
    textTransform: 'uppercase' as const,
    padding: '16px 16px 0',
  },
};

// ─── Component ────────────────────────────────────────────────────────────────

export default function ChatClient() {
  const searchParams = useSearchParams();

  const VALID_TABS: Tab[] = ['chat', 'save', 'search', 'graph'];
  const rawTab = searchParams.get('tab');
  const initialTab: Tab = VALID_TABS.includes(rawTab as Tab) ? (rawTab as Tab) : 'chat';
  const initialUrl = searchParams.get('url') || '';
  const initialTitle = searchParams.get('title') || '';
  const initialText = searchParams.get('text') || '';

  const [activeTab, setActiveTab] = useState<Tab>(initialTab);
  const [isDesktop, setIsDesktop] = useState(false);
  const [showIOSPrompt, setShowIOSPrompt] = useState(false);
  const [installPrompt, setInstallPrompt] = useState<BeforeInstallPromptEvent | null>(null);

  // Chat state
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Graph state
  const graphFetchedRef = useRef(false);
  const [isLoadingGraph, setIsLoadingGraph] = useState(false);
  const [graphError, setGraphError] = useState<string | null>(null);
  const [graphHubs, setGraphHubs] = useState<SearchNode[]>([]);
  const [allGraphNodes, setAllGraphNodes] = useState<Record<number, SearchNode>>({});
  const [graphEdges, setGraphEdges] = useState<GraphEdge[]>([]);
  const [selectedGraphId, setSelectedGraphId] = useState<number | null>(null);

  // Search state
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SearchNode[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [searchError, setSearchError] = useState<string | null>(null);
  const [expandedNode, setExpandedNode] = useState<number | null>(null);

  // Save state
  const [saveForm, setSaveForm] = useState<SaveForm>({
    title: initialTitle,
    description: '',
    content: initialText,
    url: initialUrl,
    type: 'research',
  });
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState<string | null>(null);
  const [saveError, setSaveError] = useState<string | null>(null);

  // Responsive detection + SW registration + install prompts
  useEffect(() => {
    // 600px breakpoint matches Samsung A16 5G (412px viewport) per device spec
    const mq = window.matchMedia('(min-width: 600px)');
    setIsDesktop(mq.matches);
    const handler = (e: MediaQueryListEvent) => setIsDesktop(e.matches);
    mq.addEventListener('change', handler);

    registerServiceWorker();

    // iOS: manual prompt (iOS Safari never fires beforeinstallprompt)
    if (isIOS()) {
      setShowIOSPrompt(true);
    }

    // Android / Chrome: capture the native install prompt
    const onBeforeInstall = (e: Event) => {
      e.preventDefault();
      setInstallPrompt(e as BeforeInstallPromptEvent);
    };
    window.addEventListener('beforeinstallprompt', onBeforeInstall);

    // Hide install prompt if already installed
    window.addEventListener('appinstalled', () => setInstallPrompt(null));

    return () => {
      mq.removeEventListener('change', handler);
      window.removeEventListener('beforeinstallprompt', onBeforeInstall);
    };
  }, []);

  // Auto-scroll messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  // Auto-resize textarea
  const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setInput(e.target.value);
    e.target.style.height = 'auto';
    e.target.style.height = Math.min(e.target.scrollHeight, 120) + 'px';
  };

  const sendMessage = useCallback(async () => {
    const text = input.trim();
    if (!text || isLoading) return;

    const newMessages: Message[] = [...messages, { role: 'user', content: text }];
    setMessages(newMessages);
    setInput('');
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
    }
    setIsLoading(true);

    try {
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ messages: newMessages }),
      });
      const data = await res.json();

      if (data.success) {
        const assistantMsg: Message = { role: 'assistant', content: data.reply };
        if (data.actions_taken?.length > 0) {
          const actionSummary = data.actions_taken
            .map((a: ActionTaken) =>
              a.error ? `Failed to create ${a.type}` : `Created ${a.type}`
            )
            .join(', ');
          assistantMsg.content = data.reply + `\n\n_Actions: ${actionSummary}_`;
        }
        setMessages((prev) => [...prev, assistantMsg]);
      } else {
        setMessages((prev) => [
          ...prev,
          { role: 'assistant', content: `Error: ${data.error || 'Something went wrong'}` },
        ]);
      }
    } catch {
      setMessages((prev) => [
        ...prev,
        { role: 'assistant', content: 'Network error. Please try again.' },
      ]);
    } finally {
      setIsLoading(false);
    }
  }, [input, messages, isLoading]);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  useEffect(() => {
    if (activeTab !== 'graph' || graphFetchedRef.current) return;
    graphFetchedRef.current = true;
    setIsLoadingGraph(true);
    setGraphError(null);
    Promise.all([
      fetch(`${RAH_BASE}/nodes?sortBy=edges&limit=20`),
      fetch(`${RAH_BASE}/nodes?limit=200`),
      fetch(`${RAH_BASE}/edges`),
    ])
      .then(([hubsRes, allRes, edgesRes]) => {
        if (!hubsRes.ok || !allRes.ok || !edgesRes.ok) throw new Error('Failed to load graph data');
        return Promise.all([hubsRes.json(), allRes.json(), edgesRes.json()]);
      })
      .then(([hubs, all, edges]) => {
        const nodeRecord: Record<number, SearchNode> = {};
        for (const n of ((all.data as SearchNode[]) || [])) {
          if (n?.id) nodeRecord[n.id] = n;
        }
        setGraphHubs((hubs.data as SearchNode[]) || []);
        setAllGraphNodes(nodeRecord);
        setGraphEdges((edges.data as GraphEdge[]) || []);
      })
      .catch((err) => {
        setGraphError(err instanceof Error ? err.message : 'Failed to load graph');
        graphFetchedRef.current = false;
      })
      .finally(() => setIsLoadingGraph(false));
  }, [activeTab]);

  const handleSearch = async (e?: FormEvent) => {
    e?.preventDefault();
    const q = searchQuery.trim();
    if (!q || isSearching) return;

    setIsSearching(true);
    setSearchError(null);
    setExpandedNode(null);

    try {
      const res = await fetch(
        `${RAH_BASE}/nodes/search?q=${encodeURIComponent(q.slice(0, 200))}&limit=20`
      );
      if (!res.ok) throw new Error(`Search failed: ${res.status}`);
      const data = await res.json();
      setSearchResults((data.data as SearchNode[]) || []);
    } catch (err) {
      setSearchError(err instanceof Error ? err.message : 'Search failed');
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const handleSave = async (e: FormEvent) => {
    e.preventDefault();
    if (!saveForm.title.trim() || isSaving) return;

    setIsSaving(true);
    setSaveSuccess(null);
    setSaveError(null);

    try {
      const res = await fetch('/api/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(saveForm),
      });
      const data = await res.json();

      if (data.success) {
        setSaveSuccess(`Saved! Node ID: ${data.id}`);
        setSaveForm({ title: '', description: '', content: '', url: '', type: 'research' });
      } else {
        setSaveError(data.error || 'Failed to save');
      }
    } catch {
      setSaveError('Network error. Please try again.');
    } finally {
      setIsSaving(false);
    }
  };

  // ─── Render tabs ────────────────────────────────────────────────────────────

  const renderChat = () => (
    <>
      <div style={S.messages} role="log" aria-label="Chat messages" aria-live="polite">
        {messages.length === 0 && (
          <div style={{ color: '#6b6b6b', fontSize: '16px', textAlign: 'center', marginTop: '40px' }}>
            Ask RA-H anything about your knowledge graph.
          </div>
        )}
        {messages.map((msg, i) => (
          <div key={i} style={{ display: 'flex', flexDirection: 'column' }}>
            <div style={S.messageRole(msg.role)}>
              {msg.role === 'user' ? 'You' : 'RA-H'}
            </div>
            <div style={S.messageBubble(msg.role)}>{msg.content}</div>
          </div>
        ))}
        {isLoading && (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <div style={S.messageRole('assistant')}>RA-H</div>
            <div style={{ ...S.messageBubble('assistant'), color: '#6b6b6b' }}>Thinking…</div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <div style={S.inputRow}>
        <label htmlFor="chat-input" style={{ display: 'none' }}>
          Message
        </label>
        <textarea
          id="chat-input"
          ref={textareaRef}
          value={input}
          onChange={handleInputChange}
          onKeyDown={handleKeyDown}
          placeholder="Message RA-H… (Enter to send, Shift+Enter for newline)"
          style={S.textarea}
          aria-label="Chat message input"
          rows={1}
          disabled={isLoading}
        />
        <button
          onClick={sendMessage}
          disabled={!input.trim() || isLoading}
          style={S.sendBtn(!input.trim() || isLoading)}
          aria-label="Send message"
        >
          Send
        </button>
      </div>
    </>
  );

  const renderSave = () => (
    <form onSubmit={handleSave} style={S.form} aria-label="Save to RA-H">
      {saveSuccess && <div style={S.successBanner} role="status">{saveSuccess}</div>}
      {saveError && <div style={S.errorBanner} role="alert">{saveError}</div>}

      <div style={S.formGroup}>
        <label htmlFor="save-title" style={S.label}>
          Title *
        </label>
        <input
          id="save-title"
          type="text"
          value={saveForm.title}
          onChange={(e) => setSaveForm((f) => ({ ...f, title: e.target.value }))}
          placeholder="Node title"
          style={S.input}
          required
          aria-label="Node title"
        />
      </div>

      <div style={S.formGroup}>
        <label htmlFor="save-description" style={S.label}>
          Description
        </label>
        <input
          id="save-description"
          type="text"
          value={saveForm.description}
          onChange={(e) => setSaveForm((f) => ({ ...f, description: e.target.value }))}
          placeholder="One-line summary"
          style={S.input}
          aria-label="Node description"
        />
      </div>

      <div style={S.formGroup}>
        <label htmlFor="save-url" style={S.label}>
          URL
        </label>
        <input
          id="save-url"
          type="url"
          inputMode="url"
          value={saveForm.url}
          onChange={(e) => setSaveForm((f) => ({ ...f, url: e.target.value }))}
          placeholder="https://..."
          style={S.input}
          aria-label="Source URL"
        />
      </div>

      <div style={S.formGroup}>
        <label htmlFor="save-type" style={S.label}>
          Type
        </label>
        <select
          id="save-type"
          value={saveForm.type}
          onChange={(e) => setSaveForm((f) => ({ ...f, type: e.target.value }))}
          style={S.select}
          aria-label="Node type"
        >
          {NODE_TYPES.map((t) => (
            <option key={t.value} value={t.value}>
              {t.label}
            </option>
          ))}
        </select>
      </div>

      <div style={S.formGroup}>
        <label htmlFor="save-content" style={S.label}>
          Notes
        </label>
        <textarea
          id="save-content"
          value={saveForm.content}
          onChange={(e) => setSaveForm((f) => ({ ...f, content: e.target.value }))}
          placeholder="Full notes, context, or content…"
          style={S.textareaField}
          aria-label="Node notes"
          rows={4}
        />
      </div>

      <button
        type="submit"
        disabled={!saveForm.title.trim() || isSaving}
        style={S.submitBtn(!saveForm.title.trim() || isSaving)}
        aria-label="Save node to RA-H"
      >
        {isSaving ? 'Saving…' : 'Save to RA-H'}
      </button>

      {saveForm.url && canShare({ url: saveForm.url, title: saveForm.title }) && (
        <button
          type="button"
          onClick={() =>
            navigator.share({ url: saveForm.url, title: saveForm.title || 'Shared via RA-H' })
          }
          style={{ ...S.submitBtn(false), background: '#1a1a1a', color: '#e5e5e5' }}
          aria-label="Share this URL via system share sheet"
        >
          Share via…
        </button>
      )}

      <div style={S.bookmarkletBox}>
        <div style={{ fontSize: '13px', fontWeight: 600, color: '#6b6b6b' }}>
          Bookmarklet
        </div>
        <div style={{ fontSize: '13px', color: '#6b6b6b', lineHeight: '1.5' }}>
          Drag this to your bookmarks bar to save any page to RA-H in one click:
        </div>
        {/* eslint-disable-next-line @next/next/no-html-link-for-pages */}
        <a
          href={BOOKMARKLET_URL}
          style={S.bookmarkletLink}
          aria-label="Bookmarklet: Save to RA-H — drag this to your bookmarks bar"
          onClick={(e) => e.preventDefault()}
          draggable
        >
          + Save to RA-H
        </a>
        <div style={{ fontSize: '12px', color: '#6b6b6b' }}>
          Drag the button above to your bookmarks bar. Do not click — drag.
        </div>
      </div>
    </form>
  );

  const renderSearch = () => (
    <div style={S.searchPanel} aria-label="Search knowledge graph">
      <form onSubmit={handleSearch} style={S.searchInputRow}>
        <label htmlFor="search-input" style={{ display: 'none' }}>Search</label>
        <input
          id="search-input"
          type="search"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search your knowledge graph…"
          style={{ ...S.input, flex: 1, margin: 0 }}
          aria-label="Search query"
          autoComplete="off"
        />
        <button
          type="submit"
          disabled={!searchQuery.trim() || isSearching}
          style={S.sendBtn(!searchQuery.trim() || isSearching)}
          aria-label="Search"
        >
          {isSearching ? '…' : 'Go'}
        </button>
      </form>

      <div style={S.searchResults} role="list" aria-label="Search results">
        {searchError && (
          <div style={S.errorBanner} role="alert">{searchError}</div>
        )}

        {!isSearching && searchResults.length === 0 && searchQuery && !searchError && (
          <div style={{ color: '#6b6b6b', fontSize: '14px', textAlign: 'center', marginTop: '32px' }}>
            No results found.
          </div>
        )}

        {!isSearching && searchResults.length === 0 && !searchQuery && (
          <div style={{ color: '#6b6b6b', fontSize: '14px', textAlign: 'center', marginTop: '32px' }}>
            Search across all nodes in your graph.
          </div>
        )}

        {searchResults.map((node) => {
          const isExpanded = expandedNode === node.id;
          const dims = parseDims(node.dimensions);
          return (
            <div
              key={node.id}
              role="listitem"
              style={S.nodeCard(isExpanded)}
              onClick={() => setExpandedNode(isExpanded ? null : node.id)}
              aria-expanded={isExpanded}
              aria-label={`Node: ${node.title}`}
            >
              <div style={S.nodeTitle}>{node.title}</div>
              {node.description && (
                <div style={S.nodeDescription}>{node.description}</div>
              )}
              {dims.length > 0 && (
                <div style={S.dimBadges}>
                  {dims.map((d) => (
                    <span key={d} style={S.dimBadge}>{d}</span>
                  ))}
                </div>
              )}
              {isExpanded && node.notes && (
                <div style={S.nodeNotes}>{node.notes}</div>
              )}
              {isExpanded && node.link && (
                <a
                  href={node.link}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={(e) => e.stopPropagation()}
                  style={{ display: 'block', fontSize: '12px', color: '#6b6b6b', marginTop: '8px', wordBreak: 'break-all' }}
                >
                  {node.link}
                </a>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );

  const renderGraph = () => {
    try {
    const selectedNode = selectedGraphId !== null ? allGraphNodes[selectedGraphId] : null;
    const connections = selectedGraphId !== null
      ? graphEdges.filter((e) => e.from_node_id === selectedGraphId || e.to_node_id === selectedGraphId)
      : [];

    return (
      <div style={S.graphPanel} aria-label="Knowledge graph">
        <div style={S.graphHeader}>
          {selectedNode ? (
            <button style={S.backBtn} onClick={() => setSelectedGraphId(null)} aria-label="Back to hub nodes">
              ← Back
            </button>
          ) : (
            <span>Top nodes by connections</span>
          )}
          <span>{Object.keys(allGraphNodes).length} nodes · {graphEdges.length} edges</span>
        </div>

        <div style={S.graphList} role="list">
          {isLoadingGraph && (
            <div style={{ color: '#6b6b6b', textAlign: 'center', marginTop: '40px' }}>Loading…</div>
          )}
          {graphError && (
            <div style={S.errorBanner} role="alert">{graphError}</div>
          )}

          {/* Hub node list */}
          {!isLoadingGraph && !selectedNode && graphHubs.map((node) => {
            const edgeCount = graphEdges.filter(
              (e) => e.from_node_id === node.id || e.to_node_id === node.id
            ).length;
            const dims = parseDims(node.dimensions);
            return (
              <div
                key={node.id}
                role="listitem"
                style={S.hubCard(false)}
                onClick={() => setSelectedGraphId(node.id)}
                aria-label={`Node: ${node.title}, ${edgeCount} connections`}
              >
                <div style={S.hubTitle}>{node.title}</div>
                <div style={S.hubMeta}>
                  <span><span style={S.edgeDot} />{edgeCount} connections</span>
                  {dims.slice(0, 2).map((d) => (
                    <span key={d} style={S.dimBadge}>{d}</span>
                  ))}
                </div>
                {node.description && (
                  <div style={{ fontSize: '12px', color: '#6b6b6b', lineHeight: '1.4' }}>
                    {node.description}
                  </div>
                )}
              </div>
            );
          })}

          {/* Selected node + connections */}
          {!isLoadingGraph && selectedNode && (
            <>
              <div style={{ ...S.hubCard(true), cursor: 'default' }}>
                <div style={S.hubTitle}>{selectedNode.title}</div>
                {selectedNode.description && (
                  <div style={{ fontSize: '13px', color: '#9b9b9b', lineHeight: '1.5', marginTop: '4px' }}>
                    {selectedNode.description}
                  </div>
                )}
                {selectedNode.dimensions && (
                  <div style={{ ...S.dimBadges, marginTop: '8px' }}>
                    {parseDims(selectedNode.dimensions).map((d) => (
                      <span key={d} style={S.dimBadge}>{d}</span>
                    ))}
                  </div>
                )}
              </div>

              {connections.length > 0 && (
                <div style={{ fontSize: '12px', color: '#6b6b6b', padding: '4px 2px' }}>
                  {connections.length} connection{connections.length !== 1 ? 's' : ''}
                </div>
              )}

              <div style={S.connectionList}>
                {connections.map((edge) => {
                  const neighborId = edge.from_node_id === selectedGraphId ? edge.to_node_id : edge.from_node_id;
                  const neighbor = allGraphNodes[neighborId];
                  const direction = edge.from_node_id === selectedGraphId ? '→' : '←';
                  return (
                    <div
                      key={edge.id}
                      style={S.connectionItem}
                      onClick={() => setSelectedGraphId(neighborId)}
                      role="button"
                      aria-label={`Connected to ${neighbor?.title || `Node ${neighborId}`}`}
                    >
                      <div style={S.connectionTitle}>
                        {direction} {neighbor?.title || `Node ${neighborId}`}
                      </div>
                      {edge.context?.explanation && (
                        <div style={S.connectionRel}>{edge.context.explanation}</div>
                      )}
                    </div>
                  );
                })}
              </div>
            </>
          )}
        </div>
      </div>
    );
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      return <div style={S.errorBanner} role="alert">Graph render error: {msg}</div>;
    }
  };

  const tabContent: Record<Tab, () => React.ReactNode> = {
    chat: renderChat,
    save: renderSave,
    search: renderSearch,
    graph: renderGraph,
  };

  // ─── Layout ─────────────────────────────────────────────────────────────────

  return (
    <div style={{ ...S.root, flexDirection: isDesktop ? 'row' : 'column' }}>
      {/* Android: native install prompt */}
      {installPrompt && (
        <div
          role="banner"
          style={{
            position: 'fixed',
            bottom: isDesktop ? '16px' : 'calc(68px + env(safe-area-inset-bottom))',
            left: '50%',
            transform: 'translateX(-50%)',
            width: 'calc(100% - 32px)',
            maxWidth: '400px',
            background: '#151515',
            border: '1px solid #1a1a1a',
            borderRadius: '12px',
            padding: '12px 16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
            zIndex: 100,
            fontSize: '14px',
          }}
        >
          <span style={{ color: '#e5e5e5', lineHeight: '1.4' }}>
            Add RA-H to your home screen
          </span>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              onClick={async () => {
                await installPrompt.prompt();
                const { outcome } = await installPrompt.userChoice;
                if (outcome === 'accepted') setInstallPrompt(null);
              }}
              style={{
                background: '#e5e5e5',
                color: '#0a0a0a',
                border: 'none',
                borderRadius: '8px',
                padding: '8px 14px',
                cursor: 'pointer',
                fontFamily: 'inherit',
                fontSize: '14px',
                fontWeight: 600,
                minHeight: '44px',
              }}
              aria-label="Install RA-H app"
            >
              Install
            </button>
            <button
              onClick={() => setInstallPrompt(null)}
              style={{
                background: 'transparent',
                border: 'none',
                color: '#6b6b6b',
                cursor: 'pointer',
                fontSize: '18px',
                minHeight: '44px',
                minWidth: '44px',
                padding: '0',
              }}
              aria-label="Dismiss install prompt"
            >
              ✕
            </button>
          </div>
        </div>
      )}

      {/* iOS: manual Add to Home Screen instruction */}
      {showIOSPrompt && (
        <div
          role="banner"
          style={{
            position: 'fixed',
            bottom: isDesktop ? '16px' : 'calc(68px + env(safe-area-inset-bottom))',
            left: '50%',
            transform: 'translateX(-50%)',
            width: 'calc(100% - 32px)',
            maxWidth: '400px',
            background: '#151515',
            border: '1px solid #1a1a1a',
            borderRadius: '12px',
            padding: '12px 16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
            zIndex: 100,
            fontSize: '14px',
          }}
        >
          <span style={{ color: '#e5e5e5', lineHeight: '1.4' }}>
            Install: tap <strong>Share</strong> then <strong>Add to Home Screen</strong>
          </span>
          <button
            onClick={() => setShowIOSPrompt(false)}
            style={{
              background: 'transparent',
              border: 'none',
              color: '#6b6b6b',
              cursor: 'pointer',
              fontSize: '18px',
              minHeight: '44px',
              minWidth: '44px',
              padding: '0',
            }}
            aria-label="Dismiss install prompt"
          >
            ✕
          </button>
        </div>
      )}
      {/* Side nav (desktop) / Bottom nav (mobile) */}
      <nav
        style={S.nav(isDesktop)}
        aria-label="RA-H Command Center navigation"
      >
        {isDesktop && (
          <div style={S.navBrand}>RA-H</div>
        )}
        {TABS.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            style={S.navTab(activeTab === tab.id, isDesktop)}
            aria-label={`${tab.label} tab`}
            aria-current={activeTab === tab.id ? 'page' : undefined}
          >
            <span aria-hidden="true">{tab.icon}</span>
            <span style={S.navTabLabel(isDesktop)}>{tab.label}</span>
          </button>
        ))}
      </nav>

      {/* Main content */}
      <main
        style={S.main(isDesktop)}
        aria-label={`${TABS.find((t) => t.id === activeTab)?.label} panel`}
      >
        {isDesktop && (
          <div style={S.sectionTitle}>
            {TABS.find((t) => t.id === activeTab)?.label}
          </div>
        )}
        <div style={{ display: 'flex', flexDirection: 'column', flex: 1, overflow: 'hidden' }}>
          {tabContent[activeTab]()}
        </div>
      </main>
    </div>
  );
}
