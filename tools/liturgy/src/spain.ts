import type { Reading } from './readings.ts';

/*
 * Spain's own Readings, entered by hand because the public-domain seed
 * doesn't have them. Each entry was checked against the CEE's Calendario
 * litúrgico-pastoral (2023-24, 2024-25 or 2025-26), which is used only to
 * check, never copied wholesale (ADR-0003; issue #16 tracks permission).
 * Psalms use Hebrew numbering: the CEE's "Sal 26" is Psalm 27.
 */

const r = (kind: Reading['kind'], ...refs: [book: string, passage: string][]): Reading => ({
  kind,
  options: refs.map(([book, passage]) => ({ book, passage })),
});

/**
 * Proper Readings of Celebrations in Spain's calendar, by romcal id. A
 * Celebration whose Readings change with the Sunday cycle lists them per
 * cycle (`A`, `B`, `C`).
 */
export const SPAIN_PROPERS: Record<string, Reading[] | Record<'A' | 'B' | 'C', Reading[]>> = {
  // Spain's Solemnity, with its own first reading (the universal Feast has none).
  james_apostle: [
    r('first', ['Acts', '4:33;5:12,27-33;12:2']),
    r('psalm', ['Ps', '67']),
    r('second', ['2Cor', '4:7-15']),
    r('gospel', ['Matt', '20:20-28']),
  ],
  our_lady_of_the_pillar: [
    r('first', ['1Chr', '15:3-4,15-16;16:1-2'], ['Acts', '1:12-14']),
    r('psalm', ['Ps', '27']),
    r('gospel', ['Luke', '11:27-28']),
  ],
  our_lord_jesus_christ_the_eternal_high_priest: {
    A: [
      r('first', ['Gen', '22:9-18'], ['Heb', '10:4-10']),
      r('psalm', ['Ps', '40']),
      r('gospel', ['Matt', '26:36-42']),
    ],
    B: [
      r('first', ['Jer', '31:31-34']),
      r('psalm', ['Ps', '110']),
      r('second', ['Heb', '10:11-18']),
      r('gospel', ['Mark', '14:12a,22-25']),
    ],
    C: [
      r('first', ['Isa', '6:1-4,8'], ['Heb', '2:10-18']),
      r('psalm', ['Ps', '23']),
      r('gospel', ['John', '17:1-2,9,14-26']),
    ],
  },
  isidore_of_seville_bishop: [
    r('first', ['1Cor', '2:1-10']),
    r('psalm', ['Ps', '119']),
    r('gospel', ['Matt', '5:13-16']),
  ],
  teresa_of_jesus_of_avila_virgin: [
    r('first', ['Sir', '15:1-6']),
    r('psalm', ['Ps', '89']),
    r('gospel', ['Matt', '11:25-30']),
  ],
  bridget_of_sweden_religious: [
    r('first', ['Gal', '2:19-20']),
    r('psalm', ['Ps', '34']),
    r('gospel', ['John', '15:1-8']),
  ],
};

/**
 * Where Spain's lectionary gives different verses from the seed, keyed by
 * seed day id and Reading kind; the replacement is the main option.
 */
export const SPAIN_VERSES: Record<string, Partial<Record<Reading['kind'], [string, string]>>> = {
  'OW26-5Fri 2': { first: ['Job', '38:1,12-21;40:3-5'] },
  'OW26-0Sun B': { gospel: ['Mark', '9:38-43,45,47-48'] },
};
