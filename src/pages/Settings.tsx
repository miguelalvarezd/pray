import React, { useState, useRef } from 'react';
import { Moon, Sun, Monitor, Calendar, Download, Upload, CheckCircle, AlertTriangle } from 'lucide-react';
import { useTheme } from '@/components/ThemeProvider';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { motion, AnimatePresence } from 'motion/react';

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
        try {
          backup[key] = JSON.parse(value);
        } catch {
          backup[key] = value;
        }
      }
    });

    const blob = new Blob([JSON.stringify(backup, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    const date = new Date().toISOString().split('T')[0];
    a.download = `prayer-backup-${date}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    setExportStatus('success');
    setTimeout(() => setExportStatus('idle'), 2500);
  };

  const handleImport = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const data = JSON.parse(event.target?.result as string);
        
        // Validate structure
        const validKeys = new Set(STORAGE_KEYS);
        const importedKeys = Object.keys(data);
        const hasValidKeys = importedKeys.some(k => validKeys.has(k));
        
        if (!hasValidKeys) {
          setImportError('Invalid backup file. No recognized data found.');
          setImportStatus('error');
          setTimeout(() => setImportStatus('idle'), 4000);
          return;
        }

        // Write to localStorage
        importedKeys.forEach(key => {
          if (validKeys.has(key)) {
            localStorage.setItem(key, JSON.stringify(data[key]));
          }
        });

        setImportStatus('success');
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      } catch {
        setImportError('Could not parse backup file. Make sure it is a valid JSON file.');
        setImportStatus('error');
        setTimeout(() => setImportStatus('idle'), 4000);
      }
    };
    reader.readAsText(file);

    // Reset file input so the same file can be re-imported
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  return (
    <div className="space-y-6 pb-24 pt-12 px-4 max-w-md mx-auto">
      <header className="space-y-1">
        <h1 className="text-3xl font-semibold tracking-tight">Settings</h1>
        <p className="text-slate-500 dark:text-slate-400">Manage your app preferences</p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Appearance</CardTitle>
          <CardDescription>Customize how the app looks on your device.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-3 gap-2">
            <Button
              variant={theme === 'light' ? 'default' : 'outline'}
              className="flex flex-col h-auto py-4 space-y-2"
              onClick={() => setTheme('light')}
            >
              <Sun className="h-5 w-5" />
              <span>Light</span>
            </Button>
            <Button
              variant={theme === 'dark' ? 'default' : 'outline'}
              className="flex flex-col h-auto py-4 space-y-2"
              onClick={() => setTheme('dark')}
            >
              <Moon className="h-5 w-5" />
              <span>Dark</span>
            </Button>
            <Button
              variant={theme === 'system' ? 'default' : 'outline'}
              className="flex flex-col h-auto py-4 space-y-2"
              onClick={() => setTheme('system')}
            >
              <Monitor className="h-5 w-5" />
              <span>System</span>
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Data & Backup</CardTitle>
          <CardDescription>Export your data as a JSON file for safekeeping, or import a previous backup.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <Button
              variant="outline"
              className="flex flex-col h-auto py-4 space-y-2"
              onClick={handleExport}
            >
              <AnimatePresence mode="wait">
                {exportStatus === 'success' ? (
                  <motion.div key="check" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                    <CheckCircle className="h-5 w-5 text-emerald-500" />
                  </motion.div>
                ) : (
                  <motion.div key="download" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                    <Download className="h-5 w-5" />
                  </motion.div>
                )}
              </AnimatePresence>
              <span>{exportStatus === 'success' ? 'Exported!' : 'Export'}</span>
            </Button>
            <Button
              variant="outline"
              className="flex flex-col h-auto py-4 space-y-2"
              onClick={() => fileInputRef.current?.click()}
            >
              <AnimatePresence mode="wait">
                {importStatus === 'success' ? (
                  <motion.div key="check" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                    <CheckCircle className="h-5 w-5 text-emerald-500" />
                  </motion.div>
                ) : importStatus === 'error' ? (
                  <motion.div key="error" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                    <AlertTriangle className="h-5 w-5 text-red-500" />
                  </motion.div>
                ) : (
                  <motion.div key="upload" initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}>
                    <Upload className="h-5 w-5" />
                  </motion.div>
                )}
              </AnimatePresence>
              <span>
                {importStatus === 'success' ? 'Imported!' : importStatus === 'error' ? 'Error' : 'Import'}
              </span>
            </Button>
          </div>
          
          <AnimatePresence>
            {importStatus === 'error' && (
              <motion.p
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="text-sm text-red-500 dark:text-red-400"
              >
                {importError}
              </motion.p>
            )}
          </AnimatePresence>
          
          <input
            ref={fileInputRef}
            type="file"
            accept=".json"
            className="hidden"
            onChange={handleImport}
          />
          
          <p className="text-xs text-slate-500 dark:text-slate-400">
            Your data stays on this device. Export regularly to avoid losing it.
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Developer Mode</CardTitle>
          <CardDescription>Override the current date for testing purposes.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-700 dark:text-slate-300">Simulate Date</label>
            <div className="flex space-x-2">
              <div className="relative flex-1">
                <Calendar className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                <Input
                  type="date"
                  value={dateOverride || ''}
                  onChange={(e) => setDateOverride(e.target.value || null)}
                  className="pl-9"
                />
              </div>
              {dateOverride && (
                <Button variant="outline" onClick={() => setDateOverride(null)}>
                  Reset
                </Button>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>About</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4 text-sm text-slate-600 dark:text-slate-400">
          <p>
            Prayer & Intention Tracker helps you maintain a consistent prayer life.
            Your data is stored locally on your device for privacy.
          </p>
          <p>
            Intentions are automatically sorted by urgency. High priority items and those with approaching target dates will appear at the top of your list.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
