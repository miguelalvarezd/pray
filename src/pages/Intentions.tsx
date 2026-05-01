import React, { useState, useMemo } from 'react';
import { format, parseISO, differenceInDays } from 'date-fns';
import { Calendar, AlertCircle, Archive, ArchiveRestore, Trash2, BookHeart, Sparkles, ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Intention, Novena, Priority, DailyLog } from '@/types';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Textarea } from '@/components/ui/Textarea';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/Card';
import { cn } from '@/lib/utils';
import { sortIntentions, calculateUrgency, buildIntentionCountMap } from '@/lib/intentions';
import { NOVENA_LIBRARY, NovenaTemplate } from '@/lib/novenaLibrary';

interface IntentionsProps {
  intentions: Intention[];
  novenas: Novena[];
  logs: Record<string, DailyLog>;
  addIntention: (intention: Omit<Intention, 'id' | 'createdAt' | 'isArchived'>) => void;
  updateIntention: (id: string, updates: Partial<Intention>) => void;
  deleteIntention: (id: string) => void;
  addNovena: (novena: Omit<Novena, 'id' | 'createdAt'>) => void;
  deleteNovena: (id: string) => void;
  currentDate: Date;
  isAdding: boolean;
  setIsAdding: (v: boolean) => void;
  addingType: 'intentions' | 'novenas';
}

export function Intentions({
  intentions,
  novenas,
  logs,
  addIntention,
  updateIntention,
  deleteIntention,
  addNovena,
  deleteNovena,
  currentDate,
  isAdding,
  setIsAdding,
  addingType,
}: IntentionsProps) {
  const [view, setView] = useState<'intentions' | 'novenas'>('intentions');
  const [showArchived, setShowArchived] = useState(false);

  // Novena add form: custom vs library template.
  const [novenaSource, setNovenaSource] = useState<'custom' | 'library'>('library');
  const [selectedTemplateId, setSelectedTemplateId] = useState<string | null>(null);

  const [newTitle, setNewTitle] = useState('');
  const [newDesc, setNewDesc] = useState('');
  const [newDate, setNewDate] = useState('');
  const [newPriority, setNewPriority] = useState<Priority>('medium');
  const [newNovenaSaint, setNewNovenaSaint] = useState('');
  const [newNovenaIntention, setNewNovenaIntention] = useState('');
  const [newNovenaStartDate, setNewNovenaStartDate] = useState(format(currentDate, 'yyyy-MM-dd'));

  const prayedCounts = useMemo(() => buildIntentionCountMap(logs), [logs]);

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
    const startDate = newNovenaStartDate || format(currentDate, 'yyyy-MM-dd');

    if (novenaSource === 'library') {
      const template = NOVENA_LIBRARY.find((t) => t.id === selectedTemplateId);
      if (!template) return;
      const intentionText = newNovenaIntention.trim() || template.suggestedIntention;
      addNovena({
        title: template.title,
        intention: intentionText,
        startDate,
        prayer: template.prayer,
        templateId: template.id,
      });
    } else {
      if (!newNovenaSaint.trim() || !newNovenaIntention.trim()) return;
      addNovena({
        title: newNovenaSaint.trim(),
        intention: newNovenaIntention.trim(),
        startDate,
      });
    }

    setNewNovenaSaint('');
    setNewNovenaIntention('');
    setNewNovenaStartDate(format(currentDate, 'yyyy-MM-dd'));
    setSelectedTemplateId(null);
    setNovenaSource('library');
    setIsAdding(false);
  };

  const canSubmitNovena =
    novenaSource === 'library'
      ? selectedTemplateId !== null
      : newNovenaSaint.trim().length > 0 && newNovenaIntention.trim().length > 0;

  const activeIntentions = sortIntentions(intentions.filter((i) => !i.isArchived), currentDate);
  const archivedIntentions = intentions.filter((i) => i.isArchived);
  const displayedIntentions = showArchived ? archivedIntentions : activeIntentions;
  const activeNovenas = novenas.filter((n) => differenceInDays(currentDate, parseISO(n.startDate)) <= 8);
  const historicalNovenas = novenas.filter((n) => differenceInDays(currentDate, parseISO(n.startDate)) > 8);
  const displayedNovenas = showArchived ? historicalNovenas : activeNovenas;

  // When addingType is triggered externally, auto-switch the view tab to match
  React.useEffect(() => {
    if (isAdding) {
      setView(addingType);
    }
  }, [isAdding, addingType]);

  return (
    <div className="space-y-10 pb-32 pt-12 px-6 max-w-screen-sm mx-auto">
      <header>
        <div className="space-y-2">
          <p className="font-label text-xs uppercase tracking-[0.15em] text-on-surface-variant">Ask and it will be given to you</p>
          <h1 className="font-headline text-4xl font-medium text-on-surface leading-tight">
            Your Heart's<br /><span className="italic">Quiet Echoes</span>
          </h1>
        </div>
      </header>

      <div className="flex gap-2">
        <button
          onClick={() => { setView('intentions'); setIsAdding(false); setShowArchived(false); }}
          className={cn(
            'px-5 py-2 rounded-full font-label text-sm font-medium tracking-wide transition-all',
            view === 'intentions'
              ? 'bg-secondary-container text-on-secondary-container'
              : 'text-on-surface-variant hover:bg-surface-container'
          )}
        >
          Intentions
        </button>
        <button
          onClick={() => { setView('novenas'); setIsAdding(false); setShowArchived(false); }}
          className={cn(
            'px-5 py-2 rounded-full font-label text-sm font-medium tracking-wide transition-all',
            view === 'novenas'
              ? 'bg-tertiary-container text-on-tertiary-container'
              : 'text-on-surface-variant hover:bg-surface-container'
          )}
        >
          Novenas
        </button>
      </div>

      {/* Add Intention Form */}
      <AnimatePresence initial={false}>
        {isAdding && addingType === 'intentions' && (
          <motion.div initial={{ height: 0, marginTop: 0 }} animate={{ height: 'auto', marginTop: '2.5rem' }} exit={{ height: 0, marginTop: 0 }} transition={{ duration: 0.25 }} className="overflow-hidden">
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

      {/* Add Novena Form */}
      <AnimatePresence initial={false}>
        {isAdding && addingType === 'novenas' && (
          <motion.div initial={{ height: 0, marginTop: 0 }} animate={{ height: 'auto', marginTop: '2.5rem' }} exit={{ height: 0, marginTop: 0 }} transition={{ duration: 0.25 }} className="overflow-hidden">
            <Card className="bg-surface-container-low">
              <CardHeader>
                <CardTitle>New Novena</CardTitle>
                <CardDescription>A 9-day prayer to a specific saint or for a specific intention.</CardDescription>
              </CardHeader>
              <CardContent>
                {/* Source toggle */}
                <div className="flex gap-2 mb-4">
                  <button
                    type="button"
                    onClick={() => setNovenaSource('library')}
                    className={cn(
                      'flex items-center gap-1.5 px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all',
                      novenaSource === 'library'
                        ? 'bg-tertiary-container text-on-tertiary-container'
                        : 'text-on-surface-variant hover:bg-surface-container'
                    )}
                  >
                    <Sparkles className="h-3 w-3" />
                    From Library
                  </button>
                  <button
                    type="button"
                    onClick={() => setNovenaSource('custom')}
                    className={cn(
                      'px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all',
                      novenaSource === 'custom'
                        ? 'bg-tertiary-container text-on-tertiary-container'
                        : 'text-on-surface-variant hover:bg-surface-container'
                    )}
                  >
                    Custom
                  </button>
                </div>

                <form onSubmit={handleAddNovena} className="space-y-4">
                  {novenaSource === 'library' ? (
                    <NovenaLibraryPicker
                      selectedId={selectedTemplateId}
                      onSelect={(id) => setSelectedTemplateId(id)}
                    />
                  ) : (
                    <Input
                      placeholder="Saint or Novena Name"
                      value={newNovenaSaint}
                      onChange={(e) => setNewNovenaSaint(e.target.value)}
                      autoFocus
                    />
                  )}
                  <Textarea
                    placeholder={
                      novenaSource === 'library' && selectedTemplateId
                        ? `Your intention (default: ${NOVENA_LIBRARY.find((t) => t.id === selectedTemplateId)?.suggestedIntention})`
                        : 'Your intention for this novena'
                    }
                    value={newNovenaIntention}
                    onChange={(e) => setNewNovenaIntention(e.target.value)}
                    className="min-h-[60px]"
                  />
                  <div className="space-y-1.5">
                    <label className="font-label text-[10px] uppercase tracking-[0.15em] text-on-surface-variant">Start Date</label>
                    <div className="relative">
                      <Calendar className="absolute left-3 top-3 h-4 w-4 text-outline-variant" />
                      <Input type="date" value={newNovenaStartDate} onChange={(e) => setNewNovenaStartDate(e.target.value)} className="pl-9" />
                    </div>
                  </div>
                  <div className="flex justify-end gap-3 pt-2">
                    <Button type="button" variant="ghost" onClick={() => setIsAdding(false)}>Cancel</Button>
                    <Button
                      type="submit"
                      disabled={!canSubmitNovena}
                      className="bg-tertiary hover:bg-tertiary-dim text-on-tertiary"
                    >
                      Start Novena
                    </Button>
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
            <button onClick={() => setShowArchived(false)} className={cn('px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all', !showArchived ? 'bg-primary-container text-on-primary-container' : 'text-on-surface-variant hover:bg-surface-container')}>
              Active ({activeIntentions.length})
            </button>
            <button onClick={() => setShowArchived(true)} className={cn('px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all', showArchived ? 'bg-primary-container text-on-primary-container' : 'text-on-surface-variant hover:bg-surface-container')}>
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
                  const prayedCount = prayedCounts[intention.id] || 0;
                  return (
                    <motion.div key={intention.id} layout initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }} transition={{ duration: 0.25 }}>
                      <Card className={cn(isUrgent && 'bg-error-container/10')}>
                        <CardContent className="p-6">
                          <div className="flex justify-between items-start">
                            <div className="space-y-2 pr-4">
                              <div className="flex items-center gap-2">
                                <h3 className="font-headline text-xl text-on-surface">{intention.title}</h3>
                                {isUrgent && <AlertCircle className="h-3.5 w-3.5 text-error" />}
                              </div>
                              {intention.description && <p className="font-body text-sm text-on-surface-variant line-clamp-2">{intention.description}</p>}
                              <div className="flex flex-wrap gap-2 pt-1">
                                <span className={cn('inline-flex items-center rounded-full px-3 py-1 font-label text-[10px] font-bold uppercase tracking-widest',
                                  intention.priority === 'high' ? 'bg-error-container/20 text-error' :
                                    intention.priority === 'medium' ? 'bg-tertiary-container text-on-tertiary-container' :
                                      'bg-secondary-container text-on-secondary-container'
                                )}>{intention.priority}</span>
                                {intention.targetDate && <span className="inline-flex items-center rounded-full bg-surface-container px-3 py-1 font-label text-[10px] text-on-surface-variant uppercase tracking-widest">Target: {format(parseISO(intention.targetDate), 'MMM d, yyyy')}</span>}
                                {prayedCount > 0 && (
                                  <span className="inline-flex items-center gap-1 rounded-full bg-primary-container/60 text-on-primary-container px-3 py-1 font-label text-[10px] font-semibold uppercase tracking-widest">
                                    <Sparkles className="h-2.5 w-2.5" />
                                    Prayed {prayedCount} {prayedCount === 1 ? 'day' : 'days'}
                                  </span>
                                )}
                              </div>
                            </div>
                            <div className="flex flex-col gap-2 shrink-0">
                              <button className="w-8 h-8 rounded-full flex items-center justify-center text-outline hover:bg-surface-container hover:text-on-surface transition-colors" onClick={() => updateIntention(intention.id, { isArchived: !intention.isArchived })} title={intention.isArchived ? 'Restore' : 'Archive'}>
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
            <button onClick={() => setShowArchived(false)} className={cn('px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all', !showArchived ? 'bg-tertiary-container text-on-tertiary-container' : 'text-on-surface-variant hover:bg-surface-container')}>
              Active ({activeNovenas.length})
            </button>
            <button onClick={() => setShowArchived(true)} className={cn('px-4 py-1.5 rounded-full font-label text-xs font-semibold uppercase tracking-wider transition-all', showArchived ? 'bg-tertiary-container text-on-tertiary-container' : 'text-on-surface-variant hover:bg-surface-container')}>
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
                      <Card className={cn(isCompleted && 'opacity-60')}>
                        <CardContent className="p-6">
                          <div className="flex justify-between items-start">
                            <div className="space-y-2 pr-4">
                              <div className="flex items-center gap-2">
                                <BookHeart className="h-4 w-4 text-tertiary" />
                                <h3 className="font-headline text-xl text-on-surface">{novena.title}</h3>
                              </div>
                              <p className="font-body text-sm text-on-surface-variant">{novena.intention}</p>
                              <span className={cn('inline-flex items-center rounded-full px-3 py-1 font-label text-[10px] font-bold uppercase tracking-widest',
                                isCompleted ? 'bg-surface-container text-on-surface-variant' :
                                  isFuture ? 'bg-surface-container text-on-surface-variant' :
                                    'bg-tertiary-container text-on-tertiary-container'
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

/**
 * Picker for preloaded novena templates. Each row expands to preview the
 * full prayer before starting.
 */
function NovenaLibraryPicker({
  selectedId,
  onSelect,
}: {
  selectedId: string | null;
  onSelect: (id: string) => void;
}) {
  const [expanded, setExpanded] = useState<string | null>(null);
  return (
    <div className="space-y-2 max-h-[360px] overflow-y-auto">
      {NOVENA_LIBRARY.map((t: NovenaTemplate) => {
        const isSelected = selectedId === t.id;
        const isExpanded = expanded === t.id;
        return (
          <div
            key={t.id}
            className={cn(
              'rounded-2xl border-2 transition-colors',
              isSelected
                ? 'border-tertiary bg-tertiary-container/30'
                : 'border-transparent bg-surface-container'
            )}
          >
            <button
              type="button"
              onClick={() => onSelect(t.id)}
              className="w-full text-left p-4 flex items-start gap-3"
            >
              <div className="w-9 h-9 rounded-full bg-tertiary-container flex items-center justify-center shrink-0">
                <BookHeart className="h-4 w-4 text-tertiary" />
              </div>
              <div className="flex-1">
                <p className="font-headline text-base text-on-surface">{t.title}</p>
                <p className="font-label text-[10px] uppercase tracking-wider text-on-surface-variant mt-0.5">
                  {t.patron}
                </p>
                <p className="font-body text-xs text-on-surface-variant mt-1.5 leading-relaxed">
                  {t.description}
                </p>
              </div>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  setExpanded(isExpanded ? null : t.id);
                }}
                className="shrink-0 w-7 h-7 rounded-full flex items-center justify-center hover:bg-surface-container-high transition-colors"
                aria-label={isExpanded ? 'Hide prayer' : 'Show prayer'}
              >
                <motion.div animate={{ rotate: isExpanded ? 180 : 0 }} transition={{ duration: 0.2 }}>
                  <ChevronDown className="h-4 w-4 text-on-surface-variant" />
                </motion.div>
              </button>
            </button>
            <AnimatePresence initial={false}>
              {isExpanded && (
                <motion.div
                  initial={{ height: 0 }}
                  animate={{ height: 'auto' }}
                  exit={{ height: 0 }}
                  transition={{ duration: 0.25 }}
                  className="overflow-hidden border-t border-outline-variant/10"
                >
                  <p className="px-4 pb-4 pt-3 font-body text-xs text-on-surface-variant leading-relaxed whitespace-pre-line">
                    {t.prayer}
                  </p>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        );
      })}
    </div>
  );
}
