import { format, parseISO, differenceInDays, subDays } from 'date-fns';
import { DailyLog } from '@/types';

/**
 * Generic streak calculator. Given a map of logs by YYYY-MM-DD and a predicate
 * that decides whether a single day counts toward the streak, returns the
 * user's current and best ever streaks.
 *
 * "Current" walks backwards from today. It tolerates today being empty as
 * long as yesterday counted — so a user who hasn't prayed yet today still
 * sees their streak from yesterday.
 */
export function calculateStreak(
  logs: Record<string, DailyLog>,
  predicate: (log: DailyLog) => boolean,
  today: Date
): { current: number; best: number } {
  const todayStr = format(today, 'yyyy-MM-dd');
  const yesterdayStr = format(subDays(today, 1), 'yyyy-MM-dd');

  const hasActivity = (dateStr: string): boolean => {
    const log = logs[dateStr];
    return log ? predicate(log) : false;
  };

  // Current streak — walk backwards from today.
  let current = 0;
  let checkDate = today;
  if (hasActivity(todayStr)) {
    current++;
    checkDate = subDays(today, 1);
  } else if (hasActivity(yesterdayStr)) {
    checkDate = subDays(today, 1);
  }

  if (current > 0 || hasActivity(yesterdayStr)) {
    while (true) {
      const dateStr = format(checkDate, 'yyyy-MM-dd');
      if (hasActivity(dateStr)) {
        if (dateStr !== todayStr) current++;
        checkDate = subDays(checkDate, 1);
      } else {
        break;
      }
    }
  }

  // Best streak — scan all dates chronologically for the longest consecutive run.
  let best = 0;
  let temp = 0;
  const sortedDates = Object.keys(logs).sort();
  let lastDate: Date | null = null;

  for (const dateStr of sortedDates) {
    if (!hasActivity(dateStr)) continue;
    const d = parseISO(dateStr);
    if (!lastDate) {
      temp = 1;
    } else {
      const diff = Math.abs(differenceInDays(d, lastDate));
      if (diff === 1) temp++;
      else if (diff > 1) temp = 1;
    }
    lastDate = d;
    if (temp > best) best = temp;
  }

  return { current, best };
}

/**
 * Common predicate: day counts if *any* prayer or novena was completed.
 */
export const hasAnyActivity = (log: DailyLog): boolean =>
  (log.completedPrayers && log.completedPrayers.length > 0) ||
  (log.completedNovenas && log.completedNovenas.length > 0) ||
  false;

/**
 * Builds a predicate that checks whether a specific prayer was completed.
 */
export const hasPrayerCompleted =
  (prayerId: string) =>
  (log: DailyLog): boolean =>
    log.completedPrayers?.includes(prayerId) ?? false;
