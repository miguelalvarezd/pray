import React, { useState } from 'react';
import { format } from 'date-fns';
import { AnimatePresence } from 'motion/react';
import { ThemeProvider } from '@/components/ThemeProvider';
import { BottomNav, Tab } from '@/components/BottomNav';
import { Today } from '@/pages/Today';
import { Intentions } from '@/pages/Intentions';
import { History } from '@/pages/History';
import { Stats } from '@/pages/Stats';
import { Settings } from '@/pages/Settings';
import { RosaryGuide } from '@/components/rosary/RosaryGuide';
import { MassGuide } from '@/components/mass/MassGuide';
import { FloatingActionMenu } from '@/components/FloatingActionMenu';
import { FloatingActionMenuIntentions } from '@/components/FloatingActionMenuIntentions';
import { useLocalStorage } from '@/hooks/useLocalStorage';
import { DailyLog, Intention, Novena, DEFAULT_PRAYERS } from '@/types';

export default function App() {
  const [currentTab, setCurrentTab] = useState<Tab>('today');
  const [rosaryOpen, setRosaryOpen] = useState(false);
  const [massOpen, setMassOpen] = useState(false);
  const [intentionsAdding, setIntentionsAdding] = useState(false);
  const [intentionsAddingType, setIntentionsAddingType] = useState<'intentions' | 'novenas'>('intentions');

  const handleTabChange = (tab: Tab) => {
    setCurrentTab(tab);
    window.scrollTo({ top: 0, behavior: 'instant' });
  };

  // State
  const [intentions, setIntentions] = useLocalStorage<Intention[]>('prayer-intentions', []);
  const [novenas, setNovenas] = useLocalStorage<Novena[]>('prayer-novenas', []);
  const [logs, setLogs] = useLocalStorage<Record<string, DailyLog>>('prayer-logs', {});
  const [dateOverride, setDateOverride] = useLocalStorage<string | null>('prayer-date-override', null);

  // Current day logic (starts at 4:00 AM)
  const getLogicalDate = () => {
    if (dateOverride) return new Date(`${dateOverride}T12:00:00`);
    const now = new Date();
    // Shift back 4 hours so 00:00-03:59 belongs to the previous logical day
    return new Date(now.getTime() - 4 * 60 * 60 * 1000);
  };

  const today = getLogicalDate();
  const todayStr = format(today, 'yyyy-MM-dd');
  const todayLog = logs[todayStr] || { date: todayStr, completedPrayers: [], completedIntentions: [], completedNovenas: [], completedActivities: [] };

  const updateTodayLog = (newLog: DailyLog) => {
    setLogs(prev => ({ ...prev, [todayStr]: newLog }));
  };

  const addIntention = (intention: Omit<Intention, 'id' | 'createdAt' | 'isArchived'>) => {
    const newIntention: Intention = {
      ...intention,
      id: crypto.randomUUID(),
      createdAt: today.toISOString(),
      isArchived: false,
    };
    setIntentions(prev => [...prev, newIntention]);
  };

  const updateIntention = (id: string, updates: Partial<Intention>) => {
    setIntentions(prev => prev.map(i => i.id === id ? { ...i, ...updates } : i));
  };

  const deleteIntention = (id: string) => {
    setIntentions(prev => prev.filter(i => i.id !== id));
  };

  const addNovena = (novena: Omit<Novena, 'id' | 'createdAt'>) => {
    const newNovena: Novena = {
      ...novena,
      id: crypto.randomUUID(),
      createdAt: today.toISOString(),
    };
    setNovenas(prev => [...prev, newNovena]);
  };

  const deleteNovena = (id: string) => {
    setNovenas(prev => prev.filter(n => n.id !== id));
  };

  const renderPage = () => {
    switch (currentTab) {
      case 'today':
        return (
          <Today
            log={todayLog}
            updateLog={updateTodayLog}
            intentions={intentions}
            novenas={novenas}
            prayers={DEFAULT_PRAYERS}
            currentDate={today}
          />
        );
      case 'intentions':
        return (
          <Intentions
            intentions={intentions}
            novenas={novenas}
            logs={logs}
            addIntention={addIntention}
            updateIntention={updateIntention}
            deleteIntention={deleteIntention}
            addNovena={addNovena}
            deleteNovena={deleteNovena}
            currentDate={today}
            isAdding={intentionsAdding}
            setIsAdding={setIntentionsAdding}
            addingType={intentionsAddingType}
          />
        );
      case 'history':
        return <History logs={logs} prayers={DEFAULT_PRAYERS} novenas={novenas} currentDate={today} />;
      case 'stats':
        return <Stats logs={logs} prayers={DEFAULT_PRAYERS} novenas={novenas} currentDate={today} />;
      case 'settings':
        return <Settings dateOverride={dateOverride} setDateOverride={setDateOverride} />;
    }
  };

  const isRosaryDone = todayLog.completedPrayers.includes('rosary');
  const isMassDone = todayLog.completedPrayers.includes('mass');

  const handleRosaryToggle = () => {
    const prayers = todayLog.completedPrayers;
    updateTodayLog({
      ...todayLog,
      completedPrayers: prayers.includes('rosary')
        ? prayers.filter((p) => p !== 'rosary')
        : [...prayers, 'rosary'],
    });
  };

  const handleMassToggle = () => {
    const prayers = todayLog.completedPrayers;
    updateTodayLog({
      ...todayLog,
      completedPrayers: prayers.includes('mass')
        ? prayers.filter((p) => p !== 'mass')
        : [...prayers, 'mass'],
    });
  };

  return (
    <ThemeProvider defaultTheme="light" storageKey="prayer-tracker-theme">
      <div className="min-h-screen bg-surface text-on-surface font-body selection:bg-primary-container selection:text-on-primary-container">
        {rosaryOpen ? (
          <RosaryGuide
            currentDate={today}
            onClose={() => setRosaryOpen(false)}
            onComplete={handleRosaryToggle}
            isDone={isRosaryDone}
          />
        ) : massOpen ? (
          <MassGuide
            currentDate={today}
            onClose={() => setMassOpen(false)}
            onComplete={handleMassToggle}
            isDone={isMassDone}
          />
        ) : (
          <>
            <main className="mx-auto w-full max-w-screen-sm">
              <AnimatePresence mode="wait">
                <div key={currentTab}>
                  {renderPage()}
                </div>
              </AnimatePresence>
            </main>

            {currentTab === 'today' && (
              <FloatingActionMenu
                onRosary={() => setRosaryOpen(true)}
                onMass={() => setMassOpen(true)}
              />
            )}

            {currentTab === 'intentions' && (
              <FloatingActionMenuIntentions
                onAddIntention={() => {
                  setIntentionsAddingType('intentions');
                  setIntentionsAdding(true);
                }}
                onAddNovena={() => {
                  setIntentionsAddingType('novenas');
                  setIntentionsAdding(true);
                }}
              />
            )}

            <BottomNav currentTab={currentTab} onChange={handleTabChange} />
          </>
        )}
      </div>
    </ThemeProvider>
  );
}
