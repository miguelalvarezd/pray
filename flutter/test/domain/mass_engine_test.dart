import 'package:flutter_test/flutter_test.dart';
import 'package:pray/domain/mass/index.dart';

void main() {
  group('generateMassSteps', () {
    test('default options yield a non-trivial step list ending in complete', () {
      final steps = generateMassSteps(kDefaultMassOptions);
      expect(steps, isNotEmpty);
      expect(steps.last.kind, MassStepKind.complete);
    });

    test('all four sections are present in default order', () {
      final steps = generateMassSteps(kDefaultMassOptions);
      final sections = steps.map((s) => s.section).toList();
      expect(sections.first, MassSection.introductory);
      // Sections should appear in the canonical Missal order.
      final firstWord = sections.indexOf(MassSection.word);
      final firstEucharist = sections.indexOf(MassSection.eucharist);
      final firstConcluding = sections.indexOf(MassSection.concluding);
      expect(firstWord, greaterThan(0));
      expect(firstEucharist, greaterThan(firstWord));
      expect(firstConcluding, greaterThan(firstEucharist));
    });

    test('penitential variant swap changes the corresponding steps', () {
      final a = generateMassSteps(
          kDefaultMassOptions.copyWith(penitential: PenitentialVariant.a));
      final b = generateMassSteps(
          kDefaultMassOptions.copyWith(penitential: PenitentialVariant.b));
      final c = generateMassSteps(
          kDefaultMassOptions.copyWith(penitential: PenitentialVariant.c));
      final aIds = a
          .where((s) => s.group == OptionGroup.penitential)
          .map((s) => s.id)
          .toList();
      final bIds = b
          .where((s) => s.group == OptionGroup.penitential)
          .map((s) => s.id)
          .toList();
      final cIds = c
          .where((s) => s.group == OptionGroup.penitential)
          .map((s) => s.id)
          .toList();
      expect(aIds.first, startsWith('penit.a.'));
      expect(bIds.first, startsWith('penit.b.'));
      expect(cIds.first, startsWith('penit.c.'));
    });

    test('creed variant swap changes between Nicene and Apostles', () {
      final nicene = generateMassSteps(kDefaultMassOptions);
      final apostles = generateMassSteps(
          kDefaultMassOptions.copyWith(creed: CreedVariant.apostles));
      expect(
        nicene.where((s) => s.group == OptionGroup.creed).single.variant,
        'nicene',
      );
      expect(
        apostles.where((s) => s.group == OptionGroup.creed).single.variant,
        'apostles',
      );
    });

    test('all four eucharistic prayers can be generated', () {
      for (final v in EucharisticVariant.values) {
        final steps =
            generateMassSteps(kDefaultMassOptions.copyWith(eucharistic: v));
        // Each variant should contain its own section header step.
        expect(
          steps.where((s) =>
              s.kind == MassStepKind.sectionHeader &&
              s.group == OptionGroup.eucharistic &&
              s.variant == v.name),
          hasLength(1),
          reason: 'EP ${v.name}',
        );
      }
    });

    test('mystery of faith variant is reflected in the step text', () {
      final a = generateMassSteps(
          kDefaultMassOptions.copyWith(mysteryOfFaith: MysteryOfFaithVariant.a));
      final b = generateMassSteps(
          kDefaultMassOptions.copyWith(mysteryOfFaith: MysteryOfFaithVariant.b));
      final aMof = a
          .firstWhere((s) => s.id.endsWith('.mystery_of_faith'))
          .response!
          .en;
      final bMof = b
          .firstWhere((s) => s.id.endsWith('.mystery_of_faith'))
          .response!
          .en;
      expect(aMof, contains('We proclaim your Death'));
      expect(bMof, contains('When we eat this Bread'));
    });
  });

  group('groupMassSteps', () {
    test('merges consecutive steps with the same mergeGroup', () {
      const a = MassStep(
          id: 'x.1',
          section: MassSection.introductory,
          kind: MassStepKind.celebrant,
          mergeGroup: 'g');
      const b = MassStep(
          id: 'x.2',
          section: MassSection.introductory,
          kind: MassStepKind.all,
          mergeGroup: 'g');
      const c = MassStep(
          id: 'y.1',
          section: MassSection.word,
          kind: MassStepKind.all);
      final groups = groupMassSteps(const [a, b, c]);
      expect(groups, hasLength(2));
      expect(groups[0], hasLength(2));
      expect(groups[1], hasLength(1));
    });
  });

  group('I18nText', () {
    test('falls back to English when target language is missing', () {
      const t = I18nText(en: 'Hello');
      expect(t.forLang(Lang.en), 'Hello');
      expect(t.forLang(Lang.es), 'Hello');
      expect(t.forLang(Lang.de), 'Hello');
    });

    test('returns the requested language when present', () {
      const t = I18nText(en: 'Hi', es: 'Hola', de: 'Hallo');
      expect(t.forLang(Lang.es), 'Hola');
      expect(t.forLang(Lang.de), 'Hallo');
    });
  });
}
