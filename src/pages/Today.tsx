import React from 'react';
import { format, parseISO, differenceInDays } from 'date-fns';
import { DailyLog, Intention, Novena, Prayer } from '@/types';
import { StreakBar } from '@/components/today/StreakBar';
import { ActiveNovenas } from '@/components/today/ActiveNovenas';
import { DailyPrayerList } from '@/components/today/DailyPrayerList';
import { OtherPrayers } from '@/components/today/OtherPrayers';
import { IntentionsList } from '@/components/today/IntentionsList';
import { GratitudeJournal } from '@/components/today/GratitudeJournal';
import { DailyReflection } from '@/components/today/DailyReflection';

interface TodayProps {
  log: DailyLog;
  updateLog: (log: DailyLog) => void;
  intentions: Intention[];
  novenas: Novena[];
  prayers: Prayer[];
  currentDate: Date;
}

export function Today({
  log,
  updateLog,
  intentions,
  novenas,
  prayers,
  currentDate,
}: TodayProps) {
  const todayStr = format(currentDate, 'EEEE, MMMM do');

  // Toggle helpers — each returns a new log with one id flipped in a list.
  const toggleId = (field: keyof DailyLog) => (id: string) => {
    const current = (log[field] as string[] | undefined) || [];
    const next = current.includes(id)
      ? current.filter((x) => x !== id)
      : [...current, id];
    updateLog({ ...log, [field]: next });
  };

  const togglePrayer = toggleId('completedPrayers');
  const toggleIntention = toggleId('completedIntentions');
  const toggleNovena = toggleId('completedNovenas');
  const toggleActivity = toggleId('completedActivities');

  // Streak bar — counts prayers + active novenas as the denominator.
  const activeNovenasCount = novenas.filter((n) => {
    const day = differenceInDays(currentDate, parseISO(n.startDate)) + 1;
    return day >= 1 && day <= 9;
  }).length;
  const completedCount =
    log.completedPrayers.length + (log.completedNovenas?.length || 0);
  const totalCount = prayers.length + activeNovenasCount;

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto">
      <header className="space-y-2 pl-1">
        <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">
          {todayStr}
        </p>
        <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">
          Today's <br />
          <span className="italic text-primary">Intentions</span>
        </h1>
      </header>

      <StreakBar completedCount={completedCount} totalCount={totalCount} />

      <ActiveNovenas
        novenas={novenas}
        log={log}
        currentDate={currentDate}
        onToggle={toggleNovena}
      />

      <DailyPrayerList
        prayers={prayers}
        log={log}
        currentDate={currentDate}
        onToggle={togglePrayer}
      />

      <OtherPrayers log={log} onToggle={toggleActivity} />

      <IntentionsList
        intentions={intentions}
        log={log}
        currentDate={currentDate}
        onToggle={toggleIntention}
      />

      <GratitudeJournal
        log={log}
        onSave={(journal) => updateLog({ ...log, journal })}
      />

      <DailyReflection currentDate={currentDate} />
    </div>
  );
}
