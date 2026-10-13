import 'types.dart';

/// Concluding Rites — Final Blessing and Dismissal.
List<MassStep> concludingRitesSteps() => const [
      MassStep(
        id: 'concluding.section',
        section: MassSection.concluding,
        kind: MassStepKind.sectionHeader,
        mergeGroup: 'concluding.header',
        title: I18nText(
          en: 'Concluding Rites',
          es: 'Ritos de Conclusión',
          de: 'Entlassung',
        ),
        text: I18nText(
          en: 'Stand for the final blessing and dismissal.',
          es: 'Poneos de pie para la bendición final y la despedida.',
          de: 'Stehen für den Schlusssegen und die Entlassung.',
        ),
      ),
      MassStep(
        id: 'concluding.announcements',
        section: MassSection.concluding,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'concluding.header',
        title: I18nText(
          en: 'Brief Announcements',
          es: 'Breves avisos',
          de: 'Kurze Mitteilungen',
        ),
        text: I18nText(
          en: 'Brief announcements may be made to the congregation, if necessary.',
          es: 'Se pueden hacer breves avisos a la asamblea, si es necesario.',
          de: 'Gegebenenfalls werden kurze Mitteilungen an die Gemeinde gemacht.',
        ),
      ),
      MassStep(
        id: 'concluding.greeting',
        section: MassSection.concluding,
        kind: MassStepKind.response,
        mergeGroup: 'concluding.farewell',
        title: I18nText(en: 'Greeting', es: 'Saludo', de: 'Gruß'),
        call: I18nText(
          en: 'The Lord be with you.',
          es: 'El Señor esté con vosotros.',
          de: 'Der Herr sei mit euch.',
        ),
        response: I18nText(
          en: 'And with your spirit.',
          es: 'Y con tu espíritu.',
          de: 'Und mit deinem Geiste.',
        ),
      ),
      MassStep(
        id: 'concluding.blessing',
        section: MassSection.concluding,
        kind: MassStepKind.response,
        mergeGroup: 'concluding.farewell',
        title: I18nText(
          en: 'Final Blessing',
          es: 'Bendición Final',
          de: 'Schlusssegen',
        ),
        call: I18nText(
          en: 'May almighty God bless you,\nthe Father, and the Son, ✝ and the Holy Spirit.',
          es: 'La bendición de Dios todopoderoso,\nPadre, Hijo ✝ y Espíritu Santo,\ndescienda sobre vosotros.',
          de: 'Es segne euch der allmächtige Gott,\nder Vater und der Sohn ✝ und der Heilige Geist.',
        ),
        response: I18nText(en: 'Amen.', es: 'Amén.', de: 'Amen.'),
      ),
      MassStep(
        id: 'concluding.dismissal',
        section: MassSection.concluding,
        kind: MassStepKind.response,
        mergeGroup: 'concluding.farewell',
        title: I18nText(
          en: 'Dismissal',
          es: 'Despedida',
          de: 'Entlassung',
        ),
        call: I18nText(
          en: 'Go forth, the Mass is ended.',
          es: 'Podéis ir en paz.',
          de: 'Gehet hin in Frieden.',
        ),
        response: I18nText(
          en: 'Thanks be to God.',
          es: 'Demos gracias a Dios.',
          de: 'Dank sei Gott, dem Herrn.',
        ),
      ),
    ];
