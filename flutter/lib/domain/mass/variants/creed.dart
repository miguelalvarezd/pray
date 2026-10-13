import '../types.dart';

/// Profession of Faith — Nicene Creed (standard) or Apostles' Creed.
List<MassStep> creedSteps(CreedVariant variant) {
  switch (variant) {
    case CreedVariant.apostles:
      return _apostles;
    case CreedVariant.nicene:
      return _nicene;
  }
}

const List<MassStep> _nicene = [
  MassStep(
    id: 'creed.nicene',
    section: MassSection.word,
    kind: MassStepKind.all,
    group: OptionGroup.creed,
    variant: 'nicene',
    title: I18nText(
      en: 'Nicene Creed',
      es: 'Credo Niceno-Constantinopolitano',
      de: 'Großes Glaubensbekenntnis',
    ),
    text: I18nText(
      en:
          'I believe in one God,\nthe Father almighty,\nmaker of heaven and earth,\nof all things visible and invisible.\n\nI believe in one Lord Jesus Christ,\nthe Only Begotten Son of God,\nborn of the Father before all ages.\nGod from God, Light from Light,\ntrue God from true God,\nbegotten, not made, consubstantial with the Father;\nthrough him all things were made.\nFor us men and for our salvation\nhe came down from heaven,\nand by the Holy Spirit was incarnate of the Virgin Mary,\nand became man.\n\nFor our sake he was crucified under Pontius Pilate,\nhe suffered death and was buried,\nand rose again on the third day\nin accordance with the Scriptures.\nHe ascended into heaven\nand is seated at the right hand of the Father.\nHe will come again in glory\nto judge the living and the dead\nand his kingdom will have no end.\n\nI believe in the Holy Spirit, the Lord, the giver of life,\nwho proceeds from the Father and the Son,\nwho with the Father and the Son is adored and glorified,\nwho has spoken through the prophets.\n\nI believe in one, holy, catholic and apostolic Church.\nI confess one Baptism for the forgiveness of sins\nand I look forward to the resurrection of the dead\nand the life of the world to come. Amen.',
      es:
          'Creo en un solo Dios,\nPadre todopoderoso,\nCreador del cielo y de la tierra,\nde todo lo visible e invisible.\n\nCreo en un solo Señor, Jesucristo,\nHijo único de Dios,\nnacido del Padre antes de todos los siglos:\nDios de Dios, Luz de Luz,\nDios verdadero de Dios verdadero,\nengendrado, no creado,\nde la misma naturaleza del Padre,\npor quien todo fue hecho;\nque por nosotros, los hombres,\ny por nuestra salvación bajó del cielo,\ny por obra del Espíritu Santo\nse encarnó de María, la Virgen,\ny se hizo hombre;\ny por nuestra causa fue crucificado\nen tiempos de Poncio Pilato;\npadeció y fue sepultado,\ny resucitó al tercer día, según las Escrituras,\ny subió al cielo, y está sentado a la derecha del Padre;\ny de nuevo vendrá con gloria\npara juzgar a vivos y muertos,\ny su reino no tendrá fin.\n\nCreo en el Espíritu Santo, Señor y dador de vida,\nque procede del Padre y del Hijo,\nque con el Padre y el Hijo\nrecibe una misma adoración y gloria,\ny que habló por los profetas.\n\nCreo en la Iglesia,\nque es una, santa, católica y apostólica.\nConfieso que hay un solo bautismo\npara el perdón de los pecados.\nEspero la resurrección de los muertos\ny la vida del mundo futuro. Amén.',
      de:
          'Ich glaube an den einen Gott,\nden Vater, den Allmächtigen,\nder alles geschaffen hat, Himmel und Erde,\ndie sichtbare und die unsichtbare Welt.\n\nUnd an den einen Herrn Jesus Christus,\nGottes eingeborenen Sohn,\naus dem Vater geboren vor aller Zeit:\nGott von Gott,\nLicht vom Licht,\nwahrer Gott vom wahren Gott,\ngezeugt, nicht geschaffen,\nein Wesen mit dem Vater;\ndurch ihn ist alles geschaffen.\nFür uns Menschen und zu unserem Heil\nist er vom Himmel gekommen,\nhat Fleisch angenommen durch den Heiligen Geist\nvon der Jungfrau Maria\nund ist Mensch geworden.\nEr wurde für uns gekreuzigt unter Pontius Pilatus,\nhat gelitten und ist begraben worden,\nist am dritten Tage auferstanden\nnach der Schrift\nund aufgefahren in den Himmel.\nEr sitzt zur Rechten des Vaters\nund wird wiederkommen in Herrlichkeit,\nzu richten die Lebenden und die Toten;\nseinem Reich wird kein Ende sein.\n\nIch glaube an den Heiligen Geist,\nder Herr ist und lebendig macht,\nder aus dem Vater und dem Sohn hervorgeht,\nder mit dem Vater und dem Sohn\nangebetet und verherrlicht wird,\nder gesprochen hat durch die Propheten,\nund die eine, heilige, katholische und apostolische Kirche.\nIch bekenne die eine Taufe zur Vergebung der Sünden.\nIch erwarte die Auferstehung der Toten\nund das Leben der kommenden Welt. Amen.',
    ),
    speaker: Speaker.all,
  ),
];

const List<MassStep> _apostles = [
  MassStep(
    id: 'creed.apostles',
    section: MassSection.word,
    kind: MassStepKind.all,
    group: OptionGroup.creed,
    variant: 'apostles',
    title: I18nText(
      en: "Apostles' Creed",
      es: 'Símbolo de los Apóstoles',
      de: 'Apostolisches Glaubensbekenntnis',
    ),
    text: I18nText(
      en:
          'I believe in God,\nthe Father almighty,\nCreator of heaven and earth,\n\nand in Jesus Christ, his only Son, our Lord,\nwho was conceived by the Holy Spirit,\nborn of the Virgin Mary,\nsuffered under Pontius Pilate,\nwas crucified, died and was buried;\nhe descended into hell;\non the third day he rose again from the dead;\nhe ascended into heaven,\nand is seated at the right hand of God the Father almighty;\nfrom there he will come to judge the living and the dead.\n\nI believe in the Holy Spirit,\nthe holy catholic Church,\nthe communion of saints,\nthe forgiveness of sins,\nthe resurrection of the body,\nand life everlasting. Amen.',
      es:
          'Creo en Dios, Padre todopoderoso,\nCreador del cielo y de la tierra.\n\nCreo en Jesucristo, su único Hijo, nuestro Señor,\nque fue concebido por obra y gracia del Espíritu Santo,\nnació de santa María Virgen,\npadeció bajo el poder de Poncio Pilato,\nfue crucificado, muerto y sepultado,\ndescendió a los infiernos,\nal tercer día resucitó de entre los muertos,\nsubió a los cielos\ny está sentado a la derecha de Dios, Padre todopoderoso.\nDesde allí ha de venir a juzgar a vivos y muertos.\n\nCreo en el Espíritu Santo,\nla santa Iglesia católica,\nla comunión de los santos,\nel perdón de los pecados,\nla resurrección de la carne\ny la vida eterna. Amén.',
      de:
          'Ich glaube an Gott,\nden Vater, den Allmächtigen,\nden Schöpfer des Himmels und der Erde,\n\nund an Jesus Christus,\nseinen eingeborenen Sohn, unsern Herrn,\nempfangen durch den Heiligen Geist,\ngeboren von der Jungfrau Maria,\ngelitten unter Pontius Pilatus,\ngekreuzigt, gestorben und begraben,\nhinabgestiegen in das Reich des Todes,\nam dritten Tage auferstanden von den Toten,\naufgefahren in den Himmel;\ner sitzt zur Rechten Gottes,\ndes allmächtigen Vaters;\nvon dort wird er kommen,\nzu richten die Lebenden und die Toten.\n\nIch glaube an den Heiligen Geist,\ndie heilige katholische Kirche,\nGemeinschaft der Heiligen,\nVergebung der Sünden,\nAuferstehung der Toten\nund das ewige Leben. Amen.',
    ),
    speaker: Speaker.all,
  ),
];
