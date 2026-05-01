import React, { useState } from 'react';
import { ChevronLeft } from 'lucide-react';
import { cn } from '@/lib/utils';
import { LANGUAGES, SECTION_LABELS, type Lang } from '@/lib/mass/index';

interface LanguageSelectorProps {
  onStart: (primary: Lang, secondary: Lang | null) => void;
  onClose: () => void;
}

const SECTIONS = ['introductory', 'word', 'eucharist', 'concluding'] as const;

export function LanguageSelector({ onStart, onClose }: LanguageSelectorProps) {
  const [primary, setPrimary] = useState<Lang>('en');
  const [secondary, setSecondary] = useState<Lang | null>(null);

  return (
    <div className="flex flex-col h-full">
      {/* Top bar */}
      <div className="flex items-center px-6 py-4 shrink-0">
        <button
          onClick={onClose}
          className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
          aria-label="Back"
        >
          <ChevronLeft className="h-5 w-5 text-on-surface-variant" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto min-h-0 px-6 pb-6 space-y-7">
        <div className="space-y-1">
          <p className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">
            Follow Mass
          </p>
          <h2 className="font-headline text-3xl font-medium text-on-surface leading-tight">
            Choose Your<br /><span className="italic text-primary">Languages</span>
          </h2>
        </div>

        {/* Primary language */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Primary language
          </p>
          <div className="flex gap-2 flex-wrap">
            {LANGUAGES.map((lang) => (
              <button
                key={lang.code}
                onClick={() => {
                  setPrimary(lang.code);
                  if (secondary === lang.code) setSecondary(null);
                }}
                className={cn(
                  'px-4 py-2 rounded-full font-label text-sm font-semibold transition-all border-2',
                  primary === lang.code
                    ? 'bg-primary border-primary text-on-primary'
                    : 'bg-surface-container border-transparent text-on-surface hover:border-outline-variant',
                )}
              >
                {lang.native}
              </button>
            ))}
          </div>
        </div>

        {/* Secondary language */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Secondary language <span className="normal-case tracking-normal font-normal text-on-surface-variant/60">(optional — shown below each prayer)</span>
          </p>
          <div className="flex gap-2 flex-wrap">
            {LANGUAGES.map((lang) => (
              <button
                key={lang.code}
                disabled={lang.code === primary}
                onClick={() => setSecondary((prev) => (prev === lang.code ? null : lang.code))}
                className={cn(
                  'px-4 py-2 rounded-full font-label text-sm font-semibold transition-all border-2',
                  secondary === lang.code
                    ? 'bg-secondary border-secondary text-on-secondary'
                    : 'bg-surface-container border-transparent text-on-surface hover:border-outline-variant disabled:opacity-30 disabled:cursor-not-allowed',
                )}
              >
                {lang.native}
              </button>
            ))}
            <button
              onClick={() => setSecondary(null)}
              className={cn(
                'px-4 py-2 rounded-full font-label text-sm font-semibold transition-all border-2',
                secondary === null
                  ? 'bg-surface-container-high border-outline-variant text-on-surface'
                  : 'bg-surface-container border-transparent text-on-surface-variant hover:border-outline-variant',
              )}
            >
              None
            </button>
          </div>
        </div>

        {/* Mass outline preview */}
        <div className="space-y-2">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Today&rsquo;s Mass
          </p>
          <div className="bg-surface-container rounded-3xl px-5 py-4 space-y-2">
            {SECTIONS.map((section, i) => (
              <div key={section} className="flex items-center gap-3">
                <div className={cn(
                  'w-1.5 h-1.5 rounded-full shrink-0',
                  i === 0 ? 'bg-primary' : 'bg-outline-variant',
                )} />
                <p className="font-body text-sm text-on-surface-variant">
                  {SECTION_LABELS[section][primary]}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="shrink-0 px-6 pb-[calc(2rem+env(safe-area-inset-bottom))] pt-4 border-t border-outline-variant/10">
        <button
          onClick={() => onStart(primary, secondary)}
          className="w-full py-4 rounded-full bg-primary text-on-primary font-label text-sm font-semibold uppercase tracking-wider hover:opacity-90 active:scale-[0.98] transition-all"
        >
          Begin the Mass
        </button>
      </div>
    </div>
  );
}
