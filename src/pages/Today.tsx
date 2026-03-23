import React from 'react';
import { format, parseISO, differenceInDays } from 'date-fns';
import { CheckCircle2, Circle, Sun, Moon, Book, Heart, Church, Crown, BookHeart } from 'lucide-react';
import { DailyLog, Intention, Novena, Prayer, DEFAULT_PRAYERS } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { cn } from '@/lib/utils';
import { sortIntentions } from '@/lib/intentions';

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
  ).slice(0, 5); // Show top 5 most urgent

  const activeNovenas = novenas.filter(novena => {
    const startDate = parseISO(novena.startDate);
    const dayOfNovena = differenceInDays(currentDate, startDate) + 1;
    return dayOfNovena >= 1 && dayOfNovena <= 9;
  });

  const getIcon = (iconName?: string) => {
    switch (iconName) {
      case 'Sun': return <Sun className="h-5 w-5" />;
      case 'Moon': return <Moon className="h-5 w-5" />;
      case 'Book': return <Book className="h-5 w-5" />;
      case 'Church': return <Church className="h-5 w-5" />;
      default: return <Crown className="h-5 w-5" />;
    }
  };

  return (
    <div className="space-y-6 pb-24 pt-6 px-4 max-w-md mx-auto">
      <header className="space-y-1">
        <h1 className="text-3xl font-semibold tracking-tight">Today</h1>
        <p className="text-slate-500 dark:text-slate-400">{todayStr}</p>
      </header>

      {activeNovenas.length > 0 && (
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">Active Novenas</CardTitle>
          </CardHeader>
          <CardContent className="space-y-1">
            {activeNovenas.map((novena) => {
              const completedNovenas = log.completedNovenas || [];
              const isCompleted = completedNovenas.includes(novena.id);
              const startDate = parseISO(novena.startDate);
              const dayOfNovena = differenceInDays(currentDate, startDate) + 1;

              return (
                <button
                  key={novena.id}
                  onClick={() => toggleNovena(novena.id)}
                  className={cn(
                    'flex w-full items-center justify-between rounded-xl p-3 text-left transition-colors',
                    isCompleted
                      ? 'bg-rose-50/50 text-rose-900 dark:bg-rose-950/30 dark:text-rose-200'
                      : 'hover:bg-slate-100 dark:hover:bg-slate-800/50'
                  )}
                >
                  <div className="flex items-center space-x-3 pr-4">
                    <div className={cn(
                      "p-2 rounded-lg shrink-0",
                      isCompleted ? "bg-rose-100 text-rose-600 dark:bg-rose-900/50 dark:text-rose-400" : "bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400"
                    )}>
                      <BookHeart className="h-5 w-5" />
                    </div>
                    <div className="flex flex-col space-y-0.5">
                      <span className={cn("font-medium line-clamp-1", isCompleted && "line-through opacity-70")}>
                        {novena.title}
                      </span>
                      <span className="text-xs text-slate-500 line-clamp-1 dark:text-slate-400">
                        Day {dayOfNovena} of 9 • {novena.intention}
                      </span>
                    </div>
                  </div>
                  {isCompleted ? (
                    <CheckCircle2 className="h-6 w-6 shrink-0 text-rose-600 dark:text-rose-400" />
                  ) : (
                    <Circle className="h-6 w-6 shrink-0 text-slate-300 dark:text-slate-600" />
                  )}
                </button>
              );
            })}
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-lg">Daily Prayers</CardTitle>
        </CardHeader>
        <CardContent className="space-y-1">
          {prayers.map((prayer) => {
            const isCompleted = log.completedPrayers.includes(prayer.id);
            return (
              <button
                key={prayer.id}
                onClick={() => togglePrayer(prayer.id)}
                className={cn(
                  'flex w-full items-center justify-between rounded-xl p-3 transition-colors',
                  isCompleted
                    ? 'bg-indigo-50/50 text-indigo-900 dark:bg-indigo-950/30 dark:text-indigo-200'
                    : 'hover:bg-slate-100 dark:hover:bg-slate-800/50'
                )}
              >
                <div className="flex items-center space-x-3">
                  <div className={cn(
                    "p-2 rounded-lg",
                    isCompleted ? "bg-indigo-100 text-indigo-600 dark:bg-indigo-900/50 dark:text-indigo-400" : "bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400"
                  )}>
                    {getIcon(prayer.icon)}
                  </div>
                  <span className={cn("font-medium", isCompleted && "line-through opacity-70")}>{prayer.title}</span>
                </div>
                {isCompleted ? (
                  <CheckCircle2 className="h-6 w-6 text-indigo-600 dark:text-indigo-400" />
                ) : (
                  <Circle className="h-6 w-6 text-slate-300 dark:text-slate-600" />
                )}
              </button>
            );
          })}
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-lg">Top Intentions</CardTitle>
        </CardHeader>
        <CardContent className="space-y-1">
          {activeIntentions.length === 0 ? (
            <p className="text-sm text-slate-500 py-4 text-center">No active intentions.</p>
          ) : (
            activeIntentions.map((intention) => {
              const isCompleted = log.completedIntentions.includes(intention.id);
              return (
                <button
                  key={intention.id}
                  onClick={() => toggleIntention(intention.id)}
                  className={cn(
                    'flex w-full items-center justify-between rounded-xl p-3 text-left transition-colors',
                    isCompleted
                      ? 'bg-emerald-50/50 text-emerald-900 dark:bg-emerald-950/30 dark:text-emerald-200'
                      : 'hover:bg-slate-100 dark:hover:bg-slate-800/50'
                  )}
                >
                  <div className="flex flex-col space-y-1 pr-4">
                    <span className={cn("font-medium line-clamp-1", isCompleted && "line-through opacity-70")}>
                      {intention.title}
                    </span>
                    {intention.description && (
                      <span className="text-xs text-slate-500 line-clamp-1 dark:text-slate-400">
                        {intention.description}
                      </span>
                    )}
                  </div>
                  {isCompleted ? (
                    <CheckCircle2 className="h-6 w-6 shrink-0 text-emerald-600 dark:text-emerald-400" />
                  ) : (
                    <Circle className="h-6 w-6 shrink-0 text-slate-300 dark:text-slate-600" />
                  )}
                </button>
              );
            })
          )}
        </CardContent>
      </Card>
    </div>
  );
}
