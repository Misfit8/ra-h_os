import { Suspense } from 'react';
import ChatClient from './ChatClient';

export const metadata = {
  title: 'RA-H Command Center',
  description: 'Chat with your knowledge graph',
};

export default function ChatPage() {
  return (
    <Suspense
      fallback={
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            height: '100dvh',
            background: '#0a0a0a',
            color: '#6b6b6b',
            fontFamily: "'Geist', 'Inter', -apple-system, sans-serif",
            fontSize: '16px',
          }}
        >
          Loading...
        </div>
      }
    >
      <ChatClient />
    </Suspense>
  );
}
