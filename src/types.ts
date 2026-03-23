export type Priority = 'low' | 'medium' | 'high';

export interface Intention {
  id: string;
  title: string;
  description?: string;
  createdAt: string; // ISO date string
  targetDate?: string; // ISO date string
  priority: Priority;
  isArchived: boolean;
}

export interface Novena {
  id: string;
  title: string; // e.g., "St. Jude"
  intention: string;
  startDate: string; // YYYY-MM-DD format
  createdAt: string; // ISO date string
}

export interface DailyLog {
  date: string; // YYYY-MM-DD format
  completedPrayers: string[]; // IDs of completed standard prayers
  completedIntentions: string[]; // IDs of intentions prayed for today
  completedNovenas?: string[]; // IDs of novenas prayed for today
}

export interface Prayer {
  id: string;
  title: string;
  icon?: string;
}

export const DEFAULT_PRAYERS: Prayer[] = [
  { id: 'morning_prayer', title: 'Morning Prayer', icon: 'Sun' },

  { id: 'mass', title: 'Mass', icon: 'Church' },
  { id: 'rosary', title: 'Rosary', icon: 'Crown' },
  { id: 'evening_prayer', title: 'Evening Prayer', icon: 'Moon' },
  { id: 'bible_reading', title: 'Bible Reading', icon: 'Book' },
  
];
