import React from 'react';
import type { MassStep, Lang } from '@/lib/mass/index';

import { cn } from '@/lib/utils';

interface MassStepViewProps {
  step: MassStep;
  primary: Lang;
  secondary: Lang | null;
}

function DualText({
  primary,
  secondary,
  primaryLang,
  secondaryLang,
  className,
}: {
  primary: string;
  secondary: string | null;
  primaryLang?: string;
  secondaryLang?: string;
  className?: string;
}) {
  return (
    <div className={className}>
      <p className="font-headline text-xl text-on-surface leading-relaxed whitespace-pre-line">
        {primary}
      </p>
      {secondary && (
        <p className="font-body text-sm text-on-surface-variant mt-0.5 leading-snug whitespace-pre-line">
          {secondary}
        </p>
      )}
    </div>
  );
}

export function MassStepView({ step, primary, secondary }: MassStepViewProps) {
  const t = (field: Record<Lang, string> | undefined) => field?.[primary] ?? '';
  const t2 = (field: Record<Lang, string> | undefined) =>
    secondary ? (field?.[secondary] ?? null) : null;

  if (step.kind === 'section_header') {
    return (
      <div className="space-y-2 py-4">
        <h2 className="font-headline text-3xl font-medium text-on-surface leading-tight">
          {t(step.title)}
        </h2>
        {step.text && (
          <p className="font-body text-sm text-on-surface-variant leading-relaxed mt-2">
            {t(step.text)}
            {secondary && step.text[secondary] && (
              <span className="block mt-1 text-on-surface-variant/70 leading-snug">
                {step.text[secondary]}
              </span>
            )}
          </p>
        )}
      </div>
    );
  }

  if (step.kind === 'reading_placeholder') {
    return (
      <div className="space-y-5 py-4">
        {step.title && (
          <p className="font-headline text-xl text-on-surface-variant/40 text-right">{t(step.title)}</p>
        )}
        <div className="bg-surface-container rounded-3xl px-6 py-8">
          <p className="font-label text-xs uppercase tracking-widest text-on-surface-variant/60 italic">
            {t(step.text)}
          </p>
        </div>
      </div>
    );
  }

  if (step.kind === 'silence') {
    return (
      <div className="flex items-center justify-center py-10">
        <p className="font-headline italic text-on-surface-variant/60 text-lg text-center">
          {t(step.text) || 'Pause in silent prayer'}
          {secondary && step.text?.[secondary] && (
            <span className="block mt-1 text-sm leading-snug">{step.text[secondary]}</span>
          )}
        </p>
      </div>
    );
  }

  if (step.kind === 'response') {
    const callPrimary = t(step.call);
    const callSecondary = t2(step.call);
    const resPrimary = t(step.response);
    const resSecondary = t2(step.response);

    // Split on newline to detect multi-exchange pairs
    const callLines = callPrimary.split('\n').filter(l => l.trim());
    const resLines = resPrimary.split('\n').filter(l => l.trim());
    const callLines2 = callSecondary?.split('\n').filter(l => l.trim()) ?? [];
    const resLines2 = resSecondary?.split('\n').filter(l => l.trim()) ?? [];

    const isMultiExchange = callLines.length > 1 && callLines.length === resLines.length;

    return (
      <div className="space-y-5">
        {step.title && (
          <p className="font-headline text-xl text-on-surface-variant/40 text-right">{t(step.title)}</p>
        )}


        {isMultiExchange ? (
          /* Numbered exchange pairs */
          <div className="space-y-4">
            {callLines.map((line, i) => (
              <div key={i} className="space-y-2">
                {/* Number badge */}
                <div className="flex items-center gap-2">
                  <span className="w-5 h-5 rounded-full bg-outline-variant/20 text-on-surface-variant font-label text-[10px] font-bold flex items-center justify-center shrink-0">
                    {i + 1}
                  </span>
                  <span className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant/60">
                    Priest
                  </span>
                </div>
                <div className="pl-7">
                  <p className="font-headline text-lg text-on-surface leading-relaxed whitespace-pre-line">
                    {line}
                  </p>
                  {callLines2[i] && (
                    <p className="font-body text-sm text-on-surface-variant mt-0.5 leading-snug">
                      {callLines2[i]}
                    </p>
                  )}
                </div>
                {/* Response */}
                <div className="ml-7 bg-primary-container/30 rounded-3xl px-6 py-8 space-y-3">
                  <p className="font-label text-[10px] uppercase tracking-widest text-primary/70">
                    All
                  </p>
                  <div>
                    <p className="font-headline text-lg text-on-surface leading-relaxed whitespace-pre-line">
                      {resLines[i]}
                    </p>
                    {resLines2[i] && (
                      <p className="font-body text-sm text-on-surface-variant mt-0.5 leading-snug">
                        {resLines2[i]}
                      </p>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          /* Single exchange — original layout */
          <>
            <div className="space-y-1">
              <p className="font-label text-[10px] uppercase tracking-widest text-on-surface-variant/60">
                Priest
              </p>
              <DualText
                primary={callPrimary}
                secondary={callSecondary}
                primaryLang={primary}
                secondaryLang={secondary ?? undefined}
              />
            </div>
            <div className="space-y-3 bg-primary-container/30 rounded-3xl px-6 py-8">
              <p className="font-label text-[10px] uppercase tracking-widest text-primary/70">
                All
              </p>
              <DualText
                primary={resPrimary}
                secondary={resSecondary}
                primaryLang={primary}
                secondaryLang={secondary ?? undefined}
              />
            </div>
          </>
        )}
      </div>
    );
  }

  // celebrant | all
  const speakerLabel =
    step.speaker === 'priest' ? 'Priest'
    : step.speaker === 'reader' ? 'Reader'
    : 'All';

  const isAll = step.speaker === 'all' || step.kind === 'all';

  return (
    <div className="space-y-5">
      {step.title && (
        <p className="font-headline text-xl text-on-surface-variant/40 text-right">{t(step.title)}</p>
      )}

      <div className={cn('space-y-3', isAll && 'bg-primary-container/30 rounded-3xl px-6 py-8')}>
        <p className={cn(
          'font-label text-[10px] uppercase tracking-widest',
          isAll ? 'text-primary/70' : 'text-on-surface-variant/60',
        )}>
          {speakerLabel}
        </p>
        <DualText
          primary={t(step.text)}
          secondary={t2(step.text)}
          primaryLang={primary}
          secondaryLang={secondary ?? undefined}
        />
      </div>
    </div>
  );
}
