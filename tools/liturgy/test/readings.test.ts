import { test } from 'node:test';
import assert from 'node:assert/strict';

import { generateLiturgy, type LiturgyData } from '../src/calendar.ts';

// Expected References come from the CEE's Calendario litúrgico-pastoral
// 2025-2026 where it covers the Day, and otherwise from the Roman Lectionary.
// Psalms use Hebrew numbering; each reading lists its options ("or").
const data: LiturgyData = await generateLiturgy({ fromYear: 2022, toYear: 2027 });

/** The Day's Readings as `kind: Book passage | Book passage` lines. */
function readings(date: string): string[] {
  const key = data.days[date]?.readings;
  assert.ok(key, `no Readings for ${date}`);
  return data.lectionary[key].map(
    (r) => `${r.kind}: ${r.options.map((o) => `${o.book} ${o.passage}`).join(' | ')}`,
  );
}

test('a Sunday in cycle A (26th Sunday in Ordinary Time, 27 Sep 2026)', () => {
  assert.deepEqual(readings('2026-09-27'), [
    'first: Ezek 18:25-28',
    'psalm: Ps 25:4-5,6-7,8-9',
    'second: Phil 2:1-11 | Phil 2:1-5',
    'gospel: Matt 21:28-32',
  ]);
});

test('a Sunday in cycle B (26th Sunday in Ordinary Time, 29 Sep 2024)', () => {
  const r = readings('2024-09-29');
  assert.equal(r[0], 'first: Num 11:25-29');
  // The seed gives Mark 9:38-48; Spain's lectionary selects 38-43, 45, 47-48
  // (verse-range differences are fixed entry by entry, see #26).
  assert.match(r[3], /^gospel: Mark 9:38-/);
});

test('a Sunday in cycle C with a shorter Gospel (24th Sunday in Ordinary Time, 11 Sep 2022)', () => {
  assert.equal(readings('2022-09-11')[3], 'gospel: Luke 15:1-32 | Luke 15:1-10');
});

test('a weekday in cycle II (Monday of the 26th week, 28 Sep 2026)', () => {
  assert.deepEqual(readings('2026-09-28'), [
    'first: Job 1:6-22',
    'psalm: Ps 17:1,2-3,6-7',
    'gospel: Luke 9:46-50',
  ]);
});

test('a weekday in cycle I (Monday of the 26th week, Saint Vincent de Paul, 27 Sep 2027)', () => {
  const r = readings('2027-09-27');
  assert.equal(r[0], 'first: Zech 8:1-8');
  assert.equal(r[2], 'gospel: Luke 9:46-50');
});

test('Ash Wednesday (18 Feb 2026)', () => {
  const r = readings('2026-02-18');
  assert.equal(r[0], 'first: Joel 2:12-18');
  // Psalm verse numbering differs between lectionaries; the psalm is 51.
  assert.match(r[1], /^psalm: Ps 51:/);
  assert.equal(r[2], 'second: 2Cor 5:20-6:2');
  assert.equal(r[3], 'gospel: Matt 6:1-6,16-18');
});

test('a Lent Sunday with alternative Gospels (3rd Sunday of Lent, year A, 8 Mar 2026)', () => {
  assert.match(readings('2026-03-08')[3], /^gospel: John 4:5-42 \| John 4:5-/);
});

test('an Easter weekday (Friday of the 6th week, San Isidro, 15 May 2026): a Memorial without proper Readings uses the weekday', () => {
  const r = readings('2026-05-15');
  assert.equal(r[0], 'first: Acts 18:9-18');
  assert.equal(r.at(-1), 'gospel: John 16:20-23a');
});

test('a Memorial with a proper Gospel keeps the weekday first reading (Guardian Angels, 2 Oct 2026)', () => {
  const r = readings('2026-10-02');
  // Spain reads Job 38:1,12-21; 40:3-5; its own verse ranges come with #26.
  assert.match(r[0], /^first: Job 38:1,12-21;40:3-/);
  assert.equal(r.at(-1), 'gospel: Matt 18:1-5,10');
});

test('a Memorial with alternative proper Gospels (Saint Martha, 29 Jul 2026)', () => {
  const r = readings('2026-07-29');
  assert.match(r[0], /^first: Jer 15:10,16-21/);
  assert.equal(r.at(-1), 'gospel: John 11:19-27 | Luke 10:38-42');
});

test('a Solemnity replacing a Sunday uses its own Readings (All Saints, Sunday 1 Nov 2026)', () => {
  assert.equal(data.days['2026-11-01'].celebration, 'all_saints');
  const r = readings('2026-11-01');
  assert.equal(r[0], 'first: Rev 7:2-4,9-14');
  assert.equal(r.at(-1), 'gospel: Matt 5:1-12a');
});

test('a Day with Optional Memorials uses the weekday Readings (28 Sep 2026)', () => {
  assert.ok(data.days['2026-09-28'].optionalMemorials);
  assert.equal(readings('2026-09-28')[0], 'first: Job 1:6-22');
});

test('the Easter Vigil lists its readings in order (4 Apr 2026)', () => {
  const r = readings('2026-04-04');
  assert.equal(r[0], 'first: Gen 1:1-2:2 | Gen 1:1,26-31b');
  assert.equal(r[2], 'first: Gen 22:1-18 | Gen 22:1-2,9a,10-13,15-18');
  assert.equal(r.at(-1), 'gospel: Matt 28:1-10');
});

test('every Day has a First Reading, a Psalm and a Gospel', async () => {
  const all = await generateLiturgy({ fromYear: 2020, toYear: 2040 });
  const missing = Object.entries(all.days)
    .filter(([, day]) => {
      const kinds = new Set(all.lectionary[day.readings ?? '']?.map((r) => r.kind));
      // Good Friday and Holy Saturday have no Mass in the usual sense, but
      // both still have Readings (the Passion; the Vigil).
      return !(kinds.has('first') && kinds.has('psalm') && kinds.has('gospel'));
    })
    .map(([date]) => date);
  assert.deepEqual(missing, []);
});

test('All Souls has its own Readings (2 Nov 2026)', () => {
  assert.equal(data.days['2026-11-02'].celebration, 'commemoration_of_all_the_faithful_departed');
  const r = readings('2026-11-02');
  assert.ok(r.some((line) => line.startsWith('second: 1Cor 15:')), r.join('\n'));
});
