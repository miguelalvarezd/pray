import React, { useState } from 'react';
import { format, parseISO, differenceInDays } from 'date-fns';
import { Plus, Calendar, AlertCircle, Archive, ArchiveRestore, Trash2, BookHeart } from 'lucide-react';
import { Intention, Novena, Priority } from '@/types';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Textarea } from '@/components/ui/Textarea';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/Card';
import { cn } from '@/lib/utils';
import { sortIntentions, calculateUrgency } from '@/lib/intentions';

interface IntentionsProps {
  intentions: Intention[];
  novenas: Novena[];
  addIntention: (intention: Omit<Intention, 'id' | 'createdAt' | 'isArchived'>) => void;
  updateIntention: (id: string, updates: Partial<Intention>) => void;
  deleteIntention: (id: string) => void;
  addNovena: (novena: Omit<Novena, 'id' | 'createdAt'>) => void;
  deleteNovena: (id: string) => void;
  currentDate: Date;
}

export function Intentions({ 
  intentions, 
  novenas, 
  addIntention, 
  updateIntention, 
  deleteIntention, 
  addNovena, 
  deleteNovena, 
  currentDate 
}: IntentionsProps) {
  const [view, setView] = useState<'intentions' | 'novenas'>('intentions');
  const [isAdding, setIsAdding] = useState(false);
  const [showArchived, setShowArchived] = useState(false);
  
  // Intention form state
  const [newTitle, setNewTitle] = useState('');
  const [newDesc, setNewDesc] = useState('');
  const [newDate, setNewDate] = useState('');
  const [newPriority, setNewPriority] = useState<Priority>('medium');

  // Novena form state
  const [newNovenaSaint, setNewNovenaSaint] = useState('');
  const [newNovenaIntention, setNewNovenaIntention] = useState('');
  const [newNovenaStartDate, setNewNovenaStartDate] = useState(format(currentDate, 'yyyy-MM-dd'));

  const handleAddIntention = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;

    addIntention({
      title: newTitle.trim(),
      description: newDesc.trim() || undefined,
      targetDate: newDate || undefined,
      priority: newPriority,
    });

    setNewTitle('');
    setNewDesc('');
    setNewDate('');
    setNewPriority('medium');
    setIsAdding(false);
  };

  const handleAddNovena = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newNovenaSaint.trim() || !newNovenaIntention.trim()) return;

    addNovena({
      title: newNovenaSaint.trim(),
      intention: newNovenaIntention.trim(),
      startDate: newNovenaStartDate || format(currentDate, 'yyyy-MM-dd'),
    });

    setNewNovenaSaint('');
    setNewNovenaIntention('');
    setNewNovenaStartDate(format(currentDate, 'yyyy-MM-dd'));
    setIsAdding(false);
  };

  const activeIntentions = sortIntentions(intentions.filter(i => !i.isArchived), currentDate);
  const archivedIntentions = intentions.filter(i => i.isArchived);
  const displayedIntentions = showArchived ? archivedIntentions : activeIntentions;

  return (
    <div className="space-y-6 pb-24 pt-6 px-4 max-w-md mx-auto">
      <header className="flex items-center justify-between">
        <h1 className="text-3xl font-semibold tracking-tight">Prayers</h1>
        <Button size="icon" variant="ghost" onClick={() => setIsAdding(!isAdding)}>
          <Plus className={cn("h-6 w-6 transition-transform", isAdding && "rotate-45")} />
        </Button>
      </header>

      <div className="flex p-1 bg-slate-200/50 dark:bg-slate-800/50 rounded-xl">
        <button
          onClick={() => { setView('intentions'); setIsAdding(false); }}
          className={cn(
            "flex-1 py-2 text-sm font-medium rounded-lg transition-all",
            view === 'intentions' ? "bg-white dark:bg-slate-950 shadow-sm text-slate-900 dark:text-slate-50" : "text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200"
          )}
        >
          Intentions
        </button>
        <button
          onClick={() => { setView('novenas'); setIsAdding(false); }}
          className={cn(
            "flex-1 py-2 text-sm font-medium rounded-lg transition-all",
            view === 'novenas' ? "bg-white dark:bg-slate-950 shadow-sm text-slate-900 dark:text-slate-50" : "text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200"
          )}
        >
          Novenas
        </button>
      </div>

      {isAdding && view === 'intentions' && (
        <Card className="border-indigo-100 bg-indigo-50/50 dark:border-indigo-900/50 dark:bg-indigo-950/20">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">New Intention</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleAddIntention} className="space-y-4">
              <div className="space-y-2">
                <Input
                  placeholder="What are you praying for?"
                  value={newTitle}
                  onChange={(e) => setNewTitle(e.target.value)}
                  autoFocus
                />
                <Textarea
                  placeholder="Additional details (optional)"
                  value={newDesc}
                  onChange={(e) => setNewDesc(e.target.value)}
                  className="min-h-[60px]"
                />
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-slate-500 dark:text-slate-400">Target Date</label>
                  <div className="relative">
                    <Calendar className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                    <Input
                      type="date"
                      value={newDate}
                      onChange={(e) => setNewDate(e.target.value)}
                      className="pl-9"
                    />
                  </div>
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-slate-500 dark:text-slate-400">Priority</label>
                  <select
                    value={newPriority}
                    onChange={(e) => setNewPriority(e.target.value as Priority)}
                    className="flex h-10 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm ring-offset-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 dark:border-slate-800 dark:bg-slate-950 dark:ring-offset-slate-950 dark:focus-visible:ring-indigo-400"
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                  </select>
                </div>
              </div>

              <div className="flex justify-end space-x-2 pt-2">
                <Button type="button" variant="ghost" onClick={() => setIsAdding(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={!newTitle.trim()}>
                  Add Intention
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {isAdding && view === 'novenas' && (
        <Card className="border-indigo-100 bg-indigo-50/50 dark:border-indigo-900/50 dark:bg-indigo-950/20">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">New Novena</CardTitle>
            <CardDescription>A 9-day prayer to a specific saint or for a specific intention.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleAddNovena} className="space-y-4">
              <div className="space-y-2">
                <Input
                  placeholder="Saint or Novena Name (e.g., St. Jude)"
                  value={newNovenaSaint}
                  onChange={(e) => setNewNovenaSaint(e.target.value)}
                  autoFocus
                />
                <Textarea
                  placeholder="Your intention for this novena"
                  value={newNovenaIntention}
                  onChange={(e) => setNewNovenaIntention(e.target.value)}
                  className="min-h-[60px]"
                />
              </div>
              
              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-500 dark:text-slate-400">Start Date</label>
                <div className="relative">
                  <Calendar className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                  <Input
                    type="date"
                    value={newNovenaStartDate}
                    onChange={(e) => setNewNovenaStartDate(e.target.value)}
                    className="pl-9"
                  />
                </div>
              </div>

              <div className="flex justify-end space-x-2 pt-2">
                <Button type="button" variant="ghost" onClick={() => setIsAdding(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={!newNovenaSaint.trim() || !newNovenaIntention.trim()}>
                  Start Novena
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {view === 'intentions' && (
        <>
          <div className="flex space-x-2 mb-4">
            <Button
              variant={!showArchived ? 'secondary' : 'ghost'}
              size="sm"
              onClick={() => setShowArchived(false)}
              className="rounded-full"
            >
              Active ({activeIntentions.length})
            </Button>
            <Button
              variant={showArchived ? 'secondary' : 'ghost'}
              size="sm"
              onClick={() => setShowArchived(true)}
              className="rounded-full"
            >
              Archived ({archivedIntentions.length})
            </Button>
          </div>

          <div className="space-y-3">
            {displayedIntentions.length === 0 ? (
              <div className="text-center py-12 text-slate-500 dark:text-slate-400">
                <p>{showArchived ? 'No archived intentions.' : 'No active intentions.'}</p>
                {!showArchived && !isAdding && (
                  <Button variant="link" onClick={() => setIsAdding(true)} className="mt-2">
                    Add your first intention
                  </Button>
                )}
              </div>
            ) : (
              displayedIntentions.map((intention) => {
                const urgency = calculateUrgency(intention, currentDate);
                const isUrgent = urgency > 40 && !intention.isArchived;

                return (
                  <Card key={intention.id} className={cn(
                    "transition-all",
                    isUrgent && "border-orange-200 bg-orange-50/30 dark:border-orange-900/30 dark:bg-orange-950/10"
                  )}>
                    <CardContent className="p-4">
                      <div className="flex justify-between items-start">
                        <div className="space-y-1 pr-4">
                          <div className="flex items-center space-x-2">
                            <h3 className="font-medium leading-none">{intention.title}</h3>
                            {isUrgent && <AlertCircle className="h-3.5 w-3.5 text-orange-500" />}
                          </div>
                          {intention.description && (
                            <p className="text-sm text-slate-500 dark:text-slate-400 line-clamp-2 mt-1">
                              {intention.description}
                            </p>
                          )}
                          
                          <div className="flex flex-wrap gap-2 mt-3">
                            <span className={cn(
                              "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset",
                              intention.priority === 'high' ? "bg-red-50 text-red-700 ring-red-600/10 dark:bg-red-900/20 dark:text-red-400 dark:ring-red-500/20" :
                              intention.priority === 'medium' ? "bg-yellow-50 text-yellow-800 ring-yellow-600/20 dark:bg-yellow-900/20 dark:text-yellow-400 dark:ring-yellow-500/20" :
                              "bg-green-50 text-green-700 ring-green-600/20 dark:bg-green-900/20 dark:text-green-400 dark:ring-green-500/20"
                            )}>
                              {intention.priority}
                            </span>
                            {intention.targetDate && (
                              <span className="inline-flex items-center rounded-md bg-slate-50 px-2 py-1 text-xs font-medium text-slate-600 ring-1 ring-inset ring-slate-500/10 dark:bg-slate-800/50 dark:text-slate-400 dark:ring-slate-700/50">
                                Target: {format(parseISO(intention.targetDate), 'MMM d, yyyy')}
                              </span>
                            )}
                          </div>
                        </div>
                        
                        <div className="flex flex-col space-y-2 shrink-0">
                          <Button
                            variant="ghost"
                            size="icon"
                            className="h-8 w-8 text-slate-400 hover:text-slate-900 dark:hover:text-slate-50"
                            onClick={() => updateIntention(intention.id, { isArchived: !intention.isArchived })}
                            title={intention.isArchived ? "Restore" : "Archive"}
                          >
                            {intention.isArchived ? <ArchiveRestore className="h-4 w-4" /> : <Archive className="h-4 w-4" />}
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="h-8 w-8 text-slate-400 hover:text-red-600 dark:hover:text-red-400"
                            onClick={() => deleteIntention(intention.id)}
                            title="Delete"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                );
              })
            )}
          </div>
        </>
      )}

      {view === 'novenas' && (
        <div className="space-y-3">
          {novenas.length === 0 ? (
            <div className="text-center py-12 text-slate-500 dark:text-slate-400">
              <p>No active novenas.</p>
              {!isAdding && (
                <Button variant="link" onClick={() => setIsAdding(true)} className="mt-2">
                  Start a novena
                </Button>
              )}
            </div>
          ) : (
            novenas.map((novena) => {
              const startDate = parseISO(novena.startDate);
              const daysDiff = differenceInDays(currentDate, startDate);
              const dayOfNovena = daysDiff + 1;
              const isCompleted = dayOfNovena > 9;
              const isFuture = dayOfNovena < 1;

              return (
                <Card key={novena.id} className={cn(
                  "transition-all",
                  isCompleted && "opacity-60"
                )}>
                  <CardContent className="p-4">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1 pr-4">
                        <div className="flex items-center space-x-2">
                          <BookHeart className="h-4 w-4 text-indigo-500" />
                          <h3 className="font-medium leading-none">{novena.title}</h3>
                        </div>
                        <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
                          {novena.intention}
                        </p>
                        
                        <div className="flex flex-wrap gap-2 mt-3">
                          <span className={cn(
                            "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset",
                            isCompleted ? "bg-slate-50 text-slate-600 ring-slate-500/10 dark:bg-slate-800/50 dark:text-slate-400 dark:ring-slate-700/50" :
                            isFuture ? "bg-slate-50 text-slate-600 ring-slate-500/10 dark:bg-slate-800/50 dark:text-slate-400 dark:ring-slate-700/50" :
                            "bg-indigo-50 text-indigo-700 ring-indigo-600/20 dark:bg-indigo-900/20 dark:text-indigo-400 dark:ring-indigo-500/20"
                          )}>
                            {isCompleted ? 'Completed' : isFuture ? `Starts ${format(startDate, 'MMM d')}` : `Day ${dayOfNovena} of 9`}
                          </span>
                        </div>
                      </div>
                      
                      <div className="flex flex-col space-y-2 shrink-0">
                        <Button
                          variant="ghost"
                          size="icon"
                          className="h-8 w-8 text-slate-400 hover:text-red-600 dark:hover:text-red-400"
                          onClick={() => deleteNovena(novena.id)}
                          title="Delete"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              );
            })
          )}
        </div>
      )}
    </div>
  );
}
