import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/current_date_provider.dart';
import '../../domain/rosary_engine.dart';
import '../../services/api/lectio_client.dart';
import '../../services/api/litcal_client.dart';

/// One section within an expanded prayer card. Mirrors `PrayerSection` in
/// `src/types.ts`: a header label plus either prose [content] or a list of
/// [items].
class PrayerSection {
  final String title;
  final String? content;
  final List<PrayerItem> items;
  const PrayerSection({required this.title, this.content, this.items = const []});
}

class PrayerItem {
  /// Lucide icon name, optional.
  final String? icon;
  final String text;
  const PrayerItem({this.icon, required this.text});
}

/// Returns the dynamic-content sections for a given default-prayer id.
/// Mirrors `getDynamicPrayers` in `src/lib/api.ts` — pulls from the litcal
/// + lectio clients when available and falls back to the curated defaults.
List<PrayerSection> sectionsFor(WidgetRef ref, String prayerId) {
  switch (prayerId) {
    case 'morning_prayer':
      return _morning(ref);
    case 'mass':
      return _mass(ref);
    case 'rosary':
      return _rosary(ref);
    case 'evening_prayer':
      return _evening(ref);
    case 'bible_reading':
      return _bible(ref);
    default:
      return const [];
  }
}

List<PrayerSection> _morning(WidgetRef ref) {
  final date = ref.watch(currentDateProvider);
  final lectio = ref.watch(dailyLectioProvider(date)).value;
  return [
    const PrayerSection(
      title: 'MORNING OFFERING',
      content:
          'O Jesus, through the Immaculate Heart of Mary, I offer you my prayers, works, joys, and sufferings of this day in union with the Holy Sacrifice of the Mass throughout the world.',
    ),
    if (lectio?.dailyPrayer != null)
      PrayerSection(title: 'DAILY DEVOTION', content: lectio!.dailyPrayer),
  ];
}

List<PrayerSection> _mass(WidgetRef ref) {
  final date = ref.watch(currentDateProvider);
  final day = ref.watch(liturgicalDayProvider(date)).value;
  final lectio = ref.watch(dailyLectioProvider(date)).value;
  final celebration = day?.celebrations.firstOrNull;
  final readings = celebration?.readings;
  final hasLitcalReadings = readings != null &&
      (readings['first_reading'] != null || readings['gospel'] != null);

  final sections = <PrayerSection>[];

  if (celebration != null) {
    sections.add(PrayerSection(
      title: "TODAY'S LITURGY",
      content: celebration.title,
    ));
    if (hasLitcalReadings) {
      sections.add(PrayerSection(
        title: "TODAY'S READINGS",
        items: [
          if (readings['first_reading'] is String)
            PrayerItem(icon: 'Book', text: readings['first_reading'] as String),
          if (readings['responsorial_psalm'] is String)
            PrayerItem(icon: 'Music', text: readings['responsorial_psalm'] as String),
          if (readings['second_reading'] is String)
            PrayerItem(icon: 'Book', text: readings['second_reading'] as String),
          if (readings['gospel'] is String)
            PrayerItem(icon: 'Book', text: readings['gospel'] as String),
        ],
      ));
    }
  } else {
    sections.add(const PrayerSection(
      title: 'SAINT OF THE DAY',
      content: 'Roman Calendar',
    ));
  }

  if (!hasLitcalReadings && lectio != null) {
    sections.add(PrayerSection(
      title: "TODAY'S READINGS",
      items: [
        if (lectio.firstReadingRef != null)
          PrayerItem(icon: 'Book', text: lectio.firstReadingRef!),
        if (lectio.psalmRef != null)
          PrayerItem(icon: 'Music', text: lectio.psalmRef!),
        if (lectio.secondReadingRef != null)
          PrayerItem(icon: 'Book', text: lectio.secondReadingRef!),
        if (lectio.gospelRef != null)
          PrayerItem(icon: 'Book', text: lectio.gospelRef!),
      ],
    ));
  } else if (!hasLitcalReadings) {
    sections.add(const PrayerSection(
      title: "TODAY'S READINGS",
      items: [
        PrayerItem(icon: 'Book', text: 'Daily Reading'),
        PrayerItem(icon: 'Music', text: 'Daily Psalm'),
        PrayerItem(icon: 'Book', text: 'Daily Gospel'),
      ],
    ));
  }
  return sections;
}

List<PrayerSection> _rosary(WidgetRef ref) {
  final date = ref.watch(currentDateProvider);
  final mysterySet = getMysterySetForDate(date);
  return [
    PrayerSection(
      title: "TODAY'S MYSTERIES",
      content: mysterySet.name,
      items: [
        for (final m in mysterySet.mysteries)
          PrayerItem(text: '${m.number}. ${m.name}'),
      ],
    ),
  ];
}

List<PrayerSection> _evening(WidgetRef ref) {
  final date = ref.watch(currentDateProvider);
  final lectio = ref.watch(dailyLectioProvider(date)).value;
  return [
    const PrayerSection(
      title: 'EXAMEN',
      content:
          "Review the day with gratitude. Note where you felt God's presence and where you fell short. Ask for forgiveness and grace for tomorrow.",
    ),
    if (lectio?.saintReflection != null)
      PrayerSection(
          title: 'EVENING REFLECTION', content: lectio!.saintReflection),
  ];
}

List<PrayerSection> _bible(WidgetRef ref) {
  final date = ref.watch(currentDateProvider);
  final lectio = ref.watch(dailyLectioProvider(date)).value;
  final quote = lectio?.quote;
  final citation = lectio?.quoteCitation ?? 'The Gospel';
  if (quote != null) {
    return [
      PrayerSection(
        title: 'VERSE OF THE DAY',
        content: '"$quote"\n\n— $citation',
      ),
    ];
  }
  return const [
    PrayerSection(
      title: 'SUGGESTED READING',
      content: 'Gospel of John, Chapter 15',
    ),
  ];
}
