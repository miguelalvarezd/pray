import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Resolves a Lucide icon name (PascalCase, as used in the React data model)
/// to a Flutter `IconData`. Returns `LucideIcons.book` as a sensible fallback
/// so the UI never blanks out when an unknown name slips in.
IconData lucideIconFor(String name) {
  return _byName[name] ?? LucideIcons.book;
}

const _byName = <String, IconData>{
  // Default prayers
  'Sunrise': LucideIcons.sunrise,
  'Church': LucideIcons.church,
  'Crown': LucideIcons.crown,
  'MoonStar': LucideIcons.moonStar,
  'Book': LucideIcons.book,
  // Extra activities (DEFAULT_EXTRA_ACTIVITIES in src/types.ts)
  'MessageSquareHeart': LucideIcons.messageSquareHeart,
  'Sun': LucideIcons.sun,
  'Cross': LucideIcons.cross,
  'Clock': LucideIcons.clock,
  'BookMarked': LucideIcons.bookMarked,
  'BookHeart': LucideIcons.bookHeart,
  'Droplets': LucideIcons.droplets,
  'Bell': LucideIcons.bell,
  'Scroll': LucideIcons.scroll,
  'HandHeart': LucideIcons.handHeart,
  'HandCoins': LucideIcons.handCoins,
  'HeartHandshake': LucideIcons.heartHandshake,
  'BookText': LucideIcons.bookText,
  'UtensilsCrossed': LucideIcons.utensilsCrossed,
  'MountainSnow': LucideIcons.mountainSnow,
  'Compass': LucideIcons.compass,
  'Brain': LucideIcons.brain,
  // Common UI
  'Plus': LucideIcons.plus,
  'X': LucideIcons.x,
  'Check': LucideIcons.check,
  'ChevronDown': LucideIcons.chevronDown,
  'ChevronUp': LucideIcons.chevronUp,
  'Music': LucideIcons.music,
  'Sparkles': LucideIcons.sparkles,
  'Calendar': LucideIcons.calendar,
};
