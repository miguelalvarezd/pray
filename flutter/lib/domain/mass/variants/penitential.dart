import '../types.dart';

/// Penitential Act — three authorized forms per the Roman Missal.
List<MassStep> penitentialActSteps(PenitentialVariant variant) {
  switch (variant) {
    case PenitentialVariant.a:
      return _formA;
    case PenitentialVariant.b:
      return _formB;
    case PenitentialVariant.c:
      return _formC;
  }
}

const _kyrie = I18nText(
  en: 'Lord, have mercy.\nChrist, have mercy.\nLord, have mercy.',
  es: 'Señor, ten piedad.\nCristo, ten piedad.\nSeñor, ten piedad.',
  de: 'Herr, erbarme dich.\nChristus, erbarme dich.\nHerr, erbarme dich.',
);

// Form A — Confiteor
const List<MassStep> _formA = [
  MassStep(
    id: 'penit.a.confiteor',
    section: MassSection.introductory,
    kind: MassStepKind.all,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'a',
    title: I18nText(
      en: 'Penitential Act — Form A',
      es: 'Acto Penitencial — Forma A',
      de: 'Bußakt — Form A',
    ),
    text: I18nText(
      en:
          'I confess to almighty God\nand to you, my brothers and sisters,\nthat I have greatly sinned,\nin my thoughts and in my words,\nin what I have done and in what I have failed to do,\nthrough my fault, through my fault,\nthrough my most grievous fault;\ntherefore I ask blessed Mary ever-Virgin,\nall the Angels and Saints,\nand you, my brothers and sisters,\nto pray for me to the Lord our God.',
      es:
          'Yo confieso ante Dios todopoderoso\ny ante vosotros, hermanos,\nque he pecado mucho\nde pensamiento, palabra, obra y omisión.\nPor mi culpa, por mi culpa,\npor mi gran culpa.\nPor eso ruego a Santa María, siempre Virgen,\na los ángeles, a los santos\ny a vosotros, hermanos,\nque intercedáis por mí ante Dios, nuestro Señor.',
      de:
          'Ich bekenne Gott, dem Allmächtigen,\nund allen Brüdern und Schwestern,\ndass ich Gutes unterlassen und Böses getan habe –\nich habe gesündigt in Gedanken, Worten und Werken\ndurch meine Schuld,\ndurch meine Schuld,\ndurch meine große Schuld.\nDarum bitte ich die selige Jungfrau Maria,\nalle Engel und Heiligen\nund euch, Brüder und Schwestern,\nfür mich zu beten bei Gott, unserem Herrn.',
    ),
    speaker: Speaker.all,
  ),
  MassStep(
    id: 'penit.a.absolution',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'a',
    title: I18nText(en: 'Absolution', es: 'Absolución', de: 'Absolutionsgebet'),
    call: I18nText(
      en: 'May almighty God have mercy on us, forgive us our sins, and bring us to everlasting life.',
      es: 'Dios todopoderoso tenga misericordia de nosotros, perdone nuestros pecados y nos lleve a la vida eterna.',
      de: 'Der allmächtige Gott erbarme sich unser. Er lasse uns die Sünden nach und führe uns zum ewigen Leben.',
    ),
    response: I18nText(en: 'Amen.', es: 'Amén.', de: 'Amen.'),
  ),
  MassStep(
    id: 'penit.a.kyrie',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'a',
    title: I18nText(en: 'Kyrie', es: 'Señor, ten piedad', de: 'Kyrie'),
    call: _kyrie,
    response: _kyrie,
  ),
];

// Form B — Shorter exchange
const List<MassStep> _formB = [
  MassStep(
    id: 'penit.b.exchange',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'b',
    title: I18nText(
      en: 'Penitential Act — Form B',
      es: 'Acto Penitencial — Forma B',
      de: 'Bußakt — Form B',
    ),
    call: I18nText(
      en: 'Have mercy on us, O Lord.\n\nShow us, O Lord, your mercy.',
      es: 'Señor, ten misericordia de nosotros.\n\nMuéstranos, Señor, tu misericordia.',
      de: 'Erbarme dich unser, o Herr.\n\nErweise uns, Herr, deine Huld.',
    ),
    response: I18nText(
      en: 'For we have sinned against you.\n\nAnd grant us your salvation.',
      es: 'Porque hemos pecado contra ti.\n\nY danos tu salvación.',
      de: 'Denn wir haben gesündigt gegen dich.\n\nUnd gewähre uns dein Heil.',
    ),
  ),
  MassStep(
    id: 'penit.b.absolution',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'b',
    title: I18nText(en: 'Absolution', es: 'Absolución', de: 'Absolutionsgebet'),
    call: I18nText(
      en: 'May almighty God have mercy on us, forgive us our sins, and bring us to everlasting life.',
      es: 'Dios todopoderoso tenga misericordia de nosotros, perdone nuestros pecados y nos lleve a la vida eterna.',
      de: 'Der allmächtige Gott erbarme sich unser. Er lasse uns die Sünden nach und führe uns zum ewigen Leben.',
    ),
    response: I18nText(en: 'Amen.', es: 'Amén.', de: 'Amen.'),
  ),
  MassStep(
    id: 'penit.b.kyrie',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'b',
    title: I18nText(en: 'Kyrie', es: 'Señor, ten piedad', de: 'Kyrie'),
    call: _kyrie,
    response: _kyrie,
  ),
];

// Form C — Kyrie with invocations
const List<MassStep> _formC = [
  MassStep(
    id: 'penit.c.invocation1',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'c',
    title: I18nText(
      en: 'Penitential Act — Form C',
      es: 'Acto Penitencial — Forma C',
      de: 'Bußakt — Form C',
    ),
    call: I18nText(
      en: 'You were sent to heal the contrite of heart:\nLord, have mercy.',
      es: 'Tú que eres enviado a sanar los corazones afligidos:\nSeñor, ten piedad.',
      de: 'Du wurdest gesandt, um die zu heilen, die zerbrochenen Herzens sind:\nHerr, erbarme dich.',
    ),
    response: I18nText(en: 'Lord, have mercy.', es: 'Señor, ten piedad.', de: 'Herr, erbarme dich.'),
  ),
  MassStep(
    id: 'penit.c.invocation2',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'c',
    call: I18nText(
      en: 'You came to call sinners:\nChrist, have mercy.',
      es: 'Tú que has venido a llamar a los pecadores:\nCristo, ten piedad.',
      de: 'Du bist gekommen, um die Sünder zu rufen:\nChristus, erbarme dich.',
    ),
    response: I18nText(en: 'Christ, have mercy.', es: 'Cristo, ten piedad.', de: 'Christus, erbarme dich.'),
  ),
  MassStep(
    id: 'penit.c.invocation3',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'c',
    call: I18nText(
      en: 'You are seated at the right hand of the Father to intercede for us:\nLord, have mercy.',
      es: 'Tú que estás sentado a la derecha del Padre para interceder por nosotros:\nSeñor, ten piedad.',
      de: 'Du sitzt zur Rechten des Vaters und trittst für uns ein:\nHerr, erbarme dich.',
    ),
    response: I18nText(en: 'Lord, have mercy.', es: 'Señor, ten piedad.', de: 'Herr, erbarme dich.'),
  ),
  MassStep(
    id: 'penit.c.absolution',
    section: MassSection.introductory,
    kind: MassStepKind.response,
    mergeGroup: 'intro.penitential',
    group: OptionGroup.penitential,
    variant: 'c',
    title: I18nText(en: 'Absolution', es: 'Absolución', de: 'Absolutionsgebet'),
    call: I18nText(
      en: 'May almighty God have mercy on us, forgive us our sins, and bring us to everlasting life.',
      es: 'Dios todopoderoso tenga misericordia de nosotros, perdone nuestros pecados y nos lleve a la vida eterna.',
      de: 'Der allmächtige Gott erbarme sich unser. Er lasse uns die Sünden nach und führe uns zum ewigen Leben.',
    ),
    response: I18nText(en: 'Amen.', es: 'Amén.', de: 'Amen.'),
  ),
];

