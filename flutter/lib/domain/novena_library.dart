/// Preloaded novena templates. When a user starts one of these, the prayer
/// text is copied onto the Novena record (so edits to this library don't
/// retroactively change an in-progress novena).
///
/// Order and field shape mirror `NOVENA_LIBRARY` in
/// `src/lib/novenaLibrary.ts` so a template-id is portable across React and
/// Flutter exports.
library;

class NovenaTemplate {
  final String id;
  final String title;
  final String patron;
  final String description;
  final String suggestedIntention;

  /// Said each day of the 9-day novena.
  final String prayer;

  const NovenaTemplate({
    required this.id,
    required this.title,
    required this.patron,
    required this.description,
    required this.suggestedIntention,
    required this.prayer,
  });
}

const List<NovenaTemplate> kNovenaLibrary = [
  NovenaTemplate(
    id: 'st-jude',
    title: 'St. Jude Thaddeus',
    patron: 'Patron of Hopeless Causes',
    description: 'Traditionally prayed in desperate or seemingly impossible situations.',
    suggestedIntention: 'A seemingly impossible need',
    prayer:
        'Most holy apostle, St. Jude, faithful servant and friend of Jesus, the Church honors and invokes you universally as the patron of hopeless cases, of things almost despaired of. Pray for me, I am so helpless and alone. Make use, I implore you, of that particular privilege given to you to bring visible and speedy help where help is almost despaired of. Come to my assistance in this great need that I may receive the consolation and help of heaven in all my necessities, tribulations, and sufferings, particularly (state your intention), and that I may praise God with you and all the saints forever. Amen.',
  ),
  NovenaTemplate(
    id: 'divine-mercy',
    title: 'Divine Mercy',
    patron: 'Novena from St. Faustina',
    description: 'Nine days of prayers for a different group of souls each day, beginning on Good Friday.',
    suggestedIntention: 'Mercy for the whole world',
    prayer:
        'Eternal Father, I offer You the Body and Blood, Soul and Divinity of Your dearly beloved Son, Our Lord Jesus Christ, in atonement for our sins and those of the whole world. For the sake of His sorrowful Passion, have mercy on us and on the whole world. Holy God, Holy Mighty One, Holy Immortal One, have mercy on us and on the whole world. Amen.',
  ),
  NovenaTemplate(
    id: 'sacred-heart',
    title: 'Sacred Heart of Jesus',
    patron: 'The Love of Christ',
    description: 'A devotion to the burning love of Christ for humanity, often prayed for conversion and love of God.',
    suggestedIntention: 'Trust in the love of Jesus',
    prayer:
        'O my Jesus, you have said: "Truly I say to you, ask and you shall receive, seek and you shall find, knock and it shall be opened to you." Behold I knock, I seek and ask for the grace of... (here name your request). O Sacred Heart of Jesus, in whom I have unbounded confidence, have mercy on me. Amen.',
  ),
  NovenaTemplate(
    id: 'immaculate-conception',
    title: 'Immaculate Conception',
    patron: 'Our Lady conceived without sin',
    description: 'Prayed before the feast of the Immaculate Conception on December 8.',
    suggestedIntention: 'Purity of heart and protection',
    prayer:
        "O Most Pure Virgin Mary, conceived without sin, from the first moment of your Immaculate Conception, you were filled with grace. O Mary, by your holy Immaculate Conception, deliver us from evil. Grant us the grace we ask for in this novena, if it be according to God's will, and in His honor. Amen.",
  ),
  NovenaTemplate(
    id: 'st-therese',
    title: 'St. Thérèse of Lisieux',
    patron: 'The Little Flower',
    description: 'Known for her "Little Way" — doing small things with great love. Famously promised to let fall a shower of roses.',
    suggestedIntention: "A sign of heaven's favor",
    prayer:
        "O Little Thérèse of the Child Jesus, please pick for me a rose from the heavenly gardens and send it to me as a message of love. O Little Flower of Jesus, ask God today to grant the favors I now place with confidence in your hands... (mention your intention). St. Thérèse, help me to always believe, as you did, in God's great love for me, so that I might imitate your \"Little Way\" each day. Amen.",
  ),
  NovenaTemplate(
    id: 'st-anthony',
    title: 'St. Anthony of Padua',
    patron: 'Finder of Lost Things',
    description: 'Invoked for lost objects, lost souls, and the poor. Especially loved for his childlike trust.',
    suggestedIntention: 'Recovery of what was lost',
    prayer:
        'O holy St. Anthony, gentlest of saints, your love for God and charity for His creatures made you worthy, when on earth, to possess miraculous powers. Miracles waited on your word, which you were always ready to request for those in trouble or anxiety. Encouraged by this thought, I implore you to obtain for me... (name your request). The answer to my prayer may require a miracle. Even so, you are the Saint of Miracles. Amen.',
  ),
  NovenaTemplate(
    id: 'holy-spirit',
    title: 'Holy Spirit',
    patron: 'The First Novena',
    description: 'The original novena prayed by the Apostles and Mary in the upper room before Pentecost.',
    suggestedIntention: 'The gifts of the Holy Spirit',
    prayer:
        'Come, Holy Spirit, fill the hearts of your faithful and kindle in them the fire of your love. Send forth your Spirit and they shall be created, and you shall renew the face of the earth. O God, who by the light of the Holy Spirit has instructed the hearts of the faithful, grant that by the same Holy Spirit we may be truly wise and ever rejoice in His consolation, through Christ our Lord. Amen.',
  ),
  NovenaTemplate(
    id: 'our-lady-perpetual-help',
    title: 'Our Lady of Perpetual Help',
    patron: 'Mother of ceaseless intercession',
    description: 'A Marian devotion that asks Mary to be a mother of unfailing help in every need.',
    suggestedIntention: "A mother's intercession in difficulty",
    prayer:
        'O Mother of Perpetual Help, grant that I may ever invoke your powerful name, the protection of the living and the salvation of the dying. Purest Mary, let your name henceforth be ever on my lips. Delay not, O Blessed Lady, to rescue me whenever I call on you. In my temptations, in my needs, I will never cease to call on you, ever repeating your sacred name, Mary, Mary. What a consolation, what sweetness, what confidence fills my soul when I pronounce your sacred name. Amen.',
  ),
];

NovenaTemplate? findTemplate(String id) =>
    kNovenaLibrary.where((t) => t.id == id).cast<NovenaTemplate?>().firstOrNull;
