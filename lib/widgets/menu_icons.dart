import 'package:flutter/material.dart';

import '../data/menu_data.dart';

extension MenuCategoryIcon on IconIdentifier {
  IconData get icon => switch (this) {
        IconIdentifier.chicken => Icons.outdoor_grill_rounded,
        IconIdentifier.bowl => Icons.ramen_dining_rounded,
        IconIdentifier.addOn => Icons.add_circle_outline_rounded,
        IconIdentifier.side => Icons.rice_bowl_rounded,
        IconIdentifier.special => Icons.local_fire_department_rounded,
        IconIdentifier.dessert => Icons.icecream_rounded,
      };
}

/// Photo d'un plat, quand on en a une (mêmes règles que l'application).
String? menuItemImage(String itemName, {IconIdentifier? category}) {
  final name = itemName.toLowerCase();
  if (category == IconIdentifier.chicken && name.contains('poulet')) return 'assets/images/poulet.jpg';
  if (name.contains('cheddar') && !name.startsWith('cheddar')) return 'assets/images/tasty_cheddar.jpg';
  if (name.contains('tajine')) return 'assets/images/tajine.jpg';
  return null;
}
