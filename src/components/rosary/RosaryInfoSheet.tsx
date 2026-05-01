import React from 'react';
import { X } from 'lucide-react';

interface RosaryInfoSheetProps {
  onClose: () => void;
}

export function RosaryInfoSheet({ onClose }: RosaryInfoSheetProps) {
  return (
    <div className="absolute inset-0 bg-surface z-10 flex flex-col overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-6 py-4 shrink-0 border-b border-outline-variant/10">
        <h3 className="font-headline text-lg text-on-surface">How to Pray the Rosary</h3>
        <button
          onClick={onClose}
          className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center hover:bg-surface-container-high transition-colors"
          aria-label="Close info"
        >
          <X className="h-5 w-5 text-on-surface-variant" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto min-h-0 px-6 py-6 space-y-7">
        {/* Structure */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Structure of the Rosary
          </p>
          <div className="space-y-2">
            <InfoRow label="1" text="Sign of the Cross & Apostles' Creed" />
            <InfoRow label="2" text="Our Father" />
            <InfoRow label="3" text="3 Hail Marys (Faith, Hope, Charity)" />
            <InfoRow label="4" text="Glory Be" />
            <InfoRow label="5" text="Announce each Mystery, then pray the decade" />
          </div>
        </div>

        {/* Each decade */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Each Decade
          </p>
          <div className="bg-surface-container rounded-3xl px-5 py-4 space-y-2">
            <p className="font-body text-sm text-on-surface leading-relaxed">
              Our Father &rarr; 10 Hail Marys &rarr; Glory Be &rarr; Fatima Prayer
            </p>
            <p className="font-body text-xs text-on-surface-variant/60 leading-relaxed">
              Repeat for each of the 5 mysteries.
            </p>
          </div>
        </div>

        {/* Closing */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Closing Prayers
          </p>
          <div className="space-y-2">
            <InfoRow label="1" text="Hail Holy Queen" />
            <InfoRow label="2" text="Sign of the Cross" />
            <InfoRow label="3" text="Litany of Loreto (optional)" />
            <InfoRow label="4" text="Prayer for the Pope's Intentions (optional)" />
          </div>
        </div>

        {/* Mysteries by day */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Mysteries by Day
          </p>
          <div className="space-y-2">
            <DayRow days="Monday & Saturday" mysteries="Joyful" />
            <DayRow days="Tuesday & Friday" mysteries="Sorrowful" />
            <DayRow days="Wednesday & Sunday" mysteries="Glorious" />
            <DayRow days="Thursday" mysteries="Luminous" />
          </div>
        </div>

        {/* Bead guide */}
        <div className="space-y-3">
          <p className="font-label text-xs uppercase tracking-wider text-on-surface-variant">
            Bead Guide
          </p>
          <div className="space-y-2">
            <div className="flex items-center gap-3">
              <div className="w-5 h-5 rounded-sm bg-primary border-2 border-primary shrink-0" />
              <p className="font-body text-sm text-on-surface">Crucifix — Sign of the Cross & Creed</p>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-5 h-5 rounded-full bg-tertiary border-2 border-tertiary shrink-0" />
              <p className="font-body text-sm text-on-surface">Large bead — Our Father</p>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-3.5 h-3.5 rounded-full bg-primary border-2 border-primary shrink-0 ml-0.5" />
              <p className="font-body text-sm text-on-surface">Small bead — Hail Mary</p>
            </div>
          </div>
        </div>

        {/* Tip */}
        <div className="bg-primary-container/30 rounded-3xl px-5 py-4 space-y-2">
          <p className="font-label text-[10px] uppercase tracking-widest text-primary">
            Tip
          </p>
          <p className="font-body text-sm text-on-surface leading-relaxed">
            While praying each decade, meditate on the mystery announced at the beginning. Let the words of the prayers become a backdrop to contemplation of Christ&rsquo;s life.
          </p>
        </div>
      </div>
    </div>
  );
}

function InfoRow({ label, text }: { label: string; text: string }) {
  return (
    <div className="flex items-start gap-3">
      <span className="w-6 h-6 rounded-full bg-primary-container text-on-primary-container font-label text-xs font-bold flex items-center justify-center shrink-0 mt-0.5">
        {label}
      </span>
      <p className="font-body text-sm text-on-surface leading-relaxed">{text}</p>
    </div>
  );
}

function DayRow({ days, mysteries }: { days: string; mysteries: string }) {
  return (
    <div className="flex items-center justify-between bg-surface-container rounded-2xl px-4 py-3">
      <p className="font-body text-sm text-on-surface">{days}</p>
      <p className="font-label text-xs font-semibold text-primary uppercase tracking-wider">{mysteries}</p>
    </div>
  );
}
