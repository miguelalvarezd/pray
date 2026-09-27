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

/// Book abbreviations as the English (US) lectionary writes them.
const _englishBooks = {
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
};

/// Writes a Reading as its reference in [lang]'s conventions, with a shorter
/// form or alternatives after "or" (e.g. `Lk 15:1-32 or 15:1-10`). The book
/// is repeated only when an alternative is from a different book.
String formatReading(Reading reading, Lang lang) {
  final parts = <String>[];
  String? previousBook;
  for (final option in reading.options) {
    final passage = _formatPassage(option.passage);
    parts.add(option.book == previousBook ? passage : '${_book(option.book)} $passage');
    previousBook = option.book;
  }
  return parts.join(' or ');
}

String _book(String id) => _englishBooks[id] ?? id;

/// `14:1,7-11;16:1-2` → `14:1, 7-11; 16:1-2`.
String _formatPassage(String passage) =>
    passage.replaceAll(',', ', ').replaceAll(';', '; ');
