/// Rosary prayer texts, mystery data, and step generator.
///
/// Mirrors `src/lib/rosary.ts`. The generator returns a flat list of
/// [RosaryStep] objects that drive the interactive guide — each step is
/// self-contained (prayer text, bead type, mystery context, position on
/// the visual track) so the UI only needs the current step + index.
library;

class _Prayer {
  final String title;
  final String text;
  const _Prayer({required this.title, required this.text});
}

class Prayers {
  static const signOfCross = _Prayer(
    title: 'Sign of the Cross',
    text:
        'In the name of the Father,\nand of the Son,\nand of the Holy Spirit.\nAmen.',
  );

  static const apostlesCreed = _Prayer(
    title: "Apostles' Creed",
    text:
        'I believe in God, the Father Almighty,\nCreator of Heaven and earth;\nand in Jesus Christ, His only Son, Our Lord,\nWho was conceived by the Holy Spirit,\nborn of the Virgin Mary,\nsuffered under Pontius Pilate,\nwas crucified, died, and was buried.\nHe descended into Hell;\nthe third day He arose again from the dead;\nHe ascended into Heaven,\nsitteth at the right hand of God, the Father Almighty;\nfrom thence He shall come to judge the living and the dead.\nI believe in the Holy Spirit,\nthe holy Catholic Church,\nthe communion of saints,\nthe forgiveness of sins,\nthe resurrection of the body\nand life everlasting. Amen.',
  );

  static const ourFather = _Prayer(
    title: 'Our Father',
    text:
        'Our Father, Who art in heaven,\nhallowed be Thy name;\nThy kingdom come;\nThy will be done on earth as it is in heaven.\nGive us this day our daily bread;\nand forgive us our trespasses\nas we forgive those who trespass against us;\nand lead us not into temptation,\nbut deliver us from evil. Amen.',
  );

  static const hailMary = _Prayer(
    title: 'Hail Mary',
    text:
        'Hail Mary, full of grace.\nThe Lord is with thee.\nBlessed art thou amongst women,\nand blessed is the fruit of thy womb, Jesus.\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death. Amen.',
  );

  static const gloryBe = _Prayer(
    title: 'Glory Be',
    text:
        'Glory be to the Father,\nand to the Son,\nand to the Holy Spirit.\nAs it was in the beginning,\nis now, and ever shall be,\nworld without end. Amen.',
  );

  static const fatima = _Prayer(
    title: 'Fatima Prayer',
    text:
        'O my Jesus,\nforgive us our sins,\nsave us from the fires of hell,\nlead all souls to Heaven,\nespecially those most in need of Thy mercy. Amen.',
  );

  static const hailHolyQueen = _Prayer(
    title: 'Hail Holy Queen',
    text:
        'Hail, Holy Queen, Mother of Mercy,\nour life, our sweetness and our hope!\nTo thee do we cry,\npoor banished children of Eve;\nto thee do we send up our sighs,\nmourning and weeping in this vale of tears.\nTurn then, most gracious advocate,\nthine eyes of mercy toward us,\nand after this our exile,\nshow unto us the blessed fruit of thy womb, Jesus.\nO clement, O loving, O sweet Virgin Mary!\nPray for us, O holy Mother of God,\nthat we may be made worthy of the promises of Christ. Amen.',
  );

  static const popeIntentions = _Prayer(
    title: "For the Pope's Intentions",
    text:
        'We pray for the intentions of our Holy Father the Pope,\nand for the needs of Holy Mother Church.\n\nOur Father, Who art in heaven,\nhallowed be Thy name;\nThy kingdom come;\nThy will be done on earth as it is in heaven.\nGive us this day our daily bread;\nand forgive us our trespasses\nas we forgive those who trespass against us;\nand lead us not into temptation,\nbut deliver us from evil. Amen.\n\nHail Mary, full of grace.\nThe Lord is with thee.\nBlessed art thou amongst women,\nand blessed is the fruit of thy womb, Jesus.\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death. Amen.\n\nGlory be to the Father,\nand to the Son,\nand to the Holy Spirit.\nAs it was in the beginning,\nis now, and ever shall be,\nworld without end. Amen.',
  );

  static const lorettoLitany = _Prayer(
    title: 'Litany of Loreto',
    text:
        'Lord, have mercy. Lord, have mercy.\nChrist, have mercy. Christ, have mercy.\nLord, have mercy. Lord, have mercy.\n\nChrist, hear us. Christ, graciously hear us.\n\nGod the Father of Heaven, have mercy on us.\nGod the Son, Redeemer of the world, have mercy on us.\nGod the Holy Spirit, have mercy on us.\nHoly Trinity, One God, have mercy on us.\n\nHoly Mary, pray for us.\nHoly Mother of God, pray for us.\nHoly Virgin of virgins, pray for us.\nMother of Christ, pray for us.\nMother of the Church, pray for us.\nMother of mercy, pray for us.\nMother of divine grace, pray for us.\nMother most pure, pray for us.\nMother most chaste, pray for us.\nMother inviolate, pray for us.\nMother undefiled, pray for us.\nMother most admirable, pray for us.\nMother of good counsel, pray for us.\nMother of our Creator, pray for us.\nMother of our Saviour, pray for us.\nVirgin most prudent, pray for us.\nVirgin most venerable, pray for us.\nVirgin most renowned, pray for us.\nVirgin most powerful, pray for us.\nVirgin most merciful, pray for us.\nVirgin most faithful, pray for us.\nMirror of justice, pray for us.\nSeat of wisdom, pray for us.\nCause of our joy, pray for us.\nSpiritual vessel, pray for us.\nVessel of honour, pray for us.\nSingular vessel of devotion, pray for us.\nMystical rose, pray for us.\nTower of David, pray for us.\nTower of ivory, pray for us.\nHouse of gold, pray for us.\nArk of the covenant, pray for us.\nGate of heaven, pray for us.\nMorning star, pray for us.\nHealth of the sick, pray for us.\nRefuge of sinners, pray for us.\nSolace of migrants, pray for us.\nComforter of the afflicted, pray for us.\nHelp of Christians, pray for us.\nQueen of Angels, pray for us.\nQueen of Patriarchs, pray for us.\nQueen of Prophets, pray for us.\nQueen of Apostles, pray for us.\nQueen of Martyrs, pray for us.\nQueen of Confessors, pray for us.\nQueen of Virgins, pray for us.\nQueen of all Saints, pray for us.\nQueen conceived without original sin, pray for us.\nQueen assumed into heaven, pray for us.\nQueen of the most holy Rosary, pray for us.\nQueen of families, pray for us.\nQueen of peace, pray for us.\n\nLamb of God, who takest away the sins of the world,\nspare us, O Lord.\nLamb of God, who takest away the sins of the world,\ngraciously hear us, O Lord.\nLamb of God, who takest away the sins of the world,\nhave mercy on us.\n\nPray for us, O holy Mother of God,\nthat we may be made worthy of the promises of Christ.\n\nLet us pray.\nGrant, we beseech Thee, O Lord God,\nthat we Thy servants may enjoy lasting health of mind and body,\nand by the glorious intercession of the Blessed Mary, ever Virgin,\nbe delivered from present sorrow\nand enter into the joy of eternal happiness.\nThrough Christ our Lord. Amen.',
  );
}

enum MysteryType { joyful, sorrowful, glorious, luminous }

class Mystery {
  final int number;
  final String name;
  final String scripture;
  final String reading;
  final String reflection;

  const Mystery({
    required this.number,
    required this.name,
    required this.scripture,
    required this.reading,
    required this.reflection,
  });
}

class MysterySet {
  final MysteryType type;
  final String name;
  final String shortName;
  final String days;
  final List<Mystery> mysteries;

  const MysterySet({
    required this.type,
    required this.name,
    required this.shortName,
    required this.days,
    required this.mysteries,
  });
}

const List<MysterySet> kMysterySets = [
  MysterySet(
    type: MysteryType.joyful,
    name: 'Joyful Mysteries',
    shortName: 'Joyful',
    days: 'Mon · Sat',
    mysteries: [
      Mystery(
        number: 1,
        name: 'The Annunciation',
        scripture: 'Luke 1:26–38',
        reading:
            'The angel Gabriel was sent from God to a town of Galilee called Nazareth, to a virgin betrothed to a man named Joseph, of the house of David. The virgin’s name was Mary. Upon arriving, the angel said to her, “Hail, full of grace! The Lord is with you.” Mary was deeply troubled by his words and wondered what this greeting could mean. The angel said, “Do not be afraid, Mary, for you have found favor with God. You will conceive and bear a son, and you shall name him Jesus.” Mary said, “Behold, I am the handmaid of the Lord. Let it be done to me according to your word.”',
        reflection:
            'Meditate on the Angel Gabriel announcing to Mary that she will be the Mother of God. Mary’s humble “yes” opened the door of salvation to the world.',
      ),
      Mystery(
        number: 2,
        name: 'The Visitation',
        scripture: 'Luke 1:39–56',
        reading:
            'Mary set out and traveled to the hill country in haste to a town of Judah, where she entered the house of Zechariah and greeted Elizabeth. When Elizabeth heard Mary’s greeting, the infant leaped in her womb, and Elizabeth, filled with the Holy Spirit, cried out in a loud voice: “Blessed are you among women, and blessed is the fruit of your womb. And how does this happen to me, that the mother of my Lord should come to me?” And Mary said: “My soul proclaims the greatness of the Lord; my spirit rejoices in God my Savior.”',
        reflection:
            'Mary visits her cousin Elizabeth, who is filled with the Holy Spirit. Even unborn, John the Baptist leaps for joy at the presence of Christ.',
      ),
      Mystery(
        number: 3,
        name: 'The Nativity',
        scripture: 'Luke 2:1–21',
        reading:
            'While they were in Bethlehem, the time came for Mary to have her child, and she gave birth to her firstborn son. She wrapped him in swaddling clothes and laid him in a manger, because there was no room for them in the inn. Now there were shepherds in that region living in the fields and keeping the night watch over their flock. The angel of the Lord said to them, “Do not be afraid; for behold, I proclaim to you good news of great joy. Today in the city of David a savior has been born for you who is Messiah and Lord.”',
        reflection:
            'The Son of God is born in a humble stable. God enters human history as a helpless child, wrapped in swaddling clothes and laid in a manger.',
      ),
      Mystery(
        number: 4,
        name: 'The Presentation',
        scripture: 'Luke 2:22–38',
        reading:
            'When the days were completed for their purification according to the law of Moses, they took Jesus up to Jerusalem to present him to the Lord. Now there was a man in Jerusalem whose name was Simeon. He came in the Spirit into the temple; and when the parents brought in the child Jesus, he took him into his arms and blessed God, saying: “Now, Master, you may let your servant go in peace, for my eyes have seen your salvation, a light for revelation to the Gentiles, and glory for your people Israel.”',
        reflection:
            'Mary and Joseph present the infant Jesus in the Temple. Simeon recognizes the Child as the light of the nations and a sword of sorrow for Mary.',
      ),
      Mystery(
        number: 5,
        name: 'The Finding in the Temple',
        scripture: 'Luke 2:41–52',
        reading:
            'Each year his parents went to Jerusalem for the feast of Passover, and when he was twelve years old, they went up according to festival custom. After they had completed its days, the boy Jesus remained behind in Jerusalem, but his parents did not know it. After three days they found him in the temple, sitting in the midst of the teachers, listening to them and asking them questions. His mother said to him, “Son, why have you done this to us?” He said to them, “Why were you looking for me? Did you not know that I must be in my Father’s house?”',
        reflection:
            'The twelve-year-old Jesus stays behind in Jerusalem and is found by Mary and Joseph in the Temple, teaching the elders with wisdom beyond His years.',
      ),
    ],
  ),
  MysterySet(
    type: MysteryType.sorrowful,
    name: 'Sorrowful Mysteries',
    shortName: 'Sorrowful',
    days: 'Tue · Fri',
    mysteries: [
      Mystery(
        number: 1,
        name: 'The Agony in the Garden',
        scripture: 'Luke 22:39–46',
        reading:
            'Then going out he went, as was his custom, to the Mount of Olives, and the disciples followed him. He knelt down and prayed, saying, “Father, if you are willing, take this cup away from me; still, not my will but yours be done.” And to strengthen him an angel from heaven appeared to him. He was in such agony and he prayed so fervently that his sweat became like drops of blood falling on the ground.',
        reflection:
            "Jesus prays in the Garden of Gethsemane. In anguish He accepts the Father's will, sweating blood as He faces the weight of all human sin.",
      ),
      Mystery(
        number: 2,
        name: 'The Scourging at the Pillar',
        scripture: 'John 19:1',
        reading:
            'Then Pilate took Jesus and had him scourged. He was pierced for our offenses, crushed for our sins; upon him was the chastisement that makes us whole, by his stripes we were healed.',
        reflection:
            'Jesus is bound to a pillar and scourged. He takes upon Himself our sins of the flesh, offering His wounds for our healing.',
      ),
      Mystery(
        number: 3,
        name: 'The Crowning with Thorns',
        scripture: 'Matthew 27:29',
        reading:
            'Weaving a crown out of thorns, they placed it on his head and a reed in his right hand. And kneeling before him, they mocked him, saying, “Hail, King of the Jews!” They spat upon him and took the reed and kept striking him on the head.',
        reflection:
            "A crown of thorns is pressed upon Jesus' head. The King of Kings is mocked and humiliated, bearing our pride and vanity.",
      ),
      Mystery(
        number: 4,
        name: 'The Carrying of the Cross',
        scripture: 'Luke 23:26–32',
        reading:
            'As they led him away they took hold of a certain Simon, a Cyrenian, who was coming in from the country; and after laying the cross on him, they made him carry it behind Jesus. A large crowd of people followed Jesus, including many women who mourned and lamented him. Jesus turned to them and said, “Daughters of Jerusalem, do not weep for me; weep instead for yourselves and for your children.”',
        reflection:
            'Jesus carries the cross through Jerusalem. He falls yet rises, embracing suffering as the path to redemption.',
      ),
      Mystery(
        number: 5,
        name: 'The Crucifixion',
        scripture: 'Luke 23:33–46',
        reading:
            'When they came to the place called the Skull, they crucified him and the criminals there, one on his right, the other on his left. Then Jesus said, “Father, forgive them, they know not what they do.” It was now about noon and darkness came over the whole land until three in the afternoon. Jesus cried out in a loud voice, “Father, into your hands I commend my spirit”; and when he had said this he breathed his last.',
        reflection:
            'Jesus is nailed to the cross and dies. His final words are forgiveness and surrender: "Father, into your hands I commend my spirit."',
      ),
    ],
  ),
  MysterySet(
    type: MysteryType.glorious,
    name: 'Glorious Mysteries',
    shortName: 'Glorious',
    days: 'Wed · Sun',
    mysteries: [
      Mystery(
        number: 1,
        name: 'The Resurrection',
        scripture: 'Luke 24:1–12',
        reading:
            'At daybreak on the first day of the week the women took the spices they had prepared and went to the tomb. They found the stone rolled away from the tomb; but when they entered, they did not find the body of the Lord Jesus. Two men in dazzling garments stood beside them and said, “Why do you seek the living one among the dead? He is not here, but he has been raised. Remember what he said to you while he was still in Galilee.”',
        reflection:
            'Jesus rises from the dead on the third day. Death is conquered; our hope is confirmed. He is not here — He is risen, just as He said.',
      ),
      Mystery(
        number: 2,
        name: 'The Ascension',
        scripture: 'Acts 1:9–11',
        reading:
            'When he had said this, as they were looking on, he was lifted up, and a cloud took him from their sight. While they were looking intently at the sky as he was going, suddenly two men dressed in white garments stood beside them. They said, “Men of Galilee, why are you standing there looking at the sky? This Jesus who has been taken up from you into heaven will return in the same way as you have seen him going into heaven.”',
        reflection:
            'Jesus ascends into Heaven forty days after His Resurrection. He goes to prepare a place for us, promising to return in glory.',
      ),
      Mystery(
        number: 3,
        name: 'The Descent of the Holy Spirit',
        scripture: 'Acts 2:1–4',
        reading:
            'When the time for Pentecost was fulfilled, they were all in one place together. And suddenly there came from the sky a noise like a strong driving wind, and it filled the entire house in which they were. Then there appeared to them tongues as of fire, which parted and came to rest on each one of them. And they were all filled with the Holy Spirit and began to speak in different tongues, as the Spirit enabled them to proclaim.',
        reflection:
            'The Holy Spirit descends on Mary and the Apostles at Pentecost. The Church is born, and the disciples are transformed by tongues of fire.',
      ),
      Mystery(
        number: 4,
        name: 'The Assumption',
        scripture: 'Revelation 12:1',
        reading:
            'A great sign appeared in the sky, a woman clothed with the sun, with the moon under her feet, and on her head a crown of twelve stars. “Hail, full of grace, the Lord is with you. Blessed are you among women.” The Almighty has done great things for her, holy is His name.',
        reflection:
            'Mary is taken body and soul into heavenly glory. She who bore the Lord is given the fullness of the resurrection before all others.',
      ),
      Mystery(
        number: 5,
        name: 'The Coronation of Mary',
        scripture: 'Revelation 12:1',
        reading:
            'A great sign appeared in the sky, a woman clothed with the sun, with the moon under her feet, and on her head a crown of twelve stars. She was given the crown of life, as the Queen of heaven and earth, Mother of God and our Mother, reigning with her Son forever.',
        reflection:
            'Mary is crowned Queen of Heaven and Earth. As the Mother of the King she reigns with Him, ever interceding for her children.',
      ),
    ],
  ),
  MysterySet(
    type: MysteryType.luminous,
    name: 'Luminous Mysteries',
    shortName: 'Luminous',
    days: 'Thu',
    mysteries: [
      Mystery(
        number: 1,
        name: 'The Baptism in the Jordan',
        scripture: 'Matthew 3:13–17',
        reading:
            'Then Jesus came from Galilee to John at the Jordan to be baptized by him. After Jesus was baptized, he came up from the water and behold, the heavens were opened for him, and he saw the Spirit of God descending like a dove and coming upon him. And a voice came from the heavens, saying, “This is my beloved Son, with whom I am well pleased.”',
        reflection:
            "Jesus is baptized by John. The Father's voice declares \"This is my beloved Son,\" and the Holy Spirit descends like a dove.",
      ),
      Mystery(
        number: 2,
        name: 'The Wedding at Cana',
        scripture: 'John 2:1–11',
        reading:
            'On the third day there was a wedding in Cana in Galilee, and the mother of Jesus was there. When the wine ran short, the mother of Jesus said to him, “They have no wine.” His mother said to the servers, “Do whatever he tells you.” Jesus told them, “Fill the jars with water.” He said, “Draw some out now.” The headwaiter tasted the water that had become wine. Jesus did this as the beginning of his signs in Cana in Galilee and so revealed his glory, and his disciples began to believe in him.',
        reflection:
            "At Mary's intercession, Jesus performs His first miracle, turning water into wine and revealing His glory to His disciples.",
      ),
      Mystery(
        number: 3,
        name: 'The Proclamation of the Kingdom',
        scripture: 'Mark 1:15',
        reading:
            '“This is the time of fulfillment. The kingdom of God is at hand. Repent, and believe in the gospel.” Jesus went around to all the towns and villages, teaching in their synagogues, proclaiming the gospel of the kingdom, and curing every disease and illness. “Blessed are the poor in spirit, for theirs is the kingdom of heaven.”',
        reflection:
            'Jesus proclaims the Kingdom of God, calls sinners to repentance, and forgives those who approach Him with faith and humility.',
      ),
      Mystery(
        number: 4,
        name: 'The Transfiguration',
        scripture: 'Luke 9:28–36',
        reading:
            'Jesus took Peter, John, and James and went up the mountain to pray. While he was praying his face changed in appearance and his clothing became dazzling white. And behold, two men were conversing with him, Moses and Elijah, who appeared in glory. Then from the cloud came a voice that said, “This is my chosen Son; listen to him.”',
        reflection:
            'Jesus is transfigured on Mount Tabor. His face shines like the sun. Peter, James, and John glimpse His divine glory.',
      ),
      Mystery(
        number: 5,
        name: 'The Institution of the Eucharist',
        scripture: 'Luke 22:19–20',
        reading:
            'Then he took the bread, said the blessing, broke it, and gave it to them, saying, “This is my body, which will be given for you; do this in memory of me.” And likewise the cup after they had eaten, saying, “This cup is the new covenant in my blood, which will be shed for you.”',
        reflection:
            'At the Last Supper, Jesus gives us His Body and Blood under the forms of bread and wine — the supreme gift of Himself.',
      ),
    ],
  ),
];

/// Returns today's recommended mystery set based on the traditional day
/// assignment. Mirrors `getMysterySetForDate` exactly:
/// Mon/Sat → Joyful · Tue/Fri → Sorrowful · Wed/Sun → Glorious · Thu → Luminous.
MysterySet getMysterySetForDate(DateTime date) {
  // Dart weekday: Mon=1..Sun=7. JS getDay: Sun=0..Sat=6.
  final js = date.weekday == 7 ? 0 : date.weekday;
  switch (js) {
    case 1:
    case 6:
      return kMysterySets[0];
    case 2:
    case 5:
      return kMysterySets[1];
    case 3:
    case 0:
      return kMysterySets[2];
    case 4:
    default:
      return kMysterySets[3];
  }
}

enum BeadType { crucifix, large, small, none }

enum StepType { prayer, mysteryReveal, complete }

enum TrackPhase { intro, decade }

class StepTrack {
  final TrackPhase phase;
  final int position;
  final int total;
  const StepTrack({
    required this.phase,
    required this.position,
    required this.total,
  });
}

class StepMystery {
  final String typeLabel;
  final int number;
  final String name;
  final String scripture;
  final String reading;
  final String reflection;

  const StepMystery({
    required this.typeLabel,
    required this.number,
    required this.name,
    required this.scripture,
    required this.reading,
    required this.reflection,
  });
}

class RosaryStep {
  final String key;
  final StepType type;
  final String prayerTitle;
  final String? prayerSubtitle;
  final String prayerText;
  final BeadType bead;

  /// Decade context. 0 = intro or closing, 1–5 = a specific decade.
  final int decadeNumber;

  /// Bead tracker within the current phase. Null for steps that don't sit
  /// on a physical bead (Glory Be, Fatima, announcements).
  final StepTrack? track;

  final StepMystery? mystery;

  const RosaryStep({
    required this.key,
    required this.type,
    required this.prayerTitle,
    this.prayerSubtitle,
    required this.prayerText,
    required this.bead,
    required this.decadeNumber,
    this.track,
    this.mystery,
  });
}

/// Produces the complete ordered list of rosary steps for [set]. ~82 steps total
/// (7 intro + 5 × 14 decade + 5 closing).
List<RosaryStep> generateRosarySteps(MysterySet set) {
  final steps = <RosaryStep>[];

  // --- Intro ---------------------------------------------------------------
  steps.add(const RosaryStep(
    key: 'sign_of_cross_start',
    type: StepType.prayer,
    prayerTitle: 'Sign of the Cross',
    prayerSubtitle: 'Begin with the crucifix',
    prayerText:
        'In the name of the Father,\nand of the Son,\nand of the Holy Spirit.\nAmen.',
    bead: BeadType.crucifix,
    decadeNumber: 0,
    track: StepTrack(phase: TrackPhase.intro, position: 0, total: 6),
  ));

  steps.add(RosaryStep(
    key: 'apostles_creed',
    type: StepType.prayer,
    prayerTitle: Prayers.apostlesCreed.title,
    prayerSubtitle: 'While holding the crucifix',
    prayerText: Prayers.apostlesCreed.text,
    bead: BeadType.crucifix,
    decadeNumber: 0,
    track: const StepTrack(phase: TrackPhase.intro, position: 0, total: 6),
  ));

  steps.add(RosaryStep(
    key: 'intro_our_father',
    type: StepType.prayer,
    prayerTitle: Prayers.ourFather.title,
    prayerSubtitle: 'On the first large bead',
    prayerText: Prayers.ourFather.text,
    bead: BeadType.large,
    decadeNumber: 0,
    track: const StepTrack(phase: TrackPhase.intro, position: 1, total: 6),
  ));

  const introIntentions = [
    'For an increase in faith',
    'For an increase in hope',
    'For an increase in charity',
  ];
  for (var i = 0; i < 3; i++) {
    steps.add(RosaryStep(
      key: 'intro_hm_$i',
      type: StepType.prayer,
      prayerTitle: Prayers.hailMary.title,
      prayerSubtitle: introIntentions[i],
      prayerText: Prayers.hailMary.text,
      bead: BeadType.small,
      decadeNumber: 0,
      track: StepTrack(phase: TrackPhase.intro, position: 2 + i, total: 6),
    ));
  }

  steps.add(RosaryStep(
    key: 'intro_glory_be',
    type: StepType.prayer,
    prayerTitle: Prayers.gloryBe.title,
    prayerText: Prayers.gloryBe.text,
    bead: BeadType.none,
    decadeNumber: 0,
    track: StepTrack(phase: TrackPhase.intro, position: 5, total: 6),
  ));

  // --- 5 decades -----------------------------------------------------------
  for (var d = 0; d < 5; d++) {
    final m = set.mysteries[d];
    final decade = d + 1;
    final mysteryCtx = StepMystery(
      typeLabel: set.name,
      number: m.number,
      name: m.name,
      scripture: m.scripture,
      reading: m.reading,
      reflection: m.reflection,
    );

    // Mystery announcement — sits on the first large bead so the row stays
    // visible and the highlight transitions smoothly from Fatima (pos 11).
    steps.add(RosaryStep(
      key: 'd${decade}_announce',
      type: StepType.mysteryReveal,
      prayerTitle: '${m.number}. ${m.name}',
      prayerSubtitle: m.scripture,
      prayerText: m.reflection,
      bead: BeadType.none,
      decadeNumber: decade,
      mystery: mysteryCtx,
      track: StepTrack(phase: TrackPhase.decade, position: 0, total: 12),
    ));

    // Our Father
    steps.add(RosaryStep(
      key: 'd${decade}_our_father',
      type: StepType.prayer,
      prayerTitle: Prayers.ourFather.title,
      prayerSubtitle: m.name,
      prayerText: Prayers.ourFather.text,
      bead: BeadType.large,
      decadeNumber: decade,
      mystery: mysteryCtx,
      track: const StepTrack(phase: TrackPhase.decade, position: 0, total: 12),
    ));

    // 10 Hail Marys
    for (var hm = 0; hm < 10; hm++) {
      steps.add(RosaryStep(
        key: 'd${decade}_hm$hm',
        type: StepType.prayer,
        prayerTitle: Prayers.hailMary.title,
        prayerSubtitle: '${m.name} · ${hm + 1} of 10',
        prayerText: Prayers.hailMary.text,
        bead: BeadType.small,
        decadeNumber: decade,
        mystery: mysteryCtx,
        track: StepTrack(phase: TrackPhase.decade, position: 1 + hm, total: 12),
      ));
    }

    // Glory Be
    steps.add(RosaryStep(
      key: 'd${decade}_glory_be',
      type: StepType.prayer,
      prayerTitle: Prayers.gloryBe.title,
      prayerSubtitle: m.name,
      prayerText: Prayers.gloryBe.text,
      bead: BeadType.none,
      decadeNumber: decade,
      mystery: mysteryCtx,
      track: StepTrack(phase: TrackPhase.decade, position: 11, total: 12),
    ));

    // Fatima Prayer
    steps.add(RosaryStep(
      key: 'd${decade}_fatima',
      type: StepType.prayer,
      prayerTitle: Prayers.fatima.title,
      prayerSubtitle: m.name,
      prayerText: Prayers.fatima.text,
      bead: BeadType.none,
      decadeNumber: decade,
      mystery: mysteryCtx,
      track: StepTrack(phase: TrackPhase.decade, position: 11, total: 12),
    ));
  }

  // --- Closing -------------------------------------------------------------
  steps.add(RosaryStep(
    key: 'hail_holy_queen',
    type: StepType.prayer,
    prayerTitle: Prayers.hailHolyQueen.title,
    prayerSubtitle: 'Closing prayer',
    prayerText: Prayers.hailHolyQueen.text,
    bead: BeadType.none,
    decadeNumber: 0,
  ));

  steps.add(const RosaryStep(
    key: 'sign_of_cross_end',
    type: StepType.prayer,
    prayerTitle: 'Sign of the Cross',
    prayerSubtitle: 'Concluding the Rosary',
    prayerText:
        'In the name of the Father,\nand of the Son,\nand of the Holy Spirit.\nAmen.',
    bead: BeadType.none,
    decadeNumber: 0,
  ));

  steps.add(RosaryStep(
    key: 'loretto_litany',
    type: StepType.prayer,
    prayerTitle: Prayers.lorettoLitany.title,
    prayerSubtitle: 'Optional closing prayer',
    prayerText: Prayers.lorettoLitany.text,
    bead: BeadType.none,
    decadeNumber: 0,
  ));

  steps.add(RosaryStep(
    key: 'pope_intentions',
    type: StepType.prayer,
    prayerTitle: Prayers.popeIntentions.title,
    prayerSubtitle: 'Our Father · Hail Mary · Glory Be',
    prayerText: Prayers.popeIntentions.text,
    bead: BeadType.none,
    decadeNumber: 0,
  ));

  steps.add(const RosaryStep(
    key: 'complete',
    type: StepType.complete,
    prayerTitle: 'Rosary Complete',
    prayerText: '',
    bead: BeadType.none,
    decadeNumber: 0,
  ));

  return steps;
}

/// Whether moving from [a] to [b] stays on the same prayer (e.g. one Hail
/// Mary to the next), so the guide can update in place and only move the
/// beads. Subtitles such as "3 of 10" may differ.
bool isSamePrayer(RosaryStep a, RosaryStep b) =>
    a.type == b.type &&
    a.prayerTitle == b.prayerTitle &&
    a.prayerText == b.prayerText;
