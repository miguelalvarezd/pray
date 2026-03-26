import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function getThemeClasses(themeColor?: string, completed?: boolean, altRow?: boolean) {
  if (!themeColor) {
    return {
      bg: completed ? 'bg-secondary-container' : altRow ? 'bg-surface-container-lowest shadow-ambient-sm' : 'bg-surface-container-low',
      iconBg: completed ? 'bg-secondary text-on-secondary' : 'bg-secondary-container text-on-secondary-container',
      checkBorder: completed ? 'bg-secondary border-secondary' : 'border-outline-variant hover:border-primary',
      checkIcon: 'text-on-secondary'
    };
  }

  const c = themeColor.toLowerCase();
  
  switch (c) {
    case 'purple':
      return {
        bg: completed ? 'bg-[var(--color-liturgical-purple-container)]' : altRow ? 'bg-surface-container-lowest shadow-ambient-sm' : 'bg-surface-container-low',
        iconBg: completed ? 'bg-[var(--color-liturgical-purple)] text-[var(--color-on-liturgical-purple)]' : 'bg-[var(--color-liturgical-purple-container)] text-[var(--color-on-liturgical-purple-container)]',
        checkBorder: completed ? 'bg-[var(--color-liturgical-purple)] border-[var(--color-liturgical-purple)]' : 'border-outline-variant hover:border-[var(--color-liturgical-purple)]',
        checkIcon: 'text-[var(--color-on-liturgical-purple)]'
      };
    case 'red':
      return {
        bg: completed ? 'bg-[var(--color-liturgical-red-container)]' : altRow ? 'bg-surface-container-lowest shadow-ambient-sm' : 'bg-surface-container-low',
        iconBg: completed ? 'bg-[var(--color-liturgical-red)] text-[var(--color-on-liturgical-red)]' : 'bg-[var(--color-liturgical-red-container)] text-[var(--color-on-liturgical-red-container)]',
        checkBorder: completed ? 'bg-[var(--color-liturgical-red)] border-[var(--color-liturgical-red)]' : 'border-outline-variant hover:border-[var(--color-liturgical-red)]',
        checkIcon: 'text-[var(--color-on-liturgical-red)]'
      };
    case 'white':
      return {
        bg: completed ? 'bg-[var(--color-liturgical-white-container)]' : altRow ? 'bg-surface-container-lowest shadow-ambient-sm' : 'bg-surface-container-low',
        iconBg: completed ? 'bg-[var(--color-liturgical-white)] text-[var(--color-on-liturgical-white)]' : 'bg-[var(--color-liturgical-white-container)] text-[var(--color-on-liturgical-white-container)]',
        checkBorder: completed ? 'bg-[var(--color-liturgical-white)] border-[var(--color-liturgical-white)]' : 'border-outline-variant hover:border-[var(--color-liturgical-white)]',
        checkIcon: 'text-[var(--color-on-liturgical-white)]'
      };
    case 'rose':
      return {
        bg: completed ? 'bg-[var(--color-liturgical-rose-container)]' : altRow ? 'bg-surface-container-lowest shadow-ambient-sm' : 'bg-surface-container-low',
        iconBg: completed ? 'bg-[var(--color-liturgical-rose)] text-[var(--color-on-liturgical-rose)]' : 'bg-[var(--color-liturgical-rose-container)] text-[var(--color-on-liturgical-rose-container)]',
        checkBorder: completed ? 'bg-[var(--color-liturgical-rose)] border-[var(--color-liturgical-rose)]' : 'border-outline-variant hover:border-[var(--color-liturgical-rose)]',
        checkIcon: 'text-[var(--color-on-liturgical-rose)]'
      };
    case 'green':
    default:
      return {
        bg: completed ? 'bg-[var(--color-liturgical-green-container)]' : altRow ? 'bg-surface-container-lowest shadow-ambient-sm' : 'bg-surface-container-low',
        iconBg: completed ? 'bg-[var(--color-liturgical-green)] text-[var(--color-on-liturgical-green)]' : 'bg-[var(--color-liturgical-green-container)] text-[var(--color-on-liturgical-green-container)]',
        checkBorder: completed ? 'bg-[var(--color-liturgical-green)] border-[var(--color-liturgical-green)]' : 'border-outline-variant hover:border-[var(--color-liturgical-green)]',
        checkIcon: 'text-[var(--color-on-liturgical-green)]'
      };
  }
}
