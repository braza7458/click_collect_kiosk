import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import 'kiosk_config.dart';
import '../models/ticket.dart';

/// Écrit les commandes de la borne dans la collection partagée `orders` —
/// celle où l'application mobile écrit aussi. Le terminal de réception
/// (click_collect_terminal) les lit toutes en direct (`source: 'kiosk'`
/// comme `source: 'app'`) et les fait avancer ; la Cloud Function envoie le
/// SMS "confirmée" puis "prête" si un numéro a été saisi.
class OrdersRepository {
  const OrdersRepository._();

  static Future<void> submitTicket(Ticket ticket) {
    final data = {
      ...ticket.toJson(),
      'id': 'kiosk-${ticket.number}',
      'restaurantName': KioskConfig.restaurantLocationName,
      'fulfillmentDetail': null,
      'status': 'confirmed',
      'source': 'kiosk',
    };
    return FirebaseFirestore.instance.collection('orders').add(data);
  }
}
