import React from 'react';
import { X, Layers, ScrollText } from 'lucide-react';
import { cn } from '@/lib/utils';
import {
  LANGUAGES,
  OPTION_LABELS,
  VARIANT_LABELS,
  type Lang,
  type MassOptions,
  type OptionGroup,
} from '@/lib/mass/index';

export type ViewMode = 'cards' | 'scroll';

interface MassSettingsSheetProps {
  primary: Lang;
  secondary: Lang | null;
  options: MassOptions;
  viewMode: ViewMode;
  onPrimaryChange: (lang: Lang) => void;
  onSecondaryChange: (lang: Lang | null) => void;
  onOptionChange: (group: OptionGroup, value: string) => void;
  onViewModeChange: (mode: ViewMode) => void;
  onClose: () => void;
}

const OPTION_GROUPS: { group: OptionGroup; variants: string[] }[] = [
  { group: 'penitential', variants: ['a', 'b', 'c'] },
  { group: 'creed', variants: ['nicene', 'apostles'] },
  { group: 'eucharistic', variants: ['i', 'ii', 'iii', 'iv'] },
  { group: 'mysteryOfFaith', variants: ['a', 'b', 'c'] },
];

export function MassSettingsSheet({
  primary,
  secondary,
  options,
  viewMode,
  onPrimaryChange,
  onSecondaryChange,
  onOptionChange,
  onViewModeChange,
  onClose,
}: MassSettingsSheetProps) {
  return (
    <div className="absolute inset-0 bg-surface z-10 flex flex-col overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-6 py-4 shrink-0 border-b border-outline-variant/10">
        <h3 className="font-headline text-lg text-on-surface">Mass Settings</h3>
        <button
          onClick={onClose}
          className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
          aria-label="Close settings"
        >
          <X className="h-5 w-5 text-on-surface-variant" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto min-h-0 px-6 py-6 space-y-7">
        {/* View mode */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Display mode
          </p>
          <div className="flex gap-2">
            <button
              onClick={() => onViewModeChange('cards')}
              className={cn(
                'flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-2xl font-label text-sm font-semibold transition-all border-2',
                viewMode === 'cards'
                  ? 'bg-primary border-primary text-on-primary'
                  : 'bg-surface-container border-transparent text-on-surface hover:border-outline-variant',
              )}
            >
              <Layers className="h-4 w-4" />
              Cards
            </button>
            <button
              onClick={() => onViewModeChange('scroll')}
              className={cn(
                'flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-2xl font-label text-sm font-semibold transition-all border-2',
                viewMode === 'scroll'
                  ? 'bg-primary border-primary text-on-primary'
                  : 'bg-surface-container border-transparent text-on-surface hover:border-outline-variant',
              )}
            >
              <ScrollText className="h-4 w-4" />
              Scroll
            </button>
          </div>
        </div>

        {/* Languages */}
        <div className="space-y-4">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Languages
          </p>

          <div className="space-y-2">
            <p className="font-body text-sm text-on-surface-variant">Primary</p>
            <div className="flex gap-2 flex-wrap">
              {LANGUAGES.map((lang) => (
                <button
                  key={lang.code}
                  onClick={() => {
                    onPrimaryChange(lang.code);
                    if (secondary === lang.code) onSecondaryChange(null);
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

          <div className="space-y-2">
            <p className="font-body text-sm text-on-surface-variant">Secondary</p>
            <div className="flex gap-2 flex-wrap">
              {LANGUAGES.map((lang) => (
                <button
                  key={lang.code}
                  disabled={lang.code === primary}
                  onClick={() => onSecondaryChange(secondary === lang.code ? null : lang.code)}
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
                onClick={() => onSecondaryChange(null)}
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
        </div>

        {/* Options — these reset stepIndex so warn the user */}
        <div className="space-y-5">
          <div className="space-y-1">
            <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
              Prayer forms
            </p>
            <p className="font-body text-xs text-on-surface-variant/60">
              Changing a form will jump to its first step.
            </p>
          </div>
          {OPTION_GROUPS.map(({ group, variants }) => (
            <div key={group} className="space-y-2">
              <p className="font-body text-sm text-on-surface">{OPTION_LABELS[group][primary]}</p>
              <div className="flex gap-2 flex-wrap">
                {variants.map((v) => (
                  <button
                    key={v}
                    onClick={() => onOptionChange(group, v)}
                    className={cn(
                      'px-4 py-2 rounded-full font-label text-sm font-semibold transition-all border-2',
                      options[group] === v
                        ? 'bg-tertiary border-tertiary text-on-tertiary'
                        : 'bg-surface-container border-transparent text-on-surface hover:border-outline-variant',
                    )}
                  >
                    {VARIANT_LABELS[group][v][primary]}
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
