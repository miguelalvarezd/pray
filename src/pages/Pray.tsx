import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Orbit } from 'lucide-react';
import { DailyLog } from '@/types';
import { RosaryGuide } from '@/components/rosary/RosaryGuide';

interface PrayProps {
  todayLog: DailyLog;
  updateTodayLog: (log: DailyLog) => void;
  currentDate: Date;
}

type ActiveGuide = 'rosary' | null;

export function Pray({ todayLog, updateTodayLog, currentDate }: PrayProps) {
  const [activeGuide, setActiveGuide] = useState<ActiveGuide>(null);

  const isRosaryDone = todayLog.completedPrayers.includes('rosary');

  const handleRosaryToggle = () => {
    const prayers = todayLog.completedPrayers;
    updateTodayLog({
      ...todayLog,
      completedPrayers: prayers.includes('rosary')
        ? prayers.filter((p) => p !== 'rosary')
        : [...prayers, 'rosary'],
    });
  };

  if (activeGuide === 'rosary') {
    return (
      <RosaryGuide
        currentDate={currentDate}
        onClose={() => setActiveGuide(null)}
        onComplete={handleRosaryToggle}
        isDone={isRosaryDone}
      />
    );
  }

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto">
      <header className="space-y-2 pl-1">
        <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">Guided prayer</p>
        <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">Pray</h1>
      </header>

      <section className="space-y-4">
        <h2 className="font-headline text-2xl text-on-surface">Prayer Guides</h2>

        <motion.button
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
            onClick={() => setActiveGuide('rosary')}
            className="w-full text-left bg-surface-container-lowest rounded-4xl p-7 shadow-ambient-sm hover:bg-surface-container-low transition-colors active:scale-[0.98]"
          >
            <div className="flex items-start gap-5">
              <div className="flex-shrink-0 w-12 h-12 rounded-2xl bg-secondary-container flex items-center justify-center">
                <Orbit className="h-6 w-6 text-on-secondary-container" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-headline text-xl text-on-surface">Holy Rosary</h3>
                <p className="font-body text-sm text-on-surface-variant mt-1 leading-relaxed">
                  Step-by-step bead-by-bead guide through the mysteries. Choose your set or follow today's recommendation.
                </p>
                <div className="flex gap-2 mt-3 flex-wrap">
                  {['Joyful', 'Sorrowful', 'Glorious', 'Luminous'].map((label) => (
                    <span
                      key={label}
                      className="font-label text-[10px] uppercase tracking-wider px-2.5 py-1 rounded-full bg-surface-container text-on-surface-variant"
                    >
                      {label}
                    </span>
                  ))}
                </div>
              </div>
            </div>
        </motion.button>
      </section>
    </div>
  );
}
