import React from 'react';
import { CheckCircle } from 'lucide-react';
import { motion } from 'motion/react';
import { cn } from '@/lib/utils';

interface MassCompletionProps {
  onClose: () => void;
  onToggleDone: () => void;
  isDone: boolean;
}

export function MassCompletion({ onClose, onToggleDone, isDone }: MassCompletionProps) {
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
            Mass Complete
          </h2>
          <p className="font-body text-sm text-on-surface-variant leading-relaxed">
            You have followed the Holy Mass.
          </p>
          <p className="font-headline italic text-on-surface-variant/60 text-base">
            &ldquo;The Mass is the most perfect form of prayer.&rdquo;
          </p>
          <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant/40">
            &mdash; Pope Paul VI
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
              : 'bg-secondary text-on-secondary hover:opacity-90',
          )}
        >
          {isDone ? (
            <>
              <CheckCircle className="h-4 w-4" />
              Marked as Done &mdash; Tap to Undo
            </>
          ) : (
            'Mark Mass as Done Today'
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
