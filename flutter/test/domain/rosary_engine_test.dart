import 'package:flutter_test/flutter_test.dart';
import 'package:pray/domain/rosary_engine.dart';

void main() {
  group('getMysterySetForDate', () {
    test('Mon → Joyful', () {
      // 2026-05-04 is a Monday.
      expect(getMysterySetForDate(DateTime(2026, 5, 4)).type,
          MysteryType.joyful);
    });

    test('Sat → Joyful', () {
      // 2026-05-02 is a Saturday.
      expect(getMysterySetForDate(DateTime(2026, 5, 2)).type,
          MysteryType.joyful);
    });

    test('Tue/Fri → Sorrowful', () {
      expect(getMysterySetForDate(DateTime(2026, 5, 5)).type,
          MysteryType.sorrowful); // Tue
      expect(getMysterySetForDate(DateTime(2026, 5, 1)).type,
          MysteryType.sorrowful); // Fri
    });

    test('Wed/Sun → Glorious', () {
      expect(getMysterySetForDate(DateTime(2026, 5, 6)).type,
          MysteryType.glorious); // Wed
      expect(getMysterySetForDate(DateTime(2026, 5, 3)).type,
          MysteryType.glorious); // Sun
    });

    test('Thu → Luminous', () {
      expect(getMysterySetForDate(DateTime(2026, 5, 7)).type,
          MysteryType.luminous);
    });
  });

  group('generateRosarySteps', () {
    final steps = generateRosarySteps(kMysterySets[0]);

    test('produces 82 steps total (7 intro + 5×14 decade + 5 closing)', () {
      expect(steps.length, 82);
    });

    test('first step is the opening Sign of the Cross on the crucifix', () {
      expect(steps.first.key, 'sign_of_cross_start');
      expect(steps.first.bead, BeadType.crucifix);
    });

    test('last step is the completion marker', () {
      expect(steps.last.key, 'complete');
      expect(steps.last.type, StepType.complete);
    });

    test('exactly 5 mystery announcements', () {
      final reveals = steps.where((s) => s.type == StepType.mysteryReveal);
      expect(reveals.length, 5);
    });

    test('exactly 50 small-bead Hail Marys in decades', () {
      final decadeHM = steps.where((s) =>
          s.bead == BeadType.small &&
          s.decadeNumber > 0 &&
          s.prayerTitle == 'Hail Mary');
      expect(decadeHM.length, 50);
    });

    test('each decade has exactly 11 tracked beads', () {
      for (var d = 1; d <= 5; d++) {
        final tracked = steps.where(
          (s) => s.decadeNumber == d && s.track?.phase == TrackPhase.decade,
        );
        expect(tracked.length, 11, reason: 'decade $d');
      }
    });

    test('decade announcements carry mystery context', () {
      final firstAnnounce =
          steps.firstWhere((s) => s.type == StepType.mysteryReveal);
      expect(firstAnnounce.mystery, isNotNull);
      expect(firstAnnounce.mystery!.typeLabel, 'Joyful Mysteries');
      expect(firstAnnounce.mystery!.name, 'The Annunciation');
    });
  });
}
