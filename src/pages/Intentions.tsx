import React, { useState } from 'react';
import { format, parseISO, differenceInDays } from 'date-fns';
import { Plus, Calendar, AlertCircle, Archive, ArchiveRestore, Trash2, BookHeart } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
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
  intentions, novenas, addIntention, updateIntention, deleteIntention, addNovena, deleteNovena, currentDate
}: IntentionsProps) {
  const [view, setView] = useState<'intentions' | 'novenas'>('intentions');
  const [isAdding, setIsAdding] = useState(false);
  const [showArchived, setShowArchived] = useState(false);

  const [newTitle, setNewTitle] = useState('');
  const [newDesc, setNewDesc] = useState('');
  const [newDate, setNewDate] = useState('');
  const [newPriority, setNewPriority] = useState<Priority>('medium');
  const [newNovenaSaint, setNewNovenaSaint] = useState('');
  const [newNovenaIntention, setNewNovenaIntention] = useState('');
  const [newNovenaStartDate, setNewNovenaStartDate] = useState(format(currentDate, 'yyyy-MM-dd'));

  const handleAddIntention = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;
    addIntention({ title: newTitle.trim(), description: newDesc.trim() || undefined, targetDate: newDate || undefined, priority: newPriority });
    setNewTitle(''); setNewDesc(''); setNewDate(''); setNewPriority('medium'); setIsAdding(false);
  };

  const handleAddNovena = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newNovenaSaint.trim() || !newNovenaIntention.trim()) return;
    addNovena({ title: newNovenaSaint.trim(), intention: newNovenaIntention.trim(), startDate: newNovenaStartDate || format(currentDate, 'yyyy-MM-dd') });
    setNewNovenaSaint(''); setNewNovenaIntention(''); setNewNovenaStartDate(format(currentDate, 'yyyy-MM-dd')); setIsAdding(false);
  };

  const activeIntentions = sortIntentions(intentions.filter(i => !i.isArchived), currentDate);
  const archivedIntentions = intentions.filter(i => i.isArchived);
  const displayedIntentions = showArchived ? archivedIntentions : activeIntentions;
  const activeNovenas = novenas.filter(n => differenceInDays(currentDate, parseISO(n.startDate)) <= 8);
  const historicalNovenas = novenas.filter(n => differenceInDays(currentDate, parseISO(n.startDate)) > 8);
  const displayedNovenas = showArchived ? historicalNovenas : activeNovenas;

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto">
      {/* Editorial Header */}
      <header className="flex items-start justify-between">
        <div className="space-y-2">
          <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">Ask and it will be given to you</p>
          <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">
            Your Heart's<br /><span className="italic">Quiet Echoes</span>
          </h1>
        </div>
        <button
          onClick={() => setIsAdding(!isAdding)}
          className="mt-4 w-12 h-12 rounded-full bg-primary text-on-primary flex items-center justify-center shadow-ambient-sm hover:opacity-90 transition-all active:scale-95"
        >
          <motion.div animate={{ rotate: isAdding ? 45 : 0 }} transition={{ duration: 0.2 }}>
            <Plus className="h-5 w-5" />
          </motion.div>
        </button>
      </header>

      {/* View Toggle */}
      <div className="flex gap-2">
        <button
          onClick={() => { setView('intentions'); setIsAdding(false); setShowArchived(false); }}
          className={cn(
            "px-5 py-2 rounded-full font-label text-sm font-medium tracking-wide transition-all",
            view === 'intentions' ? "bg-secondary-container text-on-secondary-container" : "text-on-surface-variant hover:bg-surface-container"
          )}
        >
          Intentions
        </button>
        <button
          onClick={() => { setView('novenas'); setIsAdding(false); setShowArchived(false); }}
          className={cn(
            "px-5 py-2 rounded-full font-label text-sm font-medium tracking-wide transition-all",
            view === 'novenas' ? "bg-tertiary-container text-on-tertiary-container" : "text-on-surface-variant hover:bg-surface-container"
          )}
        >
          Novenas
        </button>
      </div>

      {/* Add Forms */}
      <AnimatePresence>
        {isAdding && view === 'intentions' && (
          <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={{ duration: 0.25 }}>
            <Card className="bg-surface-container-low">
              <CardHeader><CardTitle>New Intention</CardTitle></CardHeader>
              <CardContent>
                <form onSubmit={handleAddIntention} className="space-y-4">
                  <Input placeholder="What are you praying for?" value={newTitle} onChange={(e) => setNewTitle(e.target.value)} autoFocus />
                  <Textarea placeholder="Additional details (optional)" value={newDesc} onChange={(e) => setNewDesc(e.target.value)} className="min-h-[60px]" />
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <label className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">Target Date</label>
                      <div className="relative">
                        <Calendar className="absolute left-3 top-3 h-4 w-4 text-outline-variant" />
                        <Input type="date" value={newDate} onChange={(e) => setNewDate(e.target.value)} className="pl-9" />
                      </div>
                    </div>
                    <div className="space-y-1.5">
                      <label className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">Priority</label>
                      <select value={newPriority} onChange={(e) => setNewPriority(e.target.value as Priority)} className="flex h-11 w-full rounded-xl bg-surface-container px-4 py-3 font-body text-sm text-on-surface border-b-2 border-transparent focus-visible:outline-none focus-visible:border-b-primary transition-colors">
                        <option value="low">Low</option>
                        <option value="medium">Medium</option>
                        <option value="high">High</option>
                      </select>
                    </div>
                  </div>
                  <div className="flex justify-end gap-3 pt-2">
                    <Button type="button" variant="ghost" onClick={() => setIsAdding(false)}>Cancel</Button>
                    <Button type="submit" disabled={!newTitle.trim()}>Add Intention</Button>
                  </div>
                </form>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {isAdding && view === 'novenas' && (
          <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={{ duration: 0.25 }}>
            <Card className="bg-surface-container-low">
              <CardHeader>
                <CardTitle>New Novena</CardTitle>
                <CardDescription>A 9-day prayer to a specific saint or for a specific intention.</CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleAddNovena} className="space-y-4">
                  <Input placeholder="Saint or Novena Name" value={newNovenaSaint} onChange={(e) => setNewNovenaSaint(e.target.value)} autoFocus />
                  <Textarea placeholder="Your intention for this novena" value={newNovenaIntention} onChange={(e) => setNewNovenaIntention(e.target.value)} className="min-h-[60px]" />
                  <div className="space-y-1.5">
                    <label className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">Start Date</label>
                    <div className="relative">
                      <Calendar className="absolute left-3 top-3 h-4 w-4 text-outline-variant" />
                      <Input type="date" value={newNovenaStartDate} onChange={(e) => setNewNovenaStartDate(e.target.value)} className="pl-9" />
                    </div>
                  </div>
                  <div className="flex justify-end gap-3 pt-2">
                    <Button type="button" variant="ghost" onClick={() => setIsAdding(false)}>Cancel</Button>
                    <Button type="submit" disabled={!newNovenaSaint.trim() || !newNovenaIntention.trim()} className="bg-tertiary hover:bg-tertiary-dim text-on-tertiary">Start Novena</Button>
                  </div>
                </form>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Intentions List */}
      {view === 'intentions' && (
        <>
          <div className="flex gap-2">
            <button onClick={() => setShowArchived(false)} className={cn("px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all", !showArchived ? "bg-primary-container text-on-primary-container" : "text-on-surface-variant hover:bg-surface-container")}>
              Active ({activeIntentions.length})
            </button>
            <button onClick={() => setShowArchived(true)} className={cn("px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all", showArchived ? "bg-primary-container text-on-primary-container" : "text-on-surface-variant hover:bg-surface-container")}>
              Archived ({archivedIntentions.length})
            </button>
          </div>

          <div className="space-y-4">
            <AnimatePresence mode="popLayout">
              {displayedIntentions.length === 0 ? (
                <motion.div key="empty" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="text-center py-16 text-on-surface-variant">
                  <p className="font-body italic">{showArchived ? 'No archived intentions.' : 'No active intentions.'}</p>
                  {!showArchived && !isAdding && <Button variant="link" onClick={() => setIsAdding(true)} className="mt-4">Add your first intention</Button>}
                </motion.div>
              ) : (
                displayedIntentions.map((intention) => {
                  const urgency = calculateUrgency(intention, currentDate);
                  const isUrgent = urgency > 40 && !intention.isArchived;
                  return (
                    <motion.div key={intention.id} layout initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }} transition={{ duration: 0.25 }}>
                      <Card className={cn(isUrgent && "bg-error-container/10")}>
                        <CardContent className="p-6">
                          <div className="flex justify-between items-start">
                            <div className="space-y-2 pr-4">
                              <div className="flex items-center gap-2">
                                <h3 className="font-headline text-xl text-on-surface">{intention.title}</h3>
                                {isUrgent && <AlertCircle className="h-3.5 w-3.5 text-error" />}
                              </div>
                              {intention.description && <p className="font-body text-sm text-on-surface-variant line-clamp-2">{intention.description}</p>}
                              <div className="flex flex-wrap gap-2 pt-1">
                                <span className={cn("inline-flex items-center rounded-full px-3 py-1 font-label text-[10px] font-bold uppercase tracking-widest",
                                  intention.priority === 'high' ? "bg-error-container/20 text-error" :
                                    intention.priority === 'medium' ? "bg-tertiary-container text-on-tertiary-container" :
                                      "bg-secondary-container text-on-secondary-container"
                                )}>{intention.priority}</span>
                                {intention.targetDate && <span className="inline-flex items-center rounded-full bg-surface-container px-3 py-1 font-label text-[10px] text-on-surface-variant uppercase tracking-widest">Target: {format(parseISO(intention.targetDate), 'MMM d, yyyy')}</span>}
                              </div>
                            </div>
                            <div className="flex flex-col gap-2 shrink-0">
                              <button className="w-8 h-8 rounded-full flex items-center justify-center text-outline hover:bg-surface-container hover:text-on-surface transition-colors" onClick={() => updateIntention(intention.id, { isArchived: !intention.isArchived })} title={intention.isArchived ? "Restore" : "Archive"}>
                                {intention.isArchived ? <ArchiveRestore className="h-4 w-4" /> : <Archive className="h-4 w-4" />}
                              </button>
                              <button className="w-8 h-8 rounded-full flex items-center justify-center text-outline hover:bg-error-container/20 hover:text-error transition-colors" onClick={() => deleteIntention(intention.id)} title="Delete">
                                <Trash2 className="h-4 w-4" />
                              </button>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    </motion.div>
                  );
                })
              )}
            </AnimatePresence>
          </div>
        </>
      )}

      {/* Novenas List */}
      {view === 'novenas' && (
        <>
          <div className="flex gap-2">
            <button onClick={() => setShowArchived(false)} className={cn("px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all", !showArchived ? "bg-tertiary-container text-on-tertiary-container" : "text-on-surface-variant hover:bg-surface-container")}>
              Active ({activeNovenas.length})
            </button>
            <button onClick={() => setShowArchived(true)} className={cn("px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all", showArchived ? "bg-tertiary-container text-on-tertiary-container" : "text-on-surface-variant hover:bg-surface-container")}>
              History ({historicalNovenas.length})
            </button>
          </div>

          <div className="space-y-4">
            <AnimatePresence mode="popLayout">
              {displayedNovenas.length === 0 ? (
                <motion.div key="empty-novena" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="text-center py-16 text-on-surface-variant">
                  <p className="font-body italic">{showArchived ? 'No past novenas.' : 'No active novenas.'}</p>
                  {!showArchived && !isAdding && <Button variant="link" onClick={() => setIsAdding(true)} className="mt-4 text-tertiary hover:text-tertiary-dim">Start a novena</Button>}
                </motion.div>
              ) : (
                displayedNovenas.map((novena) => {
                  const startDate = parseISO(novena.startDate);
                  const daysDiff = differenceInDays(currentDate, startDate);
                  const dayOfNovena = daysDiff + 1;
                  const isCompleted = dayOfNovena > 9;
                  const isFuture = dayOfNovena < 1;
                  return (
                    <motion.div key={novena.id} layout initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }} transition={{ duration: 0.25 }}>
                      <Card className={cn(isCompleted && "opacity-60")}>
                        <CardContent className="p-6">
                          <div className="flex justify-between items-start">
                            <div className="space-y-2 pr-4">
                              <div className="flex items-center gap-2">
                                <BookHeart className="h-4 w-4 text-tertiary" />
                                <h3 className="font-headline text-xl text-on-surface">{novena.title}</h3>
                              </div>
                              <p className="font-body text-sm text-on-surface-variant">{novena.intention}</p>
                              <span className={cn("inline-flex items-center rounded-full px-3 py-1 font-label text-[10px] font-bold uppercase tracking-widest",
                                isCompleted ? "bg-surface-container text-on-surface-variant" :
                                  isFuture ? "bg-surface-container text-on-surface-variant" :
                                    "bg-tertiary-container text-on-tertiary-container"
                              )}>
                                {isCompleted ? 'Completed' : isFuture ? `Starts ${format(startDate, 'MMM d')}` : `Day ${dayOfNovena} of 9`}
                              </span>
                            </div>
                            <button className="w-8 h-8 rounded-full flex items-center justify-center text-outline hover:bg-error-container/20 hover:text-error transition-colors" onClick={() => deleteNovena(novena.id)} title="Delete">
                              <Trash2 className="h-4 w-4" />
                            </button>
                          </div>
                        </CardContent>
                      </Card>
                    </motion.div>
                  );
                })
              )}
            </AnimatePresence>
          </div>
        </>
      )}
    </div>
  );
}
