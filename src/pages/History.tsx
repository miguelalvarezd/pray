import React, { useState, useEffect, useRef } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, subMonths, addMonths, isSameMonth, subDays } from 'date-fns';
import { DailyLog, Prayer, Novena } from '@/types';
import { Card, CardContent } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Sun, Moon, Book, Crown, Circle, Church, ChevronLeft, ChevronRight, BookHeart } from 'lucide-react';
import { cn } from '@/lib/utils';

interface HistoryProps {
  logs: Record<string, DailyLog>;
  prayers: Prayer[];
  novenas: Novena[];
  currentDate: Date;
}

export function History({ logs, prayers, novenas, currentDate }: HistoryProps) {
  const [currentMonth, setCurrentMonth] = useState(currentDate);
  const bottomRef = useRef<HTMLDivElement>(null);

  // Scroll to bottom only if viewing the current month
  useEffect(() => {
    if (isSameMonth(currentMonth, currentDate) && bottomRef.current) {
      bottomRef.current.scrollIntoView({ behavior: 'instant' });
    }
  }, [currentMonth, currentDate]);

  const monthStart = startOfMonth(currentMonth);
  const monthEnd = endOfMonth(currentMonth);
  const allDays = eachDayOfInterval({ start: monthStart, end: monthEnd });
  
  // Filter out future days so we don't show empty logs for days that haven't happened yet
  const days = allDays.filter(day => day <= currentDate);

  const getIcon = (iconName?: string) => {
    switch (iconName) {
      case 'Sun': return <Sun className="h-5 w-5" />;
      case 'Moon': return <Moon className="h-5 w-5" />;
      case 'Book': return <Book className="h-5 w-5" />;
      case 'Circle': return <Circle className="h-5 w-5" />;
      case 'Crown': return <Crown className="h-5 w-5" />;
      case 'Church': return <Church className="h-5 w-5" />;
      default: return <Crown className="h-5 w-5" />;
    }
  };

  const handlePrevMonth = () => setCurrentMonth(prev => subMonths(prev, 1));
  const handleNextMonth = () => setCurrentMonth(prev => addMonths(prev, 1));
  const canGoNext = !isSameMonth(currentMonth, currentDate) && addMonths(currentMonth, 1) <= currentDate;

  return (
    <div className="space-y-6 pb-24 pt-6 px-4 max-w-md mx-auto">
      <header className="space-y-1">
        <h1 className="text-3xl font-semibold tracking-tight">Agenda</h1>
        <p className="text-slate-500 dark:text-slate-400">Your daily prayer history</p>
      </header>

      <div className="flex items-center justify-between bg-white dark:bg-slate-950 sticky top-0 py-2 z-10">
        <Button variant="ghost" size="icon" onClick={handlePrevMonth}>
          <ChevronLeft className="h-5 w-5" />
        </Button>
        <h2 className="text-lg font-medium">{format(currentMonth, 'MMMM yyyy')}</h2>
        <Button variant="ghost" size="icon" onClick={handleNextMonth} disabled={!canGoNext}>
          <ChevronRight className="h-5 w-5" />
        </Button>
      </div>

      <div className="space-y-3 flex flex-col">
        {days.length === 0 ? (
          <div className="text-center py-12 text-slate-500 dark:text-slate-400">
            No history for this month.
          </div>
        ) : (
          days.map(date => {
            const dateStr = format(date, 'yyyy-MM-dd');
            const log = logs[dateStr];
            const completedIds = log?.completedPrayers || [];
            const completedNovenas = log?.completedNovenas || [];
            
            let dateLabel = format(date, 'MMM d');
            let dayLabel = format(date, 'EEEE');
            
            const isCurrentDay = dateStr === format(currentDate, 'yyyy-MM-dd');
            const isYesterdayDay = dateStr === format(subDays(currentDate, 1), 'yyyy-MM-dd');

            if (isCurrentDay) {
              dateLabel = 'Today';
            } else if (isYesterdayDay) {
              dateLabel = 'Yesterday';
            }

            const completionRate = completedIds.length / prayers.length;

            return (
              <Card 
                key={dateStr} 
                className={cn(
                  "overflow-hidden transition-all duration-300", 
                  isCurrentDay 
                    ? "border-indigo-300 dark:border-indigo-700 shadow-md scale-[1.03] my-4 ring-1 ring-indigo-200 dark:ring-indigo-800" 
                    : "border-slate-200 dark:border-slate-800"
                )}
              >
                <CardContent className={cn("p-0", isCurrentDay ? "p-1" : "")}>
                  <div className="flex items-center p-4">
                    <div className="w-24 shrink-0">
                      <div className={cn("font-medium", isCurrentDay ? "text-indigo-700 dark:text-indigo-300 text-lg" : "text-slate-900 dark:text-slate-100")}>{dateLabel}</div>
                      {(!isCurrentDay && !isYesterdayDay) && (
                        <div className="text-xs text-slate-500 dark:text-slate-400">{dayLabel}</div>
                      )}
                    </div>
                    
                    <div className="flex-1 flex justify-start space-x-2 overflow-x-auto pb-1 scrollbar-hide ml-4">
                      {[...prayers].sort((a, b) => {
                        const aCompleted = completedIds.includes(a.id);
                        const bCompleted = completedIds.includes(b.id);
                        if (aCompleted && !bCompleted) return -1;
                        if (!aCompleted && bCompleted) return 1;
                        return 0;
                      }).map(prayer => {
                        const isCompleted = completedIds.includes(prayer.id);
                        return (
                          <div 
                            key={prayer.id} 
                            className={cn(
                              "p-2 rounded-full flex-shrink-0 flex items-center justify-center transition-colors", 
                              isCompleted 
                                ? "bg-indigo-100 text-indigo-600 dark:bg-indigo-900/50 dark:text-indigo-400" 
                                : "bg-slate-50 text-slate-300 dark:bg-slate-900 dark:text-slate-700",
                              isCurrentDay && !isCompleted && "bg-slate-100 dark:bg-slate-800"
                            )} 
                            title={prayer.title}
                          >
                            {getIcon(prayer.icon)}
                          </div>
                        )
                      })}
                      {completedNovenas.map(novenaId => {
                        const novena = novenas.find(n => n.id === novenaId);
                        if (!novena) return null;
                        return (
                          <div 
                            key={`novena-${novena.id}`} 
                            className="p-2 rounded-full flex-shrink-0 flex items-center justify-center transition-colors bg-rose-100 text-rose-600 dark:bg-rose-900/50 dark:text-rose-400"
                            title={`Novena: ${novena.title}`}
                          >
                            <BookHeart className="h-5 w-5" />
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </CardContent>
                {/* Progress bar at the bottom of the card, outside CardContent to align perfectly */}
                <div className="h-1.5 w-full bg-slate-100 dark:bg-slate-800">
                  <div 
                    className="h-full bg-indigo-500 dark:bg-indigo-400 transition-all" 
                    style={{ width: `${completionRate * 100}%` }}
                  />
                </div>
              </Card>
            );
          })
        )}
        <div ref={bottomRef} className="h-1 w-full" />
      </div>
    </div>
  );
}
