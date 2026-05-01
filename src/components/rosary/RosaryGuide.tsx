import React, { useState, useCallback, useEffect } from 'react';
import { ChevronLeft, ChevronRight, Cross, CheckCircle, HelpCircle } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { useLocalStorage } from '@/hooks/useLocalStorage';
import {
  MysterySet,
  RosaryStep,
  StepType,
  generateRosarySteps,
  MYSTERY_SETS,
  getMysterySetForDate,
} from '@/lib/rosary';
import { RosaryInfoSheet } from './RosaryInfoSheet';

interface RosaryGuideProps {
  currentDate: Date;
  onClose: () => void;
  /** Toggles the rosary done state in the daily log. */
  onComplete: () => void;
  isDone: boolean;
}

interface RosaryProgress {
  date: string;
  mysteryType: MysterySet['type'];
  stepIndex: number;
}

// ---------------------------------------------------------------------------
// Bead track
// ---------------------------------------------------------------------------

function BeadTrack({ step }: { step: RosaryStep }) {
  const { track, bead } = step;
  if (!track) return null;

  if (track.phase === 'intro') {
    return (
      <div className="flex items-center gap-2 justify-center py-2">
        <div className={cn(
          'w-5 h-5 rounded-sm flex items-center justify-center transition-all border-2',
          bead === 'crucifix'
            ? 'bg-primary border-primary text-on-primary scale-125'
            : track.position > 0
              ? 'bg-primary/40 border-primary/40'
              : 'border-outline-variant'
        )}>
          <Cross className="h-2.5 w-2.5" />
        </div>
        <div className="w-px h-3 bg-outline-variant/40" />
        <div className={cn(
          'w-5 h-5 rounded-full transition-all border-2',
          bead === 'large' && track.position === 1
            ? 'bg-tertiary border-tertiary scale-125 shadow-sm'
            : track.position > 1
              ? 'bg-tertiary/50 border-tertiary/50'
              : 'border-outline-variant'
        )} />
        <div className="w-px h-3 bg-outline-variant/40" />
        {[2, 3, 4].map((pos) => (
          <div
            key={pos}
            className={cn(
              'w-3 h-3 rounded-full transition-all border-2',
              bead === 'small' && track.position === pos
                ? 'bg-primary border-primary scale-125 shadow-sm'
                : track.position > pos
                  ? 'bg-primary/50 border-primary/50'
                  : 'border-outline-variant'
            )}
          />
        ))}
      </div>
    );
  }

  // Decade track: 1 large (pos 0) + 10 small (pos 1–10)
  return (
    <div className="flex items-center gap-1.5 justify-center py-2 flex-wrap">
      {Array.from({ length: 11 }).map((_, pos) => {
        const isLarge = pos === 0;
        const isCurrent = track.position === pos;
        const isCompleted = track.position > pos;

        if (isLarge) {
          return (
            <React.Fragment key={pos}>
              <div className={cn(
                'w-5 h-5 rounded-full transition-all border-2',
                isCurrent
                  ? 'bg-tertiary border-tertiary scale-125 shadow-sm'
                  : isCompleted
                    ? 'bg-tertiary/50 border-tertiary/50'
                    : 'border-outline-variant'
              )} />
              <div className="w-px h-3 bg-outline-variant/40" />
            </React.Fragment>
          );
        }

        return (
          <div
            key={pos}
            className={cn(
              'w-3 h-3 rounded-full transition-all border-2',
              isCurrent
                ? 'bg-primary border-primary scale-125 shadow-sm'
                : isCompleted
                  ? 'bg-primary/50 border-primary/50'
                  : 'border-outline-variant'
            )}
          />
        );
      })}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Mystery selector
// ---------------------------------------------------------------------------

function MysterySelector({
  currentDate,
  todayProgress,
  onStart,
  onClose,
}: {
  currentDate: Date;
  todayProgress: RosaryProgress | null;
  onStart: (set: MysterySet, resumeIndex?: number) => void;
  onClose: () => void;
}) {
  const recommended = getMysterySetForDate(currentDate);
  const [selected, setSelected] = useState<MysterySet>(recommended);

  const resumeSet = todayProgress
    ? (MYSTERY_SETS.find((s) => s.type === todayProgress.mysteryType) ?? null)
    : null;

  return (
    <div className="flex flex-col h-full">
      {/* Top bar — mirrors ActiveRosary's header */}
      <div className="flex items-center px-6 py-4 shrink-0">
        <button
          onClick={onClose}
          className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
          aria-label="Back"
        >
          <ChevronLeft className="h-5 w-5 text-on-surface-variant" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto min-h-0 px-6 pb-6 space-y-6">
        <div className="space-y-1">
          <p className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">
            Today&rsquo;s recommended
          </p>
          <h2 className="font-headline text-3xl font-medium text-on-surface leading-tight">
            Choose Your<br /><span className="italic text-primary">Mysteries</span>
          </h2>
        </div>

        {/* Resume banner */}
        {resumeSet && todayProgress && (
          <button
            onClick={() => onStart(resumeSet, todayProgress.stepIndex)}
            className="w-full text-left p-5 rounded-4xl bg-secondary-container border-2 border-secondary flex items-center justify-between gap-4 active:scale-[0.98] transition-all"
          >
            <div>
              <p className="font-label text-[10px] uppercase tracking-widest text-on-secondary-container/70">
                Resume today
              </p>
              <p className="font-headline text-xl text-on-secondary-container">
                {resumeSet.name}
              </p>
              <p className="font-label text-xs text-on-secondary-container/60 mt-0.5">
                Step {todayProgress.stepIndex + 1} &middot; Tap to continue
              </p>
            </div>
            <ChevronRight className="h-5 w-5 text-on-secondary-container shrink-0" />
          </button>
        )}

        {/* Mystery picker */}
        <div className="space-y-3">
          {MYSTERY_SETS.map((set) => {
            const isSelected = selected.type === set.type;
            const isToday = recommended.type === set.type;
            return (
              <button
                key={set.type}
                onClick={() => setSelected(set)}
                className={cn(
                  'w-full text-left p-5 rounded-4xl transition-all border-2',
                  isSelected
                    ? 'bg-primary-container border-primary'
                    : 'bg-surface-container-lowest shadow-ambient-sm border-transparent hover:border-outline-variant'
                )}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className={cn(
                      'font-headline text-xl',
                      isSelected ? 'text-on-primary-container' : 'text-on-surface'
                    )}>
                      {set.name}
                    </p>
                    <p className="font-label text-[10px] uppercase tracking-wider text-on-surface-variant mt-0.5">
                      {set.days}
                      {isToday && (
                        <span className="ml-2 text-primary font-semibold">&middot; Today</span>
                      )}
                    </p>
                  </div>
                  <div className={cn(
                    'w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0 transition-all',
                    isSelected ? 'bg-primary border-primary' : 'border-outline-variant'
                  )}>
                    {isSelected && <div className="w-2 h-2 rounded-full bg-on-primary" />}
                  </div>
                </div>
                {isSelected && (
                  <div className="mt-4 space-y-1">
                    {set.mysteries.map((m) => (
                      <p key={m.number} className="font-body text-xs text-on-primary-container/70 leading-relaxed">
                        {m.number}. {m.name}
                      </p>
                    ))}
                  </div>
                )}
              </button>
            );
          })}
        </div>
      </div>

      <div className="shrink-0 px-6 pb-[calc(2rem+env(safe-area-inset-bottom))] pt-4 border-t border-outline-variant/10">
        <button
          onClick={() => onStart(selected)}
          className="w-full py-4 rounded-full bg-primary text-on-primary font-label text-sm font-semibold uppercase tracking-wider hover:opacity-90 active:scale-[0.98] transition-all"
        >
          Begin the {selected.shortName} Mysteries
        </button>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Completion screen
// ---------------------------------------------------------------------------

function CompletionScreen({
  mysteriesName,
  onClose,
  onToggleDone,
  isDone,
}: {
  mysteriesName: string;
  onClose: () => void;
  onToggleDone: () => void;
  isDone: boolean;
}) {
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <div className="flex-1 overflow-y-auto min-h-0 flex flex-col items-center justify-center px-8 text-center gap-8 py-12">
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ type: 'spring', stiffness: 300, damping: 20, delay: 0.1 }}
        >
          <CheckCircle className="h-20 w-20 text-secondary mx-auto" />
        </motion.div>
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25 }}
          className="space-y-3"
        >
          <h2 className="font-headline text-3xl font-medium text-on-surface">
            Rosary Complete
          </h2>
          <p className="font-body text-sm text-on-surface-variant leading-relaxed">
            You have prayed the {mysteriesName} of the Holy Rosary.
          </p>
          <p className="font-headline italic text-on-surface-variant/60 text-base">
            &ldquo;Pray the Rosary every day to obtain peace for the world.&rdquo;
          </p>
          <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant/40">
            &mdash; Our Lady of F&aacute;tima
          </p>
        </motion.div>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="shrink-0 px-8 pb-[calc(2rem+env(safe-area-inset-bottom))] pt-4 space-y-3 border-t border-outline-variant/10"
      >
        <button
          onClick={onToggleDone}
          className={cn(
            'w-full py-4 rounded-full font-label text-sm font-semibold uppercase tracking-wider active:scale-[0.98] transition-all flex items-center justify-center gap-2',
            isDone
              ? 'bg-surface-container text-on-surface-variant border-2 border-outline-variant hover:border-error hover:text-error'
              : 'bg-secondary text-on-secondary hover:opacity-90'
          )}
        >
          {isDone ? (
            <>
              <CheckCircle className="h-4 w-4" />
              Marked as Done &mdash; Tap to Undo
            </>
          ) : (
            'Mark Rosary as Done Today'
          )}
        </button>
        <button
          onClick={onClose}
          className="w-full py-3 rounded-full border-2 border-outline-variant text-on-surface-variant font-label text-sm font-semibold uppercase tracking-wider hover:border-primary hover:text-primary active:scale-[0.98] transition-all"
        >
          Back to Prayers
        </button>
      </motion.div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Active rosary
// ---------------------------------------------------------------------------

function ActiveRosary({
  steps,
  mysteriesName,
  initialIndex,
  onExit,
  onToggleDone,
  isDone,
  onIndexChange,
}: {
  steps: RosaryStep[];
  mysteriesName: string;
  initialIndex: number;
  onExit: () => void;
  onToggleDone: () => void;
  isDone: boolean;
  onIndexChange: (index: number, stepType: StepType) => void;
}) {
  const [index, setIndex] = useState(initialIndex);
  const [direction, setDirection] = useState<1 | -1>(1);
  const [infoOpen, setInfoOpen] = useState(false);
  const step = steps[index];
  const isFirst = index === 0;
  const isLast = index === steps.length - 1;
  const isComplete = step.type === 'complete';

  const go = useCallback((dir: 1 | -1) => {
    const next = index + dir;
    if (next < 0 || next >= steps.length) return;
    setDirection(dir);
    setIndex(next);
    onIndexChange(next, steps[next].type);
  }, [index, steps, onIndexChange]);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight' || e.key === ' ') { e.preventDefault(); go(1); }
      if (e.key === 'ArrowLeft') { e.preventDefault(); go(-1); }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [go]);

  if (isComplete) {
    return (
      <CompletionScreen
        mysteriesName={mysteriesName}
        onClose={onExit}
        onToggleDone={onToggleDone}
        isDone={isDone}
      />
    );
  }

  const contentSteps = steps.length - 1;
  const progressPct = Math.round((index / contentSteps) * 100);
  const isMysteryReveal = step.type === 'mystery_reveal';

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
          aria-label="Exit rosary"
        >
          <ChevronLeft className="h-5 w-5 text-on-surface-variant" />
        </button>
        <div className="text-center">
          {step.decadeNumber > 0 ? (
            <>
              <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">
                {step.mystery?.typeLabel}
              </p>
              <p className="font-headline text-sm text-on-surface">
                Decade {step.decadeNumber} of 5
              </p>
            </>
          ) : (
            <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">
              {index < 7 ? 'Introduction' : 'Closing'}
            </p>
          )}
        </div>
        <div className="flex items-center gap-2">
          <span className="font-label text-[10px] text-on-surface-variant/60">
            {index + 1}/{contentSteps}
          </span>
          <button
            onClick={() => setInfoOpen(true)}
            className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
            aria-label="Rosary info"
          >
            <HelpCircle className="h-4 w-4 text-on-surface-variant" />
          </button>
        </div>
      </div>

      {/* Bead track */}
      {step.track && (
        <div className="px-6 shrink-0">
          <BeadTrack step={step} />
        </div>
      )}

      {/* Scrollable content */}
      <div className="flex-1 overflow-y-auto min-h-0">
        <AnimatePresence mode="wait" initial={false}>
          <motion.div
            key={step.key}
            initial={{ opacity: 0, x: direction * 24 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: direction * -24 }}
            transition={{ duration: 0.2, ease: 'easeOut' }}
            className="px-6 py-6"
          >
            {isMysteryReveal ? (
              <div className="space-y-6">
                <div className="space-y-1">
                  <p className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">
                    {step.mystery?.typeLabel} &middot; Mystery {step.mystery?.number}
                  </p>
                  <h2 className="font-headline text-3xl font-medium text-on-surface leading-tight">
                    {step.mystery?.name}
                  </h2>
                </div>
                {/* Scripture reading */}
                <div className="bg-surface-container rounded-3xl px-5 py-4 space-y-2">
                  <p className="font-label text-[10px] uppercase tracking-widest text-primary">
                    {step.mystery?.scripture}
                  </p>
                  <p className="font-body text-sm text-on-surface leading-relaxed italic">
                    &ldquo;{step.mystery?.reading}&rdquo;
                  </p>
                </div>
                <div className="h-px bg-outline-variant/20" />
                {/* Meditation */}
                <div className="space-y-1.5">
                  <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant">
                    Meditation
                  </p>
                  <p className="font-body text-base text-on-surface-variant leading-relaxed">
                    {step.prayerText}
                  </p>
                </div>
              </div>
            ) : (
              <div className="space-y-5">
                <div className="space-y-1">
                  {step.mystery && !(step.prayerSubtitle?.includes(step.mystery.name)) && (
                    <p className="font-label text-[10px] uppercase tracking-[0.15em] text-primary">
                      {step.mystery.name}
                    </p>
                  )}
                  <h2 className="font-headline text-2xl font-medium text-on-surface">
                    {step.prayerTitle}
                  </h2>
                  {step.prayerSubtitle && (
                    <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
                      {step.prayerSubtitle}
                    </p>
                  )}
                </div>
                <div className="h-px bg-outline-variant/20" />
                <p className="font-headline text-xl text-on-surface leading-relaxed whitespace-pre-line">
                  {step.prayerText}
                </p>
              </div>
            )}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Navigation — always pinned */}
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

      {/* Info sheet */}
      <AnimatePresence>
        {infoOpen && (
          <motion.div
            key="info"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            transition={{ duration: 0.2 }}
            className="absolute inset-0"
          >
            <RosaryInfoSheet onClose={() => setInfoOpen(false)} />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main export
// ---------------------------------------------------------------------------

export function RosaryGuide({ currentDate, onClose, onComplete, isDone }: RosaryGuideProps) {
  const todayStr = format(currentDate, 'yyyy-MM-dd');
  const [progress, setProgress] = useLocalStorage<RosaryProgress | null>('rosary-progress', null);
  const todayProgress = progress?.date === todayStr ? progress : null;

  const [phase, setPhase] = useState<'select' | 'active'>('select');
  const [steps, setSteps] = useState<RosaryStep[]>([]);
  const [mysteriesName, setMysteriesName] = useState('');
  const [currentMysteryType, setCurrentMysteryType] = useState<MysterySet['type']>('joyful');
  const [initialIndex, setInitialIndex] = useState(0);

  const handleStart = (set: MysterySet, resumeIndex = 0) => {
    setSteps(generateRosarySteps(set));
    setMysteriesName(set.name);
    setCurrentMysteryType(set.type);
    setInitialIndex(resumeIndex);
    setPhase('active');
    if (resumeIndex === 0) {
      setProgress({ date: todayStr, mysteryType: set.type, stepIndex: 0 });
    }
  };

  const handleIndexChange = (index: number, stepType: StepType) => {
    if (stepType === 'complete') {
      // Rosary finished — clear saved progress
      setProgress(null);
    } else {
      setProgress({ date: todayStr, mysteryType: currentMysteryType, stepIndex: index });
    }
  };

  return (
    <div className="fixed inset-0 z-60 bg-surface overflow-hidden">
      <div className="relative h-full w-full max-w-screen-sm mx-auto overflow-hidden">
        <AnimatePresence mode="wait" initial={false}>
          {phase === 'select' ? (
            <motion.div
              key="select"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
              className="absolute inset-0 flex flex-col"
            >
              <MysterySelector
                currentDate={currentDate}
                todayProgress={todayProgress}
                onStart={handleStart}
                onClose={onClose}
              />
            </motion.div>
          ) : (
            <motion.div
              key="active"
              initial={{ opacity: 0, x: 32 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -32 }}
              transition={{ duration: 0.25 }}
              className="absolute inset-0 flex flex-col"
            >
              <ActiveRosary
                steps={steps}
                mysteriesName={mysteriesName}
                initialIndex={initialIndex}
                onExit={onClose}
                onToggleDone={onComplete}
                isDone={isDone}
                onIndexChange={handleIndexChange}
              />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
