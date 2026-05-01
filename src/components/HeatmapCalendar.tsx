import React, { useMemo, useState } from 'react';
import { format, startOfYear, endOfYear, eachDayOfInterval, getDay, parseISO, addYears, subYears } from 'date-fns';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { motion } from 'motion/react';
import { DailyLog, Prayer } from '@/types';
import { cn } from '@/lib/utils';
import { getLiturgicalColorSync } from '@/lib/api';

interface HeatmapCalendarProps {
  logs: Record<string, DailyLog>;
  prayers: Prayer[];
  currentDate: Date;
}

type FilterType = 'all' | 'prayer' | 'novena' | 'activity' | string; // string = specific prayer id

/**
 * GitHub-style year grid. Each column is a week, each row is a day of the
 * week. Cell intensity is scaled to the max count for the current filter.
 *
 * Filters:
 *  - 'all'       — any prayer, novena, or activity
 *  - 'prayer'    — any daily prayer
 *  - 'novena'    — any novena progress
 *  - 'activity'  — any extra activity
 *  - <prayerId>  — a specific prayer by id
 */
export function HeatmapCalendar({ logs, prayers, currentDate }: HeatmapCalendarProps) {
  const [year, setYear] = useState(() => currentDate.getFullYear());
  const [filter, setFilter] = useState<FilterType>('all');

  const canGoNext = year < currentDate.getFullYear();

  const { weeks, maxCount, monthLabels, gapCols } = useMemo(() => {
    const start = startOfYear(new Date(year, 0, 1));
    const end = endOfYear(new Date(year, 0, 1));
    const allDays = eachDayOfInterval({ start, end });

    // Count lookup for the current filter.
    const countFor = (log: DailyLog | undefined): number => {
      if (!log) return 0;
      switch (filter) {
        case 'all':
          return (
            (log.completedPrayers?.length || 0) +
            (log.completedNovenas?.length || 0) +
            (log.completedActivities?.length || 0)
          );
        case 'prayer':
          return log.completedPrayers?.length || 0;
        case 'novena':
          return log.completedNovenas?.length || 0;
        case 'activity':
          return log.completedActivities?.length || 0;
        case 'mass':
          return log.completedPrayers?.includes('mass') ? 1 : 0;
        default:
          // specific prayer id
          return log.completedPrayers?.includes(filter) ? 1 : 0;
      }
    };

    // Pad the start with empty cells so the first real day lines up with
    // the correct row (Monday = row 0).
    const firstDayOfWeek = (getDay(start) + 6) % 7;
    const padded: (Date | null)[] = Array(firstDayOfWeek).fill(null).concat(allDays);

    // Group into weeks of 7.
    const weekCols: (Date | null)[][] = [];
    for (let i = 0; i < padded.length; i += 7) {
      weekCols.push(padded.slice(i, i + 7));
    }

    // Max count across year, for intensity scaling.
    let max = 0;
    for (const day of allDays) {
      const log = logs[format(day, 'yyyy-MM-dd')];
      const c = countFor(log);
      if (c > max) max = c;
    }

    // Pre-compute per-day counts for rendering.
    const weeks = weekCols.map((week) =>
      week.map((day) => {
        if (!day) return null;
        const key = format(day, 'yyyy-MM-dd');
        return { date: day, dateKey: key, count: countFor(logs[key]) };
      })
    );

    // Compute gap columns and month labels together.
    // Rule: if a month's first day falls Mon–Fri (rowIdx 0–4), the transition
    // column becomes the first column of the new month (gap before it).
    // If it falls Sat–Sun (rowIdx 5–6), that column stays with the old month
    // and the gap goes before the next column.
    const labels: { text: string; col: number }[] = [];
    const gapCols = new Set<number>();
    let prevMonth = -1;

    weekCols.forEach((week, colIdx) => {
      for (let rowIdx = 0; rowIdx < week.length; rowIdx++) {
        const day = week[rowIdx];
        if (!day) continue;
        const m = day.getMonth();
        if (m !== prevMonth) {
          if (prevMonth === -1) {
            labels.push({ text: format(day, 'MMM'), col: colIdx });
          } else {
            const targetCol = rowIdx <= 4 ? colIdx : colIdx + 1;
            if (targetCol < weekCols.length) {
              gapCols.add(targetCol);
              labels.push({ text: format(day, 'MMM'), col: targetCol });
            }
          }
          prevMonth = m;
          break;
        }
      }
    });

    return { weeks, maxCount: max, monthLabels: labels, gapCols };
  }, [logs, year, filter]);

  // 5-stop intensity scale. 0 = empty, 4 = densest.
  const intensityFor = (count: number): number => {
    if (count <= 0) return 0;
    if (maxCount <= 1) return 4;
    const ratio = count / maxCount;
    if (ratio >= 0.75) return 4;
    if (ratio >= 0.5) return 3;
    if (ratio >= 0.25) return 2;
    return 1;
  };

  const intensityClass = (level: number): string => {
    switch (level) {
      case 0:
        return 'bg-surface-container-high';
      case 1:
        return 'bg-primary/25';
      case 2:
        return 'bg-primary/45';
      case 3:
        return 'bg-primary/70';
      case 4:
        return 'bg-primary';
      default:
        return 'bg-surface-container-high';
    }
  };

  const liturgicalColorClass = (colorStr: string | undefined): string => {
    if (!colorStr) return 'bg-surface-container-high';
    const color = colorStr.toLowerCase();
    switch (color) {
      case 'purple':
        return 'bg-[var(--color-liturgical-purple)]';
      case 'red':
        return 'bg-[var(--color-liturgical-red)]';
      case 'white':
        return 'bg-[var(--color-liturgical-white)]';
      case 'rose':
        return 'bg-[var(--color-liturgical-rose)]';
      case 'green':
        return 'bg-[var(--color-liturgical-green)]';
      default:
        return 'bg-surface-container-high';
    }
  };

  const filterOptions: { id: FilterType; label: string }[] = [
    { id: 'all', label: 'All' },
    { id: 'prayer', label: 'Prayers' },
    { id: 'novena', label: 'Novenas' },
    { id: 'activity', label: 'Other' },
    { id: 'mass', label: 'Mass' },
    ...prayers.map((p) => ({ id: p.id, label: p.title })),
  ];

  return (
    <div className="space-y-4">
      {/* Header + year navigation — intentionally mirrors the month navigator style */}
      <div className="flex items-center justify-between">
        <h2 className="font-headline text-2xl text-on-surface">{year} <span className="font-headline text-2xl text-on-surface-variant font-normal">Heatmap</span></h2>
        <div className="flex gap-2">
          <button
            onClick={() => setYear((y) => y - 1)}
            className="w-10 h-10 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors active:scale-95"
            aria-label="Previous year"
          >
            <ChevronLeft className="h-5 w-5 text-on-surface-variant" />
          </button>
          <button
            onClick={() => setYear((y) => y + 1)}
            disabled={!canGoNext}
            className="w-10 h-10 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors active:scale-95 disabled:opacity-40"
            aria-label="Next year"
          >
            <ChevronRight className="h-5 w-5 text-on-surface-variant" />
          </button>
        </div>
      </div>

      {/* Filter chips */}
      <div className="flex gap-2 overflow-x-auto pb-2 -mx-1 px-1 no-scrollbar">
        {filterOptions.map((opt) => {
          const active = filter === opt.id;
          return (
            <button
              key={opt.id}
              onClick={() => setFilter(opt.id)}
              className={cn(
                'shrink-0 px-3 py-1.5 rounded-full font-label text-[10px] font-semibold uppercase tracking-wider transition-all',
                active
                  ? 'bg-primary text-on-primary'
                  : 'bg-surface-container text-on-surface-variant hover:bg-surface-container-high'
              )}
            >
              {opt.label}
            </button>
          );
        })}
      </div>

      {/* Grid */}
      <div className="flex gap-2 -mx-2 px-2">
        {/* Day labels — outside the scroll container so they never move */}
        <div className="shrink-0 flex flex-col">
          {/* Spacer matching the month row height */}
          <div className="h-[14px] mb-1" />
          <div className="grid grid-rows-7 gap-[3px]">
            {['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) => (
              <div
                key={day}
                className="font-label text-[8px] uppercase tracking-wider text-on-surface-variant w-3 h-3 flex items-center justify-center"
              >
                {day}
              </div>
            ))}
          </div>
        </div>

        {/* Scrollable heatmap */}
        <div className="overflow-x-auto pb-2">
          <div className="inline-block">
            {/* Month row */}
            <div className="flex gap-[3px] mb-1">
              {weeks.map((_, colIdx) => {
                const label = monthLabels.find((m) => m.col === colIdx);
                return (
                  <div
                    key={colIdx}
                    className="font-label text-[8px] uppercase tracking-wider text-on-surface-variant text-left whitespace-nowrap w-3 shrink-0"
                    style={gapCols.has(colIdx) ? { marginLeft: '4px' } : undefined}
                  >
                    {label?.text || ''}
                  </div>
                );
              })}
            </div>

            {/* Week columns */}
            <div className="flex gap-[3px]">
              {weeks.map((week, colIdx) => {
                return (
                <div
                  key={colIdx}
                  className="grid grid-rows-7 gap-[3px] shrink-0"
                  style={gapCols.has(colIdx) ? { marginLeft: '4px' } : undefined}
                >
                  {Array.from({ length: 7 }).map((_, rowIdx) => {
                    const cell = week[rowIdx];
                    if (!cell) {
                      return <div key={rowIdx} className="w-3 h-3" />;
                    }

                    let colorClass: string;
                    let title: string;

                    if (filter === 'mass') {
                      // Only show color if mass was completed that day
                      if (cell.count > 0) {
                        const litColor = getLiturgicalColorSync(cell.dateKey);
                        colorClass = liturgicalColorClass(litColor);
                        title = `${format(cell.date, 'MMM d, yyyy')} — ${litColor || 'unknown'}`;
                      } else {
                        colorClass = intensityClass(0);
                        title = `${format(cell.date, 'MMM d, yyyy')} — not completed`;
                      }
                    } else {
                      const level = intensityFor(cell.count);
                      colorClass = intensityClass(level);
                      title = `${format(cell.date, 'MMM d, yyyy')} — ${cell.count}`;
                    }

                    return (
                      <motion.div
                        key={rowIdx}
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 0.2, delay: colIdx * 0.005 }}
                        className={cn(
                          'w-3 h-3 rounded-[3px] transition-colors',
                          colorClass
                        )}
                        title={title}
                      />
                    );
                  })}
                </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* Legend */}
      <div className="flex items-center justify-end gap-2 pt-1">
        <span className="font-label text-[10px] uppercase tracking-wider text-on-surface-variant">
          Less
        </span>
        {[0, 1, 2, 3, 4].map((lvl) => (
          <div
            key={lvl}
            className={cn('w-3 h-3 rounded-[3px]', intensityClass(lvl))}
          />
        ))}
        <span className="font-label text-[10px] uppercase tracking-wider text-on-surface-variant">
          More
        </span>
      </div>
    </div>
  );
}
