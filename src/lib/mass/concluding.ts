import type { MassStep } from './index';

/** Concluding Rites — Final Blessing and Dismissal. */
export function concludingRitesSteps(): MassStep[] {
  return [
    {
      id: 'concluding.section',
      section: 'concluding',
      kind: 'section_header',
      mergeGroup: 'concluding.header',
      title: {
        en: 'Concluding Rites',
        es: 'Ritos de Conclusión',
        de: 'Entlassung',
      },
      text: {
        en: 'Stand for the final blessing and dismissal.',
        es: 'Poneos de pie para la bendición final y la despedida.',
        de: 'Stehen für den Schlusssegen und die Entlassung.',
      },
    },

    {
      id: 'concluding.announcements',
      section: 'concluding',
      kind: 'reading_placeholder',
      mergeGroup: 'concluding.header',
      title: {
        en: 'Brief Announcements',
        es: 'Breves avisos',
        de: 'Kurze Mitteilungen',
      },
      text: {
        en: 'Brief announcements may be made to the congregation, if necessary.',
        es: 'Se pueden hacer breves avisos a la asamblea, si es necesario.',
        de: 'Gegebenenfalls werden kurze Mitteilungen an die Gemeinde gemacht.',
      },
    },

    {
      id: 'concluding.greeting',
      section: 'concluding',
      kind: 'response',
      mergeGroup: 'concluding.farewell',
      title: {
        en: 'Greeting',
        es: 'Saludo',
        de: 'Gruß',
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
      id: 'concluding.blessing',
      section: 'concluding',
      kind: 'response',
      mergeGroup: 'concluding.farewell',
      title: {
        en: 'Final Blessing',
        es: 'Bendición Final',
        de: 'Schlusssegen',
      },
      call: {
        en: 'May almighty God bless you,\nthe Father, and the Son, ✝ and the Holy Spirit.',
        es: 'La bendición de Dios todopoderoso,\nPadre, Hijo ✝ y Espíritu Santo,\ndescienda sobre vosotros.',
        de: 'Es segne euch der allmächtige Gott,\nder Vater und der Sohn ✝ und der Heilige Geist.',
      },
      response: {
        en: 'Amen.',
        es: 'Amén.',
        de: 'Amen.',
      },
    },

    {
      id: 'concluding.dismissal',
      section: 'concluding',
      kind: 'response',
      mergeGroup: 'concluding.farewell',
      title: {
        en: 'Dismissal',
        es: 'Despedida',
        de: 'Entlassung',
      },
      call: {
        en: 'Go forth, the Mass is ended.',
        es: 'Podéis ir en paz.',
        de: 'Gehet hin in Frieden.',
      },
      response: {
        en: 'Thanks be to God.',
        es: 'Demos gracias a Dios.',
        de: 'Dank sei Gott, dem Herrn.',
      },
    },
  ];
}
