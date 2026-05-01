import type { MassStep, MassOptions } from './index';
import { creedSteps } from './variants/creed';

/** Liturgy of the Word — readings, Gospel Acclamation, Creed, Prayer of the Faithful. */
export function liturgyOfTheWordSteps(opts: MassOptions): MassStep[] {
  return [
    {
      id: 'word.section',
      section: 'word',
      kind: 'section_header',
      title: {
        en: 'Liturgy of the Word',
        es: 'Liturgia de la Palabra',
        de: 'Wortgottesdienst',
      },
      text: {
        en: 'Sit for the readings. Stand for the Gospel.',
        es: 'Sentaos para las lecturas. Poneos de pie para el Evangelio.',
        de: 'Sitzen für die Lesungen. Stehen für das Evangelium.',
      },
    },

    {
      id: 'word.first_reading',
      section: 'word',
      kind: 'reading_placeholder',
      mergeGroup: 'word.readings',
      title: {
        en: 'First Reading',
        es: 'Primera Lectura',
        de: 'Erste Lesung',
      },
      text: {
        en: 'Listen attentively, then respond "Thanks be to God."',
        es: 'Escucha con atención. Responde: "Te alabamos, Señor."',
        de: 'Höre aufmerksam zu. Antworte: "Dank sei Gott dem Herrn."',
      },
    },

    {
      id: 'word.first_reading_response',
      section: 'word',
      kind: 'response',
      mergeGroup: 'word.readings',
      call: {
        en: 'The word of the Lord.',
        es: 'Palabra de Dios.',
        de: 'Wort des lebendigen Gottes.',
      },
      response: {
        en: 'Thanks be to God.',
        es: 'Te alabamos, Señor.',
        de: 'Dank sei Gott.',
      },
    },

    {
      id: 'word.responsorial_psalm',
      section: 'word',
      kind: 'reading_placeholder',
      mergeGroup: 'word.readings',
      title: {
        en: 'Responsorial Psalm',
        es: 'Salmo Responsorial',
        de: 'Antwortpsalm',
      },
      text: {
        en: 'Listen and respond with the refrain.',
        es: 'Escucha y responde con el estribillo.',
        de: 'Höre zu und antworte mit dem Kehrvers.',
      },
    },

    {
      id: 'word.second_reading',
      section: 'word',
      kind: 'reading_placeholder',
      mergeGroup: 'word.readings',
      title: {
        en: 'Second Reading',
        es: 'Segunda Lectura',
        de: 'Zweite Lesung',
      },
      text: {
        en: 'Listen attentively, then respond "Thanks be to God."',
        es: 'Escucha con atención. Responde: "Te alabamos, Señor."',
        de: 'Höre aufmerksam zu. Antworte: "Dank sei Gott dem Herrn."',
      },
    },

    {
      id: 'word.second_reading_response',
      section: 'word',
      kind: 'response',
      mergeGroup: 'word.readings',
      call: {
        en: 'The word of the Lord.',
        es: 'Palabra de Dios.',
        de: 'Wort des lebendigen Gottes.',
      },
      response: {
        en: 'Thanks be to God.',
        es: 'Te alabamos, Señor.',
        de: 'Dank sei Gott.',
      },
    },

    {
      id: 'word.gospel_acclamation',
      section: 'word',
      kind: 'all',
      mergeGroup: 'word.gospel',
      title: {
        en: 'Gospel Acclamation',
        es: 'Aclamación antes del Evangelio',
        de: 'Ruf vor dem Evangelium',
      },
      text: {
        en: 'Alleluia, alleluia, alleluia.',
        es: 'Aleluya, aleluya, aleluya.',
        de: 'Halleluja, Halleluja, Halleluja.',
      },
      speaker: 'all',
    },

    {
      id: 'word.gospel_announce',
      section: 'word',
      kind: 'response',
      mergeGroup: 'word.gospel',
      title: {
        en: 'Announcement of the Gospel',
        es: 'Anuncio del Evangelio',
        de: 'Ankündigung des Evangeliums',
      },
      call: {
        en: 'A reading from the holy Gospel according to N.',
        es: 'Lectura del santo Evangelio según san N.',
        de: 'Aus dem heiligen Evangelium nach N.',
      },
      response: {
        en: 'Glory to you, O Lord.',
        es: 'Gloria a ti, Señor.',
        de: 'Ehre sei dir, o Herr.',
      },
    },

    {
      id: 'word.gospel',
      section: 'word',
      kind: 'reading_placeholder',
      mergeGroup: 'word.gospel',
      title: {
        en: 'The Gospel',
        es: 'El Evangelio',
        de: 'Das Evangelium',
      },
      text: {
        en: 'Listen to the Gospel proclaimed by the deacon or priest.',
        es: 'Escucha el Evangelio proclamado por el diácono o el sacerdote.',
        de: 'Höre dem Evangelium zu, das der Diakon oder Priester verkündet.',
      },
    },

    {
      id: 'word.gospel_response',
      section: 'word',
      kind: 'response',
      mergeGroup: 'word.gospel',
      call: {
        en: 'The Gospel of the Lord.',
        es: 'Palabra del Señor.',
        de: 'Evangelium des Herrn.',
      },
      response: {
        en: 'Praise to you, Lord Jesus Christ.',
        es: 'Gloria a ti, Señor Jesús.',
        de: 'Lob sei dir, Christus.',
      },
    },

    {
      id: 'word.homily',
      section: 'word',
      kind: 'reading_placeholder',
      mergeGroup: 'word.homily',
      title: {
        en: 'Homily',
        es: 'Homilía',
        de: 'Predigt',
      },
      text: {
        en: 'Sit and listen to the homily. A period of silence may follow.',
        es: 'Sentaos y escuchad la homilía. Puede seguir un momento de silencio.',
        de: 'Sitzen und der Predigt zuhören. Danach folgt eine Zeit der Stille.',
      },
    },

    {
      id: 'word.homily_silence',
      section: 'word',
      kind: 'silence',
      mergeGroup: 'word.homily',
      text: {
        en: 'Pause in silent reflection.',
        es: 'Pausa de reflexión en silencio.',
        de: 'Stille Besinnung.',
      },
    },

    ...creedSteps(opts.creed),

    {
      id: 'word.potf_section',
      section: 'word',
      kind: 'reading_placeholder',
      mergeGroup: 'word.potf',
      title: {
        en: 'Prayer of the Faithful',
        es: 'Oración Universal',
        de: 'Allgemeines Gebet / Fürbitten',
      },
      text: {
        en: 'The priest leads intercessions for the Church, the world, and the local community. Respond as directed.',
        es: 'El sacerdote dirige las intercesiones por la Iglesia, el mundo y la comunidad local. Responde según se indique.',
        de: 'Der Priester leitet die Fürbitten für die Kirche, die Welt und die Gemeinde. Antworte wie angegeben.',
      },
    },

    {
      id: 'word.potf_response',
      section: 'word',
      kind: 'response',
      mergeGroup: 'word.potf',
      title: {
        en: 'Response',
        es: 'Respuesta',
        de: 'Antwort',
      },
      call: {
        en: '(Each intention ends:)\nLet us pray to the Lord.',
        es: '(Cada intención termina:)\nRoguemos al Señor.',
        de: '(Jede Bitte endet:)\nHerr, erhöre unser Gebet.',
      },
      response: {
        en: 'Lord, hear our prayer.',
        es: 'Te rogamos, óyenos.',
        de: 'Herr, erhöre unser Gebet.',
      },
    },
  ];
}
