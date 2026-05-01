import React from 'react';
import { cn } from '@/lib/utils';

interface StreakBarProps {
  completedCount: number;
  totalCount: number;
}

/**
 * Horizontal dot-grid showing progress through today's expected prayers +
 * novenas. Renders nothing when there's no target (no prayers configured).
 */
export function StreakBar({ completedCount, totalCount }: StreakBarProps) {
  if (totalCount <= 0) return null;

  return (
    <div className="flex items-center gap-4">
      <div className="flex-1">
        <div className="grid grid-cols-7 gap-1.5">
          {Array.from({ length: totalCount }, (_, i) => (
            <div
              key={i}
              className={cn(
                'h-1 rounded-full transition-all duration-500',
                i < completedCount ? 'bg-primary' : 'bg-surface-container-high'
              )}
              style={{
                opacity:
                  i < completedCount
                    ? Math.min(0.4 + (i / totalCount) * 0.6, 1)
                    : 1,
              }}
            />
          ))}
        </div>
      </div>
      <span className="font-label text-xs text-on-surface-variant uppercase tracking-wider">
        {completedCount}/{totalCount}
      </span>
    </div>
  );
}
