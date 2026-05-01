import React, { useState } from 'react';
import { format } from 'date-fns';
import { motion, AnimatePresence } from 'motion/react';
import { useLocalStorage } from '@/hooks/useLocalStorage';
import {
  generateMassSteps,
  DEFAULT_MASS_OPTIONS,
  type Lang,
  type MassOptions,
  type MassStep,
} from '@/lib/mass/index';
import { LanguageSelector } from './LanguageSelector';
import { ActiveMass } from './ActiveMass';
import type { ViewMode } from './MassSettingsSheet';

interface MassGuideProps {
  currentDate: Date;
  onClose: () => void;
  onComplete: () => void;
  isDone: boolean;
}

interface MassLanguages {
  primary: Lang;
  secondary: Lang | null;
}

interface MassProgress {
  date: string;
  stepIndex: number;
  options: MassOptions;
}

export function MassGuide({ currentDate, onClose, onComplete, isDone }: MassGuideProps) {
  const todayStr = format(currentDate, 'yyyy-MM-dd');

  const [languages, setLanguages] = useLocalStorage<MassLanguages | null>('mass-languages', null);
  const [progress, setProgress] = useLocalStorage<MassProgress | null>('mass-progress', null);
  const [viewMode, setViewMode] = useLocalStorage<ViewMode>('mass-view-mode', 'cards');

  const todayProgress = progress?.date === todayStr ? progress : null;

  // Derive initial phase: skip selector if languages already set
  const hasLanguages = languages !== null;
  const [phase, setPhase] = useState<'select' | 'active'>(hasLanguages ? 'active' : 'select');

  // Build initial steps + index from saved state or defaults
  const initOptions = todayProgress?.options ?? DEFAULT_MASS_OPTIONS;
  const initIndex = todayProgress?.stepIndex ?? 0;
  const initSteps = generateMassSteps(initOptions);

  const [steps] = useState<MassStep[]>(initSteps);

  const handleStart = (primary: Lang, secondary: Lang | null) => {
    setLanguages({ primary, secondary });
    setProgress({ date: todayStr, stepIndex: 0, options: DEFAULT_MASS_OPTIONS });
    setPhase('active');
  };

  const handleIndexChange = (index: number, isComplete: boolean) => {
    if (isComplete) {
      setProgress(null);
    } else {
      setProgress((prev) => ({
        date: todayStr,
        stepIndex: index,
        options: prev?.options ?? DEFAULT_MASS_OPTIONS,
      }));
    }
  };

  const handleLangChange = (primary: Lang, secondary: Lang | null) => {
    setLanguages({ primary, secondary });
  };

  const handleOptionChange = (newOptions: MassOptions, newIndex: number) => {
    setProgress({ date: todayStr, stepIndex: newIndex, options: newOptions });
  };

  const handleViewModeChange = (mode: ViewMode) => {
    setViewMode(mode);
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
              <LanguageSelector onStart={handleStart} onClose={onClose} />
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
              <ActiveMass
                initialSteps={steps}
                initialIndex={initIndex}
                primary={languages?.primary ?? 'en'}
                secondary={languages?.secondary ?? null}
                options={initOptions}
                viewMode={viewMode}
                onExit={onClose}
                onToggleDone={onComplete}
                isDone={isDone}
                onIndexChange={handleIndexChange}
                onLangChange={handleLangChange}
                onOptionChange={handleOptionChange}
                onViewModeChange={handleViewModeChange}
              />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
