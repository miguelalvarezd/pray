import React, { useState, useMemo } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameMonth, addMonths, subMonths, isToday, parseISO, differenceInDays } from 'date-fns';
import { ChevronLeft, ChevronRight, BookHeart } from 'lucide-react';
import { motion } from 'motion/react';
import { DailyLog, Prayer, Novena } from '@/types';
import { cn } from '@/lib/utils';
import { getIcon } from '@/lib/icons';

interface HistoryProps {
  logs: Record<string, DailyLog>;
  prayers: Prayer[];
  novenas: Novena[];
  currentDate: Date;
}

const stagger = {
  hidden: {},
  show: { transition: { staggerChildren: 0.04 } },
};

const slideIn = {
  hidden: { opacity: 0, y: 16 },
  show: { opacity: 1, y: 0, transition: { duration: 0.3 } },
};

export function History({ logs, prayers, novenas, currentDate }: HistoryProps) {
  const [currentMonth, setCurrentMonth] = useState(startOfMonth(currentDate));

  const handlePrevMonth = () => setCurrentMonth((prev) => subMonths(prev, 1));
  const handleNextMonth = () => setCurrentMonth((prev) => addMonths(prev, 1));
  const canGoNext = !isSameMonth(currentMonth, currentDate) && addMonths(currentMonth, 1) <= currentDate;

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
        <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">Your Journey</p>
        <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">
          Your Journey of<br/><span className="italic text-secondary">Devotion</span>
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

      <motion.div
        key={format(currentMonth, 'yyyy-MM')}
        variants={stagger}
        initial="hidden"
        animate="show"
        className="space-y-4 flex flex-col"
      >
        {days.length === 0 ? (
          <div className="text-center py-16 text-on-surface-variant">
            <p className="font-body italic">No history for this month.</p>
          </div>
        ) : (
          days.map((day) => {
            const dayStr = format(day, 'yyyy-MM-dd');
            const log = logs[dayStr];
            const completed = log?.completedPrayers?.length || 0;
            const total = prayers.length;
            const isCurrentDay = isToday(day);
            const pct = total > 0 ? Math.round((completed / total) * 100) : 0;

            const activeNovenasForDay = novenas.filter(n => {
              const days = differenceInDays(day, parseISO(n.startDate));
              return days >= 0 && days <= 8;
            });

            return (
              <motion.div
                key={dayStr}
                variants={slideIn}
                className={cn(
                  "rounded-[2rem] p-6 transition-all",
                  isCurrentDay
                    ? "bg-secondary-container"
                    : "bg-surface-container-lowest shadow-ambient-sm"
                )}
              >
                <div className="flex items-center justify-between mb-3">
                  <div>
                    <p className="font-headline text-lg text-on-surface">{format(day, 'EEEE')}</p>
                    <p className="font-label text-[10px] uppercase tracking-[0.1em] text-on-surface-variant">{format(day, 'MMMM d, yyyy')}</p>
                  </div>
                  <span className={cn(
                    "font-headline text-2xl font-semibold",
                    pct === 100 ? "text-secondary" : pct > 0 ? "text-primary" : "text-outline-variant"
                  )}>
                    {pct}%
                  </span>
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
                      return (
                        <div key={prayer.id} title={prayer.title} className={cn(
                          "w-10 h-10 rounded-full flex items-center justify-center transition-colors",
                          isDone ? "bg-secondary text-on-secondary shadow-ambient-sm" : "bg-surface-container text-on-surface-variant opacity-40"
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
              </motion.div>
            );
          })
        )}
      </motion.div>
    </div>
  );
}
