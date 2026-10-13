import 'types.dart';
import 'variants/creed.dart';

/// Liturgy of the Word — readings, Gospel Acclamation, Creed, Prayer of the Faithful.
List<MassStep> liturgyOfTheWordSteps(MassOptions opts) => [
      const MassStep(
        id: 'word.section',
        section: MassSection.word,
        kind: MassStepKind.sectionHeader,
        mergeGroup: 'word.readings',
        title: I18nText(
          en: 'Liturgy of the Word',
          es: 'Liturgia de la Palabra',
          de: 'Wortgottesdienst',
        ),
        text: I18nText(
          en: 'Sit for the readings. Stand for the Gospel.',
          es: 'Sentaos para las lecturas. Poneos de pie para el Evangelio.',
          de: 'Sitzen für die Lesungen. Stehen für das Evangelium.',
        ),
      ),
      const MassStep(
        id: 'word.first_reading',
        section: MassSection.word,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'word.readings',
        title: I18nText(
          en: 'First Reading',
          es: 'Primera Lectura',
          de: 'Erste Lesung',
        ),
        text: I18nText(
          en: 'Listen attentively, then respond "Thanks be to God."',
          es: 'Escucha con atención. Responde: "Te alabamos, Señor."',
          de: 'Höre aufmerksam zu. Antworte: "Dank sei Gott dem Herrn."',
        ),
      ),
      const MassStep(
        id: 'word.first_reading_response',
        section: MassSection.word,
        kind: MassStepKind.response,
        mergeGroup: 'word.readings',
        call: I18nText(
          en: 'The word of the Lord.',
          es: 'Palabra de Dios.',
          de: 'Wort des lebendigen Gottes.',
        ),
        response: I18nText(
          en: 'Thanks be to God.',
          es: 'Te alabamos, Señor.',
          de: 'Dank sei Gott.',
        ),
      ),
      const MassStep(
        id: 'word.responsorial_psalm',
        section: MassSection.word,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'word.readings',
        title: I18nText(
          en: 'Responsorial Psalm',
          es: 'Salmo Responsorial',
          de: 'Antwortpsalm',
        ),
        text: I18nText(
          en: 'Listen and respond with the refrain.',
          es: 'Escucha y responde con el estribillo.',
          de: 'Höre zu und antworte mit dem Kehrvers.',
        ),
      ),
      const MassStep(
        id: 'word.second_reading',
        section: MassSection.word,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'word.readings',
        title: I18nText(
          en: 'Second Reading',
          es: 'Segunda Lectura',
          de: 'Zweite Lesung',
        ),
        text: I18nText(
          en: 'Listen attentively, then respond "Thanks be to God."',
          es: 'Escucha con atención. Responde: "Te alabamos, Señor."',
          de: 'Höre aufmerksam zu. Antworte: "Dank sei Gott dem Herrn."',
        ),
      ),
      const MassStep(
        id: 'word.second_reading_response',
        section: MassSection.word,
        kind: MassStepKind.response,
        mergeGroup: 'word.readings',
        call: I18nText(
          en: 'The word of the Lord.',
          es: 'Palabra de Dios.',
          de: 'Wort des lebendigen Gottes.',
        ),
        response: I18nText(
          en: 'Thanks be to God.',
          es: 'Te alabamos, Señor.',
          de: 'Dank sei Gott.',
        ),
      ),
      const MassStep(
        id: 'word.gospel_acclamation',
        section: MassSection.word,
        kind: MassStepKind.all,
        mergeGroup: 'word.gospel',
        title: I18nText(
          en: 'Gospel Acclamation',
          es: 'Aclamación antes del Evangelio',
          de: 'Ruf vor dem Evangelium',
        ),
        text: I18nText(
          en: 'Alleluia, alleluia, alleluia.',
          es: 'Aleluya, aleluya, aleluya.',
          de: 'Halleluja, Halleluja, Halleluja.',
        ),
        speaker: Speaker.all,
      ),
      const MassStep(
        id: 'word.gospel_announce',
        section: MassSection.word,
        kind: MassStepKind.response,
        mergeGroup: 'word.gospel',
        title: I18nText(
          en: 'Announcement of the Gospel',
          es: 'Anuncio del Evangelio',
          de: 'Ankündigung des Evangeliums',
        ),
        call: I18nText(
          en: 'A reading from the holy Gospel according to N.',
          es: 'Lectura del santo Evangelio según san N.',
          de: 'Aus dem heiligen Evangelium nach N.',
        ),
        response: I18nText(
          en: 'Glory to you, O Lord.',
          es: 'Gloria a ti, Señor.',
          de: 'Ehre sei dir, o Herr.',
        ),
      ),
      const MassStep(
        id: 'word.gospel',
        section: MassSection.word,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'word.gospel',
        title: I18nText(
          en: 'The Gospel',
          es: 'El Evangelio',
          de: 'Das Evangelium',
        ),
        text: I18nText(
          en: 'Listen to the Gospel proclaimed by the deacon or priest.',
          es: 'Escucha el Evangelio proclamado por el diácono o el sacerdote.',
          de: 'Höre dem Evangelium zu, das der Diakon oder Priester verkündet.',
        ),
      ),
      const MassStep(
        id: 'word.gospel_response',
        section: MassSection.word,
        kind: MassStepKind.response,
        mergeGroup: 'word.gospel',
        call: I18nText(
          en: 'The Gospel of the Lord.',
          es: 'Palabra del Señor.',
          de: 'Evangelium des Herrn.',
        ),
        response: I18nText(
          en: 'Praise to you, Lord Jesus Christ.',
          es: 'Gloria a ti, Señor Jesús.',
          de: 'Lob sei dir, Christus.',
        ),
      ),
      const MassStep(
        id: 'word.homily',
        section: MassSection.word,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'word.homily',
        title: I18nText(
          en: 'Homily',
          es: 'Homilía',
          de: 'Predigt',
        ),
        text: I18nText(
          en: 'Sit and listen to the homily. A period of silence may follow.',
          es: 'Sentaos y escuchad la homilía. Puede seguir un momento de silencio.',
          de: 'Sitzen und der Predigt zuhören. Danach folgt eine Zeit der Stille.',
        ),
      ),
      const MassStep(
        id: 'word.homily_silence',
        section: MassSection.word,
        kind: MassStepKind.silence,
        mergeGroup: 'word.homily',
        text: I18nText(
          en: 'Pause in silent reflection.',
          es: 'Pausa de reflexión en silencio.',
          de: 'Stille Besinnung.',
        ),
      ),
      ...creedSteps(opts.creed),
      const MassStep(
        id: 'word.potf_section',
        section: MassSection.word,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'word.potf',
        title: I18nText(
          en: 'Prayer of the Faithful',
          es: 'Oración Universal',
          de: 'Allgemeines Gebet / Fürbitten',
        ),
        text: I18nText(
          en: 'The priest leads intercessions for the Church, the world, and the local community. Respond as directed.',
          es: 'El sacerdote dirige las intercesiones por la Iglesia, el mundo y la comunidad local. Responde según se indique.',
          de: 'Der Priester leitet die Fürbitten für die Kirche, die Welt und die Gemeinde. Antworte wie angegeben.',
        ),
      ),
      const MassStep(
        id: 'word.potf_response',
        section: MassSection.word,
        kind: MassStepKind.response,
        mergeGroup: 'word.potf',
        title: I18nText(en: 'Response', es: 'Respuesta', de: 'Antwort'),
        call: I18nText(
          en: '(Each intention ends:)\nLet us pray to the Lord.',
          es: '(Cada intención termina:)\nRoguemos al Señor.',
          de: '(Jede Bitte endet:)\nHerr, erhöre unser Gebet.',
        ),
        response: I18nText(
          en: 'Lord, hear our prayer.',
          es: 'Te rogamos, óyenos.',
          de: 'Herr, erhöre unser Gebet.',
        ),
      ),
    ];
