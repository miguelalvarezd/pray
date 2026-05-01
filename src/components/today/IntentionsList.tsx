import React from 'react';
import { Check } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { DailyLog, Intention } from '@/types';
import { cn } from '@/lib/utils';
import { sortIntentions } from '@/lib/intentions';

interface IntentionsListProps {
  intentions: Intention[];
  log: DailyLog;
  currentDate: Date;
  onToggle: (id: string) => void;
}

/**
 * Top 5 active intentions surfaced on the Today page, ordered by urgency.
 */
export function IntentionsList({
  intentions,
  log,
  currentDate,
  onToggle,
}: IntentionsListProps) {
  const active = sortIntentions(
    intentions.filter((i) => !i.isArchived),
    currentDate
  ).slice(0, 5);

  return (
    <section className="space-y-4">
      <h2 className="font-headline text-2xl font-medium">Intentions</h2>
      {active.length === 0 ? (
        <p className="text-sm text-on-surface-variant py-8 text-center font-body italic">
          No active intentions.
        </p>
      ) : (
        <div className="space-y-3">
          <AnimatePresence mode="popLayout">
            {active.map((intention) => {
              const isCompleted = log.completedIntentions.includes(intention.id);
              return (
                <motion.button
                  key={intention.id}
                  layout
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
                  whileTap={{ scale: 0.97 }}
                  onClick={() => onToggle(intention.id)}
                  className={cn(
                    'flex w-full items-center justify-between rounded-4xl p-5 text-left transition-all duration-300',
                    isCompleted
                      ? 'bg-secondary-container'
                      : 'bg-surface-container-lowest shadow-ambient-sm'
                  )}
                >
                  <div className="flex flex-col gap-1 pr-4">
                    <span
                      className={cn(
                        'font-headline text-lg text-on-surface',
                        isCompleted && 'line-through opacity-60'
                      )}
                    >
                      {intention.title}
                    </span>
                    {intention.description && (
                      <span className="font-body text-sm text-on-surface-variant line-clamp-1">
                        {intention.description}
                      </span>
                    )}
                  </div>
                  <div
                    className={cn(
                      'w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all border-2',
                      isCompleted ? 'bg-secondary border-secondary' : 'border-outline-variant'
                    )}
                  >
                    {isCompleted && (
                      <Check className="h-4 w-4 text-on-secondary" strokeWidth={3} />
                    )}
                  </div>
                </motion.button>
              );
            })}
          </AnimatePresence>
        </div>
      )}
    </section>
  );
}
