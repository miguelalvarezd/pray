# Pray

A personal prayer companion for your phone: a daily checklist of prayers and Activities, the Intentions you pray for, Novenas, guided Rosary and Mass, and Spain's Liturgical Calendar with each Day's Reading References.

Everything works offline and stays on the device. There is no account and no server (see [ADR-0002](docs/adr/0002-data-stays-on-device.md)).

## Features

- **Today**:
  - check off the Daily Prayers (Morning Prayer, Holy Mass, Rosary, Evening Prayer, Bible Reading) and Activities (Confession, Adoration, Volunteering, …);
  - pray for your Intentions and active Novenas;
  - write a Gratitude Entry.
  
  The Day runs from 04:00 to 03:59, so praying after midnight counts toward the previous Day.
- **Holy Mass**: the Day's Celebration and its rank, any Optional Memorials, and the Reading References, following Spain's Liturgical Calendar.
- **Intentions**:
  - set a Priority and a Target Date;
  - mark an Intention Answered, recording the Day and an optional note on how;
  - archive it, or restore it later.
  
  Once the Target Date has passed, the app asks whether it was answered.
- **Novenas**:
  - nine Days, started from a Novena Template or written yourself;
  - optionally offered for an Intention, so each Day you pray the Novena counts for that Intention;
  - past Novenas show as Completed or Incomplete.
- **Prayer Guides**: a step-by-step Rosary (tap to advance) and Mass. The Mass Guide is in English, Spanish or German and shows each Reading's reference.
- **History and Stats**: a month-by-month view of each Day, a heatmap, and your Streak of Prayed Days.
- **Backup**: export everything to a JSON file and import it on another device. Older backups, including ones from the React app, are upgraded on import.

The words used throughout the app and the code are defined in [CONTEXT.md](CONTEXT.md).

## Repository layout

| Path | What it is |
| --- | --- |
| `flutter/` | **The app** (Flutter, for Android and iOS; see [ADR-0001](docs/adr/0001-flutter-is-the-only-client.md)) |
| `tools/liturgy/` | Generator for the bundled liturgical data (Node/TypeScript; see [its README](tools/liturgy/README.md)) |
| `docs/adr/` | Architecture decisions |
| `docs/agents/`, `AGENTS.md` | Configuration for coding agents (issue tracker, triage labels, domain docs) |
| `CONTEXT.md` | The domain glossary |
| `src/`, `public/`, `index.html` | The retired React PWA, kept only until a Flutter web build replaces it (#12) |

Inside `flutter/lib/`:

- `features/`: one folder per screen (Today, Intentions, History, Stats, Settings, the Rosary and Mass Guides)
- `domain/`: pure logic (Streaks, Urgency, Novena outcomes, the Rosary and Mass steps)
- `data/`: Hive models, repositories (Riverpod notifiers), backup and schema migrations
- `services/liturgy/`: the Liturgical Day lookup and Reading Reference formatting
- `core/`: navigation, theme, the Day boundary and shared widgets

## Running the app

**Prerequisites:** the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.11 or later) and, for a phone, the Android SDK with `adb`.

```bash
cd flutter
flutter pub get
flutter run          # on a connected phone or emulator
```

### On your Android phone, over Wi-Fi (Android 11+)

1. On the phone, turn on **Developer options** (tap **Settings → About phone → Build number** 7 times), then **Wireless debugging**.
2. Choose **Pair device with pairing code**, then pair and connect from the computer. The phone and computer must be on the same Wi-Fi.

   ```bash
   adb pair <ip>:<pairing-port>     # asks for the 6-digit code
   adb connect <ip>:<port>          # the port shown on the Wireless debugging screen
   flutter run                      # r = hot reload, R = restart, q = quit
   ```

3. To install a standalone build instead, run `flutter build apk --release` and copy `build/app/outputs/flutter-apk/app-release.apk` to the phone.

**On WSL2:** if `adb connect` times out, set `networkingMode=mirrored` in `%UserProfile%\.wslconfig` and run `wsl --shutdown`.

**Before testing a new build on a phone that already has your data, export a backup** (Settings → Data & Backup → Export). On first launch, a new version upgrades the data stored on the device to the current schema.

To check anything that depends on the date, set a date in Settings → Developer Mode; the whole app treats it as today.

## Tests

```bash
cd flutter && flutter analyze && flutter test
cd tools/liturgy && npm install && npm test
```

The Flutter tests cover:

- pure domain logic;
- the data layer, through a Riverpod container over test Hive boxes;
- backups and migrations;
- the Liturgical Day lookup, against the real bundled data;
- a few app-level widget tests (in-memory boxes, a fixed Day).

The generator's tests check its output against Spain's official CEE calendars.

## Liturgical data

The app never fetches the liturgy from the network. `tools/liturgy` generates `flutter/assets/liturgy/liturgy.json` ahead of time, and the app bundles it. For every Day from 2020 to 2040 the file gives the Celebration, its rank and colour, any Optional Memorials, and the Reading References.

It combines:

- [romcal](https://github.com/romcal/romcal), with Spain's national calendar and our fixes for Spain;
- a public-domain lectionary;
- Spain's own proper Readings, each checked against the CEE's calendar.

See [ADR-0003](docs/adr/0003-liturgical-calendar-computed-in-app.md).

To change the data, edit the generator and run `npm run generate`. Regenerate with a later end year before the app's range test starts failing, which happens once the current year is within 3 years of the end.

## Data and backups

- Data lives in Hive boxes on the device.
- The data has a schema version, and every change to its shape adds a migration step. The same steps upgrade both imported backups and the data already on the device.
- A backup is a versioned JSON file. It can only be imported by a version of the app at least as new as the one that exported it.

## Plans

Ideas for later are GitHub issues labelled [`future`](https://github.com/miguelalvarezd/pray/issues?q=label%3Afuture):

- a light web version;
- sync between devices;
- a public liturgy API;
- a region setting for the Liturgical Calendar;
- permission from the CEE to use their calendars.
