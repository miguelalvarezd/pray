import React from 'react';
import { Home, Heart, Church, Clock, Settings as SettingsIcon } from 'lucide-react';
import { motion } from 'motion/react';
import { cn } from '@/lib/utils';

export type Tab = 'today' | 'intentions' | 'history' | 'stats' | 'settings';

interface BottomNavProps {
  currentTab: Tab;
  onChange: (tab: Tab) => void;
}

export function BottomNav({ currentTab, onChange }: BottomNavProps) {
  const tabs = [
    { id: 'today' as Tab, label: 'Home', icon: Home },
    { id: 'intentions' as Tab, label: 'Intentions', icon: Heart },
    { id: 'history' as Tab, label: 'History', icon: Clock },
    { id: 'stats' as Tab, label: 'Stats', icon: Church },
    { id: 'settings' as Tab, label: 'Settings', icon: SettingsIcon },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 rounded-t-[2rem] bg-surface-container-lowest/95 backdrop-blur-[20px] shadow-[0_-8px_30px_rgba(0,0,0,0.05)]">
      <div className="flex items-center justify-around px-4 pt-4 pb-[calc(1rem+env(safe-area-inset-bottom))]">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = currentTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => onChange(tab.id)}
              className={cn(
                'relative flex flex-col items-center justify-center space-y-1 px-5 py-1.5 transition-all duration-300',
                isActive
                  ? 'bg-secondary-container text-secondary rounded-full scale-90'
                  : 'text-outline-variant hover:text-primary'
              )}
            >
              <Icon
                className="h-5 w-5"
                strokeWidth={isActive ? 2.5 : 1.5}
                fill={isActive ? 'currentColor' : 'none'}
              />
              <span className="font-label text-[10px] font-medium tracking-wide">{tab.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
