import { format, differenceInDays, isBefore, parseISO } from 'date-fns';
import { Intention } from '@/types';

export function calculateUrgency(intention: Intention, currentDate: Date = new Date()): number {
  if (intention.isArchived) return -1;

  let score = 0;

  // Base score from priority
  if (intention.priority === 'high') score += 50;
  if (intention.priority === 'medium') score += 30;
  if (intention.priority === 'low') score += 10;

  // Target date logic
  if (intention.targetDate) {
    const target = parseISO(intention.targetDate);
    const now = currentDate;
    const daysUntil = differenceInDays(target, now);

    if (daysUntil < 0) {
      // Passed target date, urgency decays rapidly
      score -= Math.abs(daysUntil) * 5;
    } else if (daysUntil <= 7) {
      // Within a week, urgency spikes
      score += (7 - daysUntil) * 10;
    } else {
      // More than a week away, slight increase as it gets closer
      score += Math.max(0, 20 - daysUntil);
    }
  } else {
    // No target date, decays slowly over time since creation
    const created = parseISO(intention.createdAt);
    const daysSince = differenceInDays(currentDate, created);
    score -= daysSince * 0.5;
  }

  return score;
}

export function sortIntentions(intentions: Intention[], currentDate: Date = new Date()): Intention[] {
  return [...intentions].sort((a, b) => {
    return calculateUrgency(b, currentDate) - calculateUrgency(a, currentDate);
  });
}
