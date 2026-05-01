import type { MassStep, MassOptions } from './index';
import { penitentialActSteps } from './variants/penitential';

/**
 * Introductory Rites — Sign of the Cross, Greeting, Penitential Act (variant),
 * Gloria, and the Collect placeholder.
 *
 * Kyrie is embedded in the Penitential Act variant (Form A and B end with
 * the Kyrie; Form C subsumes it with invocations).
 */
export function introductoryRitesSteps(opts: MassOptions): MassStep[] {
  return [
    {
      id: 'intro.section',
      section: 'introductory',
      kind: 'section_header',
      mergeGroup: 'intro.opening',
      title: {
        en: 'Introductory Rites',
        es: 'Ritos Iniciales',
        de: 'Eröffnung',
      },
      text: {
        en: 'The people gather. Stand as the priest enters.',
        es: 'La asamblea se reúne. Poneos de pie al entrar el sacerdote.',
        de: 'Die Gemeinde versammelt sich. Stehen, wenn der Priester einzieht.',
      },
    },

    {
      id: 'intro.sign_of_cross',
      section: 'introductory',
      kind: 'celebrant',
      mergeGroup: 'intro.opening',
      title: {
        en: 'Sign of the Cross',
        es: 'Señal de la Cruz',
        de: 'Kreuzzeichen',
      },
      text: {
        en: 'In the name of the Father, and of the Son, and of the Holy Spirit.',
        es: 'En el nombre del Padre, y del Hijo, y del Espíritu Santo.',
        de: 'Im Namen des Vaters und des Sohnes und des Heiligen Geistes.',
      },
      speaker: 'priest',
    },

    {
      id: 'intro.sign_of_cross_amen',
      section: 'introductory',
      kind: 'all',
      mergeGroup: 'intro.opening',
      text: { en: 'Amen.', es: 'Amén.', de: 'Amen.' },
      speaker: 'all',
    },

    {
      id: 'intro.greeting',
      section: 'introductory',
      kind: 'response',
      mergeGroup: 'intro.opening',
      title: {
        en: 'Greeting',
        es: 'Saludo',
        de: 'Liturgischer Gruß',
      },
      call: {
        en: 'The Lord be with you.',
        es: 'El Señor esté con vosotros.',
        de: 'Der Herr sei mit euch.',
      },
      response: {
        en: 'And with your spirit.',
        es: 'Y con tu espíritu.',
        de: 'Und mit deinem Geiste.',
      },
    },

    {
      id: 'intro.penitential_invite',
      section: 'introductory',
      kind: 'celebrant',
      title: {
        en: 'Invitation to the Penitential Act',
        es: 'Invitación al Acto Penitencial',
        de: 'Einladung zum Bußakt',
      },
      text: {
        en: 'Brethren (brothers and sisters), let us acknowledge our sins, and so prepare ourselves to celebrate the sacred mysteries.',
        es: 'Hermanos: para celebrar dignamente estos sagrados misterios, reconozcamos nuestros pecados.',
        de: 'Brüder und Schwestern, damit wir die heiligen Geheimnisse würdig feiern können, wollen wir bekennen, dass wir gesündigt haben.',
      },
      speaker: 'priest',
    },

    ...penitentialActSteps(opts.penitential),

    {
      id: 'intro.gloria',
      section: 'introductory',
      kind: 'all',
      mergeGroup: 'intro.gloria',
      title: { en: 'Gloria', es: 'Gloria', de: 'Gloria' },
      text: {
        en:
          'Glory to God in the highest,\nand on earth peace to people of good will.\n\nWe praise you, we bless you, we adore you, we glorify you, we give you thanks for your great glory, Lord God, heavenly King, O God, almighty Father.\n\nLord Jesus Christ, Only Begotten Son, Lord God, Lamb of God, Son of the Father, you take away the sins of the world, have mercy on us; you take away the sins of the world, receive our prayer; you are seated at the right hand of the Father, have mercy on us.\n\nFor you alone are the Holy One, you alone are the Lord, you alone are the Most High, Jesus Christ, with the Holy Spirit, in the glory of God the Father. Amen.',
        es:
          'Gloria a Dios en el cielo,\ny en la tierra paz a los hombres que ama el Señor.\n\nPor tu inmensa gloria te alabamos, te bendecimos, te adoramos, te glorificamos, te damos gracias, Señor Dios, Rey celestial, Dios Padre todopoderoso.\n\nSeñor, Hijo único, Jesucristo. Señor Dios, Cordero de Dios, Hijo del Padre; tú que quitas el pecado del mundo, ten piedad de nosotros; tú que quitas el pecado del mundo, atiende nuestra súplica; tú que estás sentado a la derecha del Padre, ten piedad de nosotros.\n\nPorque sólo tú eres Santo, sólo tú Señor, sólo tú Altísimo, Jesucristo, con el Espíritu Santo en la gloria de Dios Padre. Amén.',
        de:
          'Ehre sei Gott in der Höhe\nund Friede auf Erden den Menschen seiner Gnade.\n\nWir loben dich, wir preisen dich, wir beten dich an, wir rühmen dich und danken dir, denn groß ist deine Herrlichkeit: Herr und Gott, König des Himmels, Gott und Vater, Herrscher über das All.\n\nHerr, eingeborener Sohn, Jesus Christus. Herr und Gott, Lamm Gottes, Sohn des Vaters: Du nimmst hinweg die Sünde der Welt, erbarme dich unser; du nimmst hinweg die Sünde der Welt, nimm an unser Gebet; du sitzest zur Rechten des Vaters, erbarme dich unser.\n\nDenn du allein bist der Heilige, du allein der Herr, du allein der Höchste, Jesus Christus, mit dem Heiligen Geist, zur Ehre Gottes des Vaters. Amen.',
      },
      speaker: 'all',
    },

    {
      id: 'intro.collect_placeholder',
      section: 'introductory',
      kind: 'reading_placeholder',
      mergeGroup: 'intro.gloria',
      title: {
        en: 'The Collect',
        es: 'Oración Colecta',
        de: 'Tagesgebet',
      },
      text: {
        en: 'The priest invites the faithful to pray, then says the Collect proper to the day. Respond "Amen" when it ends.',
        es: 'El sacerdote invita a orar y dice la Oración Colecta propia del día. Responded «Amén» al concluir.',
        de: 'Der Priester lädt zum Gebet ein und spricht das Tagesgebet. Antworten Sie am Ende mit "Amen".',
      },
    },
  ];
}
