import '../types.dart';

/// Eucharistic Prayer — four authorized forms.
///
/// Each includes: epiclesis, institution narrative (consecration),
/// anamnesis/oblation, intercessions, and doxology. The Sanctus, Mystery
/// of Faith, and Great Amen are shared across all variants and are
/// generated here to keep them in step.
List<MassStep> eucharisticPrayerSteps(MassOptions opts) {
  switch (opts.eucharistic) {
    case EucharisticVariant.i:
      return _epI(opts.mysteryOfFaith);
    case EucharisticVariant.iii:
      return _epIII(opts.mysteryOfFaith);
    case EucharisticVariant.iv:
      return _epIV(opts.mysteryOfFaith);
    case EucharisticVariant.ii:
      return _epII(opts.mysteryOfFaith);
  }
}

class _Shared {
  final MassStep prefaceDialogue;
  final MassStep sanctus;
  final MassStep mysteryOfFaith;
  final MassStep doxology;
  const _Shared({
    required this.prefaceDialogue,
    required this.sanctus,
    required this.mysteryOfFaith,
    required this.doxology,
  });
}

_Shared _shared(String variant, MysteryOfFaithVariant mof) {
  late final I18nText mofCall;
  late final I18nText mofResponse;
  switch (mof) {
    case MysteryOfFaithVariant.c:
      mofCall = const I18nText(
        en: 'The mystery of faith.',
        es: 'Cristo se entregó por nosotros.',
        de: 'Geheimnis des Glaubens.',
      );
      mofResponse = const I18nText(
        en: 'Save us, Savior of the world,\nfor by your Cross and Resurrection\nyou have set us free.',
        es: 'Por tu cruz y resurrección nos has salvado, Señor.\n¡Salvador del mundo, sálvanos!',
        de: 'Rette uns, Heiland der Welt,\nder du durch dein Kreuz und deine Auferstehung\nuns befreit hast.',
      );
    case MysteryOfFaithVariant.b:
      mofCall = const I18nText(
        en: 'The mystery of faith.',
        es: 'Aclamad el misterio de la redención.',
        de: 'Geheimnis des Glaubens.',
      );
      mofResponse = const I18nText(
        en: 'When we eat this Bread and drink this Cup,\nwe proclaim your Death, O Lord,\nuntil you come again.',
        es: 'Cada vez que comemos de este pan y bebemos de este cáliz,\nanunciamos tu muerte, Señor,\nhasta que vuelvas.',
        de: 'Wenn wir dieses Brot essen und aus diesem Kelch trinken,\nverkünden wir deinen Tod, o Herr,\nbis du kommst in Herrlichkeit.',
      );
    case MysteryOfFaithVariant.a:
      mofCall = const I18nText(
        en: 'The mystery of faith.',
        es: 'Éste es el misterio de la fe.',
        de: 'Geheimnis des Glaubens.',
      );
      mofResponse = const I18nText(
        en: 'We proclaim your Death, O Lord,\nand profess your Resurrection\nuntil you come again.',
        es: 'Anunciamos tu muerte,\nproclamamos tu resurrección.\n¡Ven, Señor Jesús!',
        de: 'Deinen Tod, o Herr, verkünden wir,\nund deine Auferstehung preisen wir,\nbis du kommst in Herrlichkeit.',
      );
  }

  return _Shared(
    prefaceDialogue: MassStep(
      id: 'ep.$variant.preface_dialogue',
      section: MassSection.eucharist,
      kind: MassStepKind.response,
      mergeGroup: 'ep.$variant.start',
      group: OptionGroup.eucharistic,
      variant: variant,
      title: const I18nText(
          en: 'Preface Dialogue',
          es: 'Diálogo del Prefacio',
          de: 'Präfationsdialog'),
      call: const I18nText(
        en: 'The Lord be with you.\nLift up your hearts.\nLet us give thanks to the Lord our God.',
        es: 'El Señor esté con vosotros.\nLevantemos el corazón.\nDemos gracias al Señor, nuestro Dios.',
        de: 'Der Herr sei mit euch.\nErhebet die Herzen.\nLasset uns danken dem Herrn, unserm Gott.',
      ),
      response: const I18nText(
        en: 'And with your spirit.\nWe lift them up to the Lord.\nIt is right and just.',
        es: 'Y con tu espíritu.\nLo tenemos levantado hacia el Señor.\nEs justo y necesario.',
        de: 'Und mit deinem Geiste.\nWir haben sie beim Herrn.\nDas ist würdig und recht.',
      ),
    ),
    sanctus: MassStep(
      id: 'ep.$variant.sanctus',
      section: MassSection.eucharist,
      kind: MassStepKind.all,
      group: OptionGroup.eucharistic,
      variant: variant,
      title: const I18nText(
        en: 'Holy, Holy, Holy (Sanctus)',
        es: 'Santo, Santo, Santo (Sanctus)',
        de: 'Heilig, Heilig, Heilig (Sanctus)',
      ),
      text: const I18nText(
        en: 'Holy, Holy, Holy Lord God of hosts.\nHeaven and earth are full of your glory.\nHosanna in the highest.\nBlessed is he who comes in the name of the Lord.\nHosanna in the highest.',
        es: 'Santo, Santo, Santo es el Señor, Dios del universo.\nLlenos están el cielo y la tierra de tu gloria.\nHosanna en el cielo.\nBendito el que viene en nombre del Señor.\nHosanna en el cielo.',
        de: 'Heilig, heilig, heilig, Gott, Herr aller Mächte und Gewalten.\nErfüllt sind Himmel und Erde von deiner Herrlichkeit.\nHosanna in der Höhe.\nHochgelobt sei, der da kommt im Namen des Herrn.\nHosanna in der Höhe.',
      ),
      speaker: Speaker.all,
    ),
    mysteryOfFaith: MassStep(
      id: 'ep.$variant.mystery_of_faith',
      section: MassSection.eucharist,
      kind: MassStepKind.response,
      group: OptionGroup.eucharistic,
      variant: variant,
      title: const I18nText(
          en: 'Mystery of Faith',
          es: 'Misterio de la fe',
          de: 'Geheimnis des Glaubens'),
      call: mofCall,
      response: mofResponse,
    ),
    doxology: MassStep(
      id: 'ep.$variant.doxology',
      section: MassSection.eucharist,
      kind: MassStepKind.response,
      group: OptionGroup.eucharistic,
      variant: variant,
      title: const I18nText(en: 'Doxology', es: 'Doxología', de: 'Doxologie'),
      call: const I18nText(
        en: 'Through him, and with him, and in him, O God, almighty Father, in the unity of the Holy Spirit, all glory and honour is yours, for ever and ever.',
        es: 'Por Cristo, con él y en él, a ti, Dios Padre omnipotente, en la unidad del Espíritu Santo, todo honor y toda gloria, por los siglos de los siglos.',
        de: 'Durch ihn und mit ihm und in ihm ist dir, Gott, allmächtiger Vater, in der Einheit des Heiligen Geistes alle Ehre und Verherrlichung jetzt und in Ewigkeit.',
      ),
      response: const I18nText(en: 'Amen.', es: 'Amén.', de: 'Amen.'),
    ),
  );
}

// ---------------------------------------------------------------------------
// EP I — Roman Canon
// ---------------------------------------------------------------------------
List<MassStep> _epI(MysteryOfFaithVariant mof) {
  final s = _shared('i', mof);
  return [
    const MassStep(
      id: 'ep.i.section',
      section: MassSection.eucharist,
      kind: MassStepKind.sectionHeader,
      mergeGroup: 'ep.i.start',
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Eucharistic Prayer I — The Roman Canon',
        es: 'Plegaria Eucarística I — El Canon Romano',
        de: 'Hochgebet I — Römischer Kanon',
      ),
    ),
    s.prefaceDialogue,
    s.sanctus,
    const MassStep(
      id: 'ep.i.te_igitur',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Opening Prayer (Te igitur)',
        es: 'Oración inicial (Te igitur)',
        de: 'Eröffnungsgebet (Te igitur)',
      ),
      text: I18nText(
        en: 'To you, therefore, most merciful Father, we make humble prayer and petition through Jesus Christ, your Son, our Lord: that you accept and bless these gifts, these offerings, these holy and unblemished sacrifices, which we offer you firstly for your holy catholic Church. Be pleased to grant her peace, to guard, unite and govern her throughout the whole world, together with your servant N. our Pope and N. our Bishop, and all those who, holding to the truth, hand on the catholic and apostolic faith.',
        es: 'A ti, pues, Padre misericordioso, te pedimos y suplicamos por Jesucristo, tu Hijo y Señor nuestro, que aceptes y bendigas estos dones, este presente y este sacrificio santo e inmaculado, que te ofrecemos ante todo por tu santa Iglesia católica: dígnate concederle la paz, protegerla, unirla y gobernarla en todo el mundo, junto con tu siervo el Papa N., con nuestro Obispo N., y con todos los que, fieles a la verdad, promueven la fe católica y apostólica.',
        de: 'Darum bitten wir dich, gütiger Vater, durch Jesus Christus, deinen Sohn, unseren Herrn: Nimm diese Opfergaben gnädig an und segne sie. Wir bringen sie dir dar zunächst für deine heilige, katholische und apostolische Kirche. Schenk ihr deinen Frieden, beschütze sie, einige sie und leite sie auf der ganzen Erde, zusammen mit deinem Diener, unserem Papst N., unserem Bischof N. und allen, die das katholische und apostolische Glaubensgut getreu bewahren.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.memento_vivorum',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Commemoration of the Living',
        es: 'Conmemoración de los vivos',
        de: 'Gedächtnis der Lebenden',
      ),
      text: I18nText(
        en: 'Remember, Lord, your servants N. and N. and all gathered here, whose faith and devotion are known to you. For them we offer you this sacrifice of praise or they offer it for themselves and all who are dear to them: for the redemption of their souls, in hope of health and well-being, and paying their homage to you, the eternal God, living and true.',
        es: 'Acuérdate, Señor, de tus siervos N. y N. y de todos los aquí reunidos, cuya fe y entrega te son conocidas. Por ellos te ofrecemos, o ellos te ofrecen esta oblación de alabanza, por sí mismos y por todos los suyos, en favor de la redención de sus almas, con la esperanza de su salvación y bienestar, y te rinden su homenaje a ti, eterno, vivo y verdadero.',
        de: 'Gedenke, Herr, deiner Diener N. und N. und aller hier Versammelten, deren Glaube und Hingabe dir bekannt sind. Für sie alle bringen wir dir dieses Lobopfer dar oder sie bringen es dar für sich und die Ihrigen, für die Erlösung ihrer Seelen, für die Hoffnung auf ihr Heil und Wohlergehen; und sie weihen ihr Gelübde dir, dem ewigen, lebendigen und wahren Gott.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.communicantes',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'In Communion with the Saints',
        es: 'En comunión con los santos',
        de: 'Gemeinschaft mit den Heiligen',
      ),
      text: I18nText(
        en: 'In communion with those whose memory we venerate, especially the glorious ever-Virgin Mary, Mother of our God and Lord, Jesus Christ, and blessed Joseph, her Spouse, your blessed Apostles and Martyrs, Peter and Paul, Andrew, James, John, Thomas, James, Philip, Bartholomew, Matthew, Simon and Jude; Linus, Cletus, Clement, Sixtus, Cornelius, Cyprian, Lawrence, Chrysogonus, John and Paul, Cosmas and Damian and all your Saints; we ask that through their merits and prayers, in all things we may be defended by your protecting help.',
        es: 'Unidos en la misma fe con la Virgen María, la Madre de Dios, Jesucristo nuestro Señor, con su esposo el bienaventurado José, con tus santos Apóstoles y Mártires, con Pedro y Pablo, Andrés, Santiago, Juan, Tomás, Santiago, Felipe, Bartolomé, Mateo, Simón y Tadeo; con Lino, Cleto, Clemente, Sixto, Cornelio, Cipriano, Lorenzo, Crisógono, Juan y Pablo, Cosme y Damián, y con todos tus santos; por sus méritos e intercesiones protégenos siempre con tu auxilio.',
        de: 'In Gemeinschaft mit der seligen Jungfrau und Gottesmutter Maria, mit deinem seligen Diener, dem Nährvater Jesu Christi, Joseph, mit deinen heiligen Aposteln und Märtyrern: Petrus und Paulus, Andreas, Jakobus, Johannes, Thomas, Jakobus, Philippus, Bartholomäus, Matthäus, Simon und Thaddäus; Linus, Kletus, Klemens, Xystus, Kornelius, Cyprian, Laurentius, Chrysogonus, Johannes und Paulus, Kosmas und Damian und all deinen Heiligen: Durch ihre Verdienste und Gebete schenke uns in allem deinen Schutz.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.hanc_igitur',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Prayer over the Offerings (Hanc igitur)',
        es: 'Oración sobre las ofrendas (Hanc igitur)',
        de: 'Fürbitten über die Gaben (Hanc igitur)',
      ),
      text: I18nText(
        en: 'Therefore, Lord, we pray: graciously accept this oblation of our service, that of your whole family; order our days in your peace, and command that we be delivered from eternal damnation and counted among the flock of those you have chosen.',
        es: 'Por tanto, Señor, te pedimos que recibas propicio esta ofrenda de tus siervos y de toda tu familia santa; ordena en tu paz nuestros días, líbranos de la condenación eterna y cuéntanos en el rebaño de tus elegidos.',
        de: 'Darum bitten wir dich, Herr: Nimm diese Gaben deiner Diener und deiner ganzen Familie gnädig an. Schenk uns deine Güte und deinen Frieden. Reiß uns heraus aus der ewigen Verdammnis und zähle uns zur Herde deiner Auserwählten.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.quam_oblationem',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Epiclesis (Quam oblationem)',
        es: 'Epíclesis (Quam oblationem)',
        de: 'Epiklese (Quam oblationem)',
      ),
      text: I18nText(
        en: 'Be pleased, O God, we pray, to bless, acknowledge, and approve this offering in every respect; make it spiritual and acceptable, so that it may become for us the Body and Blood of your most beloved Son, our Lord Jesus Christ.',
        es: 'Dígnate, oh Dios, bendecir esta ofrenda, aceptarla, aprobarla, hacerla perfecta y agradable, de manera que se convierta para nosotros en el Cuerpo y Sangre de tu amadísimo Hijo, nuestro Señor Jesucristo.',
        de: 'Sei so gütig, Gott, diese Opfergabe in jeder Hinsicht zu segnen, anzunehmen und gutzuheißen. Mach sie vollkommen und annehmbar für dich, damit sie uns zum Leib und Blut deines geliebten Sohnes, unseres Herrn Jesus Christus, werde.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.institution_bread',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Institution Narrative — Bread',
        es: 'Narración de la institución — Pan',
        de: 'Einsetzungsbericht — Brot',
      ),
      text: I18nText(
        en: 'On the day before he was to suffer, he took bread in his holy and venerable hands, and with eyes raised to heaven to you, O God, his almighty Father, giving you thanks, he said the blessing, broke the bread and gave it to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND EAT OF IT,\nFOR THIS IS MY BODY,\nWHICH WILL BE GIVEN UP FOR YOU.',
        es: 'El cual, la víspera de su Pasión, tomó el pan en sus santas y venerables manos, y, con los ojos levantados al cielo, hacia ti, Dios, Padre suyo todopoderoso, dándote gracias, lo bendijo, lo partió y lo dio a sus discípulos, diciendo:\n\nTOMAD Y COMED TODOS DE ÉL,\nPORQUE ESTO ES MI CUERPO,\nQUE SERÁ ENTREGADO POR VOSOTROS.',
        de: 'Er nahm am Tag vor seinem Leiden das Brot in seine heiligen und ehrwürdigen Hände, erhob seine Augen zum Himmel zu dir, Gott, seinem allmächtigen Vater, dankte dir, brach das Brot, reichte es seinen Jüngern und sprach:\n\nNEHMET UND ESSET ALLE DAVON:\nDAS IST MEIN LEIB,\nDER FÜR EUCH HINGEGEBEN WIRD.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.institution_cup',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Institution Narrative — Chalice',
        es: 'Narración de la institución — Cáliz',
        de: 'Einsetzungsbericht — Kelch',
      ),
      text: I18nText(
        en: 'In a similar way, when supper was ended, he took this precious chalice in his holy and venerable hands, and once more giving you thanks, he said the blessing and gave the chalice to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND DRINK FROM IT,\nFOR THIS IS THE CHALICE OF MY BLOOD,\nTHE BLOOD OF THE NEW AND ETERNAL COVENANT,\nWHICH WILL BE POURED OUT FOR YOU AND FOR MANY\nFOR THE FORGIVENESS OF SINS.\nDO THIS IN MEMORY OF ME.',
        es: 'Del mismo modo, acabada la cena, tomó este admirable cáliz en sus santas y venerables manos, y, dándote gracias de nuevo, lo bendijo y lo pasó a sus discípulos, diciendo:\n\nTOMAD Y BEBED TODOS DE ÉL,\nPORQUE ÉSTE ES EL CÁLIZ DE MI SANGRE,\nSANGRE DE LA ALIANZA NUEVA Y ETERNA,\nQUE SERÁ DERRAMADA POR VOSOTROS\nY POR MUCHOS\nPARA EL PERDÓN DE LOS PECADOS.\nHACED ESTO EN CONMEMORACIÓN MÍA.',
        de: 'Ebenso nahm er nach dem Mahl den Kelch in seine heiligen und ehrwürdigen Hände, dankte abermals dir, sprach den Segen, reichte den Kelch seinen Jüngern und sprach:\n\nNEHMET UND TRINKET ALLE DARAUS:\nDAS IST DER KELCH MEINES BLUTES,\nDES BLUTES DES NEUEN UND EWIGEN BUNDES,\nDAS FÜR EUCH UND FÜR ALLE VERGOSSEN WIRD\nZUR VERGEBUNG DER SÜNDEN.\nTUT DIES ZU MEINEM GEDÄCHTNIS.',
      ),
      speaker: Speaker.priest,
    ),
    s.mysteryOfFaith,
    const MassStep(
      id: 'ep.i.unde_et_memores',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Anamnesis (Unde et memores)',
        es: 'Anamnesis (Unde et memores)',
        de: 'Anamnese (Unde et memores)',
      ),
      text: I18nText(
        en: 'Therefore, O Lord, as we celebrate the memorial of the blessed Passion, the Resurrection from the dead, and the glorious Ascension into heaven of Christ, your Son, our Lord, we, your servants and your holy people, offer to your glorious majesty from the gifts that you have given us, this pure victim, this holy victim, this spotless victim, the holy Bread of eternal life and the Chalice of everlasting salvation.',
        es: 'Por eso, Señor, nosotros, tus siervos, y todo tu pueblo santo, al celebrar este memorial de la bienaventurada Pasión, de la Resurrección de los infiernos y de la gloriosa Ascensión a los cielos de Cristo, tu Hijo, Señor nuestro, ofrecemos a tu excelsa majestad, de los bienes que nos has dado, la víctima pura, la víctima santa, la víctima sin mancha, el Pan santo de la vida eterna y el Cáliz de la salvación perpetua.',
        de: 'Darum feiern wir, Herr, das Gedächtnis des seligen Leidens, der Auferstehung aus dem Tod und der glorreichen Himmelfahrt deines Sohnes, unseres Herrn Jesus Christus. Wir, deine Diener und dein heiliges Volk, bringen dir aus deinen Gaben und Gütern das reine, heilige, makellose Opfer dar: das heilige Brot des ewigen Lebens und den Kelch des immerwährenden Heils.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.supplices',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Prayer for the Church',
        es: 'Oración por la Iglesia',
        de: 'Gebet für die Kirche',
      ),
      text: I18nText(
        en: 'In humble prayer we ask you, almighty God: command that these gifts be borne by the hands of your holy Angel to your altar on high in the sight of your divine majesty, so that all of us, who through this participation at the altar receive the most holy Body and Blood of your Son, may be filled with every grace and heavenly blessing.',
        es: 'Te pedimos humildemente, Dios todopoderoso, que esta ofrenda sea llevada a tu presencia, al altar del cielo, por manos de tu ángel, para que cuantos recibamos el Cuerpo y la Sangre de tu Hijo al participar aquí de este altar seamos colmados de gracia y bendición celestial.',
        de: 'Wir bitten dich, allmächtiger Gott: Befiehl, durch die Hände deines heiligen Engels diese Gaben deinem himmlischen Altar zuzutragen, deiner erhabenen Gegenwart. Wenn wir dann an diesem Altar die Kommunion empfangen und den heiligsten Leib und das Blut deines Sohnes zu uns nehmen, lass uns mit jedem Segen des Himmels und jeder Gnade erfüllt werden.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.memento_defunctorum',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'Commemoration of the Departed',
        es: 'Conmemoración de los difuntos',
        de: 'Gedächtnis der Verstorbenen',
      ),
      text: I18nText(
        en: 'Remember also, Lord, your servants N. and N., who have gone before us with the sign of faith and rest in the sleep of peace. Grant them, O Lord, we pray, and all who sleep in Christ, a place of refreshment, light and peace.',
        es: 'Acuérdate también, Señor, de tus siervos N. y N., que nos han precedido con el signo de la fe y duermen ya el sueño de la paz. A ellos, Señor, y a todos los que descansan en Cristo, concédeles el lugar del descanso, de la luz y de la paz.',
        de: 'Gedenke auch, Herr, deiner Diener N. und N., die vor uns hingegangen sind mit dem Zeichen des Glaubens und schlafen im Frieden. Ihnen und allen, die in Christus ruhen, schenke, wie wir bitten, den Ort der Erquickung, des Lichtes und des Friedens.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.i.nobis_quoque',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'i',
      title: I18nText(
        en: 'For Us Sinners',
        es: 'Por nosotros, pecadores',
        de: 'Für uns Sünder',
      ),
      text: I18nText(
        en: 'To us, also, your servants, who, though sinners, hope in your abundant mercies, graciously grant some share and fellowship with your holy Apostles and Martyrs: with John the Baptist, Stephen, Matthias, Barnabas, Ignatius, Alexander, Marcellinus, Peter, Felicity, Perpetua, Agatha, Lucy, Agnes, Cecilia, Anastasia and all your Saints; admit us, we beseech you, into their company, not weighing our merits, but granting us your pardon.',
        es: 'A nosotros, tus siervos pecadores, que esperamos en tu inmensa misericordia, admítenos en la compañía de tus santos Apóstoles y Mártires: Juan, Esteban, Matías, Bernabé, Ignacio, Alejandro, Marcelino, Pedro, Felicidad, Perpetua, Ágata, Lucía, Inés, Cecilia, Anastasia y todos tus Santos. Te pedimos que nos admitas en su compañía, no por nuestros méritos, sino por tu misericordia.',
        de: 'Auch uns Sündern, deinen Dienern, die wir auf deine reiche Barmherzigkeit vertrauen, schenke Gemeinschaft und Anteil mit deinen heiligen Aposteln und Märtyrern: mit Johannes dem Täufer, Stephanus, Matthias, Barnabas, Ignatius, Alexander, Marzellin, Petrus, Felizitas, Perpetua, Agatha, Lucia, Agnes, Cäcilia, Anastasia und all deinen Heiligen. Nimm uns in ihre Gemeinschaft auf, nicht nach unserem Verdienst, sondern nach deiner Vergebung.',
      ),
      speaker: Speaker.priest,
    ),
    s.doxology,
  ];
}

// ---------------------------------------------------------------------------
// EP II
// ---------------------------------------------------------------------------
List<MassStep> _epII(MysteryOfFaithVariant mof) {
  final s = _shared('ii', mof);
  return [
    const MassStep(
      id: 'ep.ii.section',
      section: MassSection.eucharist,
      kind: MassStepKind.sectionHeader,
      mergeGroup: 'ep.ii.start',
      group: OptionGroup.eucharistic,
      variant: 'ii',
      title: I18nText(en: 'Eucharistic Prayer II', es: 'Plegaria Eucarística II', de: 'Hochgebet II'),
    ),
    s.prefaceDialogue,
    const MassStep(
      id: 'ep.ii.preface',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'ii',
      title: I18nText(
        en: 'Preface of Eucharistic Prayer II',
        es: 'Prefacio de la Plegaria Eucarística II',
        de: 'Präfation des Hochgebets II',
      ),
      text: I18nText(
        en: 'It is truly right and just, our duty and our salvation, always and everywhere to give you thanks, Father most holy, through your beloved Son, Jesus Christ, your Word through whom you made all things, whom you sent as our Saviour and Redeemer, incarnate by the Holy Spirit and born of the Virgin.\n\nFulfilling your will and gaining for you a holy people, he stretched out his hands as he endured his Passion, so as to break the bonds of death and manifest the resurrection.\n\nAnd so, with the Angels and all the Saints we declare your glory, as with one voice we acclaim:',
        es: 'En verdad es justo y necesario, es nuestro deber y salvación darte gracias siempre y en todo lugar, Padre santo, a través de tu amado Hijo, Jesucristo, Palabra tuya por quien todo lo has creado, a quien enviaste como Salvador y Redentor, Dios hecho hombre por obra del Espíritu Santo, nacido de María Virgen.\n\nÉl, cumpliendo tu voluntad y adquiriéndote un pueblo santo, extendió sus brazos en la cruz para vencer la muerte y manifestar la resurrección.\n\nPor eso, con los ángeles y los santos, proclamamos tu gloria diciendo a una voz:',
        de: 'In Wahrheit ist es würdig und recht, dir, heiliger Vater, zu danken durch deinen geliebten Sohn Jesus Christus. Er ist dein Wort, durch das du alles erschaffen hast. Ihn hast du gesandt als unseren Heiland und Erlöser; er ist Gott, vom Heiligen Geist empfangen, von der Jungfrau Maria geboren.\n\nEr hat deinen Willen erfüllt und dir ein heiliges Volk erworben, indem er die Arme am Kreuz ausstreckte, um den Tod zu besiegen und die Auferstehung zu offenbaren.\n\nDarum singen wir mit den Engeln und Heiligen dein Lob und bekennen:',
      ),
      speaker: Speaker.priest,
    ),
    s.sanctus,
    const MassStep(
      id: 'ep.ii.epiclesis',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'ii',
      title: I18nText(en: 'Epiclesis', es: 'Epíclesis', de: 'Epiklese'),
      text: I18nText(
        en: 'You are indeed Holy, O Lord, the fount of all holiness.\n\nMake holy, therefore, these gifts, we pray, by sending down your Spirit upon them like the dewfall, so that they may become for us the Body and Blood of our Lord Jesus Christ.',
        es: 'Santo eres en verdad, Señor, fuente de toda santidad.\n\nPor eso te pedimos que santifiques estos dones con la efusión de tu Espíritu, de manera que se conviertan para nosotros en el Cuerpo y la Sangre de nuestro Señor Jesucristo.',
        de: 'Du bist heilig, großer Gott, du bist der Quell aller Heiligkeit.\n\nDarum bitten wir dich: Sende deinen Geist auf diese Gaben herab und heilige sie, damit sie uns werden Leib und Blut unseres Herrn Jesus Christus.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.ii.institution_bread',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'ii',
      title: I18nText(
        en: 'Institution Narrative — Bread',
        es: 'Narración de la institución — Pan',
        de: 'Einsetzungsbericht — Brot',
      ),
      text: I18nText(
        en: 'At the time he was betrayed and entered willingly into his Passion, he took bread and, giving thanks, broke it, and gave it to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND EAT OF IT,\nFOR THIS IS MY BODY,\nWHICH WILL BE GIVEN UP FOR YOU.',
        es: 'Él, cuando iba a ser entregado a su Pasión voluntariamente aceptada, tomó el pan, dándote gracias, lo partió y lo dio a sus discípulos, diciendo:\n\nTOMAD Y COMED TODOS DE ÉL,\nPORQUE ESTO ES MI CUERPO,\nQUE SERÁ ENTREGADO POR VOSOTROS.',
        de: 'In der Nacht, da er ausgeliefert wurde und sich aus freiem Willen dem Leiden hingab, nahm er das Brot und sagte Dank, brach es und reichte es seinen Jüngern mit den Worten:\n\nNEHMET UND ESSET ALLE DAVON:\nDAS IST MEIN LEIB,\nDER FÜR EUCH HINGEGEBEN WIRD.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.ii.institution_cup',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'ii',
      title: I18nText(
        en: 'Institution Narrative — Chalice',
        es: 'Narración de la institución — Cáliz',
        de: 'Einsetzungsbericht — Kelch',
      ),
      text: I18nText(
        en: 'In a similar way, when supper was ended, he took the chalice and, once more giving thanks, he gave it to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND DRINK FROM IT,\nFOR THIS IS THE CHALICE OF MY BLOOD,\nTHE BLOOD OF THE NEW AND ETERNAL COVENANT,\nWHICH WILL BE POURED OUT FOR YOU AND FOR MANY\nFOR THE FORGIVENESS OF SINS.\nDO THIS IN MEMORY OF ME.',
        es: 'Del mismo modo, acabada la cena, tomó el cáliz, te dio gracias de nuevo y lo pasó a sus discípulos, diciendo:\n\nTOMAD Y BEBED TODOS DE ÉL,\nPORQUE ÉSTE ES EL CÁLIZ DE MI SANGRE,\nSANGRE DE LA ALIANZA NUEVA Y ETERNA,\nQUE SERÁ DERRAMADA POR VOSOTROS\nY POR MUCHOS\nPARA EL PERDÓN DE LOS PECADOS.\nHACED ESTO EN CONMEMORACIÓN MÍA.',
        de: 'Ebenso nahm er nach dem Mahl den Kelch, dankte abermals und reichte ihn seinen Jüngern mit den Worten:\n\nNEHMET UND TRINKET ALLE DARAUS:\nDAS IST DER KELCH MEINES BLUTES,\nDES BLUTES DES NEUEN UND EWIGEN BUNDES,\nDAS FÜR EUCH UND FÜR ALLE VERGOSSEN WIRD\nZUR VERGEBUNG DER SÜNDEN.\nTUT DIES ZU MEINEM GEDÄCHTNIS.',
      ),
      speaker: Speaker.priest,
    ),
    s.mysteryOfFaith,
    const MassStep(
      id: 'ep.ii.anamnesis',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'ii',
      title: I18nText(en: 'Anamnesis', es: 'Anamnesis', de: 'Anamnese'),
      text: I18nText(
        en: 'Therefore, as we celebrate the memorial of his Death and Resurrection, we offer you, Lord, the Bread of life and the Chalice of salvation, giving thanks that you have held us worthy to be in your presence and minister to you.\n\nHumbly we pray that, partaking of the Body and Blood of Christ, we may be gathered into one by the Holy Spirit.',
        es: 'Así, pues, al celebrar ahora el memorial de su muerte y resurrección, te ofrecemos, Señor, el pan de vida y el cáliz de salvación, y te damos gracias porque nos haces dignos de servirte en tu presencia.\n\nTe pedimos humildemente que el Espíritu Santo congregue en la unidad a cuantos participamos del Cuerpo y Sangre de Cristo.',
        de: 'Daher feiern wir das Gedächtnis seines Todes und seiner Auferstehung und bringen dir, Herr, das Brot des Lebens und den Kelch des Heils dar. Wir danken dir, dass du uns berufen hast, vor dir zu stehen und dir zu dienen.\n\nWir bitten dich: Lass uns durch die Gemeinschaft am Leib und Blut Christi vom Heiligen Geist zusammengeführt werden.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.ii.intercessions',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'ii',
      title: I18nText(en: 'Intercessions', es: 'Intercesiones', de: 'Fürbitten'),
      text: I18nText(
        en: 'Remember, Lord, your Church, spread throughout the world, and bring her to the fullness of charity, together with N. our Pope and N. our Bishop and all the clergy.\n\nRemember also our brothers and sisters who have fallen asleep in the hope of the resurrection, and all who have died in your mercy: welcome them into the light of your face.\n\nHave mercy on us all, we pray, that with the Blessed Virgin Mary, Mother of God, with blessed Joseph, her Spouse, with the blessed Apostles, and all the Saints who have pleased you throughout the ages, we may merit to be co-heirs to eternal life.',
        es: 'Acuérdate, Señor, de tu Iglesia extendida por toda la tierra; perfecciónala en la caridad junto con el Papa N., nuestro Obispo N. y todos los ministros sagrados.\n\nAcuérdate también de nuestros hermanos que se durmieron en la esperanza de la resurrección y de todos los que han muerto en tu misericordia: admítelos a contemplar la luz de tu rostro.\n\nCompadécete de todos nosotros, y así, con la Virgen María, Madre de Dios, con san José, esposo de la Virgen, con los apóstoles y todos los santos que a lo largo de la historia te han agradado, merezcamos, por tu gracia, compartir la vida eterna.',
        de: 'Gedenke, Herr, deiner Kirche auf der ganzen Welt und vollende sie in der Liebe, zusammen mit unserem Papst N., unserem Bischof N. und allen Dienern deiner Kirche.\n\nGedenke auch unserer Brüder und Schwestern, die in der Hoffnung auf die Auferstehung entschlafen sind, und all derer, die in deiner Barmherzigkeit verstorben sind. Nimm sie auf in das Licht deines Angesichts.\n\nErbarme dich unser aller. Zusammen mit der seligen Jungfrau und Gottesmutter Maria, mit dem heiligen Joseph, ihrem Bräutigam, mit den Aposteln und allen Heiligen, die dir wohlgefällig waren, sollen wir durch deine Gnade das ewige Leben erlangen.',
      ),
      speaker: Speaker.priest,
    ),
    s.doxology,
  ];
}

// ---------------------------------------------------------------------------
// EP III
// ---------------------------------------------------------------------------
List<MassStep> _epIII(MysteryOfFaithVariant mof) {
  final s = _shared('iii', mof);
  return [
    const MassStep(
      id: 'ep.iii.section',
      section: MassSection.eucharist,
      kind: MassStepKind.sectionHeader,
      mergeGroup: 'ep.iii.start',
      group: OptionGroup.eucharistic,
      variant: 'iii',
      title: I18nText(en: 'Eucharistic Prayer III', es: 'Plegaria Eucarística III', de: 'Hochgebet III'),
    ),
    s.prefaceDialogue,
    s.sanctus,
    const MassStep(
      id: 'ep.iii.opening',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iii',
      title: I18nText(en: 'Opening Prayer', es: 'Oración inicial', de: 'Eröffnungsgebet'),
      text: I18nText(
        en: 'You are indeed Holy, O Lord, and all you have created rightly gives you praise, for through your Son our Lord Jesus Christ, by the power and working of the Holy Spirit, you give life to all things and make them holy, and you never cease to gather a people to yourself, so that from the rising of the sun to its setting a pure sacrifice may be offered to your name.',
        es: 'Santo eres en verdad, Padre, y con razón te alaban todas tus criaturas, ya que por Jesucristo, tu Hijo, Señor nuestro, con la fuerza del Espíritu Santo, das vida y santificas todo, y congregas ante ti un pueblo que, desde el oriente hasta el occidente, ofrezca en tu nombre un sacrificio perfecto.',
        de: 'Du bist heilig, Herr, starker Gott. Alle Schöpfung lobt dich mit Recht, denn durch Jesus Christus, deinen Sohn und unseren Herrn, durch die Kraft und Wirkung des Heiligen Geistes belebst und heiligst du das All. Du berufst immerfort ein Volk, das dir von Aufgang bis Untergang der Sonne ein reines Opfer darbringt.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iii.epiclesis',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iii',
      title: I18nText(en: 'Epiclesis', es: 'Epíclesis', de: 'Epiklese'),
      text: I18nText(
        en: 'Therefore, O Lord, we humbly implore you: by the same Spirit graciously make holy these gifts we have brought to you for consecration, that they may become the Body and Blood of your Son our Lord Jesus Christ, at whose command we celebrate these mysteries.',
        es: 'Por eso, Padre, te suplicamos que santifiques por el mismo Espíritu estos dones que hemos separado para ti, de manera que se conviertan en el Cuerpo y la Sangre de tu Hijo Jesucristo, Señor nuestro, que nos mandó celebrar estos misterios.',
        de: 'Darum bitten wir dich, heiliger Vater: Heilige durch denselben Geist diese Gaben, die wir dir zur Weihe dargebracht haben, damit sie werden Leib und Blut deines Sohnes Jesus Christus, unseres Herrn, der uns aufgetragen hat, dieses Geheimnis zu feiern.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iii.institution_bread',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iii',
      title: I18nText(en: 'Institution Narrative — Bread', es: 'Narración de la institución — Pan', de: 'Einsetzungsbericht — Brot'),
      text: I18nText(
        en: 'For on the night he was betrayed he himself took bread, and, giving you thanks, he said the blessing, broke the bread and gave it to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND EAT OF IT,\nFOR THIS IS MY BODY,\nWHICH WILL BE GIVEN UP FOR YOU.',
        es: 'Porque él mismo, la noche en que iba a ser entregado, tomó el pan, te dio gracias, lo partió y lo dio a sus discípulos, diciendo:\n\nTOMAD Y COMED TODOS DE ÉL,\nPORQUE ESTO ES MI CUERPO,\nQUE SERÁ ENTREGADO POR VOSOTROS.',
        de: 'Er hat in der Nacht, da er ausgeliefert wurde, das Brot in seine Hände genommen, dir, seinem Vater, Dank gesagt, das Brot gebrochen und seinen Jüngern gereicht mit den Worten:\n\nNEHMET UND ESSET ALLE DAVON:\nDAS IST MEIN LEIB,\nDER FÜR EUCH HINGEGEBEN WIRD.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iii.institution_cup',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iii',
      title: I18nText(en: 'Institution Narrative — Chalice', es: 'Narración de la institución — Cáliz', de: 'Einsetzungsbericht — Kelch'),
      text: I18nText(
        en: 'In a similar way, when supper was ended, he took the chalice, and, giving you thanks, he said the blessing, and gave the chalice to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND DRINK FROM IT,\nFOR THIS IS THE CHALICE OF MY BLOOD,\nTHE BLOOD OF THE NEW AND ETERNAL COVENANT,\nWHICH WILL BE POURED OUT FOR YOU AND FOR MANY\nFOR THE FORGIVENESS OF SINS.\nDO THIS IN MEMORY OF ME.',
        es: 'Del mismo modo, acabada la cena, tomó el cáliz, te dio gracias y lo pasó a sus discípulos, diciendo:\n\nTOMAD Y BEBED TODOS DE ÉL,\nPORQUE ÉSTE ES EL CÁLIZ DE MI SANGRE,\nSANGRE DE LA ALIANZA NUEVA Y ETERNA,\nQUE SERÁ DERRAMADA POR VOSOTROS\nY POR MUCHOS\nPARA EL PERDÓN DE LOS PECADOS.\nHACED ESTO EN CONMEMORACIÓN MÍA.',
        de: 'Ebenso nahm er nach dem Mahl den Kelch, dankte dir abermals, reichte ihn seinen Jüngern und sprach:\n\nNEHMET UND TRINKET ALLE DARAUS:\nDAS IST DER KELCH MEINES BLUTES,\nDES BLUTES DES NEUEN UND EWIGEN BUNDES,\nDAS FÜR EUCH UND FÜR ALLE VERGOSSEN WIRD\nZUR VERGEBUNG DER SÜNDEN.\nTUT DIES ZU MEINEM GEDÄCHTNIS.',
      ),
      speaker: Speaker.priest,
    ),
    s.mysteryOfFaith,
    const MassStep(
      id: 'ep.iii.anamnesis',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iii',
      title: I18nText(en: 'Anamnesis & Oblation', es: 'Anamnesis y oblación', de: 'Anamnese und Darbringung'),
      text: I18nText(
        en: 'Therefore, O Lord, as we celebrate the memorial of the saving Passion of your Son, his wondrous Resurrection and Ascension into heaven, and as we look forward to his second coming, we offer you in thanksgiving this holy and living sacrifice.\n\nLook, we pray, upon the oblation of your Church and, recognizing the sacrificial Victim by whose death you willed to reconcile us to yourself, grant that we, who are nourished by the Body and Blood of your Son and filled with his Holy Spirit, may become one body, one spirit in Christ.',
        es: 'Por eso, Padre, al celebrar ahora el memorial de la pasión salvadora de tu Hijo, de su admirable resurrección y ascensión al cielo, mientras esperamos su venida gloriosa, te ofrecemos, en esta acción de gracias, el sacrificio vivo y santo.\n\nDirige tu mirada sobre la ofrenda de tu Iglesia y reconoce en ella la víctima por cuya inmolación quisiste reconciliarnos contigo; y concede que cuantos compartimos este cuerpo y esta sangre de tu Hijo, formemos un solo cuerpo y un solo espíritu en Cristo.',
        de: 'Darum feiern wir, Herr, das Gedächtnis des heilbringenden Leidens deines Sohnes, seiner wunderbaren Auferstehung und Himmelfahrt. Wir erwarten seine Wiederkunft in Herrlichkeit und bringen dir in dieser Danksagung das lebendige und heilige Opfer dar.\n\nSchau auf das Opfer deiner Kirche und erkenne darin das Opferlamm, durch dessen Tod du uns mit dir versöhnen wolltest. Gib, dass wir, gestärkt mit dem Leib und Blut deines Sohnes und erfüllt vom Heiligen Geist, ein Leib und ein Geist in Christus werden.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iii.intercessions',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iii',
      title: I18nText(en: 'Intercessions', es: 'Intercesiones', de: 'Fürbitten'),
      text: I18nText(
        en: 'May he make of us an eternal offering to you, so that we may obtain an inheritance with your elect, especially with the most Blessed Virgin Mary, Mother of God, with blessed Joseph, her Spouse, with your blessed Apostles and glorious Martyrs and with all the Saints, on whose constant intercession in your presence we rely for unfailing help.\n\nMay this Sacrifice of our reconciliation, we pray, O Lord, advance the peace and salvation of all the world. Be pleased to confirm in faith and charity your pilgrim Church on earth, with your servant N. our Pope and N. our Bishop, the Order of Bishops, all the clergy, and the entire people you have gained for your own.\n\nRemember your servants N. and N., whom you have called from this world to yourself. Grant that they, who were united with your Son in a death like his, may also be one with him in his Resurrection.',
        es: 'Que él nos transforme en ofrenda permanente, para que gocemos de tu heredad junto con tus elegidos: principalmente con la Virgen María, la Madre de Dios, con José, el esposo de la Virgen, con los apóstoles y los mártires y todos los santos, que en todo tiempo te agradaron, para que, sostenidos por su intercesión y por tu auxilio, te alabemos por Jesucristo, tu Hijo amado.\n\nY ahora te pedimos, Padre, que este sacrificio de reconciliación lleve la paz y la salvación al mundo entero. Confirma en la fe y en la caridad a tu Iglesia, peregrina en la tierra: a tu siervo el Papa N., a nuestro Obispo N., al orden episcopal, al clero y a todo el pueblo redimido por ti.\n\nEscucha las oraciones de esta familia que has congregado en tu presencia. En tu misericordia, Padre, reúne a todos tus hijos dispersos por el mundo. Recibe con bondad, Padre misericordioso, a nuestros hermanos difuntos y a todos los que murieron en tu amistad; llévalos a contemplar la luz de tu rostro.',
        de: 'Er mache uns zur ewigen Gabe für dich, damit wir das Erbe erlangen bei deinen Auserwählten, vor allem bei der seligen Jungfrau und Gottesmutter Maria, bei dem heiligen Joseph, ihrem Bräutigam, bei deinen heiligen Aposteln und Märtyrern und bei allen Heiligen, auf deren Fürsprache wir uns immer verlassen.\n\nDieses Versöhnungsopfer bringe, so bitten wir, Friede und Heil für die ganze Welt. Stärke im Glauben und in der Liebe deine Kirche auf ihrem Weg durch die Zeit: deinen Diener, unseren Papst N., unseren Bischof N., alle Bischöfe, Priester und Diakone und das ganze Volk, das du dir erworben hast.\n\nGedenke deiner Diener N. und N., die du aus dieser Welt zu dir gerufen hast. Da sie dem Tod deines Sohnes gleichgestaltet wurden, lass sie auch seiner Auferstehung teilhaftig werden.',
      ),
      speaker: Speaker.priest,
    ),
    s.doxology,
  ];
}

// ---------------------------------------------------------------------------
// EP IV
// ---------------------------------------------------------------------------
List<MassStep> _epIV(MysteryOfFaithVariant mof) {
  final s = _shared('iv', mof);
  return [
    const MassStep(
      id: 'ep.iv.section',
      section: MassSection.eucharist,
      kind: MassStepKind.sectionHeader,
      mergeGroup: 'ep.iv.start',
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(en: 'Eucharistic Prayer IV', es: 'Plegaria Eucarística IV', de: 'Hochgebet IV'),
    ),
    s.prefaceDialogue,
    const MassStep(
      id: 'ep.iv.preface',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(
        en: 'Preface of Eucharistic Prayer IV',
        es: 'Prefacio de la Plegaria Eucarística IV',
        de: 'Präfation des Hochgebets IV',
      ),
      text: I18nText(
        en: 'It is truly right to give you thanks, truly just to give you glory, Father most holy, for you are the one God living and true, existing before all ages and abiding for all eternity, dwelling in unapproachable light; yet you, who alone are good, the source of life, have made all that is, so that you might fill your creatures with blessings and bring joy to many of them by the glory of your light.\n\nAnd so, in your presence are countless hosts of Angels, who serve you day and night and, gazing upon the glory of your face, glorify you without ceasing.\n\nWith them we, too, confess your name in exultation, giving voice to every creature under heaven, as we acclaim:',
        es: 'En verdad es justo darte gracias, es justo proclamar tu gloria, Padre santo, único Dios vivo y verdadero; tú existes antes de todos los siglos y permaneces para siempre: habitas en una luz inaccesible; y, siendo único bueno, fuente y origen de toda vida, has creado todo para colmarlo de tus bendiciones y alegrar a muchos de ellos con la gloria de tu luz.\n\nPor eso, ante ti se congregan innumerables ángeles que te sirven día y noche, contemplan la gloria de tu rostro y te glorifican sin cesar.\n\nUniéndonos a ellos nosotros proclamamos tu gloria con toda la creación diciendo a una voz:',
        de: 'Wahrlich, es ist heilsam, dir zu danken, es ist würdig und recht, dir zu schmeicheln, heiliger Vater. Du bist der einzige lebendige und wahre Gott; du lebst vor aller Zeit und bleibst in Ewigkeit: Licht in unnahbarem Glanz. Du allein bist gut und bist der Quell des Lebens. Du hast alles geschaffen, damit du deine Geschöpfe mit Güte erfüllst und viele von ihnen mit dem Glanz deines Lichtes erfreust.\n\nDarum verherrlichen dich zahllose Engel, die dir dienen Tag und Nacht, das Antlitz deiner Herrlichkeit schauen und dich ohne Unterlass preisen.\n\nIn ihre Stimmen mischt sich auch unsere Stimme und die Stimme aller Geschöpfe, wenn wir dein Lob singen und bekennen:',
      ),
      speaker: Speaker.priest,
    ),
    s.sanctus,
    const MassStep(
      id: 'ep.iv.opening',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(en: 'Opening Prayer', es: 'Oración inicial', de: 'Eröffnungsgebet'),
      text: I18nText(
        en: 'We give you praise, Father most holy, for you are great and you have fashioned all your works in wisdom and in love. You formed man in your own image and entrusted the whole world to his care, so that in serving you alone, the Creator, he might have dominion over all creatures. And when through disobedience he had lost your friendship, you did not abandon him to the domain of death. For you came in mercy to the aid of all, so that those who seek might find you. Time and again you offered them covenants and through the prophets taught them to look forward to salvation.',
        es: 'Te glorificamos, Padre santo, porque eres grande y porque hiciste todas las cosas con sabiduría y amor. A imagen tuya creaste al hombre y le confiaste el universo entero, para que, sirviéndote sólo a ti, su Creador, dominara todo lo creado. Y cuando por desobediencia perdió tu amistad, no lo abandonaste al poder de la muerte, sino que, compadecido, tendiste la mano a todos, para que te encontrara el que te busca. Reiteraste además tu alianza a los hombres, y por los profetas les enseñaste a esperar la salvación.',
        de: 'Wir preisen dich, heiliger Vater, denn du bist groß, und all deine Werke hast du in Weisheit und Liebe gemacht. Den Menschen hast du nach deinem Bild geschaffen und ihm die ganze Welt anvertraut, damit er dir, dem Schöpfer, dient und über alle Geschöpfe herrscht. Als er in Ungehorsam deine Freundschaft verlor, hast du ihn nicht der Macht des Todes überlassen. Du hast dich aller erbarmt, damit alle, die dich suchen, dich auch finden. Immer neu hast du den Menschen deinen Bund angeboten und durch die Propheten sie die Hoffnung des Heiles gelehrt.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iv.epiclesis',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(en: 'Epiclesis', es: 'Epíclesis', de: 'Epiklese'),
      text: I18nText(
        en: 'Therefore, O Lord, we pray: may this same Holy Spirit graciously sanctify these offerings, that they may become the Body and Blood of our Lord Jesus Christ for the celebration of this great mystery, which he himself left us as an eternal covenant.',
        es: 'Por eso te pedimos, Señor, que el mismo Espíritu Santo santifique estas ofrendas, para que se conviertan en el Cuerpo y la Sangre de Jesucristo, nuestro Señor, y así celebremos el gran misterio que nos dejó como alianza eterna.',
        de: 'Darum bitten wir dich, Herr: Lass denselben Heiligen Geist diese Gaben heiligen, damit sie werden Leib und Blut unseres Herrn Jesus Christus zur Feier dieses großen Geheimnisses, das er uns als ewigen Bund hinterlassen hat.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iv.institution_bread',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(en: 'Institution Narrative — Bread', es: 'Narración de la institución — Pan', de: 'Einsetzungsbericht — Brot'),
      text: I18nText(
        en: 'For when the hour had come for him to be glorified by you, Father most holy, having loved his own who were in the world, he loved them to the end: and while they were at supper, he took bread, blessed and broke it, and gave it to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND EAT OF IT,\nFOR THIS IS MY BODY,\nWHICH WILL BE GIVEN UP FOR YOU.',
        es: 'Pues cuando llegó la hora de ser glorificado por ti, Padre Santo, habiendo amado a los suyos que estaban en el mundo, los amó hasta el extremo. Durante la cena tomó el pan, lo bendijo, lo partió y se lo dio a sus discípulos, diciendo:\n\nTOMAD Y COMED TODOS DE ÉL,\nPORQUE ESTO ES MI CUERPO,\nQUE SERÁ ENTREGADO POR VOSOTROS.',
        de: 'Als die Stunde kam, in der er von dir, heiliger Vater, verherrlicht werden sollte, liebte Jesus die Seinen, die in der Welt waren, bis zur Vollendung. Während des Mahles nahm er das Brot, brach es und gab es seinen Jüngern mit den Worten:\n\nNEHMET UND ESSET ALLE DAVON:\nDAS IST MEIN LEIB,\nDER FÜR EUCH HINGEGEBEN WIRD.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iv.institution_cup',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(en: 'Institution Narrative — Chalice', es: 'Narración de la institución — Cáliz', de: 'Einsetzungsbericht — Kelch'),
      text: I18nText(
        en: 'In a similar way, taking the chalice filled with the fruit of the vine, he gave thanks, and gave the chalice to his disciples, saying:\n\nTAKE THIS, ALL OF YOU, AND DRINK FROM IT,\nFOR THIS IS THE CHALICE OF MY BLOOD,\nTHE BLOOD OF THE NEW AND ETERNAL COVENANT,\nWHICH WILL BE POURED OUT FOR YOU AND FOR MANY\nFOR THE FORGIVENESS OF SINS.\nDO THIS IN MEMORY OF ME.',
        es: 'Del mismo modo tomó el cáliz lleno del fruto de la vid, dio gracias y lo pasó a sus discípulos, diciendo:\n\nTOMAD Y BEBED TODOS DE ÉL,\nPORQUE ÉSTE ES EL CÁLIZ DE MI SANGRE,\nSANGRE DE LA ALIANZA NUEVA Y ETERNA,\nQUE SERÁ DERRAMADA POR VOSOTROS\nY POR MUCHOS\nPARA EL PERDÓN DE LOS PECADOS.\nHACED ESTO EN CONMEMORACIÓN MÍA.',
        de: 'Ebenso nahm er den Kelch, der voll war von der Frucht des Weinstocks, dankte und reichte ihn seinen Jüngern mit den Worten:\n\nNEHMET UND TRINKET ALLE DARAUS:\nDAS IST DER KELCH MEINES BLUTES,\nDES BLUTES DES NEUEN UND EWIGEN BUNDES,\nDAS FÜR EUCH UND FÜR ALLE VERGOSSEN WIRD\nZUR VERGEBUNG DER SÜNDEN.\nTUT DIES ZU MEINEM GEDÄCHTNIS.',
      ),
      speaker: Speaker.priest,
    ),
    s.mysteryOfFaith,
    const MassStep(
      id: 'ep.iv.anamnesis',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(en: 'Anamnesis & Oblation', es: 'Anamnesis y oblación', de: 'Anamnese und Darbringung'),
      text: I18nText(
        en: "Therefore, O Lord, as we now celebrate the memorial of our redemption, we remember Christ's Death and his descent to the realm of the dead, we proclaim his Resurrection and his Ascension to your right hand, and, as we await his coming in glory, we offer you his Body and Blood, the sacrifice acceptable to you which brings salvation to the whole world.\n\nLook, O Lord, upon the Sacrifice which you yourself have provided for your Church, and grant in your loving kindness to all who partake of this one Bread and one Chalice that, gathered into one body by the Holy Spirit, they may truly become a living sacrifice in Christ to the praise of your glory.",
        es: 'Por eso, Señor, al celebrar ahora el memorial de nuestra redención, recordamos la muerte de Cristo y su descenso al reino de los muertos, proclamamos su resurrección y su ascensión a tu derecha; y, mientras esperamos su venida gloriosa, te ofrecemos su Cuerpo y su Sangre, sacrificio agradable a ti y salvación para el mundo entero.\n\nVuelve, Señor, tus ojos hacia la víctima que tú mismo has preparado para tu Iglesia; y a cuantos vamos a participar de un mismo pan y un mismo cáliz, concédenos que, congregados en un solo cuerpo por el Espíritu Santo, seamos en Cristo una ofrenda viva para alabanza de tu gloria.',
        de: 'Darum feiern wir, Herr, das Gedächtnis unserer Erlösung. Wir denken an Christi Tod und seinen Abstieg in das Reich des Todes. Wir bekennen seine Auferstehung und seine Erhöhung zu deiner Rechten. Wir erwarten seine Wiederkunft in Herrlichkeit und bringen dir seinen Leib und sein Blut dar, das Opfer, das dir wohlgefällt und der ganzen Welt das Heil bringt.\n\nSchau hin, Herr, auf das Opfer, das du selbst deiner Kirche bereitet hast, und gib allen, die an diesem einen Brot und diesem einen Kelch Anteil nehmen, dass sie vom Heiligen Geist gesammelt ein lebendiges Opfer werden in Christus zum Lob deiner Herrlichkeit.',
      ),
      speaker: Speaker.priest,
    ),
    const MassStep(
      id: 'ep.iv.intercessions',
      section: MassSection.eucharist,
      kind: MassStepKind.celebrant,
      group: OptionGroup.eucharistic,
      variant: 'iv',
      title: I18nText(en: 'Intercessions', es: 'Intercesiones', de: 'Fürbitten'),
      text: I18nText(
        en: 'And now, Lord, remember all for whom we offer this sacrifice: especially your servant N. our Pope, N. our Bishop, and the whole Order of Bishops, all the clergy, those who take part in this offering, those gathered here before you, your entire people, and all who seek you with a sincere heart.\n\nRemember also those who have died in the peace of your Christ and all the dead, whose faith you alone have known.\n\nTo all of us, your children, grant, O merciful Father, that we may enter into a heavenly inheritance with the Blessed Virgin Mary, Mother of God, and with your Apostles and Saints in your kingdom. There, with the whole of creation, freed from the corruption of sin and death, may we glorify you through Christ our Lord.',
        es: 'Y ahora te pedimos, Señor, que te acuerdes de todos aquellos por los que te ofrecemos este sacrificio: de tu siervo el Papa N., de nuestro Obispo N., del cuerpo episcopal, del clero, de los que ofrecen este sacrificio, de los aquí reunidos y de todo tu pueblo, y de todos los que te buscan con sincero corazón.\n\nAcuérdate también de los que murieron en la paz de Cristo, y de todos los difuntos, cuya fe sólo tú conociste.\n\nPadre misericordioso, concede a todos tus hijos que entren en la herencia del cielo con María, la Virgen Madre de Dios, con los apóstoles y los santos, en tu reino, donde, con toda la creación, libre al fin del pecado y de la muerte, te glorifiquemos por Cristo, Señor nuestro.',
        de: 'Gedenke nun, Herr, aller, für die wir dieses Opfer darbringen: deines Dieners, unseres Papstes N., unseres Bischofs N., aller Bischöfe, der Priester und Diakone und derer, die dieses Opfer feiern, derer, die hier versammelt sind, deines ganzen Volkes und aller, die dich mit aufrichtigem Herzen suchen.\n\nGedenke auch derer, die in Frieden mit Christus gestorben sind, und aller Verstorbenen, deren Glaube nur dir bekannt ist.\n\nBarmherziger Vater, lass uns alle, deine Kinder, das Erbe des Himmels empfangen zusammen mit der seligen Jungfrau und Gottesmutter Maria, mit den Aposteln und den Heiligen in deinem Reich. Dort sollen wir mit der ganzen Schöpfung, befreit von Sünde und Tod, dich preisen durch Jesus Christus, unseren Herrn.',
      ),
      speaker: Speaker.priest,
    ),
    s.doxology,
  ];
}
