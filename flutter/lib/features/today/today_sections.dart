import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/current_date_provider.dart';
import '../../domain/rosary_engine.dart';
import '../../data/settings/mass_lang.dart';
import '../../services/liturgy/liturgical_calendar.dart';
import '../../services/liturgy/reading_references.dart';

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
/// Mirrors `getDynamicPrayers` in `src/lib/api.ts`. The Holy Mass sections
/// come from the bundled Liturgical Calendar.
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
  return const [
    PrayerSection(
      title: 'MORNING OFFERING',
      content:
          'O Jesus, through the Immaculate Heart of Mary, I offer you my prayers, works, joys, and sufferings of this day in union with the Holy Sacrifice of the Mass throughout the world.',
    ),
  ];
}

List<PrayerSection> _mass(WidgetRef ref) {
  final date = ref.watch(currentDateProvider);
  final lang = ref.watch(massLangProvider);
  final liturgicalDay = ref.watch(liturgicalDayProvider(date));
  if (liturgicalDay == null) return const [];

  return [
    PrayerSection(
      title: "TODAY'S LITURGY",
      content: [
        liturgicalDay.celebration.name(lang),
        for (final m in liturgicalDay.optionalMemorials) 'or ${m.name(lang)}',
      ].join('\n'),
    ),
    if (liturgicalDay.readings.isNotEmpty)
      PrayerSection(
        title: "TODAY'S READINGS",
        items: [
          for (final r in liturgicalDay.readings)
            PrayerItem(
              icon: r.kind == ReadingKind.psalm ? 'Music' : 'Book',
              text: formatReading(r, lang),
            ),
        ],
      ),
  ];
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
  return const [
    PrayerSection(
      title: 'EXAMEN',
      content:
          "Review the day with gratitude. Note where you felt God's presence and where you fell short. Ask for forgiveness and grace for tomorrow.",
    ),
  ];
}

List<PrayerSection> _bible(WidgetRef ref) {
  return const [
    PrayerSection(
      title: 'SUGGESTED READING',
      content: 'Gospel of John, Chapter 15',
    ),
  ];
}
