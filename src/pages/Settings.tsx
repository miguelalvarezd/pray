import React, { useState, useRef } from 'react';
import { Moon, Sun, Monitor, Calendar, Download, Upload, CheckCircle, AlertTriangle } from 'lucide-react';
import { useTheme } from '@/components/ThemeProvider';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { motion, AnimatePresence } from 'motion/react';
import { cn } from '@/lib/utils';

interface SettingsProps {
  dateOverride: string | null;
  setDateOverride: (date: string | null) => void;
}

const STORAGE_KEYS = ['prayer-intentions', 'prayer-novenas', 'prayer-logs', 'prayer-date-override'];

export function Settings({ dateOverride, setDateOverride }: SettingsProps) {
  const { theme, setTheme } = useTheme();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [exportStatus, setExportStatus] = useState<'idle' | 'success'>('idle');
  const [importStatus, setImportStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [importError, setImportError] = useState('');

  const handleExport = () => {
    const backup: Record<string, unknown> = {};
    STORAGE_KEYS.forEach(key => {
      const value = localStorage.getItem(key);
      if (value !== null) {
        try { backup[key] = JSON.parse(value); }
        catch { backup[key] = value; }
      }
    });
    const blob = new Blob([JSON.stringify(backup, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `prayer-backup-${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    setExportStatus('success');
    setTimeout(() => setExportStatus('idle'), 5000);
  };

  const handleImport = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const data = JSON.parse(event.target?.result as string);
        const validKeys = new Set(STORAGE_KEYS);
        const importedKeys = Object.keys(data);
        if (!importedKeys.some(k => validKeys.has(k))) {
          setImportError('Invalid backup file. No recognized data found.');
          setImportStatus('error');
          setTimeout(() => setImportStatus('idle'), 5000);
          return;
        }
        importedKeys.forEach(key => { if (validKeys.has(key)) localStorage.setItem(key, JSON.stringify(data[key])); });
        setImportStatus('success');
        setTimeout(() => window.location.reload(), 5000);
      } catch {
        setImportError('Could not parse backup file.');
        setImportStatus('error');
        setTimeout(() => setImportStatus('idle'), 5000);
      }
    };
    reader.readAsText(file);
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  const themeOptions = [
    { id: 'light' as const, label: 'Light', icon: Sun },
    { id: 'dark' as const, label: 'Dark', icon: Moon },
    { id: 'system' as const, label: 'System', icon: Monitor },
  ];

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto">
      {/* Editorial Header */}
      <header className="space-y-2 pl-1">
        <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">Preferences</p>
        <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">Settings</h1>
      </header>

      {/* Appearance */}
      <section className="space-y-4">
        <div className="pl-1">
          <h2 className="font-headline text-xl font-medium text-on-surface">Appearance</h2>
          <p className="font-body text-sm text-on-surface-variant mt-1">Customize how the app looks.</p>
        </div>
        <div className="grid grid-cols-3 gap-3">
          {themeOptions.map(opt => {
            const Icon = opt.icon;
            const isActive = theme === opt.id;
            return (
              <button
                key={opt.id}
                onClick={() => setTheme(opt.id)}
                className={cn(
                  "flex flex-col items-center justify-center gap-2 py-5 rounded-2xl transition-all active:scale-95",
                  isActive
                    ? "bg-secondary-container text-on-secondary-container"
                    : "bg-surface-container-low text-on-surface-variant hover:bg-surface-container"
                )}
              >
                <Icon className="h-5 w-5" />
                <span className="font-label text-xs font-semibold uppercase tracking-wider">{opt.label}</span>
              </button>
            );
          })}
        </div>
      </section>

      {/* Data & Backup */}
      <section className="space-y-4">
        <div className="pl-1">
          <h2 className="font-headline text-xl font-medium text-on-surface">Data & Backup</h2>
          <p className="font-body text-sm text-on-surface-variant mt-1">Export or import your prayer data.</p>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={handleExport}
            className="flex flex-col items-center justify-center gap-2 py-6 rounded-2xl bg-surface-container-lowest shadow-ambient-sm transition-all active:scale-95 hover:bg-surface-container-low"
          >
            <AnimatePresence mode="wait">
              {exportStatus === 'success' ? (
                <motion.div key="check" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                  <CheckCircle className="h-5 w-5 text-secondary" />
                </motion.div>
              ) : (
                <motion.div key="dl" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                  <Download className="h-5 w-5 text-on-surface-variant" />
                </motion.div>
              )}
            </AnimatePresence>
            <span className="font-label text-xs font-semibold uppercase tracking-wider text-on-surface">
              {exportStatus === 'success' ? 'Exported!' : 'Export'}
            </span>
          </button>

          <button
            onClick={() => fileInputRef.current?.click()}
            className="flex flex-col items-center justify-center gap-2 py-6 rounded-2xl bg-surface-container-lowest shadow-ambient-sm transition-all active:scale-95 hover:bg-surface-container-low"
          >
            <AnimatePresence mode="wait">
              {importStatus === 'success' ? (
                <motion.div key="check" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                  <CheckCircle className="h-5 w-5 text-secondary" />
                </motion.div>
              ) : importStatus === 'error' ? (
                <motion.div key="error" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                  <AlertTriangle className="h-5 w-5 text-error" />
                </motion.div>
              ) : (
                <motion.div key="up" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                  <Upload className="h-5 w-5 text-on-surface-variant" />
                </motion.div>
              )}
            </AnimatePresence>
            <span className="font-label text-xs font-semibold uppercase tracking-wider text-on-surface">
              {importStatus === 'success' ? 'Imported!' : importStatus === 'error' ? 'Error' : 'Import'}
            </span>
          </button>
        </div>

        <AnimatePresence>
          {importStatus === 'error' && (
            <motion.p initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}
              className="text-sm text-error">{importError}</motion.p>
          )}
        </AnimatePresence>

        <input ref={fileInputRef} type="file" accept=".json" className="hidden" onChange={handleImport} />
        <p className="font-body text-xs text-on-surface-variant pl-1">
          Your data stays on this device. Export regularly to avoid losing it.
        </p>
      </section>

      {/* Developer Mode */}
      <section className="space-y-4">
        <div className="pl-1">
          <h2 className="font-headline text-xl font-medium text-on-surface">Developer Mode</h2>
          <p className="font-body text-sm text-on-surface-variant mt-1">Override the current date for testing.</p>
        </div>
        <div className="bg-surface-container-lowest rounded-[2rem] p-6 shadow-ambient-sm">
          <label className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant block mb-3">Simulate Date</label>
          <div className="flex gap-3">
            <div className="relative flex-1">
              <Calendar className="absolute left-3 top-3 h-4 w-4 text-outline-variant" />
              <Input type="date" value={dateOverride || ''} onChange={(e) => setDateOverride(e.target.value || null)} className="pl-9" />
            </div>
            {dateOverride && (
              <Button variant="secondary" onClick={() => setDateOverride(null)}>Reset</Button>
            )}
          </div>
        </div>
      </section>

      {/* About */}
      <section className="space-y-4 pb-8">
        <div className="pl-1">
          <h2 className="font-headline text-xl font-medium text-on-surface">About</h2>
        </div>
        <div className="bg-surface-container-low rounded-[2rem] p-6 space-y-3">
          <p className="font-body text-sm text-on-surface-variant leading-relaxed">
            Prayer & Intention Tracker helps you maintain a consistent prayer life. Your data is stored locally on your device for privacy.
          </p>
          <p className="font-body text-sm text-on-surface-variant leading-relaxed">
            Intentions are automatically sorted by urgency. High priority items and those with approaching target dates appear at the top.
          </p>
        </div>
      </section>
    </div>
  );
}
