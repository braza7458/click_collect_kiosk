import 'package:flutter/material.dart';

/// A kiosk stands inside one specific restaurant, so unlike the mobile app
/// there's no Click & Collect or delivery choice here — only how the order
/// will be enjoyed.
enum OrderMode { dineIn, takeaway }

extension OrderModeInfo on OrderMode {
  String get label => switch (this) {
        OrderMode.dineIn => 'Sur place',
        OrderMode.takeaway => 'À emporter',
      };

  String get description => switch (this) {
        OrderMode.dineIn => 'Vous mangez ici, en salle',
        OrderMode.takeaway => 'Vous repartez avec votre commande',
      };

  IconData get icon => switch (this) {
        OrderMode.dineIn => Icons.restaurant_outlined,
        OrderMode.takeaway => Icons.shopping_bag_outlined,
      };
}
