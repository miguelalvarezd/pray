# Store metadata draft — Pray

A working draft for App Store + Google Play submission. Edit before
publishing.

## App identity

| Field | Value | Notes |
|---|---|---|
| Display name | **Pray** | Shown under the home-screen icon |
| Short / promo name | Pray | ≤ 30 chars |
| Bundle / package | `com.miguel.pray.pray` | Inherited from `flutter create --org com.miguel.pray --project-name pray`. To shorten to `com.miguel.pray` you'd need to refactor `MainActivity.kt`'s package and the iOS `PRODUCT_BUNDLE_IDENTIFIER`. |
| Primary category | Lifestyle | Or "Reference" on iOS |
| Secondary category | Health & Fitness | Optional |
| Content rating | 4+ / Everyone | No mature content |
| Pricing | Free | No IAP, no ads |

## Tagline (≤ 30 chars)

> A daily companion for prayer.

## Subtitle (iOS, ≤ 30 chars)

> Track devotion, find peace.

## Short description (Google Play, ≤ 80 chars)

> Track your daily prayers, intentions, and novenas — privately, on your device.

## Full description (≤ 4000 chars)

> Pray is a quiet daily companion for the Catholic prayer life. Track your
> Morning Prayer, Holy Mass, Rosary, Evening Prayer, and Bible reading —
> watch your streaks build, your intentions answered, and your novenas
> through to day nine.
>
> Everything lives on your device. No accounts. No tracking. No cloud.
>
> ★ DAILY GUIDES
> · Step-by-step Rosary guide with bead tracker, mystery readings, and
>   day-of-week mystery rotation
> · Step-by-step Mass guide following the Roman Missal Ordinary, with
>   English / Spanish / German text and selectable variants for the
>   Penitential Act, Profession of Faith, and the four Eucharistic Prayers
>
> ★ INTENTIONS & NOVENAS
> · Track your prayer intentions with priority and target dates — the most
>   urgent ones rise to the top automatically
> · Pre-loaded library of classic novenas (St. Jude, Divine Mercy, Sacred
>   Heart, Our Lady of Perpetual Help, and more) — or start your own
>
> ★ HISTORY & STATS
> · Day-by-day journal of what you prayed, what you reflected on, and what
>   you wrote down
> · Year-long activity heatmap, streak tracking, and monthly per-prayer
>   progress
>
> ★ PRIVACY FIRST
> · No account, no sign-in, nothing leaves your phone
> · Export your data to a JSON file anytime; import it back on a new device
>
> ★ DAILY READINGS
> · Today's Mass readings and verse of the day pulled from public liturgical
>   calendars (cached for offline use)
>
> Pray works fully offline once installed. Built to be a quiet, distraction-
> free companion to your spiritual life — not another notification machine.

## Keywords (iOS, ≤ 100 chars total, comma-separated, no spaces)

> prayer,rosary,catholic,mass,novena,devotion,intentions,journal,bible,faith

## What's New (release notes)

### v1.0.0
> The first release of Pray.
> · Daily prayer tracking (Morning, Mass, Rosary, Evening, Bible reading)
> · Intentions with urgency-sorted list
> · 8 pre-loaded novena templates
> · Step-by-step Rosary guide with bead tracker
> · Step-by-step Mass guide (English / Spanish / German)
> · History calendar + year heatmap + monthly stats
> · Local-only storage with JSON export/import

## Screenshots (suggested order)

1. **Today** — daily prayer list with progress bar
2. **Rosary guide** — bead column + active prayer step
3. **Mass guide** — preface dialogue showing PRIEST/ALL response cards
4. **Intentions** — urgency-sorted list with priority chips
5. **Stats** — current streak card + heatmap
6. **History** — month view with the journal expansion open

iOS device frames: iPhone 6.7", iPhone 6.5". Android frames: Pixel 7, Pixel 8 Pro.

## Privacy / data declarations

- **Data collected**: none.
- **Data shared with third parties**: none.
- **Network usage**: read-only requests to `litcal.johnromanodorazio.com` and
  `dailylectio.org` for the day's liturgical calendar and readings. No
  analytics, no telemetry, no advertising IDs.
- **Permissions requested**: storage (for JSON export/import). No location,
  camera, microphone, or contacts.

## Support / contact

| Field | Value |
|---|---|
| Support URL | TBD (placeholder: `https://github.com/miguelalvarezd/pray`) |
| Privacy URL | TBD — needs a hosted privacy policy page summarizing the above |
| Marketing URL | Optional |

## Pre-submission checklist

- [ ] Replace placeholder support / privacy URLs with hosted pages
- [ ] Generate signing keystore for Android release builds (currently signs
      with the debug key — see `android/app/build.gradle.kts`)
- [ ] Bump `version` in `pubspec.yaml` from `1.0.0+1` if needed
- [ ] Capture screenshots on real devices (or with `screenshots/` package)
- [ ] Verify both APIs work over cellular and that offline mode degrades gracefully
- [ ] Manual parity walk vs the React PWA: rosary, mass, intentions CRUD
- [ ] Run `flutter build appbundle --release` and `flutter build ipa` once on a
      Mac for iOS
