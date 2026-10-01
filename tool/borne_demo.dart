// Démo visuelle de la borne SANS Firebase (carte fictive en mémoire, aucune
// commande envoyée nulle part — l'enregistrement échoue silencieusement hors
// ligne, comme prévu). Lancer avec :
//
//   flutter run -d chrome -t tool/borne_demo.dart
import 'package:flutter/material.dart';

import 'package:click_collect_kiosk/data/menu_data.dart';
import 'package:click_collect_kiosk/main.dart';
import 'package:click_collect_kiosk/state/kiosk_state.dart';

void main() {
  runApp(
    ClickCollectKioskApp(
      kioskState: KioskState()
        ..menuCategories = const [
          MenuCategory(title: 'Poulets rôtis', icon: IconIdentifier.chicken, items: [
            MenuItem(name: 'Le Poulet Rôti', price: 20.50),
            MenuItem(name: 'Le Demi-Poulet', price: 11.50),
            MenuItem(name: 'La Cuisse de Dinde', price: 21.00),
            MenuItem(name: 'Formule 1/4 de poulet + pomme de terre', price: 10.50),
          ]),
          MenuCategory(title: 'Nos Bowls', icon: IconIdentifier.bowl, items: [
            MenuItem(name: 'Crousty Cheddar', sizes: [MenuItemSize(label: 'M', price: 8.50), MenuItemSize(label: 'L', price: 10.00)], allowsSupplements: true),
            MenuItem(name: 'Poulet Tandoori', sizes: [MenuItemSize(label: 'M', price: 9.00), MenuItemSize(label: 'L', price: 10.50)], allowsSupplements: true),
          ]),
          MenuCategory(title: 'Suppléments bowls', icon: IconIdentifier.addOn, items: [
            MenuItem(name: 'Cheddar', price: 0.50, isAddOn: true),
            MenuItem(name: 'Oignons crispy', price: 0.50, isAddOn: true),
          ]),
          MenuCategory(title: 'Spéciaux de la semaine', icon: IconIdentifier.special, items: [
            MenuItem(name: 'Tajine', price: 11.50, note: 'Mercredi'),
          ]),
        ],
    ),
  );
}
