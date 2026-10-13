import 'types.dart';

const sectionLabels = <MassSection, I18nText>{
  MassSection.introductory: I18nText(
    en: 'Introductory Rites',
    es: 'Ritos Iniciales',
    de: 'Eröffnung',
  ),
  MassSection.word: I18nText(
    en: 'Liturgy of the Word',
    es: 'Liturgia de la Palabra',
    de: 'Wortgottesdienst',
  ),
  MassSection.eucharist: I18nText(
    en: 'Liturgy of the Eucharist',
    es: 'Liturgia Eucarística',
    de: 'Eucharistiefeier',
  ),
  MassSection.concluding: I18nText(
    en: 'Concluding Rites',
    es: 'Ritos de Conclusión',
    de: 'Entlassung',
  ),
};

const optionLabels = <OptionGroup, I18nText>{
  OptionGroup.penitential: I18nText(
    en: 'Penitential Act',
    es: 'Acto Penitencial',
    de: 'Bußakt',
  ),
  OptionGroup.creed: I18nText(
    en: 'Profession of Faith',
    es: 'Profesión de Fe',
    de: 'Glaubensbekenntnis',
  ),
  OptionGroup.eucharistic: I18nText(
    en: 'Eucharistic Prayer',
    es: 'Plegaria Eucarística',
    de: 'Hochgebet',
  ),
  OptionGroup.mysteryOfFaith: I18nText(
    en: 'Mystery of Faith',
    es: 'Misterio de la fe',
    de: 'Geheimnis des Glaubens',
  ),
};

const penitentialVariantLabels = <PenitentialVariant, I18nText>{
  PenitentialVariant.a:
      I18nText(en: 'Form A — Confiteor', es: 'Forma A — Yo confieso', de: 'Form A — Confiteor'),
  PenitentialVariant.b:
      I18nText(en: 'Form B — Shorter', es: 'Forma B — Breve', de: 'Form B — Kurzform'),
  PenitentialVariant.c:
      I18nText(en: 'Form C — Invocations', es: 'Forma C — Invocaciones', de: 'Form C — Anrufungen'),
};

const creedVariantLabels = <CreedVariant, I18nText>{
  CreedVariant.nicene: I18nText(
      en: 'Nicene Creed',
      es: 'Credo Niceno',
      de: 'Großes Glaubensbekenntnis'),
  CreedVariant.apostles: I18nText(
      en: "Apostles' Creed",
      es: 'Símbolo de los Apóstoles',
      de: 'Apostolisches Glaubensbekenntnis'),
};

const eucharisticVariantLabels = <EucharisticVariant, I18nText>{
  EucharisticVariant.i: I18nText(
      en: 'EP I (Roman Canon)',
      es: 'PE I (Canon Romano)',
      de: 'HG I (Römischer Kanon)'),
  EucharisticVariant.ii:
      I18nText(en: 'EP II', es: 'PE II', de: 'HG II'),
  EucharisticVariant.iii:
      I18nText(en: 'EP III', es: 'PE III', de: 'HG III'),
  EucharisticVariant.iv:
      I18nText(en: 'EP IV', es: 'PE IV', de: 'HG IV'),
};

const mysteryOfFaithVariantLabels = <MysteryOfFaithVariant, I18nText>{
  MysteryOfFaithVariant.a: I18nText(
      en: 'Form A — We proclaim',
      es: 'Forma A — Anunciamos',
      de: 'Form A — Deinen Tod'),
  MysteryOfFaithVariant.b: I18nText(
      en: 'Form B — When we eat',
      es: 'Forma B — Cada vez',
      de: 'Form B — Wenn wir dieses'),
  MysteryOfFaithVariant.c: I18nText(
      en: 'Form C — Save us',
      es: 'Forma C — Por tu cruz',
      de: 'Form C — Rette uns'),
};
