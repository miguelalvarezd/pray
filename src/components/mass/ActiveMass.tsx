import React, { useState, useCallback, useEffect, useMemo, useRef } from 'react';
import { ChevronLeft, ChevronRight, Settings2 } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { cn } from '@/lib/utils';
import {
  generateMassSteps,
  groupMassSteps,
  SECTION_LABELS,
  OPTION_LABELS,
  VARIANT_LABELS,
  type Lang,
  type MassStep,
  type MassOptions,
  type OptionGroup,
  type StepGroup,
} from '@/lib/mass/index';
import { MassStepView } from './MassStepView';
import { MassCompletion } from './MassCompletion';
import { MassSettingsSheet, type ViewMode } from './MassSettingsSheet';

interface ActiveMassProps {
  initialSteps: MassStep[];
  initialIndex: number;
  primary: Lang;
  secondary: Lang | null;
  options: MassOptions;
  viewMode: ViewMode;
  onExit: () => void;
  onToggleDone: () => void;
  isDone: boolean;
  onIndexChange: (index: number, isComplete: boolean) => void;
  onLangChange: (primary: Lang, secondary: Lang | null) => void;
  onOptionChange: (newOptions: MassOptions, newIndex: number) => void;
  onViewModeChange: (mode: ViewMode) => void;
}

export function ActiveMass({
  initialSteps,
  initialIndex,
  primary: initialPrimary,
  secondary: initialSecondary,
  options: initialOptions,
  viewMode: initialViewMode,
  onExit,
  onToggleDone,
  isDone,
  onIndexChange,
  onLangChange,
  onOptionChange,
  onViewModeChange,
}: ActiveMassProps) {
  const [steps, setSteps] = useState(initialSteps);
  const [direction, setDirection] = useState<1 | -1>(1);
  const [primary, setPrimary] = useState(initialPrimary);
  const [secondary, setSecondary] = useState(initialSecondary);
  const [options, setOptions] = useState(initialOptions);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [viewMode, setViewMode] = useState<ViewMode>(initialViewMode);

  // Group steps for card navigation
  const grouped = useMemo(() => groupMassSteps(steps), [steps]);

  // Map flat step index → group index for initial position
  const flatToGroup = useMemo(() => {
    const map = new Map<number, number>();
    let flatIdx = 0;
    grouped.forEach((group, gi) => {
      group.forEach(() => {
        map.set(flatIdx, gi);
        flatIdx++;
      });
    });
    return map;
  }, [grouped]);

  const [groupIndex, setGroupIndex] = useState(() => flatToGroup.get(initialIndex) ?? 0);

  const currentGroup = grouped[groupIndex] ?? grouped[0];
  const firstStep = currentGroup[0];
  const isFirst = groupIndex === 0;
  const isLast = groupIndex === grouped.length - 1;
  const isComplete = firstStep?.kind === 'complete';

  // Compute flat index from group (for progress saving)
  const groupToFlat = useMemo(() => {
    const map: number[] = [];
    let flatIdx = 0;
    grouped.forEach((group) => {
      map.push(flatIdx);
      flatIdx += group.length;
    });
    return map;
  }, [grouped]);

  const go = useCallback((dir: 1 | -1) => {
    const next = groupIndex + dir;
    if (next < 0 || next >= grouped.length) return;
    setDirection(dir);
    setGroupIndex(next);
    const flatIdx = groupToFlat[next];
    const nextStep = grouped[next][0];
    onIndexChange(flatIdx, nextStep.kind === 'complete');
  }, [groupIndex, grouped, groupToFlat, onIndexChange]);

  useEffect(() => {
    if (settingsOpen) return;
    if (viewMode === 'scroll') return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight' || e.key === ' ') { e.preventDefault(); go(1); }
      if (e.key === 'ArrowLeft') { e.preventDefault(); go(-1); }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [go, settingsOpen, viewMode]);

  const handlePrimaryChange = (lang: Lang) => {
    const newSecondary = secondary === lang ? null : secondary;
    setPrimary(lang);
    setSecondary(newSecondary);
    onLangChange(lang, newSecondary);
  };

  const handleSecondaryChange = (lang: Lang | null) => {
    setSecondary(lang);
    onLangChange(primary, lang);
  };

  const handleOptionChange = (group: OptionGroup, value: string) => {
    const newOptions = { ...options, [group]: value } as MassOptions;
    setOptions(newOptions);
    const newSteps = generateMassSteps(newOptions);
    setSteps(newSteps);
    const newGrouped = groupMassSteps(newSteps);
    // Jump to first group containing the changed variant
    const firstVariantGroup = newGrouped.findIndex((g) => g.some((s) => s.group === group));
    const newGI = firstVariantGroup >= 0 ? firstVariantGroup : groupIndex;
    setGroupIndex(newGI);
    // Compute flat index for the parent
    let flat = 0;
    for (let i = 0; i < newGI; i++) flat += newGrouped[i].length;
    onOptionChange(newOptions, flat);
    setSettingsOpen(false);
  };

  const handleViewModeChange = (mode: ViewMode) => {
    setViewMode(mode);
    onViewModeChange(mode);
  };

  if (isComplete) {
    return (
      <MassCompletion
        onClose={onExit}
        onToggleDone={onToggleDone}
        isDone={isDone}
      />
    );
  }

  // Count groups excluding the complete step
  const contentGroups = grouped.length - 1;
  const progressPct = Math.round((groupIndex / contentGroups) * 100);
  const visibleSteps = steps.filter(s => s.kind !== 'complete');

  // Inline pill row — shown when any step in current group belongs to a variant
  const variantGroup = currentGroup.find(s => s.group)?.group;
  const variantOptions = variantGroup
    ? Object.keys(VARIANT_LABELS[variantGroup])
    : null;

  const groupKey = currentGroup.map(s => s.id).join('+');

  return (
    <div className="relative flex flex-col h-full overflow-hidden">
      {/* Progress bar */}
      <div className="h-0.5 w-full bg-surface-container-high shrink-0">
        <motion.div
          className="h-full bg-primary"
          animate={{ width: `${progressPct}%` }}
          transition={{ duration: 0.3 }}
        />
      </div>

      {/* Top bar */}
      <div className="flex items-center justify-between px-6 py-4 shrink-0">
        <button
          onClick={onExit}
          className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
          aria-label="Exit mass"
        >
          <ChevronLeft className="h-5 w-5 text-on-surface-variant" />
        </button>
        <div className="text-center">
          {viewMode === 'cards' ? (
            <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">
              {SECTION_LABELS[firstStep.section][primary]}
            </p>
          ) : (
            <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">
              Follow Mass
            </p>
          )}
        </div>
        <div className="flex items-center gap-2">
          {viewMode === 'cards' && (
            <span className="font-label text-[10px] text-on-surface-variant/60">
              {groupIndex + 1}/{contentGroups}
            </span>
          )}
          <button
            onClick={() => setSettingsOpen(true)}
            className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
            aria-label="Mass settings"
          >
            <Settings2 className="h-4 w-4 text-on-surface-variant" />
          </button>
        </div>
      </div>

      {/* Inline variant pill row — cards mode only */}
      {viewMode === 'cards' && variantGroup && variantOptions && (
        <div className="px-6 pb-2 shrink-0">
          <div className="flex gap-2 flex-wrap items-center">
            <p className="font-label text-[10px] uppercase tracking-wider text-on-surface-variant/60 mr-1">
              {OPTION_LABELS[variantGroup][primary]}:
            </p>
            {variantOptions.map((v) => (
              <button
                key={v}
                onClick={() => handleOptionChange(variantGroup, v)}
                className={cn(
                  'px-3 py-1 rounded-full font-label text-xs font-semibold transition-all border',
                  options[variantGroup] === v
                    ? 'bg-tertiary/20 border-tertiary text-on-surface'
                    : 'border-outline-variant text-on-surface-variant hover:border-tertiary',
                )}
              >
                {VARIANT_LABELS[variantGroup][v][primary].split('—')[0].trim()}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Content area */}
      {viewMode === 'cards' ? (
        /* Card mode — one group at a time */
        <div className="flex-1 overflow-y-auto min-h-0">
          <AnimatePresence mode="wait" initial={false}>
            <motion.div
              key={groupKey}
              initial={{ opacity: 0, x: direction * 24 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: direction * -24 }}
              transition={{ duration: 0.2, ease: 'easeOut' }}
              className="px-6 py-6"
            >
              {currentGroup.map((s, i) => (
                <div key={s.id} className={i > 0 ? 'mt-6' : ''}>
                  <MassStepView step={s} primary={primary} secondary={secondary} />
                </div>
              ))}
            </motion.div>
          </AnimatePresence>
        </div>
      ) : (
        /* Scroll mode — all groups in a scrollable list */
        <div className="flex-1 overflow-y-auto min-h-0">
          <div className="px-6 py-4 space-y-2">
            {grouped
              .filter((g) => g[0].kind !== 'complete')
              .map((group, gi, arr) => (
                <div key={group.map((s) => s.id).join('+')} className="py-2">
                  {group.map((s, i) => (
                    <div key={s.id} className={i > 0 ? 'mt-6' : ''}>
                      <MassStepView step={s} primary={primary} secondary={secondary} />
                    </div>
                  ))}
                  {gi < arr.length - 1 && group[0].section !== arr[gi + 1][0].section && (
                    <div className="flex justify-center mt-10 mb-8">
                      <div className="w-10 h-1 bg-outline-variant/20 rounded-full" />
                    </div>
                  )}
                </div>
              ))}
            <div className="h-20" />
          </div>
        </div>
      )}

      {/* Navigation — cards mode only */}
      {viewMode === 'cards' && (
        <div className="shrink-0 px-6 pb-[calc(2rem+env(safe-area-inset-bottom))] pt-4 border-t border-outline-variant/10 flex gap-3">
          <button
            onClick={() => go(-1)}
            disabled={isFirst}
            className="flex-1 py-4 rounded-full border-2 border-outline-variant text-on-surface-variant font-label text-sm font-semibold uppercase tracking-wider hover:border-primary hover:text-primary active:scale-[0.98] transition-all disabled:opacity-30 flex items-center justify-center gap-2"
          >
            <ChevronLeft className="h-4 w-4" />
            Prev
          </button>
          <button
            onClick={() => go(1)}
            disabled={isLast}
            className="flex-2 py-4 rounded-full bg-primary text-on-primary font-label text-sm font-semibold uppercase tracking-wider hover:opacity-90 active:scale-[0.98] transition-all disabled:opacity-30 flex items-center justify-center gap-2"
          >
            Next
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      )}

      {/* Settings sheet */}
      <AnimatePresence>
        {settingsOpen && (
          <motion.div
            key="settings"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            transition={{ duration: 0.2 }}
            className="absolute inset-0"
          >
            <MassSettingsSheet
              primary={primary}
              secondary={secondary}
              options={options}
              viewMode={viewMode}
              onPrimaryChange={handlePrimaryChange}
              onSecondaryChange={handleSecondaryChange}
              onOptionChange={handleOptionChange}
              onViewModeChange={handleViewModeChange}
              onClose={() => setSettingsOpen(false)}
            />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
