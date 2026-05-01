/**
 * Follow Mass — Roman Missal Ordinary in three languages.
 *
 * Content is split per section (introductory / word / eucharist / concluding)
 * and per variant (penitential / creed / eucharistic) into sibling files,
 * each exporting a `MassStep[]`.  `generateMassSteps(opts)` concatenates them
 * in Missal order, picking the requested variant arrays.
 */

import { introductoryRitesSteps } from './introductory';
import { liturgyOfTheWordSteps } from './word';
import { liturgyOfTheEucharistSteps } from './eucharist';
import { concludingRitesSteps } from './concluding';
import { penitentialActSteps } from './variants/penitential';
import { creedSteps } from './variants/creed';
import { eucharisticPrayerSteps } from './variants/eucharistic';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type Lang = 'en' | 'es' | 'de';

export type I18nText = Record<Lang, string>;

export type MassSection = 'introductory' | 'word' | 'eucharist' | 'concluding';

export type MassStepKind =
  | 'section_header'
  | 'celebrant'
  | 'all'
  | 'response'
  | 'reading_placeholder'
  | 'silence'
  | 'complete';

export type OptionGroup = 'penitential' | 'creed' | 'eucharistic' | 'mysteryOfFaith';

export interface MassStep {
  id: string;
  section: MassSection;
  kind: MassStepKind;
  title?: I18nText;
  text?: I18nText;
  /** For `response` kind: the call (usually spoken by the priest). */
  call?: I18nText;
  /** For `response` kind: the reply (usually spoken by all). */
  response?: I18nText;
  speaker?: 'priest' | 'all' | 'reader';
  /** Marks this step as belonging to a swappable variant group. */
  group?: OptionGroup;
  /** The variant identifier within the group (e.g. 'a', 'ii', 'nicene'). */
  variant?: string;
  /** Steps with the same mergeGroup are rendered as a single card. */
  mergeGroup?: string;
}

export interface MassOptions {
  penitential: 'a' | 'b' | 'c';
  creed: 'nicene' | 'apostles';
  eucharistic: 'i' | 'ii' | 'iii' | 'iv';
  mysteryOfFaith: 'a' | 'b' | 'c';
}

export const DEFAULT_MASS_OPTIONS: MassOptions = {
  penitential: 'a',
  creed: 'nicene',
  eucharistic: 'ii',
  mysteryOfFaith: 'a',
};

export const LANGUAGES: { code: Lang; label: string; native: string }[] = [
  { code: 'en', label: 'English', native: 'English' },
  { code: 'es', label: 'Spanish', native: 'Español' },
  { code: 'de', label: 'German', native: 'Deutsch' },
];

export const OPTION_LABELS: Record<OptionGroup, I18nText> = {
  penitential: {
    en: 'Penitential Act',
    es: 'Acto Penitencial',
    de: 'Bußakt',
  },
  creed: {
    en: 'Profession of Faith',
    es: 'Profesión de Fe',
    de: 'Glaubensbekenntnis',
  },
  eucharistic: {
    en: 'Eucharistic Prayer',
    es: 'Plegaria Eucarística',
    de: 'Hochgebet',
  },
  mysteryOfFaith: {
    en: 'Mystery of Faith',
    es: 'Misterio de la fe',
    de: 'Geheimnis des Glaubens',
  },
};

export const VARIANT_LABELS: Record<OptionGroup, Record<string, I18nText>> = {
  penitential: {
    a: { en: 'Form A — Confiteor', es: 'Forma A — Yo confieso', de: 'Form A — Confiteor' },
    b: { en: 'Form B — Shorter', es: 'Forma B — Breve', de: 'Form B — Kurzform' },
    c: { en: 'Form C — Invocations', es: 'Forma C — Invocaciones', de: 'Form C — Anrufungen' },
  },
  creed: {
    nicene: { en: 'Nicene Creed', es: 'Credo Niceno', de: 'Großes Glaubensbekenntnis' },
    apostles: { en: "Apostles' Creed", es: 'Símbolo de los Apóstoles', de: 'Apostolisches Glaubensbekenntnis' },
  },
  eucharistic: {
    i: { en: 'EP I (Roman Canon)', es: 'PE I (Canon Romano)', de: 'HG I (Römischer Kanon)' },
    ii: { en: 'EP II', es: 'PE II', de: 'HG II' },
    iii: { en: 'EP III', es: 'PE III', de: 'HG III' },
    iv: { en: 'EP IV', es: 'PE IV', de: 'HG IV' },
  },
  mysteryOfFaith: {
    a: { en: 'Form A — We proclaim', es: 'Forma A — Anunciamos', de: 'Form A — Deinen Tod' },
    b: { en: 'Form B — When we eat', es: 'Forma B — Cada vez', de: 'Form B — Wenn wir dieses' },
    c: { en: 'Form C — Save us', es: 'Forma C — Por tu cruz', de: 'Form C — Rette uns' },
  },
};

export const SECTION_LABELS: Record<MassSection, I18nText> = {
  introductory: {
    en: 'Introductory Rites',
    es: 'Ritos Iniciales',
    de: 'Eröffnung',
  },
  word: {
    en: 'Liturgy of the Word',
    es: 'Liturgia de la Palabra',
    de: 'Wortgottesdienst',
  },
  eucharist: {
    en: 'Liturgy of the Eucharist',
    es: 'Liturgia Eucarística',
    de: 'Eucharistiefeier',
  },
  concluding: {
    en: 'Concluding Rites',
    es: 'Ritos de Conclusión',
    de: 'Entlassung',
  },
};

// ---------------------------------------------------------------------------
// Step generator
// ---------------------------------------------------------------------------

export function generateMassSteps(opts: MassOptions): MassStep[] {
  return [
    ...introductoryRitesSteps(opts),
    ...liturgyOfTheWordSteps(opts),
    ...liturgyOfTheEucharistSteps(opts),
    ...concludingRitesSteps(),
    {
      id: 'complete',
      section: 'concluding',
      kind: 'complete',
    },
  ];
}

// ---------------------------------------------------------------------------
// Step grouping — merges consecutive steps that share a mergeGroup
// ---------------------------------------------------------------------------

export type StepGroup = MassStep[];

export function groupMassSteps(steps: MassStep[]): StepGroup[] {
  const groups: StepGroup[] = [];
  let i = 0;
  while (i < steps.length) {
    const step = steps[i];
    if (step.mergeGroup) {
      const group: MassStep[] = [step];
      while (i + 1 < steps.length && steps[i + 1].mergeGroup === step.mergeGroup) {
        i++;
        group.push(steps[i]);
      }
      groups.push(group);
    } else {
      groups.push([step]);
    }
    i++;
  }
  return groups;
}

export { penitentialActSteps, creedSteps, eucharisticPrayerSteps };
