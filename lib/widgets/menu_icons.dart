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

/// Mots-clés du nom du plat → photo. L'ordre compte : le plus précis
/// d'abord ("crousty tenders" avant "tenders", "crousty cheddar" avant
/// "cheddar"). Photos dans assets/images/produits/ (générées avec Gemini),
/// sauf Crousty Cheddar et Tajine (photos fournies par le restaurant).
const _productImages = [
  ('crousty cheddar', 'assets/images/tasty_cheddar.jpg'),
  ('crousty tenders', 'assets/images/produits/crousty_tenders.jpg'),
  ('tandoori', 'assets/images/produits/bowl_tandoori.jpg'),
  ('curry', 'assets/images/produits/bowl_curry_coco.jpg'),
  ('demi-poulet', 'assets/images/produits/demi_poulet.jpg'),
  ('demi poulet', 'assets/images/produits/demi_poulet.jpg'),
  ('dinde', 'assets/images/produits/cuisse_dinde.jpg'),
  ('formule', 'assets/images/produits/formule_quart.jpg'),
  ('poulet rôti', 'assets/images/produits/poulet_roti.jpg'),
  ('poulet mariné', 'assets/images/produits/sup_poulet_marine.jpg'),
  ('tenders', 'assets/images/produits/sup_tenders.jpg'),
  ('oignon', 'assets/images/produits/sup_oignons.jpg'),
  ('cheddar', 'assets/images/produits/sup_cheddar.jpg'),
  ('barquette', 'assets/images/produits/barquette.jpg'),
  ('haricots', 'assets/images/produits/haricots_pdt.jpg'),
  ('frites', 'assets/images/produits/frites.jpg'),
  ('riz', 'assets/images/produits/riz_pilaf.jpg'),
  ('couscous', 'assets/images/produits/couscous.jpg'),
  ('tajine', 'assets/images/tajine.jpg'),
  ('tiramisu', 'assets/images/produits/tiramisu.jpg'),
  ('canette', 'assets/images/produits/canette.jpg'),
  ('boisson', 'assets/images/produits/canette.jpg'),
];

/// Photo d'un plat de la carte, ou null (l'écran affiche alors l'icône de
/// la catégorie). Mêmes règles dans l'application et les bornes.
String? menuItemImage(String itemName) {
  final name = itemName.toLowerCase();
  for (final (keyword, asset) in _productImages) {
    if (name.contains(keyword)) return asset;
  }
  return null;
}
