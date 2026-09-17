import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import 'kiosk_config.dart';
import '../models/ticket.dart';

/// Writes to the shared `orders` collection — the same one the mobile app
/// writes to, so every order placed anywhere ends up in one place. Kiosk
/// tickets carry `source: 'kiosk'` and no `userId` (there's no per-customer
/// sign-in at a kiosk, just the terminal's own anonymous session — see
/// [enableKioskMode] / `main.dart`), so they can't yet be tied back to a
/// loyalty account; `customerPhone` is kept for a future reconciliation
/// step, and also for order-status SMS (see the app's
/// `orders_repository.dart` for that design note — a Cloud Function
/// watching this collection covers the kiosk and the app identically).
class OrdersRepository {
  const OrdersRepository._();

  static Future<void> submitTicket(Ticket ticket) {
    final data = {
      ...ticket.toJson(),
      'id': 'kiosk-${ticket.number}',
      'restaurantName': KioskConfig.restaurantLocationName,
      'fulfillmentDetail': null,
      'status': 'confirmed',
      'paid': false,
      'pointsEarned': 0,
      'userId': null,
      'source': 'kiosk',
    };
    return FirebaseFirestore.instance.collection('orders').add(data);
  }
}
