export type Priority = 'low' | 'medium' | 'high';
export type ActivityCategory = 'sacramental' | 'devotional' | 'service' | 'spiritual';

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

export interface ExtraActivity {
  id: string;
  name: string;
  icon: string;
  category: ActivityCategory;
}

export const DEFAULT_EXTRA_ACTIVITIES: ExtraActivity[] = [
  // Sacramental
  { id: 'confession', name: 'Confession', icon: 'MessageSquareHeart', category: 'sacramental' },
  { id: 'adoration', name: 'Adoration', icon: 'Sun', category: 'sacramental' },
  // Devotional
  { id: 'via_crucis', name: 'Via Crucis', icon: 'Cross', category: 'devotional' },
  { id: 'holy_hour', name: 'Holy Hour', icon: 'Clock', category: 'devotional' },
  { id: 'lectio_divina', name: 'Lectio Divina', icon: 'BookMarked', category: 'devotional' },
  { id: 'divine_mercy', name: 'Divine Mercy Chaplet', icon: 'Droplets', category: 'devotional' },
  { id: 'angelus', name: 'Angelus / Regina Caeli', icon: 'Bell', category: 'devotional' },
  { id: 'litany', name: 'Litany', icon: 'Scroll', category: 'devotional' },
  // Service
  { id: 'volunteering', name: 'Volunteering', icon: 'HandHeart', category: 'service' },
  { id: 'almsgiving', name: 'Almsgiving / Charity', icon: 'HandCoins', category: 'service' },
  { id: 'visiting_sick', name: 'Visiting the Sick', icon: 'HeartHandshake', category: 'service' },
  // Spiritual
  { id: 'spiritual_reading', name: 'Spiritual Reading', icon: 'BookText', category: 'spiritual' },
  { id: 'fasting', name: 'Fasting / Abstinence', icon: 'UtensilsCrossed', category: 'spiritual' },
  { id: 'retreat', name: 'Retreat', icon: 'MountainSnow', category: 'spiritual' },
  { id: 'pilgrimage', name: 'Pilgrimage', icon: 'Compass', category: 'spiritual' },
  { id: 'examination', name: 'Examination of Conscience', icon: 'Brain', category: 'spiritual' },
];

export interface DailyLog {
  date: string; // YYYY-MM-DD format
  completedPrayers: string[]; // IDs of completed standard prayers
  completedIntentions: string[]; // IDs of intentions prayed for today
  completedNovenas?: string[]; // IDs of novenas prayed for today
  completedActivities?: string[]; // IDs of extra activities done today
  journal?: string;
}

export interface PrayerSection {
  title: string;
  content?: string;
  items?: { icon?: string; text: string }[];
}

export interface Prayer {
  id: string;
  title: string;
  subtitle?: string;
  icon?: string;
  themeColor?: string; // e.g. 'green', 'purple', 'white', 'red', 'rose'
  sections?: PrayerSection[];
}

export const DEFAULT_PRAYERS: Prayer[] = [
  {
    id: 'morning_prayer',
    title: 'Morning Prayer',
    subtitle: 'LITURGY OF THE HOURS - LAUDS',
    icon: 'Sunrise',
    sections: [
      {
        title: "MORNING OFFERING",
        content: "O Jesus, through the Immaculate Heart of Mary, I offer you my prayers, works, joys, and sufferings of this day in union with the Holy Sacrifice of the Mass throughout the world."
      }
    ]
  },
  {
    id: 'mass',
    title: 'Holy Mass',
    subtitle: 'SACRAMENTAL LIFE',
    icon: 'Church',
    sections: [
      {
        title: "SAINT OF THE DAY",
        content: "St. Martin de Porres"
      },
      {
        title: "TODAY'S READINGS",
        items: [
          { icon: 'Book', text: 'Romans 11:1-2a, 11-12, 25-29' },
          { icon: 'Music', text: 'Psalm 94' },
          { icon: 'Book', text: 'Luke 14:1, 7-11' }
        ]
      }
    ]
  },
  {
    id: 'rosary',
    title: 'Rosary',
    subtitle: 'MARIAN DEVOTION',
    icon: 'Crown',
    sections: [
      {
        title: "TODAY'S MYSTERIES",
        content: "Sorrowful Mysteries",
        items: [
          { text: "1. The Agony in the Garden" },
          { text: "2. The Scourging at the Pillar" },
          { text: "3. The Crowning with Thorns" },
          { text: "4. The Carrying of the Cross" },
          { text: "5. The Crucifixion" }
        ]
      }
    ]
  },
  {
    id: 'evening_prayer',
    title: 'Evening Prayer',
    subtitle: 'LITURGY OF THE HOURS - COMPLINE',
    icon: 'MoonStar',
    sections: [
      {
        title: "EXAMEN",
        content: "Review the day with gratitude. Note where you felt God's presence and where you fell short. Ask for forgiveness and grace for tomorrow."
      }
    ]
  },
  {
    id: 'bible_reading',
    title: 'Bible Reading',
    subtitle: 'LECTIO DIVINA',
    icon: 'Book',
    sections: [
      {
        title: "SUGGESTED READING",
        content: "Gospel of John, Chapter 15"
      }
    ]
  },
];
