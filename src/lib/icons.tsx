import React from 'react';
import { Sun, Moon, Book, Crown, Circle, Church, Music } from 'lucide-react';

export function getIcon(iconName?: string, classNameOrSize?: string | number) {
  const className = typeof classNameOrSize === 'number'
    ? `h-[${classNameOrSize}px] w-[${classNameOrSize}px]`
    : classNameOrSize || 'h-5 w-5';
  switch (iconName) {
    case 'Sun': return <Sun className={className} />;
    case 'Moon': return <Moon className={className} />;
    case 'Book': return <Book className={className} />;
    case 'Circle': return <Circle className={className} />;
    case 'Church': return <Church className={className} />;
    case 'Crown': return <Crown className={className} />;
    case 'Music': return <Music className={className} />;
    default: return <Crown className={className} />;
  }
}
