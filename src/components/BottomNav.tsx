import React from 'react';
import { Home, ListTodo, CalendarDays, Settings as SettingsIcon, BarChart2 } from 'lucide-react';
import { motion } from 'motion/react';
import { cn } from '@/lib/utils';

export type Tab = 'today' | 'intentions' | 'history' | 'stats' | 'settings';

interface BottomNavProps {
  currentTab: Tab;
  onChange: (tab: Tab) => void;
}

export function BottomNav({ currentTab, onChange }: BottomNavProps) {
  const tabs = [
    { id: 'today' as Tab, label: 'Today', icon: Home },
    { id: 'intentions' as Tab, label: 'Intentions', icon: ListTodo },
    { id: 'history' as Tab, label: 'Agenda', icon: CalendarDays },
    { id: 'stats' as Tab, label: 'Stats', icon: BarChart2 },
    { id: 'settings' as Tab, label: 'Settings', icon: SettingsIcon },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 border-t border-slate-200 bg-white pb-safe dark:border-slate-800 dark:bg-slate-950">
      <div className="flex h-16 items-center justify-around px-4">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = currentTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => onChange(tab.id)}
              className={cn(
                'relative flex flex-col items-center justify-center space-y-1 w-16 h-full transition-colors',
                isActive
                  ? 'text-indigo-600 dark:text-indigo-400'
                  : 'text-slate-500 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-50'
              )}
            >
              {isActive && (
                <motion.div
                  layoutId="activeTab"
                  className="absolute -top-px left-2 right-2 h-0.5 bg-indigo-600 dark:bg-indigo-400 rounded-full"
                  transition={{ type: 'spring', stiffness: 500, damping: 35 }}
                />
              )}
              <Icon
                className={cn('h-6 w-6', isActive && 'fill-indigo-100 dark:fill-indigo-900/50')}
                strokeWidth={isActive ? 2.5 : 2}
              />
              <span className="text-[10px] font-medium">{tab.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
