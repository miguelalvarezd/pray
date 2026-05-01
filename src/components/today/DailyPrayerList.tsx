import React, { useState, useEffect } from 'react';
import { Check, ChevronUp, ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { DailyLog, Prayer } from '@/types';
import { cn, getThemeClasses } from '@/lib/utils';
import { getIcon } from '@/lib/icons';
import { getDynamicPrayers } from '@/lib/api';

interface DailyPrayerListProps {
  prayers: Prayer[];
  log: DailyLog;
  currentDate: Date;
  onToggle: (id: string) => void;
}

/**
 * The main prayer checklist. Pulls dynamic content (readings, mysteries,
 * saint of the day) via getDynamicPrayers whenever the date or underlying
 * prayer list changes.
 */
export function DailyPrayerList({
  prayers,
  log,
  currentDate,
  onToggle,
}: DailyPrayerListProps) {
  const [dynamicPrayers, setDynamicPrayers] = useState<Prayer[]>(prayers);
  const [expanded, setExpanded] = useState<string[]>([]);

  useEffect(() => {
    let cancelled = false;
    getDynamicPrayers(prayers, currentDate).then((result) => {
      if (!cancelled) setDynamicPrayers(result);
    });
    return () => {
      cancelled = true;
    };
  }, [prayers, currentDate]);

  const toggleExpanded = (id: string) =>
    setExpanded((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );

  return (
    <section className="space-y-4">
      <h2 className="font-headline text-2xl font-medium">Daily Prayers</h2>
      <div className="space-y-3">
        <AnimatePresence mode="popLayout">
          {dynamicPrayers.map((prayer, i) => {
            const isCompleted = log.completedPrayers.includes(prayer.id);
            const isExpanded = expanded.includes(prayer.id);
            const isAltRow = i % 2 === 0;
            const theme = getThemeClasses(prayer.themeColor, isCompleted, isAltRow);
            const hasSections = prayer.sections && prayer.sections.length > 0;

            return (
              <motion.div
                key={prayer.id}
                layout
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
                className={cn(
                  'flex flex-col w-full rounded-4xl overflow-hidden transition-all duration-300',
                  theme.bg
                )}
              >
                <div
                  role="button"
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' || e.key === ' ') {
                      e.preventDefault();
                      toggleExpanded(prayer.id);
                    }
                  }}
                  onClick={() => toggleExpanded(prayer.id)}
                  className="flex w-full cursor-pointer items-center justify-between p-5 text-left active:scale-[0.98] transition-transform"
                >
                  <div className="flex items-center gap-5">
                    <div
                      className={cn(
                        'w-12 h-12 rounded-full flex items-center justify-center transition-colors shrink-0',
                        theme.iconBg
                      )}
                    >
                      {getIcon(prayer.icon)}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <p
                          className={cn(
                            'font-headline text-lg text-on-surface',
                            isCompleted && 'line-through opacity-60'
                          )}
                        >
                          {prayer.title}
                        </p>
                      </div>
                      <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">
                        {prayer.subtitle || 'Daily Practice'}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-4">
                    {hasSections &&
                      (isExpanded ? (
                        <ChevronUp className="h-5 w-5 text-on-surface-variant" />
                      ) : (
                        <ChevronDown className="h-5 w-5 text-on-surface-variant" />
                      ))}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onToggle(prayer.id);
                      }}
                      aria-label={isCompleted ? 'Mark incomplete' : 'Mark complete'}
                      className={cn(
                        'w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all border-2',
                        theme.checkBorder
                      )}
                    >
                      {isCompleted && (
                        <Check className={cn('h-4 w-4', theme.checkIcon)} strokeWidth={3} />
                      )}
                    </button>
                  </div>
                </div>

                <AnimatePresence initial={false}>
                  {isExpanded && prayer.sections && (
                    <motion.div
                      initial={{ height: 0 }}
                      animate={{ height: 'auto' }}
                      exit={{ height: 0 }}
                      transition={{ duration: 0.3, ease: 'easeInOut' }}
                      className="overflow-hidden border-t border-outline-variant/10"
                    >
                      <div className="px-5 pb-6 pt-4 space-y-6">
                        {prayer.sections.map((section, idx) => (
                          <div key={idx} className="space-y-2">
                            <h4 className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant font-semibold">
                              {section.title}
                            </h4>
                            {section.content && (
                              <p className="font-headline text-lg text-on-surface leading-snug whitespace-pre-line">
                                {section.content}
                              </p>
                            )}
                            {section.items && (
                              <ul className="space-y-3 mt-3">
                                {section.items.map((item, itemIdx) => (
                                  <li key={itemIdx} className="flex items-start gap-3">
                                    {item.icon && (
                                      <div className="mt-0.5 text-on-surface-variant opacity-70">
                                        {getIcon(item.icon, 14)}
                                      </div>
                                    )}
                                    <span className="font-body text-sm text-on-surface-variant leading-relaxed">
                                      {item.text}
                                    </span>
                                  </li>
                                ))}
                              </ul>
                            )}
                          </div>
                        ))}
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
