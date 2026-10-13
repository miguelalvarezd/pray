import '../../domain/mass/types.dart';

/// Which Reading of a Mass a passage is.
enum ReadingKind { first, psalm, second, gospel }

/// A Reading Reference in neutral form, as the bundled data stores it.
class ReadingReference {
  /// OSIS-style book id, e.g. `Luke`, `1Cor`, `Ps`.
  final String book;

  /// `chapter:verses`, with `,` between verse groups and `;` between
  /// chapters (e.g. `14:1,7-11`). Psalms use Hebrew numbering.
  final String passage;

  const ReadingReference({required this.book, required this.passage});

  factory ReadingReference.fromJson(Map<String, dynamic> j) => ReadingReference(
        book: j['book'] as String,
        passage: j['passage'] as String,
      );
}

/// One Reading of a Day: its main passage, then a shorter form or
/// alternatives.
class Reading {
  final ReadingKind kind;
  final List<ReadingReference> options;

  const Reading({required this.kind, required this.options});

  factory Reading.fromJson(Map<String, dynamic> j) => Reading(
        kind: ReadingKind.values.byName(j['kind'] as String),
        options: [
          for (final o in j['options'] as List)
            ReadingReference.fromJson(o as Map<String, dynamic>),
        ],
      );
}

/// How a language's lectionary writes a Reading Reference.
class _Style {
  final Map<String, String> books;

  /// Between chapter and verses: `:` (English), `, ` (Spain), `,` (German).
  final String chapterVerse;

  /// Between verse groups: `, `, `. `, `.`.
  final String verseGroups;

  /// Around a range that crosses chapters: `-`, ` — `, ` – `.
  final String crossChapter;

  /// The word between a Reading's options.
  final String or;

  /// Writes a psalm as its number, from its Hebrew number and first verse.
  /// When absent, the full passage is written.
  final String Function(int hebrew, int firstVerse)? psalm;

  const _Style({
    required this.books,
    required this.chapterVerse,
    required this.verseGroups,
    required this.crossChapter,
    required this.or,
    this.psalm,
  });
}

/// English (US lectionary): `Lk 14:1, 7-11`, `Ps 23:1-3a, 3b-4`.
const _english = _Style(
  books: {
    'Gen': 'Gn', 'Exod': 'Ex', 'Lev': 'Lv', 'Num': 'Nm', 'Deut': 'Dt', 'Josh': 'Jos',
    'Judg': 'Jgs', 'Ruth': 'Ru', '1Sam': '1 Sm', '2Sam': '2 Sm', '1Kgs': '1 Kgs',
    '2Kgs': '2 Kgs', '1Chr': '1 Chr', '2Chr': '2 Chr', 'Ezra': 'Ezr', 'Neh': 'Neh',
    'Tob': 'Tb', 'Jdt': 'Jdt', 'Esth': 'Est', '1Macc': '1 Mc', '2Macc': '2 Mc', 'Job': 'Jb',
    'Ps': 'Ps', 'Prov': 'Prv', 'Eccl': 'Eccl', 'Song': 'Sg', 'Wis': 'Wis', 'Sir': 'Sir',
    'Isa': 'Is', 'Jer': 'Jer', 'Lam': 'Lam', 'Bar': 'Bar', 'Ezek': 'Ez', 'Dan': 'Dn',
    'Hos': 'Hos', 'Joel': 'Jl', 'Amos': 'Am', 'Obad': 'Ob', 'Jonah': 'Jon', 'Mic': 'Mi',
    'Nah': 'Na', 'Hab': 'Hb', 'Zeph': 'Zep', 'Hag': 'Hg', 'Zech': 'Zec', 'Mal': 'Mal',
    'Matt': 'Mt', 'Mark': 'Mk', 'Luke': 'Lk', 'John': 'Jn', 'Acts': 'Acts', 'Rom': 'Rom',
    '1Cor': '1 Cor', '2Cor': '2 Cor', 'Gal': 'Gal', 'Eph': 'Eph', 'Phil': 'Phil',
    'Col': 'Col', '1Thess': '1 Thes', '2Thess': '2 Thes', '1Tim': '1 Tm', '2Tim': '2 Tm',
    'Titus': 'Ti', 'Phlm': 'Phlm', 'Heb': 'Heb', 'Jas': 'Jas', '1Pet': '1 Pt', '2Pet': '2 Pt',
    '1John': '1 Jn', '2John': '2 Jn', '3John': '3 Jn', 'Jude': 'Jude', 'Rev': 'Rv',
  },
  chapterVerse: ':',
  verseGroups: ', ',
  crossChapter: '-',
  or: 'or',
);

/// Spanish, as Spain's lectionary (CEE) writes it: `Lc 14, 1. 7-11`,
/// `2 Cor 5, 20 — 6, 2`, and psalms by their Greek/Vulgate number only.
final _spanish = _Style(
  books: const {
    'Gen': 'Gen', 'Exod': 'Ex', 'Lev': 'Lev', 'Num': 'Num', 'Deut': 'Dt', 'Josh': 'Jos',
    'Judg': 'Jue', 'Ruth': 'Rut', '1Sam': '1 Sam', '2Sam': '2 Sam', '1Kgs': '1 Re',
    '2Kgs': '2 Re', '1Chr': '1 Cron', '2Chr': '2 Cron', 'Ezra': 'Esd', 'Neh': 'Neh',
    'Tob': 'Tob', 'Jdt': 'Jdt', 'Esth': 'Est', '1Macc': '1 Mac', '2Macc': '2 Mac',
    'Job': 'Job', 'Ps': 'Sal', 'Prov': 'Prov', 'Eccl': 'Ecl', 'Song': 'Cant', 'Wis': 'Sab',
    'Sir': 'Eclo', 'Isa': 'Is', 'Jer': 'Jer', 'Lam': 'Lam', 'Bar': 'Bar', 'Ezek': 'Ez',
    'Dan': 'Dan', 'Hos': 'Os', 'Joel': 'Jl', 'Amos': 'Am', 'Obad': 'Abd', 'Jonah': 'Jon',
    'Mic': 'Miq', 'Nah': 'Nah', 'Hab': 'Hab', 'Zeph': 'Sof', 'Hag': 'Ag', 'Zech': 'Zac',
    'Mal': 'Mal', 'Matt': 'Mt', 'Mark': 'Mc', 'Luke': 'Lc', 'John': 'Jn', 'Acts': 'Hch',
    'Rom': 'Rom', '1Cor': '1 Cor', '2Cor': '2 Cor', 'Gal': 'Gal', 'Eph': 'Ef',
    'Phil': 'Flp', 'Col': 'Col', '1Thess': '1 Tes', '2Thess': '2 Tes', '1Tim': '1 Tim',
    '2Tim': '2 Tim', 'Titus': 'Tit', 'Phlm': 'Flm', 'Heb': 'Heb', 'Jas': 'Sant',
    '1Pet': '1 Pe', '2Pet': '2 Pe', '1John': '1 Jn', '2John': '2 Jn', '3John': '3 Jn',
    'Jude': 'Jds', 'Rev': 'Ap',
  },
  chapterVerse: ', ',
  verseGroups: '. ',
  crossChapter: ' — ',
  or: 'o',
  psalm: (hebrew, verse) => '${vulgatePsalm(hebrew, verse)}',
);

/// German (Einheitsübersetzung / Schott): `Lk 14,1.7-11`, and psalms with
/// the Hebrew number then the Greek/Vulgate one: `Ps 23 (22)`.
final _german = _Style(
  books: const {
    'Gen': 'Gen', 'Exod': 'Ex', 'Lev': 'Lev', 'Num': 'Num', 'Deut': 'Dtn', 'Josh': 'Jos',
    'Judg': 'Ri', 'Ruth': 'Rut', '1Sam': '1 Sam', '2Sam': '2 Sam', '1Kgs': '1 Kön',
    '2Kgs': '2 Kön', '1Chr': '1 Chr', '2Chr': '2 Chr', 'Ezra': 'Esra', 'Neh': 'Neh',
    'Tob': 'Tob', 'Jdt': 'Jdt', 'Esth': 'Est', '1Macc': '1 Makk', '2Macc': '2 Makk',
    'Job': 'Ijob', 'Ps': 'Ps', 'Prov': 'Spr', 'Eccl': 'Koh', 'Song': 'Hld', 'Wis': 'Weish',
    'Sir': 'Sir', 'Isa': 'Jes', 'Jer': 'Jer', 'Lam': 'Klgl', 'Bar': 'Bar', 'Ezek': 'Ez',
    'Dan': 'Dan', 'Hos': 'Hos', 'Joel': 'Joël', 'Amos': 'Am', 'Obad': 'Obd',
    'Jonah': 'Jona', 'Mic': 'Mi', 'Nah': 'Nah', 'Hab': 'Hab', 'Zeph': 'Zef', 'Hag': 'Hag',
    'Zech': 'Sach', 'Mal': 'Mal', 'Matt': 'Mt', 'Mark': 'Mk', 'Luke': 'Lk', 'John': 'Joh',
    'Acts': 'Apg', 'Rom': 'Röm', '1Cor': '1 Kor', '2Cor': '2 Kor', 'Gal': 'Gal',
    'Eph': 'Eph', 'Phil': 'Phil', 'Col': 'Kol', '1Thess': '1 Thess', '2Thess': '2 Thess',
    '1Tim': '1 Tim', '2Tim': '2 Tim', 'Titus': 'Tit', 'Phlm': 'Phlm', 'Heb': 'Hebr',
    'Jas': 'Jak', '1Pet': '1 Petr', '2Pet': '2 Petr', '1John': '1 Joh', '2John': '2 Joh',
    '3John': '3 Joh', 'Jude': 'Jud', 'Rev': 'Offb',
  },
  chapterVerse: ',',
  verseGroups: '.',
  crossChapter: ' – ',
  or: 'oder',
  psalm: (hebrew, verse) => '$hebrew (${vulgatePsalm(hebrew, verse)})',
);

/// The word for "or" between alternatives in [lang] (Reading options,
/// Optional Memorials).
String orIn(Lang lang) => _styleFor(lang).or;

_Style _styleFor(Lang lang) => switch (lang) {
      Lang.en => _english,
      Lang.es => _spanish,
      Lang.de => _german,
    };

/// Writes a Reading as its reference in [lang]'s lectionary conventions, with
/// a shorter form or alternatives after "or" (e.g. `Lk 15:1-32 or 15:1-10`).
/// The book is repeated only when an alternative is from a different book.
String formatReading(Reading reading, Lang lang) {
  final style = _styleFor(lang);
  final parts = <String>[];
  String? previousBook;
  for (final option in reading.options) {
    final passage = _formatPassage(option, style);
    final book = style.books[option.book] ?? option.book;
    parts.add(option.book == previousBook ? passage : '$book $passage');
    previousBook = option.book;
  }
  return parts.join(' ${style.or} ');
}

String _formatPassage(ReadingReference ref, _Style style) {
  if (ref.book == 'Ps' && style.psalm != null) {
    final m = RegExp(r'^(\d+)(?::(\d+))?').firstMatch(ref.passage);
    if (m != null) {
      return style.psalm!(int.parse(m[1]!), int.tryParse(m[2] ?? '') ?? 1);
    }
  }
  return ref.passage.split(';').map((group) => _formatGroup(group, style)).join('; ');
}

/// One chapter's part of a passage, e.g. `14:1,7-11` or `5:20-6:2`.
String _formatGroup(String group, _Style style) {
  // A range crossing chapters: `5:20-6:2`.
  final cross = RegExp(r'^(\d+):([\w]+)-(\d+):([\w]+)$').firstMatch(group);
  if (cross != null) {
    return '${cross[1]}${style.chapterVerse}${cross[2]}'
        '${style.crossChapter}${cross[3]}${style.chapterVerse}${cross[4]}';
  }
  final colon = group.indexOf(':');
  final verses = (colon < 0 ? group : group.substring(colon + 1))
      .split(',')
      .join(style.verseGroups);
  return colon < 0 ? verses : '${group.substring(0, colon)}${style.chapterVerse}$verses';
}

/// A psalm's Greek/Vulgate number, as Spain's lectionary uses, from its
/// Hebrew number and first verse. Hebrew 9–10 are one psalm there, 114–115
/// are one, and 116 and 147 are each two.
int vulgatePsalm(int hebrew, int firstVerse) {
  if (hebrew <= 8 || hebrew >= 148) return hebrew;
  if (hebrew <= 10) return 9;
  if (hebrew <= 113) return hebrew - 1;
  if (hebrew <= 115) return 113;
  if (hebrew == 116) return firstVerse <= 9 ? 114 : 115;
  if (hebrew <= 146) return hebrew - 1;
  return firstVerse <= 11 ? 146 : 147;
}
