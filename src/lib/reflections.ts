/**
 * Curated fallback list of short reflections used by the daily rotating
 * quote on the Today page when the remote devotion API is unavailable.
 *
 * These are picked deterministically by day-of-year, so the same day
 * always shows the same reflection across reloads.
 */
export interface Reflection {
  text: string;
  citation: string;
}

export const CURATED_REFLECTIONS: Reflection[] = [
  { text: 'I am the Way, the Truth, and the Life.', citation: 'John 14:6' },
  { text: 'Be still, and know that I am God.', citation: 'Psalm 46:10' },
  { text: 'The Lord is my shepherd, I shall not want.', citation: 'Psalm 23:1' },
  { text: 'Ask, and it will be given to you; seek, and you will find.', citation: 'Matthew 7:7' },
  { text: 'Come to me, all you who labor and are burdened, and I will give you rest.', citation: 'Matthew 11:28' },
  { text: 'Blessed are the pure in heart, for they shall see God.', citation: 'Matthew 5:8' },
  { text: 'Where your treasure is, there also will your heart be.', citation: 'Matthew 6:21' },
  { text: 'Not my will, but yours be done.', citation: 'Luke 22:42' },
  { text: 'Love one another as I have loved you.', citation: 'John 15:12' },
  { text: 'My grace is sufficient for you, for power is made perfect in weakness.', citation: '2 Corinthians 12:9' },
  { text: 'I can do all things through Him who strengthens me.', citation: 'Philippians 4:13' },
  { text: 'Rejoice in the Lord always. I shall say it again: rejoice!', citation: 'Philippians 4:4' },
  { text: 'Pray without ceasing.', citation: '1 Thessalonians 5:17' },
  { text: 'In everything give thanks.', citation: '1 Thessalonians 5:18' },
  { text: 'Behold, I make all things new.', citation: 'Revelation 21:5' },
  { text: 'Everything, to give pleasure to God.', citation: 'St. Thérèse of Lisieux' },
  { text: 'Start by doing what is necessary; then do what is possible; and suddenly you are doing the impossible.', citation: 'St. Francis of Assisi' },
  { text: 'You learn to speak by speaking, to study by studying, to run by running, to work by working; so you learn to love God and man by loving.', citation: 'St. Francis de Sales' },
  { text: 'We can do no great things, only small things with great love.', citation: 'St. Teresa of Calcutta' },
  { text: 'Let nothing disturb you, let nothing frighten you; all things pass; God does not change.', citation: 'St. Teresa of Ávila' },
  { text: 'Silence is the language God speaks, and everything else is a bad translation.', citation: 'Fr. Thomas Keating' },
  { text: 'For where two or three are gathered together in my name, there am I in the midst of them.', citation: 'Matthew 18:20' },
  { text: 'The harvest is abundant but the laborers are few.', citation: 'Matthew 9:37' },
  { text: 'Whatever you did for one of the least of these, you did for me.', citation: 'Matthew 25:40' },
  { text: 'Blessed are the peacemakers, for they shall be called children of God.', citation: 'Matthew 5:9' },
  { text: 'Do not be afraid; just have faith.', citation: 'Mark 5:36' },
  { text: 'Whoever wishes to be great among you will be your servant.', citation: 'Matthew 20:26' },
  { text: 'Your word is a lamp to my feet and a light to my path.', citation: 'Psalm 119:105' },
  { text: 'Cast all your anxieties on him, because he cares for you.', citation: '1 Peter 5:7' },
  { text: 'Faith is the substance of things hoped for, the evidence of things not seen.', citation: 'Hebrews 11:1' },
  { text: 'Charity is the soul of faith, makes it alive; without love, faith dies.', citation: 'St. Anthony of Padua' },
];

/**
 * Deterministically picks a reflection for a given date. Same date → same
 * reflection. Uses day-of-year so the rotation cycles predictably.
 */
export function getReflectionForDate(date: Date): Reflection {
  const start = new Date(date.getFullYear(), 0, 0);
  const diff = date.getTime() - start.getTime();
  const dayOfYear = Math.floor(diff / (1000 * 60 * 60 * 24));
  return CURATED_REFLECTIONS[dayOfYear % CURATED_REFLECTIONS.length];
}
