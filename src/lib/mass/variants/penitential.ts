import type { MassStep, MassOptions } from '../index';

/** Penitential Act — three authorized forms per the Roman Missal. */
export function penitentialActSteps(variant: MassOptions['penitential']): MassStep[] {
  if (variant === 'a') return formA();
  if (variant === 'b') return formB();
  return formC();
}

// ---------------------------------------------------------------------------
// Form A — Confiteor
// ---------------------------------------------------------------------------
function formA(): MassStep[] {
  return [
    {
      id: 'penit.a.confiteor',
      section: 'introductory',
      kind: 'all',
      group: 'penitential',
      variant: 'a',
      title: {
        en: 'Penitential Act — Form A',
        es: 'Acto Penitencial — Forma A',
        de: 'Bußakt — Form A',
      },
      text: {
        en: 'I confess to almighty God\nand to you, my brothers and sisters,\nthat I have greatly sinned,\nin my thoughts and in my words,\nin what I have done and in what I have failed to do,\nthrough my fault, through my fault,\nthrough my most grievous fault;\ntherefore I ask blessed Mary ever-Virgin,\nall the Angels and Saints,\nand you, my brothers and sisters,\nto pray for me to the Lord our God.',
        es: 'Yo confieso ante Dios todopoderoso\ny ante vosotros, hermanos,\nque he pecado mucho\nde pensamiento, palabra, obra y omisión.\nPor mi culpa, por mi culpa,\npor mi gran culpa.\nPor eso ruego a Santa María, siempre Virgen,\na los ángeles, a los santos\ny a vosotros, hermanos,\nque intercedáis por mí ante Dios, nuestro Señor.',
        de: 'Ich bekenne Gott, dem Allmächtigen,\nund allen Brüdern und Schwestern,\ndass ich Gutes unterlassen und Böses getan habe –\nich habe gesündigt in Gedanken, Worten und Werken\ndurch meine Schuld,\ndurch meine Schuld,\ndurch meine große Schuld.\nDarum bitte ich die selige Jungfrau Maria,\nalle Engel und Heiligen\nund euch, Brüder und Schwestern,\nfür mich zu beten bei Gott, unserem Herrn.',
      },
      speaker: 'all',
    },
    {
      id: 'penit.a.absolution',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'a',
      title: {
        en: 'Absolution',
        es: 'Absolución',
        de: 'Absolutionsgebet',
      },
      call: {
        en: 'May almighty God have mercy on us, forgive us our sins, and bring us to everlasting life.',
        es: 'Dios todopoderoso tenga misericordia de nosotros, perdone nuestros pecados y nos lleve a la vida eterna.',
        de: 'Der allmächtige Gott erbarme sich unser. Er lasse uns die Sünden nach und führe uns zum ewigen Leben.',
      },
      response: {
        en: 'Amen.',
        es: 'Amén.',
        de: 'Amen.',
      },
    },
    {
      id: 'penit.a.kyrie',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'a',
      title: {
        en: 'Kyrie',
        es: 'Señor, ten piedad',
        de: 'Kyrie',
      },
      call: {
        en: 'Lord, have mercy.\nChrist, have mercy.\nLord, have mercy.',
        es: 'Señor, ten piedad.\nCristo, ten piedad.\nSeñor, ten piedad.',
        de: 'Herr, erbarme dich.\nChristus, erbarme dich.\nHerr, erbarme dich.',
      },
      response: {
        en: 'Lord, have mercy.\nChrist, have mercy.\nLord, have mercy.',
        es: 'Señor, ten piedad.\nCristo, ten piedad.\nSeñor, ten piedad.',
        de: 'Herr, erbarme dich.\nChristus, erbarme dich.\nHerr, erbarme dich.',
      },
    },
  ];
}

// ---------------------------------------------------------------------------
// Form B — Shorter exchange
// ---------------------------------------------------------------------------
function formB(): MassStep[] {
  return [
    {
      id: 'penit.b.exchange',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'b',
      title: {
        en: 'Penitential Act — Form B',
        es: 'Acto Penitencial — Forma B',
        de: 'Bußakt — Form B',
      },
      call: {
        en: 'Have mercy on us, O Lord.\n\nShow us, O Lord, your mercy.',
        es: 'Señor, ten misericordia de nosotros.\n\nMuéstranos, Señor, tu misericordia.',
        de: 'Erbarme dich unser, o Herr.\n\nErweise uns, Herr, deine Huld.',
      },
      response: {
        en: 'For we have sinned against you.\n\nAnd grant us your salvation.',
        es: 'Porque hemos pecado contra ti.\n\nY danos tu salvación.',
        de: 'Denn wir haben gesündigt gegen dich.\n\nUnd gewähre uns dein Heil.',
      },
    },
    {
      id: 'penit.b.absolution',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'b',
      title: {
        en: 'Absolution',
        es: 'Absolución',
        de: 'Absolutionsgebet',
      },
      call: {
        en: 'May almighty God have mercy on us, forgive us our sins, and bring us to everlasting life.',
        es: 'Dios todopoderoso tenga misericordia de nosotros, perdone nuestros pecados y nos lleve a la vida eterna.',
        de: 'Der allmächtige Gott erbarme sich unser. Er lasse uns die Sünden nach und führe uns zum ewigen Leben.',
      },
      response: {
        en: 'Amen.',
        es: 'Amén.',
        de: 'Amen.',
      },
    },
    {
      id: 'penit.b.kyrie',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'b',
      title: {
        en: 'Kyrie',
        es: 'Señor, ten piedad',
        de: 'Kyrie',
      },
      call: {
        en: 'Lord, have mercy.\nChrist, have mercy.\nLord, have mercy.',
        es: 'Señor, ten piedad.\nCristo, ten piedad.\nSeñor, ten piedad.',
        de: 'Herr, erbarme dich.\nChristus, erbarme dich.\nHerr, erbarme dich.',
      },
      response: {
        en: 'Lord, have mercy.\nChrist, have mercy.\nLord, have mercy.',
        es: 'Señor, ten piedad.\nCristo, ten piedad.\nSeñor, ten piedad.',
        de: 'Herr, erbarme dich.\nChristus, erbarme dich.\nHerr, erbarme dich.',
      },
    },
  ];
}

// ---------------------------------------------------------------------------
// Form C — Kyrie with invocations
// ---------------------------------------------------------------------------
function formC(): MassStep[] {
  return [
    {
      id: 'penit.c.invocation1',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'c',
      title: {
        en: 'Penitential Act — Form C',
        es: 'Acto Penitencial — Forma C',
        de: 'Bußakt — Form C',
      },
      call: {
        en: 'You were sent to heal the contrite of heart:\nLord, have mercy.',
        es: 'Tú que eres enviado a sanar los corazones afligidos:\nSeñor, ten piedad.',
        de: 'Du wurdest gesandt, um die zu heilen, die zerbrochenen Herzens sind:\nHerr, erbarme dich.',
      },
      response: {
        en: 'Lord, have mercy.',
        es: 'Señor, ten piedad.',
        de: 'Herr, erbarme dich.',
      },
    },
    {
      id: 'penit.c.invocation2',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'c',
      call: {
        en: 'You came to call sinners:\nChrist, have mercy.',
        es: 'Tú que has venido a llamar a los pecadores:\nCristo, ten piedad.',
        de: 'Du bist gekommen, um die Sünder zu rufen:\nChristus, erbarme dich.',
      },
      response: {
        en: 'Christ, have mercy.',
        es: 'Cristo, ten piedad.',
        de: 'Christus, erbarme dich.',
      },
    },
    {
      id: 'penit.c.invocation3',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'c',
      call: {
        en: 'You are seated at the right hand of the Father to intercede for us:\nLord, have mercy.',
        es: 'Tú que estás sentado a la derecha del Padre para interceder por nosotros:\nSeñor, ten piedad.',
        de: 'Du sitzt zur Rechten des Vaters und trittst für uns ein:\nHerr, erbarme dich.',
      },
      response: {
        en: 'Lord, have mercy.',
        es: 'Señor, ten piedad.',
        de: 'Herr, erbarme dich.',
      },
    },
    {
      id: 'penit.c.absolution',
      section: 'introductory',
      kind: 'response',
      group: 'penitential',
      variant: 'c',
      title: {
        en: 'Absolution',
        es: 'Absolución',
        de: 'Absolutionsgebet',
      },
      call: {
        en: 'May almighty God have mercy on us, forgive us our sins, and bring us to everlasting life.',
        es: 'Dios todopoderoso tenga misericordia de nosotros, perdone nuestros pecados y nos lleve a la vida eterna.',
        de: 'Der allmächtige Gott erbarme sich unser. Er lasse uns die Sünden nach und führe uns zum ewigen Leben.',
      },
      response: {
        en: 'Amen.',
        es: 'Amén.',
        de: 'Amen.',
      },
    },
  ];
}
