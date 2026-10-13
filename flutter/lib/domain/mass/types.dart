/// Shared types for the Mass guide. Mirrors `src/lib/mass/index.ts`.
library;

enum Lang {
  en('English', 'English'),
  es('Spanish', 'Español'),
  de('German', 'Deutsch');

  final String label;
  final String native;
  const Lang(this.label, this.native);
}

/// A piece of text available in multiple languages. `en` is required;
/// `es`/`de` fall back to `en` when missing so the UI never blanks out.
class I18nText {
  final String en;
  final String? es;
  final String? de;

  const I18nText({required this.en, this.es, this.de});

  String forLang(Lang lang) {
    switch (lang) {
      case Lang.en:
        return en;
      case Lang.es:
        return es ?? en;
      case Lang.de:
        return de ?? en;
    }
  }
}

enum MassSection { introductory, word, eucharist, concluding }

enum MassStepKind {
  sectionHeader,
  celebrant,
  all,
  response,
  readingPlaceholder,
  silence,
  complete,
}

enum OptionGroup { penitential, creed, eucharistic, mysteryOfFaith }

enum Speaker { priest, all, reader }

enum PenitentialVariant { a, b, c }

enum CreedVariant { nicene, apostles }

enum EucharisticVariant { i, ii, iii, iv }

enum MysteryOfFaithVariant { a, b, c }

class MassOptions {
  final PenitentialVariant penitential;
  final CreedVariant creed;
  final EucharisticVariant eucharistic;
  final MysteryOfFaithVariant mysteryOfFaith;

  const MassOptions({
    this.penitential = PenitentialVariant.a,
    this.creed = CreedVariant.nicene,
    this.eucharistic = EucharisticVariant.ii,
    this.mysteryOfFaith = MysteryOfFaithVariant.a,
  });

  MassOptions copyWith({
    PenitentialVariant? penitential,
    CreedVariant? creed,
    EucharisticVariant? eucharistic,
    MysteryOfFaithVariant? mysteryOfFaith,
  }) =>
      MassOptions(
        penitential: penitential ?? this.penitential,
        creed: creed ?? this.creed,
        eucharistic: eucharistic ?? this.eucharistic,
        mysteryOfFaith: mysteryOfFaith ?? this.mysteryOfFaith,
      );
}

const MassOptions kDefaultMassOptions = MassOptions();

class MassStep {
  final String id;
  final MassSection section;
  final MassStepKind kind;
  final I18nText? title;
  final I18nText? text;

  /// For [MassStepKind.response]: the call (usually spoken by the priest).
  final I18nText? call;

  /// For [MassStepKind.response]: the reply (usually spoken by all).
  final I18nText? response;

  final Speaker? speaker;

  /// Marks this step as belonging to a swappable variant group.
  final OptionGroup? group;

  /// The variant identifier within the group (e.g. 'a', 'ii', 'nicene').
  final String? variant;

  /// Steps with the same mergeGroup are rendered as a single card.
  final String? mergeGroup;

  const MassStep({
    required this.id,
    required this.section,
    required this.kind,
    this.title,
    this.text,
    this.call,
    this.response,
    this.speaker,
    this.group,
    this.variant,
    this.mergeGroup,
  });
}
