import React, { useMemo } from 'react';
import { getReflectionForDate } from '@/lib/reflections';

interface DailyReflectionProps {
  currentDate: Date;
}

/**
 * Rotating daily reflection shown at the bottom of the Today page.
 *
 * Intentionally uses only the curated scripture/saints list — the lectionary
 * verse from the remote API is already surfaced inside the Bible Reading
 * prayer card, so repeating it here would show duplicate content.
 *
 * The pick is deterministic by date, so the same quote always appears for
 * the same day across reloads and devices.
 */
export function DailyReflection({ currentDate }: DailyReflectionProps) {
  const reflection = useMemo(() => getReflectionForDate(currentDate), [currentDate]);

  return (
    <div className="text-center pt-6 pb-4">
      <p className="font-headline italic text-on-surface-variant text-lg opacity-70 leading-snug">
        "{reflection.text}"
      </p>
      <p className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant/50 mt-2">
        — {reflection.citation}
      </p>
    </div>
  );
}
