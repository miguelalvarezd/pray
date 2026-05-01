import React, { useState, useEffect } from 'react';
import { Plus, Heart, BookHeart } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { cn } from '@/lib/utils';

interface FloatingActionMenuIntentionsProps {
  onAddIntention: () => void;
  onAddNovena: () => void;
}

export function FloatingActionMenuIntentions({ onAddIntention, onAddNovena }: FloatingActionMenuIntentionsProps) {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setOpen(false);
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [open]);

  const handleAction = (cb: () => void) => {
    setOpen(false);
    cb();
  };

  return (
    <>
      {/* Backdrop */}
      <AnimatePresence>
        {open && (
          <motion.div
            key="backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.15 }}
            className="fixed inset-0 z-40 bg-black/20"
            onClick={() => setOpen(false)}
          />
        )}
      </AnimatePresence>

      {/* Action buttons + FAB */}
      <div className="fixed bottom-[calc(6rem+env(safe-area-inset-bottom))] right-6 z-50 flex flex-col items-end gap-3">
        <AnimatePresence>
          {open && (
            <>
              {/* Add Novena */}
              <motion.div
                key="novena"
                initial={{ opacity: 0, y: 12, scale: 0.85 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: 12, scale: 0.85 }}
                transition={{ duration: 0.18, delay: 0.05 }}
                className="flex items-center gap-3"
              >
                <span className="bg-surface text-on-surface font-label text-sm font-semibold px-3 py-1.5 rounded-full shadow-md whitespace-nowrap">
                  New Novena
                </span>
                <button
                  onClick={() => handleAction(onAddNovena)}
                  aria-label="Add Novena"
                  className="w-12 h-12 rounded-full bg-tertiary text-on-tertiary shadow-lg flex items-center justify-center hover:bg-tertiary/90 active:scale-95 transition-all"
                >
                  <BookHeart className="h-5 w-5" />
                </button>
              </motion.div>

              {/* Add Intention */}
              <motion.div
                key="intention"
                initial={{ opacity: 0, y: 12, scale: 0.85 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: 12, scale: 0.85 }}
                transition={{ duration: 0.18 }}
                className="flex items-center gap-3"
              >
                <span className="bg-surface text-on-surface font-label text-sm font-semibold px-3 py-1.5 rounded-full shadow-md whitespace-nowrap">
                  New Intention
                </span>
                <button
                  onClick={() => handleAction(onAddIntention)}
                  aria-label="Add Intention"
                  className="w-12 h-12 rounded-full bg-primary text-on-primary shadow-lg flex items-center justify-center hover:bg-primary/90 active:scale-95 transition-all"
                >
                  <Heart className="h-5 w-5" />
                </button>
              </motion.div>
            </>
          )}
        </AnimatePresence>

        {/* FAB */}
        <button
          onClick={() => setOpen((v) => !v)}
          aria-label={open ? 'Close menu' : 'Add prayer or novena'}
          className={cn(
            'w-14 h-14 rounded-full bg-primary text-on-primary shadow-lg flex items-center justify-center hover:bg-primary/90 active:scale-95 transition-all',
          )}
        >
          <motion.div
            animate={{ rotate: open ? 45 : 0 }}
            transition={{ duration: 0.2 }}
          >
            <Plus className="h-6 w-6" />
          </motion.div>
        </button>
      </div>
    </>
  );
}
