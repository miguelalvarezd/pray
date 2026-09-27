import '../core/time/logical_day.dart';

/// One curated reflection. Mirrors `Reflection` in `src/lib/reflections.ts`.
class Reflection {
  final String text;
  final String citation;
  const Reflection(this.text, this.citation);
}

/// The curated Reflections, one shown per Day on Today. Order is identical to
/// `CURATED_REFLECTIONS` so the day-of-year picker yields the same quote in
/// React and Flutter.
const List<Reflection> kCuratedReflections = [
  Reflection('I am the Way, the Truth, and the Life.', 'John 14:6'),
  Reflection('Be still, and know that I am God.', 'Psalm 46:10'),
  Reflection('The Lord is my shepherd, I shall not want.', 'Psalm 23:1'),
  Reflection('Ask, and it will be given to you; seek, and you will find.', 'Matthew 7:7'),
  Reflection('Come to me, all you who labor and are burdened, and I will give you rest.', 'Matthew 11:28'),
  Reflection('Blessed are the pure in heart, for they shall see God.', 'Matthew 5:8'),
  Reflection('Where your treasure is, there also will your heart be.', 'Matthew 6:21'),
  Reflection('Not my will, but yours be done.', 'Luke 22:42'),
  Reflection('Love one another as I have loved you.', 'John 15:12'),
  Reflection('My grace is sufficient for you, for power is made perfect in weakness.', '2 Corinthians 12:9'),
  Reflection('I can do all things through Him who strengthens me.', 'Philippians 4:13'),
  Reflection('Rejoice in the Lord always. I shall say it again: rejoice!', 'Philippians 4:4'),
  Reflection('Pray without ceasing.', '1 Thessalonians 5:17'),
  Reflection('In everything give thanks.', '1 Thessalonians 5:18'),
  Reflection('Behold, I make all things new.', 'Revelation 21:5'),
  Reflection('Everything, to give pleasure to God.', 'St. Thérèse of Lisieux'),
  Reflection('Start by doing what is necessary; then do what is possible; and suddenly you are doing the impossible.', 'St. Francis of Assisi'),
  Reflection('You learn to speak by speaking, to study by studying, to run by running, to work by working; so you learn to love God and man by loving.', 'St. Francis de Sales'),
  Reflection('We can do no great things, only small things with great love.', 'St. Teresa of Calcutta'),
  Reflection('Let nothing disturb you, let nothing frighten you; all things pass; God does not change.', 'St. Teresa of Ávila'),
  Reflection('Silence is the language God speaks, and everything else is a bad translation.', 'Fr. Thomas Keating'),
  Reflection('For where two or three are gathered together in my name, there am I in the midst of them.', 'Matthew 18:20'),
  Reflection('The harvest is abundant but the laborers are few.', 'Matthew 9:37'),
  Reflection('Whatever you did for one of the least of these, you did for me.', 'Matthew 25:40'),
  Reflection('Blessed are the peacemakers, for they shall be called children of God.', 'Matthew 5:9'),
  Reflection('Do not be afraid; just have faith.', 'Mark 5:36'),
  Reflection('Whoever wishes to be great among you will be your servant.', 'Matthew 20:26'),
  Reflection('Your word is a lamp to my feet and a light to my path.', 'Psalm 119:105'),
  Reflection('Cast all your anxieties on him, because he cares for you.', '1 Peter 5:7'),
  Reflection('Faith is the substance of things hoped for, the evidence of things not seen.', 'Hebrews 11:1'),
  Reflection('Charity is the soul of faith, makes it alive; without love, faith dies.', 'St. Anthony of Padua'),
];

/// Deterministically picks a reflection for [date]. Same date → same
/// reflection across React and Flutter (uses 0-indexed day-of-year, matching
/// the React calculation: `start = Jan 0` — i.e. December 31 of the prior year).
Reflection reflectionForDate(DateTime date) {
  // React uses `new Date(year, 0, 0)` which is Dec 31 of the prior year, so
  // diff/86400000 yields a 1-indexed day-of-year. Our `dayOfYear` returns the
  // same number for Jan 1 (=1).
  final n = dayOfYear(date);
  return kCuratedReflections[n % kCuratedReflections.length];
}
