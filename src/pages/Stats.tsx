import React, { useMemo, useState } from 'react';
import { format, subDays, isSameMonth, startOfMonth, endOfMonth, eachDayOfInterval, parseISO, differenceInDays, subMonths, addMonths } from 'date-fns';
import { motion, AnimatePresence } from 'motion/react';
import { DailyLog, Prayer, Novena } from '@/types';
import { Flame, TrendingUp, ChevronLeft, ChevronRight, X, BookHeart, Sparkles } from 'lucide-react';
import { cn } from '@/lib/utils';

interface StatsProps {
  logs: Record<string, DailyLog>;
  prayers: Prayer[];
  novenas: Novena[];
  currentDate: Date;
}

export function Stats({ logs, prayers, novenas, currentDate }: StatsProps) {
  const [currentMonth, setCurrentMonth] = useState(currentDate);
  const [showStreakDetails, setShowStreakDetails] = useState<'current' | 'best' | null>(null);

  const stats = useMemo(() => {
    const today = currentDate;
    const todayStr = format(today, 'yyyy-MM-dd');
    const yesterdayStr = format(subDays(today, 1), 'yyyy-MM-dd');

    const hasActivity = (dateStr: string) => {
      const log = logs[dateStr];
      return log && ((log.completedPrayers && log.completedPrayers.length > 0) || (log.completedNovenas && log.completedNovenas.length > 0));
    };

    // Current Streak
    let currentStreak = 0;
    let checkDate = today;
    if (hasActivity(todayStr)) {
      currentStreak++;
      checkDate = subDays(today, 1);
    } else if (hasActivity(yesterdayStr)) {
      checkDate = subDays(today, 1);
    } else {
      currentStreak = 0;
    }
    if (currentStreak > 0 || hasActivity(yesterdayStr)) {
      while (true) {
        const dateStr = format(checkDate, 'yyyy-MM-dd');
        if (hasActivity(dateStr)) {
          if (dateStr !== todayStr) currentStreak++;
          checkDate = subDays(checkDate, 1);
        } else break;
      }
    }

    // Longest Streak
    let longestStreak = 0;
    let tempStreak = 0;
    const sortedDates = Object.keys(logs).sort((a, b) => b.localeCompare(a));
    if (sortedDates.length > 0) {
      const chronologicalDates = [...sortedDates].sort((a, b) => a.localeCompare(b));
      let lastDate: Date | null = null;
      chronologicalDates.forEach(dateStr => {
        if (hasActivity(dateStr)) {
          const currentDate = parseISO(dateStr);
          if (!lastDate) { tempStreak = 1; }
          else {
            const diffDays = Math.abs(differenceInDays(currentDate, lastDate));
            if (diffDays === 1) tempStreak++;
            else if (diffDays > 1) tempStreak = 1;
          }
          lastDate = currentDate;
          if (tempStreak > longestStreak) longestStreak = tempStreak;
        }
      });
    }

    // Category Streaks
    const categoryStreaks: Record<string, { current: number, best: number }> = {};
    prayers.forEach(prayer => {
      let current = 0;
      let best = 0;
      let temp = 0;
      let catCheckDate = today;
      if (logs[todayStr]?.completedPrayers?.includes(prayer.id)) { current++; catCheckDate = subDays(today, 1); }
      else if (logs[yesterdayStr]?.completedPrayers?.includes(prayer.id)) { catCheckDate = subDays(today, 1); }
      else { current = 0; }
      if (current > 0 || logs[yesterdayStr]?.completedPrayers?.includes(prayer.id)) {
        while (true) {
          const dateStr = format(catCheckDate, 'yyyy-MM-dd');
          if (logs[dateStr]?.completedPrayers?.includes(prayer.id)) { if (dateStr !== todayStr) current++; catCheckDate = subDays(catCheckDate, 1); }
          else break;
        }
      }
      let catLastDate: Date | null = null;
      if (sortedDates.length > 0) {
        const chronologicalDates = [...sortedDates].sort((a, b) => a.localeCompare(b));
        chronologicalDates.forEach(dateStr => {
          if (logs[dateStr]?.completedPrayers?.includes(prayer.id)) {
            const currentDate = parseISO(dateStr);
            if (!catLastDate) { temp = 1; }
            else {
              const diffDays = Math.abs(differenceInDays(currentDate, catLastDate));
              if (diffDays === 1) temp++;
              else if (diffDays > 1) temp = 1;
            }
            catLastDate = currentDate;
            if (temp > best) best = temp;
          }
        });
      }
      categoryStreaks[prayer.id] = { current, best };
    });

    // Monthly Stats
    const monthStart = startOfMonth(currentMonth);
    const monthEnd = endOfMonth(currentMonth);
    const daysInMonth = eachDayOfInterval({ start: monthStart, end: monthEnd });
    let monthlyTotalPrayers = 0;
    let monthlyTotalNovenas = 0;
    let monthlyTotalActivities = 0;
    const monthlyPrayerCounts: Record<string, number> = {};
    prayers.forEach(p => monthlyPrayerCounts[p.id] = 0);
    let daysWithAtLeastOnePrayer = 0;

    daysInMonth.forEach(day => {
      if (day > today && format(day, 'yyyy-MM-dd') !== format(today, 'yyyy-MM-dd')) return;
      const dateStr = format(day, 'yyyy-MM-dd');
      const log = logs[dateStr];
      if (log && ((log.completedPrayers && log.completedPrayers.length > 0) || (log.completedNovenas && log.completedNovenas.length > 0))) {
        daysWithAtLeastOnePrayer++;
        if (log.completedPrayers) {
          monthlyTotalPrayers += log.completedPrayers.length;
          log.completedPrayers.forEach(pid => { if (monthlyPrayerCounts[pid] !== undefined) monthlyPrayerCounts[pid]++; });
        }
        if (log.completedNovenas) monthlyTotalNovenas += log.completedNovenas.length;
        if (log.completedActivities) monthlyTotalActivities += log.completedActivities.length;
      }
    });

    let daysPassedInMonth = daysInMonth.length;
    if (isSameMonth(currentMonth, today)) daysPassedInMonth = parseInt(format(today, 'd'));
    else if (currentMonth > today) daysPassedInMonth = 0;
    const averagePerDay = daysPassedInMonth > 0 ? ((monthlyTotalPrayers + monthlyTotalNovenas) / daysPassedInMonth).toFixed(1) : "0.0";

    return { currentStreak, longestStreak, categoryStreaks, monthlyPrayerCounts, monthlyTotalNovenas, monthlyTotalActivities, averagePerDay, daysWithAtLeastOnePrayer, totalDaysInMonth: daysInMonth.length, daysPassedInMonth };
  }, [logs, prayers, currentMonth]);

  const handlePrevMonth = () => setCurrentMonth(prev => subMonths(prev, 1));
  const handleNextMonth = () => setCurrentMonth(prev => addMonths(prev, 1));
  const canGoNext = !isSameMonth(currentMonth, currentDate) && addMonths(currentMonth, 1) <= currentDate;

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto relative">
      {/* Editorial Header */}
      <header className="space-y-2 pl-1">
        <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">Grow in the grace and knowledge</p>
        <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">Stats</h1>
      </header>

      {/* Streak Bento Cards */}
      <div className="grid grid-cols-2 gap-4">
        <motion.button whileTap={{ scale: 0.96 }} onClick={() => setShowStreakDetails('current')}
          className="bg-secondary-container rounded-4xl p-7 flex flex-col justify-between text-left min-h-[160px]">
          <div>
            <span className="font-label text-[10px] uppercase tracking-[0.15em] text-on-secondary-container/70">Current Streak</span>
            <motion.div key={stats.currentStreak} initial={{ scale: 1.3, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
              className="flex items-baseline gap-1.5 mt-3">
              <span className="font-headline text-5xl font-semibold text-on-secondary-container">{stats.currentStreak}</span>
              <span className="font-headline text-xl text-on-secondary-container/60 italic">Days</span>
            </motion.div>
          </div>
          <div className="flex items-center gap-1.5">
            <Flame className="h-4 w-4 text-on-secondary-container" />
            <span className="font-label text-[10px] tracking-wide text-on-secondary-container/70">Tap for details</span>
          </div>
        </motion.button>

        <motion.button whileTap={{ scale: 0.96 }} onClick={() => setShowStreakDetails('best')}
          className="bg-surface-container-low rounded-4xl p-7 flex flex-col justify-between text-left min-h-[160px]">
          <div>
            <span className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">Best Streak</span>
            <motion.div key={stats.longestStreak} initial={{ scale: 1.3, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
              className="flex items-baseline gap-1.5 mt-3">
              <span className="font-headline text-5xl font-semibold text-primary">{stats.longestStreak}</span>
              <span className="font-headline text-xl text-primary/60 italic">Days</span>
            </motion.div>
          </div>
          <div className="flex items-center gap-1.5">
            <TrendingUp className="h-4 w-4 text-on-surface-variant" />
            <span className="font-label text-[10px] tracking-wide text-on-surface-variant">Tap for details</span>
          </div>
        </motion.button>
      </div>

      {/* Monthly Goal Card */}
      <div className="bg-surface-container-lowest rounded-4xl p-7 shadow-ambient-sm">
        <div className="flex items-center justify-between mb-3">
          <span className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">Monthly Goal</span>
          <span className="font-headline text-3xl font-medium text-on-surface">
            {stats.daysPassedInMonth > 0 ? Math.round((stats.daysWithAtLeastOnePrayer / stats.daysPassedInMonth) * 100) : 0}%
          </span>
        </div>
        <div className="h-1.5 w-full bg-surface-container-high rounded-full overflow-hidden">
          <motion.div
            className="h-full bg-primary rounded-full"
            initial={{ width: 0 }}
            animate={{ width: `${stats.daysPassedInMonth > 0 ? Math.round((stats.daysWithAtLeastOnePrayer / stats.daysPassedInMonth) * 100) : 0}%` }}
            transition={{ duration: 0.8, ease: "easeOut" }}
          />
        </div>
        <div className="flex justify-between mt-3">
          <span className="font-label text-xs text-on-surface-variant">{stats.daysWithAtLeastOnePrayer} active days</span>
          <span className="font-label text-xs text-on-surface-variant">{stats.averagePerDay} avg/day</span>
        </div>
      </div>

      {/* Month Navigator */}
      <div className="flex items-center justify-between">
        <h2 className="font-headline text-2xl text-on-surface">{format(currentMonth, 'MMMM')} Agenda</h2>
        <div className="flex gap-2">
          <button className="w-10 h-10 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors active:scale-95" onClick={handlePrevMonth}>
            <ChevronLeft className="h-5 w-5 text-on-surface-variant" />
          </button>
          <button className="w-10 h-10 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors active:scale-95 disabled:opacity-40" onClick={handleNextMonth} disabled={!canGoNext}>
            <ChevronRight className="h-5 w-5 text-on-surface-variant" />
          </button>
        </div>
      </div>

      {/* Prayer Progress Bars */}
      <div className="space-y-5">
        {prayers.map((prayer, i) => {
          const count = stats.monthlyPrayerCounts[prayer.id] || 0;
          const pct = stats.daysPassedInMonth > 0 ? Math.round((count / stats.daysPassedInMonth) * 100) : 0;
          return (
            <div key={prayer.id} className="space-y-2">
              <div className="flex justify-between items-end">
                <span className="font-headline text-lg text-on-surface">{prayer.title}</span>
                <span className="font-label text-xs text-on-surface-variant">{count}/{stats.daysPassedInMonth} days</span>
              </div>
              <div className="h-1.5 w-full bg-surface-container-high rounded-full overflow-hidden">
                <motion.div
                  className="h-full rounded-full bg-primary"
                  initial={{ width: 0 }}
                  animate={{ width: `${pct}%` }}
                  transition={{ duration: 0.6, delay: i * 0.1 }}
                />
              </div>
            </div>
          );
        })}
        {stats.monthlyTotalNovenas > 0 && (
          <div className="space-y-2">
            <div className="flex justify-between items-end">
              <span className="font-headline text-lg text-on-surface flex items-center gap-2">
                <BookHeart className="h-4 w-4 text-tertiary" /> Novenas
              </span>
              <span className="font-label text-xs text-on-surface-variant">{stats.monthlyTotalNovenas} days</span>
            </div>
            <div className="h-1.5 w-full bg-surface-container-high rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-tertiary rounded-full"
                initial={{ width: 0 }}
                animate={{ width: `${Math.round((stats.monthlyTotalNovenas / stats.daysPassedInMonth) * 100)}%` }}
                transition={{ duration: 0.6, delay: prayers.length * 0.1 }}
              />
            </div>
          </div>
        )}
        {stats.monthlyTotalActivities > 0 && (
          <div className="space-y-2">
            <div className="flex justify-between items-end">
              <span className="font-headline text-lg text-on-surface flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-primary-dim" /> Other Prayers
              </span>
              <span className="font-label text-xs text-on-surface-variant">{stats.monthlyTotalActivities} total</span>
            </div>
            <div className="h-1.5 w-full bg-surface-container-high rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-primary-dim rounded-full"
                initial={{ width: 0 }}
                animate={{ width: `${Math.min(Math.round((stats.monthlyTotalActivities / stats.daysPassedInMonth) * 100), 100)}%` }}
                transition={{ duration: 0.6, delay: (prayers.length + 1) * 0.1 }}
              />
            </div>
          </div>
        )}
      </div>

      {/* Streak Details Modal */}
      <AnimatePresence>
        {showStreakDetails && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-6" style={{ background: 'rgba(47, 51, 50, 0.3)', backdropFilter: 'blur(8px)' }}
            onClick={() => setShowStreakDetails(null)}>
            <motion.div initial={{ scale: 0.92, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.92, opacity: 0 }}
              transition={{ type: 'spring', stiffness: 400, damping: 30 }} onClick={e => e.stopPropagation()}
              className="w-full max-w-sm bg-surface-container-lowest rounded-4xl p-7 shadow-ambient">
              <div className="flex items-center justify-between mb-6">
                <h3 className="font-headline text-2xl text-on-surface flex items-center gap-2">
                  {showStreakDetails === 'current' ? <><Flame className="h-5 w-5 text-secondary" /> Current Streaks</> : <><TrendingUp className="h-5 w-5 text-primary" /> Best Streaks</>}
                </h3>
                <button className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors" onClick={() => setShowStreakDetails(null)}>
                  <X className="h-4 w-4 text-on-surface-variant" />
                </button>
              </div>
              <div className="space-y-3">
                {prayers.map((prayer, i) => {
                  const val = showStreakDetails === 'current' ? stats.categoryStreaks[prayer.id].current : stats.categoryStreaks[prayer.id].best;
                  return (
                    <motion.div key={prayer.id} initial={{ opacity: 0, x: -12 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.06 }}
                      className="flex items-center justify-between p-4 rounded-2xl bg-surface-container-low">
                      <span className="font-headline text-base text-on-surface">{prayer.title}</span>
                      <div className="flex items-baseline gap-1">
                        <span className="font-headline text-xl font-semibold text-on-surface">{val}</span>
                        <span className="font-label text-[10px] uppercase text-on-surface-variant">days</span>
                      </div>
                    </motion.div>
                  );
                })}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
