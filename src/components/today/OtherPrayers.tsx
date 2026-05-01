import React, { useState, useEffect, useRef } from 'react';
import { Plus, X, Check } from 'lucide-react';
import { motion, AnimatePresence, PanInfo, useDragControls } from 'motion/react';
import { DailyLog, DEFAULT_EXTRA_ACTIVITIES, ActivityCategory } from '@/types';
import { cn } from '@/lib/utils';
import { getIcon } from '@/lib/icons';

const CATEGORY_LABELS: Record<ActivityCategory, string> = {
  sacramental: 'Sacramental',
  devotional: 'Devotional',
  service: 'Service',
  spiritual: 'Spiritual',
};

const groupedActivities = DEFAULT_EXTRA_ACTIVITIES.reduce((acc, activity) => {
  if (!acc[activity.category]) acc[activity.category] = [];
  acc[activity.category].push(activity);
  return acc;
}, {} as Record<ActivityCategory, typeof DEFAULT_EXTRA_ACTIVITIES>);

interface OtherPrayersProps {
  log: DailyLog;
  onToggle: (id: string) => void;
}

/**
 * Chip list of extra activities (Confession, Rosary, etc.) plus a drag-to-
 * dismiss bottom sheet picker for adding more.
 */
export function OtherPrayers({ log, onToggle }: OtherPrayersProps) {
  const [showPicker, setShowPicker] = useState(false);
  const [sheetExpanded, setSheetExpanded] = useState(false);
  const sheetContentRef = useRef<HTMLDivElement>(null);
  const sheetDragControls = useDragControls();

  const completed = log.completedActivities || [];

  // Lock body scroll while the sheet is open.
  useEffect(() => {
    if (showPicker) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [showPicker]);

  const closeSheet = () => {
    setShowPicker(false);
    setSheetExpanded(false);
  };

  return (
    <>
      <section className="space-y-4">
        <h2 className="font-headline text-2xl font-medium">Other Prayers</h2>
        <div className="flex flex-wrap gap-2">
          <AnimatePresence mode="popLayout">
            {completed.map((actId) => {
              const activity = DEFAULT_EXTRA_ACTIVITIES.find((a) => a.id === actId);
              if (!activity) return null;
              return (
                <motion.button
                  key={activity.id}
                  layout
                  initial={{ opacity: 0, scale: 0.85 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.85, transition: { duration: 0.12 } }}
                  transition={{ duration: 0.2 }}
                  whileTap={{ scale: 0.92 }}
                  onClick={() => onToggle(activity.id)}
                  className="flex items-center gap-2 rounded-full bg-primary-container text-on-primary-container px-4 py-2 font-label text-xs tracking-wide transition-colors"
                >
                  <span className="shrink-0 [&>svg]:h-4 [&>svg]:w-4">
                    {getIcon(activity.icon)}
                  </span>
                  <span>{activity.name}</span>
                  <X className="h-3 w-3 opacity-50" />
                </motion.button>
              );
            })}
          </AnimatePresence>
          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={() => {
              setSheetExpanded(false);
              setShowPicker(true);
            }}
            className="flex items-center gap-1.5 rounded-full border-2 border-dashed border-outline-variant px-4 py-2 text-on-surface-variant font-label text-xs tracking-wide hover:border-primary hover:text-primary transition-colors"
          >
            <Plus className="h-3.5 w-3.5" />
            <span>Add</span>
          </motion.button>
        </div>
      </section>

      {showPicker && (
        <div
          className="fixed inset-0 z-50 overlay-backdrop"
          onClick={closeSheet}
        />
      )}

      <AnimatePresence>
        {showPicker && (
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', stiffness: 400, damping: 35 }}
            drag="y"
            dragControls={sheetDragControls}
            dragListener={false}
            dragConstraints={{ top: 0 }}
            dragElastic={{ top: 0.05, bottom: 0.9 }}
            dragMomentum={false}
            onDragEnd={(_event: PointerEvent, info: PanInfo) => {
              if (info.offset.y > 120 || info.velocity.y > 500) {
                closeSheet();
              } else if (info.offset.y < -40 || info.velocity.y < -500) {
                setSheetExpanded(true);
              }
            }}
            className={cn(
              'fixed bottom-0 left-0 right-0 z-50 mx-auto w-full max-w-screen-sm bg-surface-container-lowest rounded-t-4xl flex flex-col transition-[max-height] duration-300 ease-out',
              sheetExpanded ? 'max-h-[95vh]' : 'max-h-[70vh]'
            )}
          >
            <div
              onPointerDown={(e) => sheetDragControls.start(e)}
              className="flex justify-center pt-3 pb-2 cursor-grab active:cursor-grabbing shrink-0 touch-none"
            >
              <div className="w-10 h-1 rounded-full bg-outline-variant/50" />
            </div>

            <div className="flex items-center justify-between px-6 pb-4 pt-2 shrink-0">
              <h3 className="font-headline text-2xl text-on-surface">Other Activities</h3>
              <button
                className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
                onClick={closeSheet}
                aria-label="Close"
              >
                <X className="h-4 w-4 text-on-surface-variant" />
              </button>
            </div>

            <div
              ref={sheetContentRef}
              className="overflow-y-auto px-6 pb-15 flex-1 overscroll-contain"
            >
              <div className="space-y-6">
                {(Object.keys(groupedActivities) as ActivityCategory[]).map((category) => (
                  <div key={category}>
                    <p className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant mb-3">
                      {CATEGORY_LABELS[category]}
                    </p>
                    <div className="space-y-1">
                      {groupedActivities[category].map((activity) => {
                        const isAdded = completed.includes(activity.id);
                        return (
                          <motion.button
                            key={activity.id}
                            whileTap={{ scale: 0.97 }}
                            onClick={() => onToggle(activity.id)}
                            className={cn(
                              'flex w-full items-center gap-4 rounded-full p-2.5 text-left transition-colors',
                              isAdded
                                ? 'bg-primary-container'
                                : 'hover:bg-surface-container'
                            )}
                          >
                            <div
                              className={cn(
                                'w-9 h-9 rounded-full flex items-center justify-center shrink-0 transition-colors [&>svg]:h-4 [&>svg]:w-4',
                                isAdded
                                  ? 'bg-primary text-on-primary'
                                  : 'bg-surface-container-high text-on-surface-variant'
                              )}
                            >
                              {getIcon(activity.icon)}
                            </div>
                            <span
                              className={cn(
                                'font-headline text-base flex-1',
                                isAdded ? 'text-on-primary-container' : 'text-on-surface'
                              )}
                            >
                              {activity.name}
                            </span>
                            {isAdded && (
                              <div className="w-6 h-6 rounded-full bg-primary flex items-center justify-center">
                                <Check className="h-3.5 w-3.5 text-on-primary" strokeWidth={3} />
                              </div>
                            )}
                          </motion.button>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
