# 🙏 Prayer Tracker

A mobile-first Progressive Web App to track daily prayers, intentions, novenas, and streaks. All data is stored locally on your device — no account, no server, fully offline.

## Features

- **Daily Prayer Checklist** — track Morning Prayer, Mass, Rosary, Evening Prayer, Bible Reading
- **Intentions** — manage prayer intentions with priority levels and urgency scoring
- **Novenas** — 9-day prayer tracking with daily progress
- **History** — month-by-month agenda view with completion progress bars
- **Stats** — streaks (current & best), monthly breakdown per prayer category
- **Dark Mode** — automatic system detection or manual toggle
- **Export / Import** — backup and restore all data as JSON
- **PWA** — installable on your phone's home screen, works fully offline

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | React 19 + TypeScript |
| Build | Vite 6 |
| Styling | TailwindCSS v4 |
| Animations | Motion (Framer Motion) |
| Icons | Lucide React |
| PWA | vite-plugin-pwa + Workbox |
| Storage | localStorage (client-side only) |

## Run Locally

**Prerequisites:** Node.js

```bash
npm install
npm run dev
```

The app runs at `http://localhost:3000`.

## Deploy

Build and deploy to [Vercel](https://vercel.com) (free):

```bash
npm run build
npx vercel --prod
```

Open the deployed URL on your phone and tap **"Add to Home Screen"** to install as a standalone app.

## Project Structure

```
src/
├── App.tsx              — Root state management + tab routing
├── types.ts             — Data models (Intention, Novena, DailyLog, Prayer)
├── hooks/
│   └── useLocalStorage  — Generic localStorage ↔ React state hook
├── lib/
│   ├── icons.tsx        — Shared icon mapping utility
│   ├── intentions.ts    — Urgency scoring algorithm
│   └── utils.ts         — cn() utility (clsx + twMerge)
├── components/
│   ├── BottomNav.tsx     — Fixed bottom tab bar
│   ├── ThemeProvider.tsx — Dark/light/system theme context
│   └── ui/              — Button, Card, Input, Textarea
└── pages/
    ├── Today.tsx         — Daily checklist
    ├── Intentions.tsx    — Intention & novena management
    ├── History.tsx       — Monthly agenda view
    ├── Stats.tsx         — Streaks & monthly breakdown
    └── Settings.tsx      — Theme, backup, dev tools
```
