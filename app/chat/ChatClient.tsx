'use client';

import { useState, useEffect, useRef, useCallback, FormEvent } from 'react';
import { useSearchParams } from 'next/navigation';

// ─── PWA helpers ─────────────────────────────────────────────────────────────

function registerServiceWorker() {
  if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js').catch((err) => {
      console.error('[SW] Registration failed:', err);
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

// ─── Constants ────────────────────────────────────────────────────────────────

const BOOKMARKLET_URL =
  "javascript:(function(){var t=encodeURIComponent(document.title),u=encodeURIComponent(window.location.href);window.open('https://ra-hos-production.up.railway.app/chat?tab=save&url='+u+'&title='+t,'_blank');})();";

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
    height: isDesktop ? '100%' : '60px',
    borderRight: isDesktop ? '1px solid #1a1a1a' : 'none',
    borderTop: isDesktop ? 'none' : '1px solid #1a1a1a',
    background: '#0a0a0a',
    order: isDesktop ? 0 : 2,
    paddingTop: isDesktop ? '16px' : 0,
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

  const initialTab = (searchParams.get('tab') as Tab) || 'chat';
  const initialUrl = searchParams.get('url') || '';
  const initialTitle = searchParams.get('title') || '';

  const [activeTab, setActiveTab] = useState<Tab>(initialTab);
  const [isDesktop, setIsDesktop] = useState(false);
  const [showIOSPrompt, setShowIOSPrompt] = useState(false);

  // Chat state
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Save state
  const [saveForm, setSaveForm] = useState<SaveForm>({
    title: initialTitle,
    description: '',
    content: '',
    url: initialUrl,
    type: 'research',
  });
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState<string | null>(null);
  const [saveError, setSaveError] = useState<string | null>(null);

  // Responsive detection + SW registration + iOS prompt
  useEffect(() => {
    const mq = window.matchMedia('(min-width: 768px)');
    setIsDesktop(mq.matches);
    const handler = (e: MediaQueryListEvent) => setIsDesktop(e.matches);
    mq.addEventListener('change', handler);

    registerServiceWorker();

    if (isIOS()) {
      setShowIOSPrompt(true);
    }

    return () => mq.removeEventListener('change', handler);
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
    <div style={S.stub} aria-label="Search — coming soon">
      <div style={S.stubIcon}>🔍</div>
      <div style={S.stubText}>Search — coming soon</div>
      <div style={{ fontSize: '14px', color: '#6b6b6b', maxWidth: '260px', textAlign: 'center' }}>
        Full semantic search across your knowledge graph will live here.
      </div>
    </div>
  );

  const renderGraph = () => (
    <div style={S.stub} aria-label="Graph — coming soon">
      <div style={S.stubIcon}>🕸️</div>
      <div style={S.stubText}>Graph — coming soon</div>
      <div style={{ fontSize: '14px', color: '#6b6b6b', maxWidth: '260px', textAlign: 'center' }}>
        Interactive knowledge graph visualization will live here.
      </div>
    </div>
  );

  const tabContent: Record<Tab, () => React.ReactNode> = {
    chat: renderChat,
    save: renderSave,
    search: renderSearch,
    graph: renderGraph,
  };

  // ─── Layout ─────────────────────────────────────────────────────────────────

  return (
    <div style={{ ...S.root, flexDirection: isDesktop ? 'row' : 'column' }}>
      {showIOSPrompt && (
        <div
          role="banner"
          style={{
            position: 'fixed',
            bottom: isDesktop ? '16px' : '72px',
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
