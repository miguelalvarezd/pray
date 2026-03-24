import React from 'react';
import { cn } from '@/lib/utils';

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'outline' | 'ghost' | 'secondary' | 'destructive' | 'link';
  size?: 'default' | 'sm' | 'lg' | 'icon';
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'default', size = 'default', ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          'inline-flex items-center justify-center whitespace-nowrap rounded-full font-label text-sm font-semibold tracking-wide transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 active:scale-95',
          {
            'bg-gradient-to-b from-primary to-primary-dim text-on-primary hover:opacity-90 shadow-ambient-sm':
              variant === 'default',
            'bg-surface-container-high text-on-surface hover:bg-surface-container-highest':
              variant === 'secondary',
            'bg-surface-container-low text-on-surface-variant hover:bg-surface-container':
              variant === 'outline',
            'hover:bg-surface-container text-on-surface-variant':
              variant === 'ghost',
            'bg-error text-on-primary hover:opacity-90':
              variant === 'destructive',
            'text-primary underline-offset-4 hover:underline font-medium':
              variant === 'link',
            'h-10 px-5 py-2': size === 'default',
            'h-9 px-4 text-xs': size === 'sm',
            'h-12 px-8 text-sm': size === 'lg',
            'h-10 w-10': size === 'icon',
          },
          className
        )}
        {...props}
      />
    );
  }
);
Button.displayName = 'Button';

export { Button };
