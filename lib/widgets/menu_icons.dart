import 'package:flutter/material.dart';

import '../data/menu_data.dart';

extension MenuCategoryIcon on IconIdentifier {
  IconData get icon => switch (this) {
        IconIdentifier.chicken => Icons.set_meal_outlined,
        IconIdentifier.bowl => Icons.ramen_dining_outlined,
        IconIdentifier.addOn => Icons.add_circle_outline,
        IconIdentifier.side => Icons.rice_bowl_outlined,
        IconIdentifier.special => Icons.event_outlined,
        IconIdentifier.dessert => Icons.icecream_outlined,
      };
}
