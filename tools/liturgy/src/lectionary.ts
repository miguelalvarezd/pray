import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

/** One row of the seed lectionary: a reading slot of a lectionary day. */
export interface LectionaryRow {
  /** Slot code: 1 First Reading, 2 Psalm, 3 Second Reading, 6 Gospel (decimals are options). */
  slot: string;
  ref: string;
}

/** A saint's entry in the seed's general calendar. */
export interface CalendarEntry {
  month: number;
  day: number;
  code: string;
}

/** A Reading Reference in neutral form: a book id and a passage. */
export interface ReadingReference {
  /** OSIS-style book id, e.g. `Luke`, `1Cor`, `Ps`. */
  book: string;
  /**
   * `chapter:verses`, with `,` between verse groups and `;` between
   * chapters, e.g. `14:1,7-11` or `15:3-4;16:1-2`. Psalms use Hebrew
   * numbering. One-chapter books may give verses only.
   */
  passage: string;
}

export interface Lectionary {
  days: Map<string, LectionaryRow[]>;
  calendar: CalendarEntry[];
}

const here = dirname(fileURLToPath(import.meta.url));
const DATA = resolve(here, '../data/tamil-lectionary');

/** Loads the public-domain Tamil lectionary seed (see its README). */
export function loadLectionary(): Lectionary {
  const list = readFileSync(resolve(DATA, 'readings__list.sql'), 'utf8');
  const days = new Map<string, LectionaryRow[]>();
  for (const [, dayId, slot, ref] of list.matchAll(
    /\('((?:[^'\\]|\\.)*)', ([0-9.]+), '((?:[^'\\]|\\.)*)'\)/g,
  )) {
    const rows = days.get(dayId) ?? [];
    rows.push({ slot, ref });
    days.set(dayId, rows);
  }

  const cal = readFileSync(resolve(DATA, 'generalcalendar.sql'), 'utf8');
  const calendar = [
    ...cal.matchAll(/\((\d+), (\d+), '((?:[^'\\]|\\.)*)', '(?:[^'\\]|\\.)*', '[A-Za-z-]+'\)/g),
  ].map(([, month, day, code]) => ({ month: Number(month), day: Number(day), code }));

  return { days, calendar };
}

/** Tamil book abbreviations used by the seed, mapped to OSIS-style ids. */
const TAMIL_BOOKS: Record<string, string> = {
  'தொநூ': 'Gen', 'விப': 'Exod', 'லேவி': 'Lev', 'எண்': 'Num', 'இச': 'Deut', 'இணை': 'Deut',
  'யோசு': 'Josh', 'நீத': 'Judg', 'ரூத்': 'Ruth', '1சாமு': '1Sam', '2சாமு': '2Sam',
  '1அர': '1Kgs', '2அர': '2Kgs', '1குறி': '1Chr', '2குறி': '2Chr', 'எஸ்ரா': 'Ezra',
  'நெகே': 'Neh', 'தோபி': 'Tob', 'யூதி': 'Jdt', 'எஸ்(கி)': 'Esth', '1மக்': '1Macc',
  '2மக்': '2Macc', 'யோபு': 'Job', 'திபா': 'Ps', 'நீமொ': 'Prov', 'சஉ': 'Eccl', 'இபா': 'Song',
  'சாஞா': 'Wis', 'சீஞா': 'Sir', 'எசா': 'Isa', 'எரே': 'Jer', 'புல': 'Lam', 'பாரூ': 'Bar',
  'எசே': 'Ezek', 'தானி': 'Dan', 'தானி(இ)': 'Dan', 'ஓசே': 'Hos', 'யோவே': 'Joel',
  'ஆமோ': 'Amos', 'ஒப': 'Obad', 'யோனா': 'Jonah', 'மீக்': 'Mic', 'நாகூ': 'Nah', 'அப': 'Hab',
  'செப்': 'Zeph', 'ஆகா': 'Hag', 'செக்': 'Zech', 'மலா': 'Mal',
  'மத்': 'Matt', 'மாற்': 'Mark', 'லூக்': 'Luke', 'யோவா': 'John', 'திப': 'Acts',
  'உரோ': 'Rom', '1கொரி': '1Cor', '2கொரி': '2Cor', 'கலா': 'Gal', 'எபே': 'Eph',
  'பிலி': 'Phil', 'கொலோ': 'Col', '1தெச': '1Thess', '2தெச': '2Thess', '1திமொ': '1Tim',
  '2திமொ': '2Tim', 'தீத்': 'Titus', 'பில': 'Phlm', 'எபி': 'Heb', 'யாக்': 'Jas',
  '1பேது': '1Pet', '2பேது': '2Pet', '1யோவா': '1John', '2யோவா': '2John', '3யோவா': '3John',
  'யூதா': 'Jude', 'திவெ': 'Rev',
};

/**
 * Parses a seed reference such as `லூக்15:1-32` or `திபா93:1ab.1c-2.5` into
 * neutral form. Returns null for anything that isn't a plain reference (links
 * to commons or other days, notes). Psalm verse groups separated by `.` are
 * normalised to `,`.
 */
export function parseReference(ref: string): ReadingReference | null {
  const m = ref
    .trim()
    .replace(/~.*$/, '')
    .match(/^([0-9]?[^\d\s:,.;~_()]+(?:\((?:இ|கி)\))?):?([\d][\dA-Za-z,.\-–;:]*)$/);
  if (!m) return null;
  const book = TAMIL_BOOKS[m[1]];
  if (!book) return null;
  const passage = m[2].replace(/–/g, '-').replace(/\./g, ',').replace(/,+/g, ',');
  return { book, passage };
}
