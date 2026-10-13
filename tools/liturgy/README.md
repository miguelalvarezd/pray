# Liturgy generator

Generates the app's bundled liturgical data (see `docs/adr/0003-liturgical-calendar-computed-in-app.md`): Spain's Liturgical Calendar for every Day from 2020 to 2040, written to `flutter/assets/liturgy/liturgy.json`.

```bash
npm install
npm test          # checks the output against Spain's CEE calendar
npm run generate  # rewrites the bundled file
```

It uses [romcal](https://github.com/romcal/romcal) (MIT) with Spain's national calendar, plus our fixes for Spain:

- the Ascension and Corpus Christi move to Sunday;
- San Ildefonso is an obligatory Memorial.

Reading References come from the public-domain Tamil Catholic Lectionary (`data/tamil-lectionary/`). Spain's own proper Readings, and the verses where Spain's lectionary differs from the seed, are entered by hand in `src/spain.ts`. Each one is checked against the CEE's calendar, which is used only for checking and never copied wholesale (issue #16).

Regenerate with a later end year (`TO_YEAR` in `src/cli.ts`) before the app's range test starts failing: it fails once the current year is within 3 years of the end.
