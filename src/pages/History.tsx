import React, { useState, useMemo } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameMonth, addMonths, subMonths, isSameDay, parseISO, differenceInDays } from 'date-fns';
import { ChevronLeft, ChevronRight, BookHeart, ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { DailyLog, Prayer, Novena, DEFAULT_EXTRA_ACTIVITIES } from '@/types';
import { cn, getThemeClasses } from '@/lib/utils';
import { getIcon } from '@/lib/icons';
import { getLiturgicalColorSync } from '@/lib/api';

interface HistoryProps {
  logs: Record<string, DailyLog>;
  prayers: Prayer[];
  novenas: Novena[];
  currentDate: Date;
}

export function History({ logs, prayers, novenas, currentDate }: HistoryProps) {
  const [currentMonth, setCurrentMonth] = useState(startOfMonth(currentDate));

  const handlePrevMonth = () => setCurrentMonth((prev) => subMonths(prev, 1));
  const handleNextMonth = () => setCurrentMonth((prev) => addMonths(prev, 1));
  const canGoNext = !isSameMonth(currentMonth, currentDate) && addMonths(currentMonth, 1) <= currentDate;

  const [expandedDay, setExpandedDay] = useState<string | null>(null);

  const days = useMemo(() => {
    const start = startOfMonth(currentMonth);
    const end = endOfMonth(currentMonth) > currentDate ? currentDate : endOfMonth(currentMonth);
    if (end < start) return [];
    return eachDayOfInterval({ start, end }).reverse();
  }, [currentMonth, currentDate]);

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto">
      {/* Editorial Header */}
      <header className="space-y-2 pl-1">
        <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">He who began a good work will carry it on</p>
        <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">
          Your Journey of<br /><span className="italic text-secondary">Devotion</span>
        </h1>
      </header>

      {/* Month Navigator */}
      <div className="flex items-center justify-between">
        <h2 className="font-headline text-2xl text-on-surface">{format(currentMonth, 'MMMM yyyy')}</h2>
        <div className="flex gap-2">
          <button className="w-10 h-10 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors active:scale-95" onClick={handlePrevMonth}>
            <ChevronLeft className="h-5 w-5 text-on-surface-variant" />
          </button>
          <button className="w-10 h-10 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors active:scale-95 disabled:opacity-40" onClick={handleNextMonth} disabled={!canGoNext}>
            <ChevronRight className="h-5 w-5 text-on-surface-variant" />
          </button>
        </div>
      </div>

      <div className="space-y-4 flex flex-col">
        <AnimatePresence mode="popLayout">
          {days.length === 0 ? (
            <motion.div
              key="empty-state"
              layout
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
              transition={{ duration: 0.0 }}
              className="text-center py-16 text-on-surface-variant"
            >
              <p className="font-body italic">No history for this month.</p>
            </motion.div>
          ) : (
            days.map((day) => {
              const dayStr = format(day, 'yyyy-MM-dd');
              const log = logs[dayStr];
              const completed = log?.completedPrayers?.length || 0;
              const total = prayers.length;
              const isCurrentDay = isSameDay(day, currentDate);
              const pct = total > 0 ? Math.round((completed / total) * 100) : 0;

              const activeNovenasForDay = novenas.filter(n => {
                const days = differenceInDays(day, parseISO(n.startDate));
                return days >= 0 && days <= 8;
              });

              return (
                <motion.div
                  key={dayStr}
                  layout
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
                  transition={{ duration: 0.0 }}
                  className={cn(
                    "rounded-4xl overflow-hidden transition-all",
                    isCurrentDay
                      ? "bg-secondary-container"
                      : "bg-surface-container-lowest shadow-ambient-sm"
                  )}
                >
                  <div
                    className={cn("p-6", log?.journal && "cursor-pointer")}
                    onClick={() => log?.journal && setExpandedDay(expandedDay === dayStr ? null : dayStr)}
                  >
                    <div className="flex items-center justify-between mb-3">
                      <div>
                        <p className="font-headline text-lg text-on-surface">{format(day, 'EEEE')}</p>
                        <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">{format(day, 'MMMM d, yyyy')}</p>
                      </div>
                      <div className="flex items-center gap-4">
                        {log?.journal && (
                          <motion.div animate={{ rotate: expandedDay === dayStr ? 180 : 0 }} transition={{ duration: 0.2 }}>
                            <ChevronDown className="h-5 w-5 text-on-surface-variant" />
                          </motion.div>
                        )}
                        <span className={cn(
                          "font-headline text-2xl font-semibold",
                          pct === 100 ? "text-secondary" : pct > 0 ? "text-primary" : "text-outline-variant"
                        )}>
                          {pct}%
                        </span>
                      </div>
                    </div>

                    {/* Progress bar */}
                    <div className="h-1.5 w-full bg-surface-container-high rounded-full overflow-hidden">
                      <motion.div
                        className={cn(
                          "h-full rounded-full",
                          pct === 100 ? "bg-secondary" : "bg-primary"
                        )}
                        initial={{ width: 0 }}
                        animate={{ width: `${pct}%` }}
                        transition={{ duration: 0.8, delay: 0.1, ease: "easeOut" }}
                      />
                    </div>
                    {/* Tasks & Novenas */}
                    {(completed > 0 || activeNovenasForDay.length > 0) && (
                      <div className="flex flex-wrap gap-2 mt-4">
                        {/* Standard Prayers */}
                        {prayers.map(prayer => {
                          const isDone = log?.completedPrayers?.includes(prayer.id);

                          let historyColor = prayer.themeColor;
                          if (prayer.id === 'mass') {
                            historyColor = getLiturgicalColorSync(dayStr) || historyColor;
                          }

                          const theme = getThemeClasses(historyColor, isDone, false);

                          return (
                            <div key={prayer.id} title={prayer.title} className={cn(
                              "w-10 h-10 rounded-full flex items-center justify-center transition-all",
                              isDone ? cn(theme.iconBg, "shadow-ambient-sm") : "bg-surface-container text-on-surface-variant opacity-40"
                            )}>
                              {getIcon(prayer.icon, 20)}
                            </div>
                          );
                        })}
                        {/* Novenas */}
                        {activeNovenasForDay.map(novena => {
                          const isDone = log?.completedNovenas?.includes(novena.id);
                          return (
                            <div key={novena.id} title={novena.title} className={cn(
                              "w-10 h-10 rounded-full flex items-center justify-center transition-colors",
                              isDone ? "bg-tertiary text-on-tertiary shadow-ambient-sm" : "bg-surface-container text-on-surface-variant opacity-40"
                            )}>
                              <BookHeart className="h-5 w-5" />
                            </div>
                          );
                        })}
                      </div>
                    )}
                    {/* Extra Activities */}
                    {log?.completedActivities && log.completedActivities.length > 0 && (
                      <div className="flex flex-wrap gap-1.5 mt-4">
                        {log.completedActivities.map(actId => {
                          const activity = DEFAULT_EXTRA_ACTIVITIES.find(a => a.id === actId);
                          if (!activity) return null;
                          return (
                            <div key={actId} title={activity.name} className="flex items-center gap-1.5 rounded-full bg-primary-container/60 text-on-primary-container px-2.5 py-1.5">
                              <span className="shrink-0 opacity-70 [&>svg]:h-3 [&>svg]:w-3">{getIcon(activity.icon)}</span>
                              <span className="font-label text-[9px] tracking-wide">{activity.name}</span>
                            </div>
                          );
                        })}
                      </div>
                    )}
                  </div>
                  {/* Journal expansion */}
                  <AnimatePresence>
                    {expandedDay === dayStr && log?.journal && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.25, ease: 'easeInOut' }}
                        className="border-t border-outline-variant/10"
                      >
                        <p className="px-6 py-5 font-body text-sm text-on-surface-variant leading-relaxed whitespace-pre-wrap">
                          {log.journal}
                        </p>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              );
            })
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
