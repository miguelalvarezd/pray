import { test } from 'node:test';
import assert from 'node:assert/strict';

import { generateLiturgy, type LiturgyData } from '../src/calendar.ts';

// Expected values come from the CEE's Calendario litúrgico-pastoral 2025-2026
// (the official calendar for Spain), not from romcal.
const data: LiturgyData = await generateLiturgy({ fromYear: 2026, toYear: 2026 });

function celebration(date: string) {
  const day = data.days[date];
  assert.ok(day, `no data for ${date}`);
  return { ...day, name: data.names[day.celebration] };
}

test('San Ildefonso is an obligatory Memorial in Spain (23 Jan 2026)', () => {
  const day = celebration('2026-01-23');
  assert.equal(day.celebration, 'ildephonsus_of_toledo_bishop');
  assert.equal(day.rank, 'MEMORIAL');
  assert.equal(day.color, 'white');
  assert.equal(day.optionalMemorials, undefined);
});

test('San Isidro Labrador is a Memorial (15 May 2026)', () => {
  const day = celebration('2026-05-15');
  assert.equal(day.celebration, 'isidore_the_farmer');
  assert.equal(day.rank, 'MEMORIAL');
});

test('the Ascension is moved to Sunday (17 May 2026)', () => {
  assert.equal(celebration('2026-05-17').celebration, 'ascension_of_the_lord');
  assert.equal(celebration('2026-05-17').rank, 'SOLEMNITY');
  assert.notEqual(celebration('2026-05-14').celebration, 'ascension_of_the_lord');
});

test('Jesucristo, Sumo y Eterno Sacerdote is a Feast on the Thursday after Pentecost (28 May 2026)', () => {
  const day = celebration('2026-05-28');
  assert.equal(day.celebration, 'our_lord_jesus_christ_the_eternal_high_priest');
  assert.equal(day.rank, 'FEAST');
});

test('Corpus Christi is moved to Sunday (7 Jun 2026)', () => {
  assert.equal(celebration('2026-06-07').celebration, 'most_holy_body_and_blood_of_christ');
  assert.notEqual(celebration('2026-06-04').celebration, 'most_holy_body_and_blood_of_christ');
});

test('Santiago, patron of Spain, is a Solemnity (25 Jul 2026)', () => {
  const day = celebration('2026-07-25');
  assert.equal(day.celebration, 'james_apostle');
  assert.equal(day.rank, 'SOLEMNITY');
  assert.equal(day.color, 'red');
});

test('Nuestra Señora del Pilar is a Feast (12 Oct 2026)', () => {
  const day = celebration('2026-10-12');
  assert.equal(day.celebration, 'our_lady_of_the_pillar');
  assert.equal(day.rank, 'FEAST');
  assert.equal(day.name.es, 'Nuestra Señora del Pilar');
});

test('a weekday with Optional Memorials lists them as alternatives (28 Sep 2026)', () => {
  const day = celebration('2026-09-28');
  assert.equal(day.rank, 'WEEKDAY');
  assert.equal(day.season, 'ORDINARY_TIME');
  assert.equal(day.color, 'green');
  assert.deepEqual(day.optionalMemorials, [
    'wenceslaus_i_of_bohemia_martyr',
    'lawrence_ruiz_and_companions_martyrs',
  ]);
});

test('Celebration names are given in English, Spanish and German', () => {
  const name = celebration('2026-09-27').name;
  assert.equal(name.en, 'twenty-sixth Sunday in Ordinary Time');
  assert.equal(name.es, '26º domingo del Tiempo Ordinario');
  assert.equal(name.de, '26. Sonntag im Jahreskreis');
});

test('every Day of the requested years is present', async () => {
  const twoYears = await generateLiturgy({ fromYear: 2027, toYear: 2028 });
  assert.equal(Object.keys(twoYears.days).length, 365 + 366);
  assert.equal(twoYears.fromYear, 2027);
  assert.equal(twoYears.toYear, 2028);
});

test('when two Memorials fall on the same Day, the second is offered as an alternative (13 Jun 2026)', () => {
  const day = celebration('2026-06-13');
  assert.equal(day.celebration, 'immaculate_heart_of_mary');
  assert.deepEqual(day.optionalMemorials, ['anthony_of_padua_priest']);
});

test('Holy Thursday has one Celebration and no alternatives (2 Apr 2026)', () => {
  const day = celebration('2026-04-02');
  assert.equal(day.celebration, 'holy_thursday');
  assert.equal(day.optionalMemorials, undefined);
});

test('Holy Saturday, which has no Mass, has no liturgical colour (4 Apr 2026)', () => {
  const day = celebration('2026-04-04');
  assert.equal(day.season, 'PASCHAL_TRIDUUM');
  assert.equal(day.color, undefined);
});
