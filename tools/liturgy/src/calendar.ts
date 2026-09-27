import { Romcal } from 'romcal';
import { Spain_De, Spain_En, Spain_Es } from '@romcal/calendar.spain';

/** Languages the app shows Celebration names in (the Mass Guide's languages). */
export const LANGUAGES = ['en', 'es', 'de'] as const;
export type Language = (typeof LANGUAGES)[number];

export type Rank =
  | 'SOLEMNITY'
  | 'FEAST'
  | 'MEMORIAL'
  | 'OPTIONAL_MEMORIAL'
  | 'SUNDAY'
  | 'WEEKDAY';

/** One Liturgical Day, as the app reads it from the bundled data. */
export interface LiturgicalDayData {
  /** romcal season id, e.g. `ORDINARY_TIME`, `LENT`. */
  season: string;
  /** Id of the Day's Celebration; its names are in {@link LiturgyData.names}. */
  celebration: string;
  rank: Rank;
  /**
   * Liturgical colour, lower-case (`green`, `white`, `red`, `purple`, `rose`,
   * …). Absent on Days without a Mass (Holy Saturday).
   */
  color?: string;
  /** Ids of the Optional Memorials that may be celebrated instead, if any. */
  optionalMemorials?: string[];
}

export interface LiturgyData {
  version: 1;
  /** Which Liturgical Calendar the data follows. */
  calendar: 'spain';
  fromYear: number;
  toYear: number;
  /** Celebration and Optional Memorial names, by id and language. */
  names: Record<string, Record<Language, string>>;
  /** Liturgical Days keyed by `YYYY-MM-DD`. */
  days: Record<string, LiturgicalDayData>;
}

const BUNDLES = { en: Spain_En, es: Spain_Es, de: Spain_De } as const;

/**
 * Spain's transfers, set through romcal's configuration: the Ascension and
 * Corpus Christi move to Sunday; Epiphany stays on 6 January.
 */
const SPAIN_CONFIG = {
  scope: 'gregorian',
  ascensionOnSunday: true,
  corpusChristiOnSunday: true,
  epiphanyOnSunday: false,
} as const;

/**
 * Celebrations romcal lists as Optional Memorials that are obligatory
 * Memorials in Spain's calendar (checked against the CEE's calendar).
 */
const OBLIGATORY_IN_SPAIN = new Set(['ildephonsus_of_toledo_bishop']);

interface RomcalDay {
  id: string;
  name: string;
  rank: string;
  isOptional: boolean;
  colors: string[];
  seasons: string[];
}

/** Generates Spain's Liturgical Calendar for every Day of the given years. */
export async function generateLiturgy(options: {
  fromYear: number;
  toYear: number;
}): Promise<LiturgyData> {
  const { fromYear, toYear } = options;
  const data: LiturgyData = {
    version: 1,
    calendar: 'spain',
    fromYear,
    toYear,
    names: {},
    days: {},
  };

  for (let year = fromYear; year <= toYear; year++) {
    const byLanguage = {} as Record<Language, Record<string, RomcalDay[]>>;
    for (const language of LANGUAGES) {
      const romcal = new Romcal({ localizedCalendar: BUNDLES[language], ...SPAIN_CONFIG });
      byLanguage[language] = (await romcal.generateCalendar(year)) as unknown as Record<
        string,
        RomcalDay[]
      >;
    }

    for (const [date, entries] of Object.entries(byLanguage.en)) {
      entries.forEach((entry, i) => {
        data.names[entry.id] ??= {
          en: entry.name,
          es: byLanguage.es[date][i].name,
          de: byLanguage.de[date][i].name,
        };
      });
      data.days[date] = toLiturgicalDay(entries);
    }
  }
  return data;
}

/**
 * romcal lists the Day's Celebration first. Any Memorials after it are
 * alternatives: Optional Memorials, or a second obligatory Memorial falling
 * on the same Day (both then become optional). Other entries, such as Holy
 * Thursday's evening Mass, are not alternatives. Spain's obligatory Memorials
 * are promoted from the list.
 */
function toLiturgicalDay(entries: RomcalDay[]): LiturgicalDayData {
  let [celebration, ...rest] = entries;
  let optional = rest.filter(
    (e) => e.isOptional || e.rank === 'MEMORIAL' || e.rank === 'OPTIONAL_MEMORIAL',
  );

  const promoted = optional.find((e) => OBLIGATORY_IN_SPAIN.has(e.id));
  if (promoted && celebration.rank === 'WEEKDAY') {
    celebration = { ...promoted, rank: 'MEMORIAL', isOptional: false };
    // Optional Memorials give way to an obligatory Memorial.
    optional = [];
  }

  return {
    season: celebration.seasons[0] ?? 'ORDINARY_TIME',
    celebration: celebration.id,
    rank: celebration.rank as Rank,
    ...(celebration.colors[0] && { color: celebration.colors[0].toLowerCase() }),
    ...(optional.length > 0 && { optionalMemorials: optional.map((e) => e.id) }),
  };
}
