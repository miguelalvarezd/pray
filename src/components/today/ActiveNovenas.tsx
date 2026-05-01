import React, { useState } from 'react';
import { parseISO, differenceInDays } from 'date-fns';
import { Check, BookHeart, ChevronDown, ChevronUp } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { DailyLog, Novena } from '@/types';
import { cn } from '@/lib/utils';

interface ActiveNovenasProps {
  novenas: Novena[];
  log: DailyLog;
  currentDate: Date;
  onToggle: (id: string) => void;
}

/**
 * Today's active novenas (those between day 1 and day 9 from their start).
 * Each row is tappable to mark complete for the day, and expandable if the
 * novena has a prayer text attached (from the library).
 */
export function ActiveNovenas({
  novenas,
  log,
  currentDate,
  onToggle,
}: ActiveNovenasProps) {
  const [expanded, setExpanded] = useState<string[]>([]);

  const active = novenas.filter((n) => {
    const startDate = parseISO(n.startDate);
    const day = differenceInDays(currentDate, startDate) + 1;
    return day >= 1 && day <= 9;
  });

  if (active.length === 0) return null;

  const toggleExpanded = (id: string) =>
    setExpanded((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );

  return (
    <section className="space-y-4">
      <h2 className="font-headline text-2xl font-medium">Active Novenas</h2>
      <div className="space-y-3">
        <AnimatePresence mode="popLayout">
          {active.map((novena) => {
            const completedNovenas = log.completedNovenas || [];
            const isCompleted = completedNovenas.includes(novena.id);
            const startDate = parseISO(novena.startDate);
            const dayOfNovena = differenceInDays(currentDate, startDate) + 1;
            const isExpanded = expanded.includes(novena.id);
            const hasPrayer = Boolean(novena.prayer);

            return (
              <motion.div
                key={novena.id}
                layout
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
                className={cn(
                  'w-full rounded-4xl overflow-hidden transition-all duration-300',
                  isCompleted
                    ? 'bg-tertiary-container'
                    : 'bg-surface-container-lowest shadow-ambient-sm'
                )}
              >
                <div
                  role="button"
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' || e.key === ' ') {
                      e.preventDefault();
                      if (hasPrayer) toggleExpanded(novena.id);
                    }
                  }}
                  onClick={() => hasPrayer && toggleExpanded(novena.id)}
                  className={cn(
                    'flex items-center justify-between p-5 text-left transition-transform',
                    hasPrayer && 'cursor-pointer active:scale-[0.98]'
                  )}
                >
                  <div className="flex items-center gap-5 pr-4">
                    <div
                      className={cn(
                        'w-12 h-12 rounded-full flex items-center justify-center shrink-0 transition-colors',
                        isCompleted
                          ? 'bg-tertiary text-on-tertiary'
                          : 'bg-tertiary-container text-tertiary'
                      )}
                    >
                      <BookHeart className="h-5 w-5" />
                    </div>
                    <div className="flex flex-col">
                      <span
                        className={cn(
                          'font-headline text-lg text-on-surface',
                          isCompleted && 'line-through opacity-60'
                        )}
                      >
                        {novena.title}
                      </span>
                      <span className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">
                        Day {dayOfNovena} of 9 • {novena.intention}
                      </span>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    {hasPrayer && (
                      isExpanded ? (
                        <ChevronUp className="h-5 w-5 text-on-surface-variant" />
                      ) : (
                        <ChevronDown className="h-5 w-5 text-on-surface-variant" />
                      )
                    )}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onToggle(novena.id);
                      }}
                      className={cn(
                        'w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all border-2',
                        isCompleted
                          ? 'bg-tertiary border-tertiary'
                          : 'border-outline-variant'
                      )}
                      aria-label={isCompleted ? 'Mark incomplete' : 'Mark complete'}
                    >
                      {isCompleted && (
                        <Check className="h-4 w-4 text-on-tertiary" strokeWidth={3} />
                      )}
                    </button>
                  </div>
                </div>

                <AnimatePresence initial={false}>
                  {isExpanded && hasPrayer && (
                    <motion.div
                      initial={{ height: 0 }}
                      animate={{ height: 'auto' }}
                      exit={{ height: 0 }}
                      transition={{ duration: 0.3, ease: 'easeInOut' }}
                      className="overflow-hidden border-t border-outline-variant/10"
                    >
                      <div className="px-5 pb-6 pt-4">
                        <h4 className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant font-semibold mb-2">
                          Prayer for today
                        </h4>
                        <p className="font-body text-sm text-on-surface-variant leading-relaxed whitespace-pre-line">
                          {novena.prayer}
                        </p>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            );
          })}
        </AnimatePresence>
      </div>
    </section>
  );
}
