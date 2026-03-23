import React from 'react';
import { Moon, Sun, Monitor, Calendar } from 'lucide-react';
import { useTheme } from '@/components/ThemeProvider';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';

interface SettingsProps {
  dateOverride: string | null;
  setDateOverride: (date: string | null) => void;
}

export function Settings({ dateOverride, setDateOverride }: SettingsProps) {
  const { theme, setTheme } = useTheme();

  return (
    <div className="space-y-6 pb-24 pt-6 px-4 max-w-md mx-auto">
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
