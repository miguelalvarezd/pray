import React, { useState, useEffect } from 'react';
import { format, parseISO, differenceInDays } from 'date-fns';
import { Check, BookHeart, ChevronUp, ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { DailyLog, Intention, Novena, Prayer, DEFAULT_PRAYERS } from '@/types';
import { cn, getThemeClasses } from '@/lib/utils';
import { sortIntentions } from '@/lib/intentions';
import { getIcon } from '@/lib/icons';

interface TodayProps {
  log: DailyLog;
  updateLog: (log: DailyLog) => void;
  intentions: Intention[];
  novenas: Novena[];
  prayers: Prayer[];
  currentDate: Date;
}


export function Today({ log, updateLog, intentions, novenas, prayers, currentDate }: TodayProps) {
  const todayStr = format(currentDate, 'EEEE, MMMM do');
  const [expandedPrayers, setExpandedPrayers] = useState<string[]>([]);
  const [dynamicPrayers, setDynamicPrayers] = useState<Prayer[]>(prayers);
  const [journalDraft, setJournalDraft] = useState(log.journal || '');

  useEffect(() => {
    import('@/lib/api').then(({ getDynamicPrayers }) => {
      getDynamicPrayers(prayers, currentDate).then(setDynamicPrayers);
    });
  }, [prayers, currentDate]);

  useEffect(() => {
    setJournalDraft(log.journal || '');
  }, [log.date]);

  const togglePrayer = (id: string) => {
    const isCompleted = log.completedPrayers.includes(id);
    updateLog({
      ...log,
      completedPrayers: isCompleted
        ? log.completedPrayers.filter((p) => p !== id)
        : [...log.completedPrayers, id],
    });
  };

  const toggleIntention = (id: string) => {
    const isCompleted = log.completedIntentions.includes(id);
    updateLog({
      ...log,
      completedIntentions: isCompleted
        ? log.completedIntentions.filter((i) => i !== id)
        : [...log.completedIntentions, id],
    });
  };

  const toggleNovena = (id: string) => {
    const completedNovenas = log.completedNovenas || [];
    const isCompleted = completedNovenas.includes(id);
    updateLog({
      ...log,
      completedNovenas: isCompleted
        ? completedNovenas.filter((n) => n !== id)
        : [...completedNovenas, id],
    });
  };

  const activeIntentions = sortIntentions(
    intentions.filter((i) => !i.isArchived),
    currentDate
  ).slice(0, 5);

  const activeNovenas = novenas.filter(novena => {
    const startDate = parseISO(novena.startDate);
    const dayOfNovena = differenceInDays(currentDate, startDate) + 1;
    return dayOfNovena >= 1 && dayOfNovena <= 9;
  });

  // Streak calculation
  const completedCount = log.completedPrayers.length + (log.completedNovenas?.length || 0);
  const totalCount = prayers.length + activeNovenas.length;

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto">
      {/* Editorial Header */}
      <header className="space-y-2 pl-1">
        <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">{todayStr}</p>
        <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">
          Today's <br /><span className="italic text-primary">Intentions</span>
        </h1>
      </header>

      {/* Streak Indicator */}
      {totalCount > 0 && (
        <div className="flex items-center gap-4">
          <div className="flex-1">
            <div className="grid grid-cols-7 gap-1.5">
              {Array.from({ length: totalCount }, (_, i) => (
                <div
                  key={i}
                  className={cn(
                    'h-1 rounded-full transition-all duration-500',
                    i < completedCount ? 'bg-primary' : 'bg-surface-container-high'
                  )}
                  style={{ opacity: i < completedCount ? Math.min(0.4 + (i / totalCount) * 0.6, 1) : 1 }}
                />
              ))}
            </div>
          </div>
          <span className="font-label text-xs text-on-surface-variant uppercase tracking-wider">
            {completedCount}/{totalCount}
          </span>
        </div>
      )}

      {/* Active Novenas */}
      {activeNovenas.length > 0 && (
        <section className="space-y-4">
          <h2 className="font-headline text-2xl font-medium">Active Novenas</h2>
          <div className="space-y-3">
            <AnimatePresence mode="popLayout">
              {activeNovenas.map((novena) => {
                const completedNovenas = log.completedNovenas || [];
                const isCompleted = completedNovenas.includes(novena.id);
                const startDate = parseISO(novena.startDate);
                const dayOfNovena = differenceInDays(currentDate, startDate) + 1;

                return (
                  <motion.button
                    key={novena.id}
                    layout
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
                    transition={{ duration: 0.0 }}
                    whileTap={{ scale: 0.97 }}
                    onClick={() => toggleNovena(novena.id)}
                    className={cn(
                      'flex w-full items-center justify-between rounded-[2rem] p-5 text-left transition-all duration-300',
                      isCompleted
                        ? 'bg-tertiary-container'
                        : 'bg-surface-container-lowest shadow-ambient-sm'
                    )}
                  >
                    <div className="flex items-center gap-5 pr-4">
                      <div className={cn(
                        "w-12 h-12 rounded-full flex items-center justify-center shrink-0 transition-colors",
                        isCompleted ? "bg-tertiary text-on-tertiary" : "bg-tertiary-container text-tertiary"
                      )}>
                        <BookHeart className="h-5 w-5" />
                      </div>
                      <div className="flex flex-col">
                        <span className={cn("font-headline text-lg text-on-surface", isCompleted && "line-through opacity-60")}>
                          {novena.title}
                        </span>
                        <span className="font-label text-[10px] uppercase tracking-[0.1em] text-on-surface-variant">
                          Day {dayOfNovena} of 9 • {novena.intention}
                        </span>
                      </div>
                    </div>
                    <div className={cn(
                      "w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all border-2",
                      isCompleted
                        ? "bg-tertiary border-tertiary"
                        : "border-outline-variant"
                    )}>
                      {isCompleted && <Check className="h-4 w-4 text-on-tertiary" strokeWidth={3} />}
                    </div>
                  </motion.button>
                );
              })}
            </AnimatePresence>
          </div>
        </section>
      )}

      {/* Daily Prayers */}
      <section className="space-y-4">
        <h2 className="font-headline text-2xl font-medium">Daily Prayers</h2>
        <div className="space-y-3">
          <AnimatePresence mode="popLayout">
            {dynamicPrayers.map((prayer, i) => {
              const isCompleted = log.completedPrayers.includes(prayer.id);
              const isExpanded = expandedPrayers.includes(prayer.id);
              const isAltRow = i % 2 === 0;

              const theme = getThemeClasses(prayer.themeColor, isCompleted, isAltRow);

              return (
                <motion.div
                  key={prayer.id}
                  layout
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
                  transition={{ duration: 0.0 }}
                  className={cn(
                    'flex flex-col w-full rounded-[2rem] overflow-hidden transition-all duration-300',
                    theme.bg
                  )}
                >
                  {/* Header (clickable to expand) */}
                  <div
                    role="button"
                    tabIndex={0}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' || e.key === ' ') {
                        e.preventDefault();
                        setExpandedPrayers(prev => prev.includes(prayer.id) ? prev.filter(p => p !== prayer.id) : [...prev, prayer.id]);
                      }
                    }}
                    onClick={() => setExpandedPrayers(prev => prev.includes(prayer.id) ? prev.filter(p => p !== prayer.id) : [...prev, prayer.id])}
                    className="flex w-full cursor-pointer items-center justify-between p-5 text-left active:scale-[0.98] transition-transform"
                  >
                    <div className="flex items-center gap-5">
                      <div className={cn(
                        "w-12 h-12 rounded-full flex items-center justify-center transition-colors shrink-0",
                        theme.iconBg
                      )}>
                        {getIcon(prayer.icon)}
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <p className={cn("font-headline text-lg text-on-surface", isCompleted && "line-through opacity-60")}>
                            {prayer.title}
                          </p>
                        </div>
                        <p className="font-label text-[10px] uppercase tracking-[0.1em] text-on-surface-variant">
                          {prayer.subtitle || 'Daily Practice'}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-4">
                      {prayer.sections && prayer.sections.length > 0 && (
                        isExpanded ? <ChevronUp className="h-5 w-5 text-on-surface-variant" /> : <ChevronDown className="h-5 w-5 text-on-surface-variant" />
                      )}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          togglePrayer(prayer.id);
                        }}
                        className={cn(
                          "w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all border-2",
                          theme.checkBorder
                        )}
                      >
                        {isCompleted && <Check className={cn("h-4 w-4", theme.checkIcon)} strokeWidth={3} />}
                      </button>
                    </div>
                  </div>

                  {/* Expanded Content */}
                  <AnimatePresence>
                    {isExpanded && prayer.sections && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.3, ease: 'easeInOut' }}
                        className="px-5 pb-6 border-t border-outline-variant/10 pt-4"
                      >
                        <div className="space-y-6">
                          {prayer.sections.map((section, idx) => (
                            <div key={idx} className="space-y-2">
                              <h4 className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant font-semibold">
                                {section.title}
                              </h4>
                              {section.content && (
                                <p className="font-headline text-lg text-on-surface leading-snug">
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

      {/* Top Intentions */}
      <section className="space-y-4">
        <h2 className="font-headline text-2xl font-medium">Intentions</h2>
        {activeIntentions.length === 0 ? (
          <p className="text-sm text-on-surface-variant py-8 text-center font-body italic">No active intentions.</p>
        ) : (
          <div className="space-y-3">
            <AnimatePresence mode="popLayout">
              {activeIntentions.map((intention) => {
                const isCompleted = log.completedIntentions.includes(intention.id);
                return (
                  <motion.button
                    key={intention.id}
                    layout
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
                    transition={{ duration: 0.0 }}
                    whileTap={{ scale: 0.97 }}
                    onClick={() => toggleIntention(intention.id)}
                    className={cn(
                      'flex w-full items-center justify-between rounded-[2rem] p-5 text-left transition-all duration-300',
                      isCompleted
                        ? 'bg-secondary-container'
                        : 'bg-surface-container-lowest shadow-ambient-sm'
                    )}
                  >
                    <div className="flex flex-col gap-1 pr-4">
                      <span className={cn("font-headline text-lg text-on-surface", isCompleted && "line-through opacity-60")}>
                        {intention.title}
                      </span>
                      {intention.description && (
                        <span className="font-body text-sm text-on-surface-variant line-clamp-1">
                          {intention.description}
                        </span>
                      )}
                    </div>
                    <div className={cn(
                      "w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all border-2",
                      isCompleted
                        ? "bg-secondary border-secondary"
                        : "border-outline-variant"
                    )}>
                      {isCompleted && <Check className="h-4 w-4 text-on-secondary" strokeWidth={3} />}
                    </div>
                  </motion.button>
                );
              })}
            </AnimatePresence>
          </div>
        )}
      </section>

      {/* Gratitude */}
      <section className="space-y-4">
        <h2 className="font-headline text-2xl font-medium">Gratitude</h2>
        <div className="rounded-[2rem] bg-surface-container-lowest shadow-ambient-sm overflow-hidden">
          <textarea
            value={journalDraft}
            onChange={(e) => setJournalDraft(e.target.value)}
            onBlur={() => updateLog({ ...log, journal: journalDraft })}
            placeholder="What are you grateful for today? What happened?"
            className="w-full bg-transparent p-6 font-body text-sm text-on-surface placeholder:text-on-surface-variant/40 resize-none focus:outline-none min-h-[200px] leading-relaxed"
          />
          {journalDraft && (
            <div className="px-6 pb-4 flex justify-end">
              <span className="font-label text-[10px] uppercase tracking-[0.1em] text-on-surface-variant/50">
                Saved
              </span>
            </div>
          )}
        </div>
      </section>

      {/* Reflection Quote */}
      <div className="text-center pt-6 pb-4">
        <p className="font-headline italic text-on-surface-variant text-lg opacity-50">
          "I am the Way, the Truth, and the Life."
        </p>
      </div>
    </div>
  );
}
