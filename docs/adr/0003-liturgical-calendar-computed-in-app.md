# The liturgical calendar and Reading References are computed in the app

Remote sources proved unreliable for daily liturgy. LitCal has references for only about a quarter of days, its Spanish and German modes fail, and it has no Spanish national calendar. dailylectio.org serves a single, undated entry. We decided the app computes each Liturgical Day itself: the Easter-based seasons, the ranking of Sundays against feasts, the General Roman Calendar plus Spain's own celebrations and transfers, and the Reading References, looked up in a bundled lectionary table. So it works offline and is never empty. We chose references rather than full text because lectionary translations are copyrighted, while references are not.

The computing happens ahead of time, not in the app. A generator script in the repo runs the romcal calendar engine (MIT; the only one with Spain's national calendar), with our fixes for Spain, together with our lectionary table. It writes one per-date data file for a range of years: Celebration, rank, colour, Optional Memorials and Reading References. The app bundles that file and looks dates up in it. We chose this over porting romcal to Dart because the port is large, while a generated file gives identical offline behaviour and can later be served as a public API unchanged. The lectionary table is seeded from a public-domain dataset. Spain's copyrighted CEE calendars are used only to check the output, never copied.

## Consequences

- LitCal and dailylectio.org stop being runtime dependencies.
- The bundled data covers a fixed range of years and must be regenerated before that range runs out.
- Fixes to the calendar or lectionary data ship as app updates. Publishing the same data later as a public, read-only API (including colour, rank and saints) remains an option and would not change the app's offline behaviour.
