import 'types.dart';
import 'variants/eucharistic.dart';

/// Liturgy of the Eucharist — Preparation of Gifts, Sanctus,
/// Eucharistic Prayer variant, Communion Rite.
List<MassStep> liturgyOfTheEucharistSteps(MassOptions opts) => [
      const MassStep(
        id: 'eucharist.section',
        section: MassSection.eucharist,
        kind: MassStepKind.sectionHeader,
        mergeGroup: 'eucharist.offertory',
        title: I18nText(
          en: 'Liturgy of the Eucharist',
          es: 'Liturgia Eucarística',
          de: 'Eucharistiefeier',
        ),
        text: I18nText(
          en: 'The altar is prepared and the gifts are brought forward.',
          es: 'Se prepara el altar y se presentan las ofrendas.',
          de: 'Der Altar wird bereitet und die Gaben werden hervorgebracht.',
        ),
      ),
      // --- Preparation of the Gifts ---
      const MassStep(
        id: 'eucharist.offertory_bread',
        section: MassSection.eucharist,
        kind: MassStepKind.response,
        mergeGroup: 'eucharist.offertory',
        title: I18nText(
          en: 'Presentation of the Bread',
          es: 'Presentación del pan',
          de: 'Darbietung des Brotes',
        ),
        call: I18nText(
          en: 'Blessed are you, Lord God of all creation, for through your goodness we have received the bread we offer you: fruit of the earth and work of human hands, it will become for us the bread of life.',
          es: 'Bendito seas, Señor, Dios del universo, por este pan, fruto de la tierra y del trabajo del hombre, que recibimos de tu generosidad y ahora te presentamos; él será para nosotros pan de vida.',
          de: 'Gepriesen bist du, Herr, unser Gott, Schöpfer der Welt. Du schenkst uns das Brot, die Frucht der Erde und der menschlichen Arbeit. Wir bringen dir dieses Brot dar, damit es uns wird zum Brot des Lebens.',
        ),
        response: I18nText(
          en: 'Blessed be God for ever.',
          es: 'Bendito seas por siempre, Señor.',
          de: 'Gepriesen sei Gott in Ewigkeit.',
        ),
      ),
      const MassStep(
        id: 'eucharist.offertory_wine',
        section: MassSection.eucharist,
        kind: MassStepKind.response,
        mergeGroup: 'eucharist.offertory',
        title: I18nText(
          en: 'Presentation of the Wine',
          es: 'Presentación del vino',
          de: 'Darbietung des Weines',
        ),
        call: I18nText(
          en: 'Blessed are you, Lord God of all creation, for through your goodness we have received the wine we offer you: fruit of the vine and work of human hands, it will become our spiritual drink.',
          es: 'Bendito seas, Señor, Dios del universo, por este vino, fruto de la vid y del trabajo del hombre, que recibimos de tu generosidad y ahora te presentamos; él será para nosotros bebida de salvación.',
          de: 'Gepriesen bist du, Herr, unser Gott, Schöpfer der Welt. Du schenkst uns den Wein, die Frucht des Weinstocks und der menschlichen Arbeit. Wir bringen dir diesen Kelch dar, damit er uns werde zum Kelch des Heiles.',
        ),
        response: I18nText(
          en: 'Blessed be God for ever.',
          es: 'Bendito seas por siempre, Señor.',
          de: 'Gepriesen sei Gott in Ewigkeit.',
        ),
      ),
      const MassStep(
        id: 'eucharist.lavabo',
        section: MassSection.eucharist,
        kind: MassStepKind.response,
        mergeGroup: 'eucharist.offerings_prayer',
        title: I18nText(
          en: 'Invitation to Prayer',
          es: 'Invitación a la oración',
          de: 'Einladung zum Gebet',
        ),
        call: I18nText(
          en: 'Pray, brethren (brothers and sisters), that my sacrifice and yours may be acceptable to God, the almighty Father.',
          es: 'Orad, hermanos, para que este sacrificio, mío y vuestro, sea agradable a Dios, Padre todopoderoso.',
          de: 'Betet, Brüder und Schwestern, dass mein und euer Opfer Gott, dem allmächtigen Vater, gefalle.',
        ),
        response: I18nText(
          en: 'May the Lord accept the sacrifice at your hands for the praise and glory of his name, for our good and the good of all his holy Church.',
          es: 'El Señor reciba de tus manos este sacrificio, para alabanza y gloria de su nombre, para nuestro bien y el de toda su santa Iglesia.',
          de: 'Der Herr nehme das Opfer an aus deinen Händen zum Lob und Ruhme seines Namens, zum Segen für uns und seine ganze heilige Kirche.',
        ),
      ),
      const MassStep(
        id: 'eucharist.prayer_over_offerings',
        section: MassSection.eucharist,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'eucharist.offerings_prayer',
        title: I18nText(
          en: 'Prayer over the Offerings',
          es: 'Oración sobre las ofrendas',
          de: 'Gabengebet',
        ),
        text: I18nText(
          en: 'The priest says the Prayer over the Offerings proper to the day. Respond "Amen."',
          es: 'El sacerdote dice la Oración sobre las ofrendas propia del día. Responde «Amén».',
          de: 'Der Priester spricht das Gabengebet des Tages. Antworte mit „Amen".',
        ),
      ),
      // --- Eucharistic Prayer variant ---
      ...eucharisticPrayerSteps(opts),
      // --- Communion Rite ---
      const MassStep(
        id: 'eucharist.lords_prayer',
        section: MassSection.eucharist,
        kind: MassStepKind.all,
        title: I18nText(
          en: "The Lord's Prayer",
          es: 'Padrenuestro',
          de: 'Vaterunser',
        ),
        text: I18nText(
          en: 'Our Father, who art in heaven,\nhallowed be thy name;\nthy kingdom come,\nthy will be done\non earth as it is in heaven.\nGive us this day our daily bread,\nand forgive us our trespasses,\nas we forgive those who trespass against us;\nand lead us not into temptation,\nbut deliver us from evil.',
          es: 'Padre nuestro, que estás en el cielo,\nsantificado sea tu Nombre;\nvenga a nosotros tu reino;\nhágase tu voluntad\nen la tierra como en el cielo.\nDanos hoy nuestro pan de cada día;\nperdona nuestras ofensas,\ncomo también nosotros perdonamos\na los que nos ofenden;\nno nos dejes caer en la tentación,\ny líbranos del mal.',
          de: 'Vater unser im Himmel,\ngeheiligt werde dein Name.\nDein Reich komme.\nDein Wille geschehe,\nwie im Himmel, so auf Erden.\nUnser tägliches Brot gib uns heute.\nUnd vergib uns unsere Schuld,\nwie auch wir vergeben unsern Schuldigern.\nUnd führe uns nicht in Versuchung,\nsondern erlöse uns von dem Bösen.',
        ),
        speaker: Speaker.all,
      ),
      const MassStep(
        id: 'eucharist.embolism',
        section: MassSection.eucharist,
        kind: MassStepKind.response,
        mergeGroup: 'eucharist.peace',
        title: I18nText(
          en: 'Embolism & Doxology',
          es: 'Embolismo y aclamación',
          de: 'Embolismus und Lobpreis',
        ),
        call: I18nText(
          en: 'Deliver us, Lord, we pray, from every evil, graciously grant peace in our days, that, by the help of your mercy, we may be always free from sin and safe from all distress, as we await the blessed hope and the coming of our Saviour, Jesus Christ.',
          es: 'Líbranos de todos los males, Señor, y concédenos la paz en nuestros días, para que, ayudados por tu misericordia, vivamos siempre libres de pecado y protegidos de toda perturbación, mientras esperamos la gloriosa venida de nuestro Salvador Jesucristo.',
          de: 'Erlöse uns, Herr, allmächtiger Vater, von allem Bösen und gib Frieden in unseren Tagen. Komm uns zu Hilfe mit deinem Erbarmen und bewahre uns vor Verwirrung und Sünde, damit wir voll Zuversicht das Kommen unseres Erlösers Jesus Christus erwarten.',
        ),
        response: I18nText(
          en: 'For the kingdom, the power and the glory are yours now and for ever.',
          es: 'Tuyo es el reino, tuyo el poder y la gloria, por siempre, Señor.',
          de: 'Denn dein ist das Reich und die Kraft und die Herrlichkeit in Ewigkeit. Amen.',
        ),
      ),
      const MassStep(
        id: 'eucharist.sign_of_peace',
        section: MassSection.eucharist,
        kind: MassStepKind.response,
        mergeGroup: 'eucharist.peace',
        title: I18nText(
          en: 'Sign of Peace',
          es: 'Rito de la paz',
          de: 'Friedensgruß',
        ),
        call: I18nText(
          en: 'The peace of the Lord be with you always.',
          es: 'La paz del Señor esté siempre con vosotros.',
          de: 'Der Friede des Herrn sei allezeit mit euch.',
        ),
        response: I18nText(
          en: 'And with your spirit.',
          es: 'Y con tu espíritu.',
          de: 'Und mit deinem Geiste.',
        ),
      ),
      const MassStep(
        id: 'eucharist.agnus_dei',
        section: MassSection.eucharist,
        kind: MassStepKind.all,
        mergeGroup: 'eucharist.agnus_invite',
        title: I18nText(
          en: 'Lamb of God (Agnus Dei)',
          es: 'Cordero de Dios (Agnus Dei)',
          de: 'Lamm Gottes (Agnus Dei)',
        ),
        text: I18nText(
          en: 'Lamb of God, you take away the sins of the world,\nhave mercy on us.\nLamb of God, you take away the sins of the world,\nhave mercy on us.\nLamb of God, you take away the sins of the world,\ngrant us peace.',
          es: 'Cordero de Dios, que quitas el pecado del mundo,\nten piedad de nosotros.\nCordero de Dios, que quitas el pecado del mundo,\nten piedad de nosotros.\nCordero de Dios, que quitas el pecado del mundo,\ndanos la paz.',
          de: 'Lamm Gottes, du nimmst hinweg die Sünde der Welt,\nerbarme dich unser.\nLamm Gottes, du nimmst hinweg die Sünde der Welt,\nerbarme dich unser.\nLamm Gottes, du nimmst hinweg die Sünde der Welt,\ngib uns deinen Frieden.',
        ),
        speaker: Speaker.all,
      ),
      const MassStep(
        id: 'eucharist.communion_invite',
        section: MassSection.eucharist,
        kind: MassStepKind.response,
        mergeGroup: 'eucharist.agnus_invite',
        title: I18nText(
          en: 'Invitation to Communion',
          es: 'Invitación a la comunión',
          de: 'Einladung zur Kommunion',
        ),
        call: I18nText(
          en: 'Behold the Lamb of God, behold him who takes away the sins of the world. Blessed are those called to the supper of the Lamb.',
          es: 'Éste es el Cordero de Dios, que quita el pecado del mundo. Dichosos los invitados a la cena del Señor.',
          de: 'Seht das Lamm Gottes, das hinwegnimmt die Sünde der Welt. Selig, die zum Mahl des Lammes geladen sind.',
        ),
        response: I18nText(
          en: 'Lord, I am not worthy that you should enter under my roof, but only say the word and my soul shall be healed.',
          es: 'Señor, no soy digno de que entres en mi casa, pero una palabra tuya bastará para sanarme.',
          de: 'Herr, ich bin nicht würdig, dass du eingehst unter mein Dach, aber sprich nur ein Wort, so wird meine Seele gesund.',
        ),
      ),
      const MassStep(
        id: 'eucharist.communion',
        section: MassSection.eucharist,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'eucharist.communion',
        title: I18nText(en: 'Communion', es: 'Comunión', de: 'Kommunion'),
        text: I18nText(
          en: 'Approach to receive Communion. The minister says "The Body of Christ" or "The Blood of Christ." Respond "Amen."',
          es: 'Acércate a recibir la Comunión. El ministro dice «El Cuerpo de Cristo» o «La Sangre de Cristo». Responde «Amén».',
          de: 'Gehe zur Kommunion. Der Ausspender sagt „Der Leib Christi" oder „Das Blut Christi." Antworte „Amen."',
        ),
      ),
      const MassStep(
        id: 'eucharist.communion_silence',
        section: MassSection.eucharist,
        kind: MassStepKind.silence,
        mergeGroup: 'eucharist.communion',
        text: I18nText(
          en: 'A time of silent prayer and thanksgiving after Communion.',
          es: 'Momento de oración y acción de gracias en silencio tras la Comunión.',
          de: 'Stille Zeit des Gebets und der Danksagung nach der Kommunion.',
        ),
      ),
      const MassStep(
        id: 'eucharist.post_communion',
        section: MassSection.eucharist,
        kind: MassStepKind.readingPlaceholder,
        mergeGroup: 'eucharist.communion',
        title: I18nText(
          en: 'Prayer after Communion',
          es: 'Oración después de la comunión',
          de: 'Schlussgebet',
        ),
        text: I18nText(
          en: 'The priest says the Post-Communion prayer proper to the day. Respond "Amen."',
          es: 'El sacerdote dice la Oración después de la Comunión propia del día. Responde «Amén».',
          de: 'Der Priester spricht das Schlussgebet des Tages. Antworte mit „Amen."',
        ),
      ),
    ];
