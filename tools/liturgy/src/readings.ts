import {
  parseReference,
  type Lectionary,
  type LectionaryRow,
  type Reference,
} from './lectionary.ts';
import { SPAIN_PROPERS, SPAIN_VERSES } from './spain.ts';

export type ReadingKind = 'first' | 'psalm' | 'second' | 'gospel';

/** One Reading of a Day, with its options (a shorter form or alternatives). */
export interface Reading {
  kind: ReadingKind;
  options: Reference[];
}

/** The parts of a romcal calendar entry the resolver needs. */
export interface RomcalEntry {
  id: string;
  /** English name, used to match saints to the seed's calendar. */
  name: string;
  rank: string;
  dateDef: { month?: number; date?: number };
  cycles: { properCycle: string; sundayCycle: string; weekdayCycle: string };
  calendar: { weekOfSeason: number; dayOfWeek: number };
  seasons: string[];
  periods: string[];
}

const KIND_OF_SLOT: Record<string, ReadingKind> = {
  '1': 'first',
  '2': 'psalm',
  '3': 'second',
  '6': 'gospel',
};

/** Proper-of-time Celebrations whose lectionary day has its own id in the seed. */
const PROPER_OF_TIME_DAYS: Record<string, string> = {
  nativity_of_the_lord: 'Nativity of the Lord 4', // Mass during the Day
  mary_mother_of_god: 'Blessed Virgin Mary, the Mother of God',
  holy_family_of_jesus_mary_and_joseph: 'CW01-HolyFamily',
  second_sunday_after_christmas: 'CW02-0Sun',
  epiphany_of_the_lord: 'CW03-Epiphany',
  baptism_of_the_lord: 'CW04-Baptism',
  sunday_of_the_word_of_god: 'OW03-0Sun',
  ash_wednesday: 'LW00-3Wed',
  palm_sunday_of_the_passion_of_the_lord: 'LW06-0Sun',
  // Holy Thursday's Readings are those of the evening Mass of the Lord's Supper.
  holy_thursday: 'LW06-4Thu',
  thursday_of_the_lords_supper: 'LW06-4Thu',
  friday_of_the_passion_of_the_lord: 'LW06-5Fri',
  holy_saturday: 'LW06-6Sat', // the Easter Vigil
  easter_sunday: 'EW01-0Sun',
  divine_mercy_sunday: 'EW02-0Sun',
  ascension_of_the_lord: 'EW07-Ascension',
  pentecost_sunday: 'EW08-Pentecost',
  mary_mother_of_the_church: 'OW00-MaryMotherofChurch',
  most_holy_trinity: 'OW00-Trinity',
  most_holy_body_and_blood_of_christ: 'OW00-CorpusChristi',
  most_sacred_heart_of_jesus: 'OW00-SacredHeart',
  immaculate_heart_of_mary: 'OW00-ImmaculateHeart',
  our_lord_jesus_christ_king_of_the_universe: 'OW34-0Sun',
};

/** Saints whose names differ too much from the seed's to match automatically. */
const SAINT_DAYS: Record<string, string> = {
  commemoration_of_all_the_faithful_departed: 'All Souls',
};

/**
 * Memorials normally take the weekday's Readings. These have proper Readings
 * for the listed kinds, which replace the weekday's; the rest stay the
 * weekday's (as the CEE calendar shows for the Guardian Angels and Saint
 * Martha: weekday first reading, proper Gospel).
 */
const MEMORIALS_WITH_PROPER_READINGS: Record<string, ReadingKind[]> = {
  mary_mother_of_the_church: ['first', 'psalm', 'gospel'],
  immaculate_heart_of_mary: ['gospel'],
  timothy_of_ephesus_and_titus_of_crete_bishops: ['first'],
  barnabas_apostle: ['first'],
  martha_of_bethany_mary_of_bethany_and_lazarus_of_bethany: ['gospel'],
  passion_of_saint_john_the_baptist: ['gospel'],
  our_lady_of_sorrows: ['gospel'],
  holy_guardian_angels: ['gospel'],
};

const DAY_CODES = ['0Sun', '1Mon', '2Tue', '3Wed', '4Thu', '5Fri', '6Sat'];

/**
 * Resolves a Day's Readings from the seed lectionary. Returns the lectionary
 * days used (as a readable key) and the Readings, or null if none are found.
 */
export class ReadingsResolver {
  private readonly saintCodes = new Map<string, string | null>();
  /** Celebrations that fell back to the weekday because the seed lacks them. */
  readonly missingPropers = new Set<string>();

  constructor(private readonly lectionary: Lectionary) {}

  resolve(entry: RomcalEntry, date: string): { key: string; readings: Reading[] } | null {
    const weekday = this.weekdayDay(entry, date);
    const own = this.ownDay(entry, date);

    if (entry.rank === 'MEMORIAL' || entry.rank === 'OPTIONAL_MEMORIAL') {
      const proper = MEMORIALS_WITH_PROPER_READINGS[entry.id];
      const base = this.readingsOf(weekday, entry);
      const saint = proper && own ? this.readingsOf(own, entry) : null;
      if (!base || !saint) return base;
      return {
        key: `${base.key}+${saint.key}`,
        readings: base.readings.map(
          (r) => (proper!.includes(r.kind) && saint.readings.find((s) => s.kind === r.kind)) || r,
        ),
      };
    }

    const spain = spainPropers(entry);
    if (spain) return spain;

    if (own) {
      const found = this.readingsOf(own, entry);
      if (found && hasCoreReadings(found.readings)) return found;
    }
    // Solemnities, Feasts and Sundays should have Readings of their own.
    if (
      entry.cycles.properCycle !== 'PROPER_OF_TIME' ||
      PROPER_OF_TIME_DAYS[entry.id] ||
      entry.rank === 'SOLEMNITY' ||
      entry.rank === 'FEAST'
    ) {
      this.missingPropers.add(entry.id);
    }
    return this.readingsOf(weekday, entry);
  }

  /** The seed day for the Celebration itself, if it has one. */
  private ownDay(entry: RomcalEntry, date: string): string | null {
    if (PROPER_OF_TIME_DAYS[entry.id]) return PROPER_OF_TIME_DAYS[entry.id];
    if (entry.cycles.properCycle === 'PROPER_OF_TIME') return this.weekdayDay(entry, date);
    return this.saintCode(entry, date);
  }

  /** The seed day of the season weekday or Sunday that falls on this date. */
  private weekdayDay(entry: RomcalEntry, date: string): string {
    const [, month, day] = date.split('-').map(Number);
    const week = String(entry.calendar.weekOfSeason).padStart(2, '0');
    const dow = entry.calendar.dayOfWeek;
    const code = DAY_CODES[dow];
    switch (entry.seasons[0]) {
      case 'ADVENT':
        return month === 12 && day >= 17 && dow !== 0 ? `AW05-Dec${day}` : `AW${week}-${code}`;
      case 'CHRISTMAS_TIME':
        if (month === 12) return `CW01-Dec${day}`;
        if (entry.periods.includes('DAYS_BEFORE_EPIPHANY')) return `CW02-Jan${day}`;
        return `CW03-Day${dow}`;
      case 'LENT':
      case 'PASCHAL_TRIDUUM':
        return `LW${week}-${code}`;
      case 'EASTER_TIME':
        return `EW${week}-${code}`;
      default:
        return `OW${week}-${code}`;
    }
  }

  /** Matches a saint's Celebration to the seed's calendar by date and name. */
  private saintCode(entry: RomcalEntry, date: string): string | null {
    if (SAINT_DAYS[entry.id]) return SAINT_DAYS[entry.id];
    if (this.saintCodes.has(entry.id)) return this.saintCodes.get(entry.id)!;
    const [, m, d] = date.split('-').map(Number);
    const month = entry.dateDef.month ?? m;
    const day = entry.dateDef.date ?? d;
    const name = entry.name;
    let best: string | null = null;
    let bestScore = 0.2;
    for (const c of this.lectionary.calendar) {
      if (c.month !== month || c.day !== day) continue;
      const score = similarity(name, c.code);
      if (score > bestScore) [best, bestScore] = [c.code, score];
    }
    this.saintCodes.set(entry.id, best);
    return best;
  }

  /**
   * The Readings of a seed day, including its variants for the Day's Sunday
   * and weekday cycles. The key lists the seed days actually used, so it
   * identifies these Readings exactly.
   */
  private readingsOf(
    dayId: string,
    entry: RomcalEntry,
  ): { key: string; readings: Reading[] } | null {
    const sunday = entry.cycles.sundayCycle.replace('YEAR_', '');
    const weekday = entry.cycles.weekdayCycle.replace('YEAR_', '');
    const used = [dayId, `${dayId} ${sunday}`, `${dayId} ${weekday}`].filter((id) =>
      this.lectionary.days.has(id),
    );
    const rows = used.flatMap((id) => this.lectionary.days.get(id)!);
    if (rows.length === 0) return null;
    const readings = dayId === 'LW06-6Sat' ? easterVigil(rows) : this.withCommons(toReadings(rows), rows);
    return readings.length > 0
      ? { key: used.join('+'), readings: withSpainVerses(readings, used) }
      : null;
  }

  /** Fills Readings a day takes from a common (slot 9, e.g. `_Church`). */
  private withCommons(readings: Reading[], rows: LectionaryRow[]): Reading[] {
    const link = rows.find((r) => r.slot.startsWith('9'))?.ref.trim();
    if (!link?.startsWith('_')) return readings;
    const common = link.split(' or ')[0].replace(/~.*$/, '');
    const commonRows = this.lectionary.days.get(common) ?? [];
    const fromCommon = toReadings(commonRows, { firstOptionOnly: true });
    const kinds = new Set(readings.map((r) => r.kind));
    return sortReadings([...readings, ...fromCommon.filter((r) => !kinds.has(r.kind))]);
  }
}

/** Spain's own Readings for a Celebration, if it has them. */
function spainPropers(entry: RomcalEntry): { key: string; readings: Reading[] } | null {
  const proper = SPAIN_PROPERS[entry.id];
  if (!proper) return null;
  if (Array.isArray(proper)) return { key: `spain:${entry.id}`, readings: proper };
  const cycle = entry.cycles.sundayCycle.replace('YEAR_', '') as 'A' | 'B' | 'C';
  return { key: `spain:${entry.id} ${cycle}`, readings: proper[cycle] };
}

/** Applies Spain's verse ranges where they differ from the seed's. */
function withSpainVerses(readings: Reading[], dayIds: string[]): Reading[] {
  const fixes = dayIds.flatMap((id) => Object.entries(SPAIN_VERSES[id] ?? {}));
  if (fixes.length === 0) return readings;
  return readings.map((reading) => {
    const fix = fixes.find(([kind]) => kind === reading.kind)?.[1];
    if (!fix) return reading;
    const [book, passage] = fix;
    return { ...reading, options: [{ book, passage }, ...reading.options.slice(1)] };
  });
}

/** Groups rows into Readings; options within a kind keep the seed's order. */
function toReadings(rows: LectionaryRow[], opts: { firstOptionOnly?: boolean } = {}): Reading[] {
  const byKind = new Map<ReadingKind, { slot: number; ref: Reference }[]>();
  for (const row of rows) {
    const kind = KIND_OF_SLOT[row.slot.split('.')[0]];
    const ref = kind && parseReference(row.ref);
    if (!kind || !ref) continue;
    byKind.set(kind, [...(byKind.get(kind) ?? []), { slot: Number(row.slot), ref }]);
  }
  const readings = [...byKind].map(([kind, refs]) => {
    const options = refs.sort((a, b) => a.slot - b.slot).map((r) => r.ref);
    return { kind, options: opts.firstOptionOnly ? options.slice(0, 1) : options };
  });
  return sortReadings(readings);
}

/**
 * The Easter Vigil's seven Old Testament readings, each followed by its
 * Psalm, then the Epistle, its Psalm and the Gospel. Slot `1.n` is the n-th
 * reading and `1.n1` its shorter form.
 */
function easterVigil(rows: LectionaryRow[]): Reading[] {
  const refs = (prefix: string) =>
    rows
      .filter(
        (r) => r.slot === prefix || (r.slot.startsWith(prefix) && r.slot.length === prefix.length + 1),
      )
      .sort((a, b) => Number(a.slot) - Number(b.slot))
      .map((r) => parseReference(r.ref))
      .filter((r): r is Reference => r !== null);
  const out: Reading[] = [];
  for (let n = 1; n <= 7; n++) {
    out.push({ kind: 'first', options: refs(`1.${n}`) });
    out.push({ kind: 'psalm', options: refs(`2.${n}`) });
  }
  out.push({ kind: 'second', options: refs('1.8') });
  out.push({ kind: 'psalm', options: refs('2.8') });
  const gospel = toReadings(rows).find((r) => r.kind === 'gospel');
  if (gospel) out.push(gospel);
  return out.filter((r) => r.options.length > 0);
}

const ORDER: ReadingKind[] = ['first', 'psalm', 'second', 'gospel'];

function sortReadings(readings: Reading[]): Reading[] {
  return [...readings].sort((a, b) => ORDER.indexOf(a.kind) - ORDER.indexOf(b.kind));
}

function hasCoreReadings(readings: Reading[]): boolean {
  const kinds = new Set(readings.map((r) => r.kind));
  return kinds.has('first') && kinds.has('gospel');
}

const STOP_WORDS = new Set(['saint', 'saints', 'the', 'of', 'and', 'st', 'blessed', 'a', 'in', 'to']);

/** Word-overlap similarity (Jaccard) of two names, ignoring filler words. */
function similarity(a: string, b: string): number {
  const words = (s: string) =>
    new Set(
      s
        .toLowerCase()
        .replace(/[^a-z\s]/g, ' ')
        .split(/\s+/)
        .filter((w) => w.length > 1 && !STOP_WORDS.has(w)),
    );
  const x = words(a);
  const y = words(b);
  const shared = [...x].filter((w) => y.has(w)).length;
  return shared / (x.size + y.size - shared || 1);
}
