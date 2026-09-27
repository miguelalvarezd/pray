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

Regenerate with a later end year (`TO_YEAR` in `src/cli.ts`) before the app's range test starts failing, which happens 3 years before the end.
