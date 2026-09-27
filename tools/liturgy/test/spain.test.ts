import { test } from 'node:test';
import assert from 'node:assert/strict';

import { generateLiturgy, type LiturgyData } from '../src/calendar.ts';

// Expected References are checked against the CEE's Calendario
// litúrgico-pastoral 2023-24, 2024-25 and 2025-26. Psalms are stored with
// Hebrew numbering (the CEE's "Sal 26" is Psalm 27).
const data: LiturgyData = await generateLiturgy({ fromYear: 2024, toYear: 2026 });

function readings(date: string): string[] {
  const key = data.days[date]?.readings;
  assert.ok(key, `no Readings for ${date}`);
  return data.lectionary[key].map(
    (r) => `${r.kind}: ${r.options.map((o) => `${o.book} ${o.passage}`).join(' | ')}`,
  );
}

test('Nuestra Señora del Pilar (12 Oct 2026)', () => {
  assert.deepEqual(readings('2026-10-12'), [
    'first: 1Chr 15:3-4,15-16;16:1-2 | Acts 1:12-14',
    'psalm: Ps 27',
    'gospel: Luke 11:27-28',
  ]);
});

test("Santiago, Spain's Solemnity (25 Jul 2026)", () => {
  assert.deepEqual(readings('2026-07-25'), [
    'first: Acts 4:33;5:12,27-33;12:2',
    'psalm: Ps 67',
    'second: 2Cor 4:7-15',
    'gospel: Matt 20:20-28',
  ]);
});

test('Jesucristo, Sumo y Eterno Sacerdote, year A (28 May 2026)', () => {
  assert.deepEqual(readings('2026-05-28'), [
    'first: Gen 22:9-18 | Heb 10:4-10',
    'psalm: Ps 40',
    'gospel: Matt 26:36-42',
  ]);
});

test('Jesucristo, Sumo y Eterno Sacerdote, year B (23 May 2024)', () => {
  assert.deepEqual(readings('2024-05-23'), [
    'first: Jer 31:31-34',
    'psalm: Ps 110',
    'second: Heb 10:11-18',
    'gospel: Mark 14:12a,22-25',
  ]);
});

test('Jesucristo, Sumo y Eterno Sacerdote, year C (12 Jun 2025)', () => {
  assert.deepEqual(readings('2025-06-12'), [
    'first: Isa 6:1-4,8 | Heb 2:10-18',
    'psalm: Ps 23',
    'gospel: John 17:1-2,9,14-26',
  ]);
});

test('San Isidoro, a Feast in Spain (26 Apr 2024)', () => {
  assert.deepEqual(readings('2024-04-26'), [
    'first: 1Cor 2:1-10',
    'psalm: Ps 119',
    'gospel: Matt 5:13-16',
  ]);
});

test('Santa Teresa de Jesús, a Feast in Spain (15 Oct 2026)', () => {
  assert.deepEqual(readings('2026-10-15'), [
    'first: Sir 15:1-6',
    'psalm: Ps 89',
    'gospel: Matt 11:25-30',
  ]);
});

test('Santa Brígida, patroness of Europe (23 Jul 2026)', () => {
  assert.deepEqual(readings('2026-07-23'), [
    'first: Gal 2:19-20',
    'psalm: Ps 34',
    'gospel: John 15:1-8',
  ]);
});

test("Spain's verse ranges where they differ from the seed", () => {
  // Friday of the 26th week, year II (the Guardian Angels' first reading).
  assert.equal(readings('2026-10-02')[0], 'first: Job 38:1,12-21;40:3-5');
  // 26th Sunday in Ordinary Time, year B.
  assert.equal(readings('2024-09-29')[3], 'gospel: Mark 9:38-43,45,47-48');
});

test('no Celebration falls back to the weekday for lack of proper Readings', async () => {
  const all = await generateLiturgy({ fromYear: 2020, toYear: 2040 });
  assert.deepEqual(all.missingPropers, []);
});
