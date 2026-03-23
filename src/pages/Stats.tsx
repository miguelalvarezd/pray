import React, { useMemo, useState } from 'react';
import { format, subDays, isSameMonth, startOfMonth, endOfMonth, eachDayOfInterval, parseISO, differenceInDays, subMonths, addMonths } from 'date-fns';
import { DailyLog, Prayer, Novena } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Flame, TrendingUp, CalendarDays, ChevronLeft, ChevronRight, X, BookHeart } from 'lucide-react';
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

    // Calculate Current Streak (Overall)
    let currentStreak = 0;
    let checkDate = today;
    
    const hasActivity = (dateStr: string) => {
      const log = logs[dateStr];
      return log && ((log.completedPrayers && log.completedPrayers.length > 0) || (log.completedNovenas && log.completedNovenas.length > 0));
    };

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
        } else {
          break;
        }
      }
    }

    // Calculate Longest Streak (Overall)
    let longestStreak = 0;
    let tempStreak = 0;
    const sortedDates = Object.keys(logs).sort((a, b) => b.localeCompare(a));
    
    if (sortedDates.length > 0) {
      const chronologicalDates = [...sortedDates].sort((a, b) => a.localeCompare(b));
      let lastDate: Date | null = null;

      chronologicalDates.forEach(dateStr => {
        if (hasActivity(dateStr)) {
          const currentDate = parseISO(dateStr);
          if (!lastDate) {
            tempStreak = 1;
          } else {
            const diffDays = Math.abs(differenceInDays(currentDate, lastDate)); 
            if (diffDays === 1) {
              tempStreak++;
            } else if (diffDays > 1) {
              tempStreak = 1;
            }
          }
          lastDate = currentDate;
          if (tempStreak > longestStreak) longestStreak = tempStreak;
        }
      });
    }

    // Calculate category streaks
    const categoryStreaks: Record<string, { current: number, best: number }> = {};
    prayers.forEach(prayer => {
      let current = 0;
      let best = 0;
      let temp = 0;
      let catCheckDate = today;
      
      if (logs[todayStr]?.completedPrayers?.includes(prayer.id)) {
        current++;
        catCheckDate = subDays(today, 1);
      } else if (logs[yesterdayStr]?.completedPrayers?.includes(prayer.id)) {
        catCheckDate = subDays(today, 1);
      } else {
        current = 0;
      }

      if (current > 0 || logs[yesterdayStr]?.completedPrayers?.includes(prayer.id)) {
        while (true) {
          const dateStr = format(catCheckDate, 'yyyy-MM-dd');
          if (logs[dateStr]?.completedPrayers?.includes(prayer.id)) {
            if (dateStr !== todayStr) current++;
            catCheckDate = subDays(catCheckDate, 1);
          } else {
            break;
          }
        }
      }

      let catLastDate: Date | null = null;
      if (sortedDates.length > 0) {
        const chronologicalDates = [...sortedDates].sort((a, b) => a.localeCompare(b));
        chronologicalDates.forEach(dateStr => {
          if (logs[dateStr]?.completedPrayers?.includes(prayer.id)) {
            const currentDate = parseISO(dateStr);
            if (!catLastDate) {
              temp = 1;
            } else {
              const diffDays = Math.abs(differenceInDays(currentDate, catLastDate)); 
              if (diffDays === 1) {
                temp++;
              } else if (diffDays > 1) {
                temp = 1;
              }
            }
            catLastDate = currentDate;
            if (temp > best) best = temp;
          }
        });
      }

      categoryStreaks[prayer.id] = { current, best };
    });

    // Calculate Monthly Stats based on currentMonth state
    const monthStart = startOfMonth(currentMonth);
    const monthEnd = endOfMonth(currentMonth);
    const daysInMonth = eachDayOfInterval({ start: monthStart, end: monthEnd });
    
    let monthlyTotalPrayers = 0;
    let monthlyTotalNovenas = 0;
    const monthlyPrayerCounts: Record<string, number> = {};
    prayers.forEach(p => monthlyPrayerCounts[p.id] = 0);

    let daysWithAtLeastOnePrayer = 0;

    daysInMonth.forEach(day => {
      // Don't count future days in the average
      if (day > today && format(day, 'yyyy-MM-dd') !== format(today, 'yyyy-MM-dd')) return;
      
      const dateStr = format(day, 'yyyy-MM-dd');
      const log = logs[dateStr];
      if (log && ((log.completedPrayers && log.completedPrayers.length > 0) || (log.completedNovenas && log.completedNovenas.length > 0))) {
        daysWithAtLeastOnePrayer++;
        if (log.completedPrayers) {
          monthlyTotalPrayers += log.completedPrayers.length;
          log.completedPrayers.forEach(pid => {
            if (monthlyPrayerCounts[pid] !== undefined) {
              monthlyPrayerCounts[pid]++;
            }
          });
        }
        if (log.completedNovenas) {
          monthlyTotalNovenas += log.completedNovenas.length;
        }
      }
    });

    let daysPassedInMonth = daysInMonth.length;
    if (isSameMonth(currentMonth, today)) {
      daysPassedInMonth = parseInt(format(today, 'd'));
    } else if (currentMonth > today) {
      daysPassedInMonth = 0;
    }

    const averagePerDay = daysPassedInMonth > 0 ? ((monthlyTotalPrayers + monthlyTotalNovenas) / daysPassedInMonth).toFixed(1) : "0.0";

    return {
      currentStreak,
      longestStreak,
      categoryStreaks,
      monthlyPrayerCounts,
      monthlyTotalNovenas,
      averagePerDay,
      daysWithAtLeastOnePrayer,
      totalDaysInMonth: daysInMonth.length,
      daysPassedInMonth
    };
  }, [logs, prayers, currentMonth]);

  const handlePrevMonth = () => setCurrentMonth(prev => subMonths(prev, 1));
  const handleNextMonth = () => setCurrentMonth(prev => addMonths(prev, 1));
  const canGoNext = !isSameMonth(currentMonth, currentDate) && addMonths(currentMonth, 1) <= currentDate;

  return (
    <div className="space-y-6 pb-24 pt-6 px-4 max-w-md mx-auto relative">
      <header className="space-y-1">
        <h1 className="text-3xl font-semibold tracking-tight">Stats</h1>
        <p className="text-slate-500 dark:text-slate-400">Your spiritual journey</p>
      </header>

      <div className="grid grid-cols-2 gap-4">
        <Card 
          className="bg-gradient-to-br from-orange-50 to-red-50 dark:from-orange-950/30 dark:to-red-950/30 border-orange-100 dark:border-orange-900/50 cursor-pointer hover:shadow-md transition-all"
          onClick={() => setShowStreakDetails('current')}
        >
          <CardContent className="p-4 flex flex-col items-center justify-center text-center space-y-2">
            <div className="p-3 bg-orange-100 text-orange-600 dark:bg-orange-900/50 dark:text-orange-400 rounded-full">
              <Flame className="h-6 w-6" />
            </div>
            <div>
              <p className="text-3xl font-bold text-orange-700 dark:text-orange-300">{stats.currentStreak}</p>
              <p className="text-xs font-medium text-orange-600/80 dark:text-orange-400/80 uppercase tracking-wider">Current Streak</p>
            </div>
          </CardContent>
        </Card>

        <Card 
          className="bg-gradient-to-br from-indigo-50 to-blue-50 dark:from-indigo-950/30 dark:to-blue-950/30 border-indigo-100 dark:border-indigo-900/50 cursor-pointer hover:shadow-md transition-all"
          onClick={() => setShowStreakDetails('best')}
        >
          <CardContent className="p-4 flex flex-col items-center justify-center text-center space-y-2">
            <div className="p-3 bg-indigo-100 text-indigo-600 dark:bg-indigo-900/50 dark:text-indigo-400 rounded-full">
              <TrendingUp className="h-6 w-6" />
            </div>
            <div>
              <p className="text-3xl font-bold text-indigo-700 dark:text-indigo-300">{stats.longestStreak}</p>
              <p className="text-xs font-medium text-indigo-600/80 dark:text-indigo-400/80 uppercase tracking-wider">Best Streak</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="flex items-center justify-between bg-slate-50 dark:bg-slate-950 py-2 sticky top-0 z-10">
        <Button variant="ghost" size="icon" onClick={handlePrevMonth}>
          <ChevronLeft className="h-5 w-5" />
        </Button>
        <h2 className="text-lg font-medium">{format(currentMonth, 'MMMM yyyy')}</h2>
        <Button variant="ghost" size="icon" onClick={handleNextMonth} disabled={!canGoNext}>
          <ChevronRight className="h-5 w-5" />
        </Button>
      </div>

      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg flex items-center space-x-2">
            <CalendarDays className="h-5 w-5 text-slate-500" />
            <span>Monthly Overview</span>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex justify-between items-end pb-4 border-b border-slate-100 dark:border-slate-800">
            <div>
              <p className="text-3xl font-bold text-slate-900 dark:text-slate-100">{stats.daysWithAtLeastOnePrayer}</p>
              <p className="text-sm text-slate-500 dark:text-slate-400">Active Days</p>
            </div>
            <div className="text-right">
              <p className="text-3xl font-bold text-slate-900 dark:text-slate-100">{stats.averagePerDay}</p>
              <p className="text-sm text-slate-500 dark:text-slate-400">Avg. Prayers / Day</p>
            </div>
          </div>

          <div className="space-y-3 pt-2">
            <h3 className="text-sm font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">Prayer Breakdown</h3>
            {prayers.map(prayer => {
              const count = stats.monthlyPrayerCounts[prayer.id] || 0;
              const percentage = stats.daysPassedInMonth > 0 
                ? Math.round((count / stats.daysPassedInMonth) * 100) 
                : 0;
                
              return (
                <div key={prayer.id} className="space-y-1">
                  <div className="flex justify-between text-sm">
                    <span className="font-medium text-slate-700 dark:text-slate-300">{prayer.title}</span>
                    <span className="text-slate-500 dark:text-slate-400">{count} times</span>
                  </div>
                  <div className="h-2 w-full bg-slate-100 dark:bg-slate-800 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-indigo-500 dark:bg-indigo-400 rounded-full transition-all" 
                      style={{ width: `${percentage}%` }}
                    />
                  </div>
                </div>
              );
            })}
            {stats.monthlyTotalNovenas > 0 && (
              <div className="space-y-1 pt-2">
                <div className="flex justify-between text-sm">
                  <span className="font-medium text-slate-700 dark:text-slate-300 flex items-center gap-1">
                    <BookHeart className="h-4 w-4 text-rose-500" /> Novenas
                  </span>
                  <span className="text-slate-500 dark:text-slate-400">{stats.monthlyTotalNovenas} days</span>
                </div>
                <div className="h-2 w-full bg-slate-100 dark:bg-slate-800 rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-rose-500 dark:bg-rose-400 rounded-full transition-all" 
                    style={{ width: `${Math.round((stats.monthlyTotalNovenas / stats.daysPassedInMonth) * 100)}%` }}
                  />
                </div>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Streak Details Modal */}
      {showStreakDetails && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm" onClick={() => setShowStreakDetails(null)}>
          <Card className="w-full max-w-sm shadow-xl" onClick={e => e.stopPropagation()}>
            <CardHeader className="pb-3 flex flex-row items-center justify-between">
              <CardTitle className="text-xl flex items-center space-x-2">
                {showStreakDetails === 'current' ? (
                  <><Flame className="h-5 w-5 text-orange-500" /> <span>Current Streaks</span></>
                ) : (
                  <><TrendingUp className="h-5 w-5 text-indigo-500" /> <span>Best Streaks</span></>
                )}
              </CardTitle>
              <Button variant="ghost" size="icon" className="-mr-2" onClick={() => setShowStreakDetails(null)}>
                <X className="h-5 w-5" />
              </Button>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-3">
                {prayers.map(prayer => {
                  const val = showStreakDetails === 'current' 
                    ? stats.categoryStreaks[prayer.id].current 
                    : stats.categoryStreaks[prayer.id].best;
                  
                  return (
                    <div key={prayer.id} className="flex items-center justify-between p-3 rounded-lg bg-slate-50 dark:bg-slate-900 border border-slate-100 dark:border-slate-800">
                      <span className="font-medium text-slate-700 dark:text-slate-300">{prayer.title}</span>
                      <div className="flex items-center space-x-1.5">
                        <span className="text-lg font-bold text-slate-900 dark:text-slate-100">{val}</span>
                        <span className="text-xs text-slate-500 dark:text-slate-400 uppercase">days</span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
