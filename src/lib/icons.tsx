import React from 'react';
import {
  Sun, Sunrise, MoonStar, Book, Crown, Circle, Church, Music,
  MessageSquareHeart, Sparkles, Cross, Clock, Bell, Droplets, Scroll,
  HandHeart, HandCoins, HeartHandshake, BookMarked, BookText,
  UtensilsCrossed, MountainSnow, Compass, Brain
} from 'lucide-react';

export function getIcon(iconName?: string, classNameOrSize?: string | number) {
  const className = typeof classNameOrSize === 'number'
    ? `h-[${classNameOrSize}px] w-[${classNameOrSize}px]`
    : classNameOrSize || 'h-5 w-5';
  switch (iconName) {
    case 'Sunrise': return <Sunrise className={className} />;
    case 'MoonStar': return <MoonStar className={className} />;
    case 'Book': return <Book className={className} />;
    case 'Circle': return <Circle className={className} />;
    case 'Church': return <Church className={className} />;
    case 'Crown': return <Crown className={className} />;
    case 'Music': return <Music className={className} />;
    // Extra activity icons
    case 'Sun': return <Sun className={className} />;
    case 'MessageSquareHeart': return <MessageSquareHeart className={className} />;
    case 'Sparkles': return <Sparkles className={className} />;
    case 'Cross': return <Cross className={className} />;
    case 'Clock': return <Clock className={className} />;
    case 'Bell': return <Bell className={className} />;
    case 'Droplets': return <Droplets className={className} />;
    case 'Scroll': return <Scroll className={className} />;
    case 'HandHeart': return <HandHeart className={className} />;
    case 'HandCoins': return <HandCoins className={className} />;
    case 'HeartHandshake': return <HeartHandshake className={className} />;
    case 'BookMarked': return <BookMarked className={className} />;
    case 'BookText': return <BookText className={className} />;
    case 'UtensilsCrossed': return <UtensilsCrossed className={className} />;
    case 'MountainSnow': return <MountainSnow className={className} />;
    case 'Compass': return <Compass className={className} />;
    case 'Brain': return <Brain className={className} />;
    default: return <Crown className={className} />;
  }
}
