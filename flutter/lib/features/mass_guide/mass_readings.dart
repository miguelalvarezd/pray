import '../../domain/mass/types.dart';
import '../../services/liturgy/liturgical_calendar.dart';
import '../../services/liturgy/reading_references.dart';

/// The Mass Guide's Reading steps, and which Reading each one is.
const _readingSteps = {
  'word.first_reading': ReadingKind.first,
  'word.responsorial_psalm': ReadingKind.psalm,
  'word.second_reading': ReadingKind.second,
  'word.gospel': ReadingKind.gospel,
};

/// Reading References for the Mass Guide's Reading steps, by step id,
/// written in [lang]. A step whose Reading the Day doesn't have (e.g. the
/// Second Reading on a weekday) gets none. On Days with several readings of
/// a kind (the Easter Vigil), the first is shown.
Map<String, String> readingReferencesByStep(LiturgicalDay? day, Lang lang) {
  if (day == null) return const {};
  return {
    for (final MapEntry(key: stepId, value: kind) in _readingSteps.entries)
      if (day.readings.where((r) => r.kind == kind).firstOrNull case final reading?)
        stepId: formatReading(reading, lang),
  };
}
