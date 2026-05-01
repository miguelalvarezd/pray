import React, { useState, useEffect } from 'react';
import { DailyLog } from '@/types';

interface GratitudeJournalProps {
  log: DailyLog;
  onSave: (journal: string) => void;
}

/**
 * Freeform reflection box persisted on blur. Uses a local draft so typing
 * doesn't trigger a localStorage write on every keystroke.
 */
export function GratitudeJournal({ log, onSave }: GratitudeJournalProps) {
  const [draft, setDraft] = useState(log.journal || '');

  useEffect(() => {
    setDraft(log.journal || '');
  }, [log.date]);

  return (
    <section className="space-y-4">
      <h2 className="font-headline text-2xl font-medium">Gratitude</h2>
      <div className="rounded-4xl bg-surface-container-lowest shadow-ambient-sm overflow-hidden">
        <textarea
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onBlur={() => onSave(draft)}
          placeholder="What are you grateful for today? What happened?"
          className="w-full bg-transparent p-6 font-body text-sm text-on-surface placeholder:text-on-surface-variant/40 resize-none focus:outline-none min-h-[200px] leading-relaxed"
        />
        {draft && (
          <div className="px-6 pb-4 flex justify-end">
            <span className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant/50">
              Saved
            </span>
          </div>
        )}
      </div>
    </section>
  );
}
