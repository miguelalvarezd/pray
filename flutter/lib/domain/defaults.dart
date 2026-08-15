/// Built-in prayer + activity defaults. Mirrors `DEFAULT_PRAYERS` and
/// `DEFAULT_EXTRA_ACTIVITIES` in `src/types.ts` so a Flutter user's data is
/// indistinguishable from a React user's after a backup round-trip.
library;

import '../data/models/activity_category.dart';
import '../data/models/extra_activity.dart';

class PrayerDefault {
  /// Stable id used in `DailyLog.completedPrayers`.
  final String id;
  final String title;
  final String subtitle;

  /// Lucide icon name (resolved by `lucide_icons_flutter` once we wire it up).
  /// Kept as a string so the data model stays portable across React / Flutter.
  final String icon;

  const PrayerDefault({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

const List<PrayerDefault> kDefaultPrayers = [
  PrayerDefault(
    id: 'morning_prayer',
    title: 'Morning Prayer',
    subtitle: 'LITURGY OF THE HOURS — LAUDS',
    icon: 'Sunrise',
  ),
  PrayerDefault(
    id: 'mass',
    title: 'Holy Mass',
    subtitle: 'SACRAMENTAL LIFE',
    icon: 'Church',
  ),
  PrayerDefault(
    id: 'rosary',
    title: 'Rosary',
    subtitle: 'MARIAN DEVOTION',
    icon: 'Crown',
  ),
  PrayerDefault(
    id: 'evening_prayer',
    title: 'Evening Prayer',
    subtitle: 'LITURGY OF THE HOURS — COMPLINE',
    icon: 'MoonStar',
  ),
  PrayerDefault(
    id: 'bible_reading',
    title: 'Bible Reading',
    subtitle: 'LECTIO DIVINA',
    icon: 'Book',
  ),
];

const List<ExtraActivity> kDefaultExtraActivities = [
  // Sacramental
  ExtraActivity(id: 'confession', name: 'Confession', icon: 'MessageSquareHeart', category: ActivityCategory.sacramental),
  ExtraActivity(id: 'adoration', name: 'Adoration', icon: 'Sun', category: ActivityCategory.sacramental),
  // Devotional
  ExtraActivity(id: 'via_crucis', name: 'Via Crucis', icon: 'Cross', category: ActivityCategory.devotional),
  ExtraActivity(id: 'holy_hour', name: 'Holy Hour', icon: 'Clock', category: ActivityCategory.devotional),
  ExtraActivity(id: 'lectio_divina', name: 'Lectio Divina', icon: 'BookMarked', category: ActivityCategory.devotional),
  ExtraActivity(id: 'divine_mercy', name: 'Divine Mercy Chaplet', icon: 'Droplets', category: ActivityCategory.devotional),
  ExtraActivity(id: 'angelus', name: 'Angelus / Regina Caeli', icon: 'Bell', category: ActivityCategory.devotional),
  ExtraActivity(id: 'litany', name: 'Litany', icon: 'Scroll', category: ActivityCategory.devotional),
  // Service
  ExtraActivity(id: 'volunteering', name: 'Volunteering', icon: 'HandHeart', category: ActivityCategory.service),
  ExtraActivity(id: 'almsgiving', name: 'Almsgiving / Charity', icon: 'HandCoins', category: ActivityCategory.service),
  ExtraActivity(id: 'visiting_sick', name: 'Visiting the Sick', icon: 'HeartHandshake', category: ActivityCategory.service),
  // Spiritual
  ExtraActivity(id: 'spiritual_reading', name: 'Spiritual Reading', icon: 'BookText', category: ActivityCategory.spiritual),
  ExtraActivity(id: 'fasting', name: 'Fasting / Abstinence', icon: 'UtensilsCrossed', category: ActivityCategory.spiritual),
  ExtraActivity(id: 'retreat', name: 'Retreat', icon: 'MountainSnow', category: ActivityCategory.spiritual),
  ExtraActivity(id: 'pilgrimage', name: 'Pilgrimage', icon: 'Compass', category: ActivityCategory.spiritual),
  ExtraActivity(id: 'examination', name: 'Examination of Conscience', icon: 'Brain', category: ActivityCategory.spiritual),
];
