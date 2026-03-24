import { Prayer } from '@/types';

export interface LiturgicalDay {
  date: string; // YYYY-MM-DD
  season: string;
  season_week: number;
  celebrations: Array<{
    title: string;
    colour: string;
    rank: string;
  }>;
}

export interface Devotion {
  date: string;
  firstReadingRef: string;
  secondReadingRef: string;
  psalmRef: string;
  gospelRef: string;
  quote?: string;
  quoteCitation?: string;
  dailyPrayer?: string;
  saintReflection?: string;
}

export const getRosaryMysteries = (dayOfWeek: number): string => {
  // 0 is Sunday, 1 is Monday...
  switch (dayOfWeek) {
    case 1: // Mon
    case 6: // Sat
      return "Joyful Mysteries";
    case 2: // Tue
    case 5: // Fri
      return "Sorrowful Mysteries";
    case 3: // Wed
    case 0: // Sun
      return "Glorious Mysteries";
    case 4: // Thu
      return "Luminous Mysteries";
    default:
      return "The Mysteries";
  }
};

export const getRosaryMysteryList = (mysteriesType: string): string[] => {
  if (mysteriesType === "Joyful Mysteries") {
    return [
      "1. The Annunciation",
      "2. The Visitation",
      "3. The Nativity",
      "4. The Presentation",
      "5. The Finding of Jesus in the Temple"
    ];
  }
  if (mysteriesType === "Sorrowful Mysteries") {
    return [
      "1. The Agony in the Garden",
      "2. The Scourging at the Pillar",
      "3. The Crowning with Thorns",
      "4. The Carrying of the Cross",
      "5. The Crucifixion"
    ];
  }
  if (mysteriesType === "Glorious Mysteries") {
    return [
      "1. The Resurrection",
      "2. The Ascension",
      "3. The Descent of the Holy Spirit",
      "4. The Assumption",
      "5. The Coronation of Mary"
    ];
  }
  if (mysteriesType === "Luminous Mysteries") {
    return [
      "1. The Baptism in the Jordan",
      "2. The Wedding at Cana",
      "3. The Proclamation of the Kingdom",
      "4. The Transfiguration",
      "5. The Institution of the Eucharist"
    ];
  }
  return [];
};

export async function fetchLiturgicalDay(date: Date): Promise<LiturgicalDay | null> {
  try {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    // Check if the given date is actually today
    const now = new Date();
    const isToday = year === now.getFullYear() && date.getMonth() === now.getMonth() && date.getDate() === now.getDate();
    
    const url = isToday 
      ? 'http://calapi.inadiutorium.cz/api/v0/en/calendars/default/today'
      : `http://calapi.inadiutorium.cz/api/v0/en/calendars/default/${year}/${month}/${day}`;

    const response = await fetch(url);
    if (!response.ok) return null;
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch liturgical day:', error);
    return null;
  }
}

export async function fetchDailyDevotion(): Promise<Devotion | null> {
  try {
    const response = await fetch('https://dailylectio.org/devotions.json');
    if (!response.ok) return null;
    const data = await response.json();
    if (Array.isArray(data) && data.length > 0) {
      return data[0] as Devotion;
    }
    return null;
  } catch (error) {
    console.error('Failed to fetch daily devotion:', error);
    return null;
  }
}

export async function getDynamicPrayers(basePrayers: Prayer[], date: Date): Promise<Prayer[]> {
  const dynamicPrayers = structuredClone(basePrayers);

  // 1. Compute local synchronous stuff (Rosary)
  const rosary = dynamicPrayers.find(p => p.id === 'rosary');
  if (rosary) {
    const mysteriesTitle = getRosaryMysteries(date.getDay());
    const mysteriesList = getRosaryMysteryList(mysteriesTitle);

    rosary.sections = [
      {
        title: "TODAY'S MYSTERIES",
        content: mysteriesTitle,
        items: mysteriesList.map(text => ({ text }))
      }
    ];
  }

  // 2. Fetch external data concurrently
  const [liturgicalDay, devotion] = await Promise.all([
    fetchLiturgicalDay(date),
    fetchDailyDevotion()
  ]);

  // 3. Populate Mass
  const mass = dynamicPrayers.find(p => p.id === 'mass');
  if (mass) {
    const sections = [];
    
    // Attempt to extract the season from DailyLectio tags if CalAPI fails
    const devotionTags: string[] = (devotion as any)?.tags || [];
    const knownSeasons = ['advent', 'christmas', 'lent', 'easter', 'ordinary'];
    const fallbackSeason = devotionTags.find(t => knownSeasons.includes(t.toLowerCase()));
    
    if (liturgicalDay && liturgicalDay.celebrations.length > 0) {
      sections.push({
        title: "TODAY'S LITURGY",
        content: liturgicalDay.celebrations[0].title
      });
    } else if (fallbackSeason) {
      sections.push({
        title: "LITURGICAL SEASON",
        content: fallbackSeason.charAt(0).toUpperCase() + fallbackSeason.slice(1)
      });
    } else {
      sections.push({
        title: "SAINT OF THE DAY",
        content: "Roman Calendar"
      });
    }

    if (devotion) {
      const items = [];
      if (devotion.firstReadingRef) items.push({ icon: 'Book', text: devotion.firstReadingRef });
      if (devotion.secondReadingRef) items.push({ icon: 'Book', text: devotion.secondReadingRef });
      if (devotion.psalmRef) items.push({ icon: 'Music', text: devotion.psalmRef });
      if (devotion.gospelRef) items.push({ icon: 'Book', text: devotion.gospelRef });

      sections.push({
        title: "TODAY'S READINGS",
        items
      });
    } else {
      // Graceful fallback if offline or API fails
      sections.push({
        title: "TODAY'S READINGS",
        items: [
          { icon: 'Book', text: 'Daily Reading' },
          { icon: 'Music', text: 'Daily Psalm' },
          { icon: 'Book', text: 'Daily Gospel' },
        ]
      });
    }

    mass.sections = sections;
  }

  if (devotion) {
    // 4. Populate Morning Prayer
    const morning = dynamicPrayers.find(p => p.id === 'morning_prayer');
    if (morning && devotion.dailyPrayer) {
      morning.sections = [
        {
          title: "MORNING OFFERING",
          content: "O Jesus, through the Immaculate Heart of Mary, I offer you my prayers, works, joys, and sufferings of this day in union with the Holy Sacrifice of the Mass throughout the world."
        },
        {
          title: "DAILY DEVOTION",
          content: devotion.dailyPrayer
        }
      ];
    }

    // 5. Populate Bible Reading
    const bible = dynamicPrayers.find(p => p.id === 'bible_reading');
    if (bible && devotion.quote) {
      bible.sections = [
        {
          title: "VERSE OF THE DAY",
          content: `"${devotion.quote}"\n\n— ${devotion.quoteCitation || 'The Gospel'}`
        }
      ];
    }

    // 6. Populate Evening Prayer
    const evening = dynamicPrayers.find(p => p.id === 'evening_prayer');
    if (evening && devotion.saintReflection) {
      evening.sections = [
        {
          title: "EXAMEN",
          content: "Review the day with gratitude. Note where you felt God's presence and where you fell short. Ask for forgiveness and grace for tomorrow."
        },
        {
          title: "EVENING REFLECTION",
          content: devotion.saintReflection
        }
      ];
    }
  }

  return dynamicPrayers;
}
