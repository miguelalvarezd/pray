import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { generateLiturgy, type LiturgyData } from './calendar.ts';

/** The years bundled with the app. Regenerate before `TO_YEAR` gets close. */
const FROM_YEAR = 2020;
const TO_YEAR = 2040;

const here = dirname(fileURLToPath(import.meta.url));
const OUTPUT = resolve(here, '../../../flutter/assets/liturgy/liturgy.json');

/**
 * JSON with one name and one Day per line, so a regenerated file shows up in
 * diffs as the Days that actually changed.
 */
function serialize(data: LiturgyData): string {
  const lines = (record: Record<string, unknown>) =>
    Object.entries(record)
      .map(([key, value]) => `    ${JSON.stringify(key)}: ${JSON.stringify(value)}`)
      .join(',\n');
  return [
    '{',
    `  "version": ${data.version},`,
    `  "calendar": ${JSON.stringify(data.calendar)},`,
    `  "fromYear": ${data.fromYear},`,
    `  "toYear": ${data.toYear},`,
    '  "names": {',
    lines(data.names),
    '  },',
    '  "days": {',
    lines(data.days),
    '  },',
    '  "lectionary": {',
    lines(data.lectionary),
    '  }',
    '}',
    '',
  ].join('\n');
}

const data = await generateLiturgy({ fromYear: FROM_YEAR, toYear: TO_YEAR });
await mkdir(dirname(OUTPUT), { recursive: true });
await writeFile(OUTPUT, serialize(data));
console.log(
  `Wrote ${Object.keys(data.days).length} Days (${FROM_YEAR}–${TO_YEAR}) to ${OUTPUT}`,
);
if (data.missingPropers.length > 0) {
  console.warn(
    `These Celebrations have no proper Readings in the lectionary table yet, so they use the weekday's:\n  ${data.missingPropers.join('\n  ')}`,
  );
}
