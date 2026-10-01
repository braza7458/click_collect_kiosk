import 'cart_line.dart';
import 'order_mode.dart';

/// A placed kiosk order — the record shown to the customer and kept in the
/// on-terminal log for staff. [paid] is true when settled on the spot via
/// Stripe (card / Apple Pay / Google Pay); false means "pay at the
/// register", referencing the ticket number.
class Ticket {
  Ticket({
    required this.number,
    required this.date,
    required this.mode,
    required this.lines,
    required this.total,
    this.customerPhone,
    this.paid = false,
    this.userId,
    this.customerName,
    this.pointsEarned = 0,
    this.appliedRewardLabel,
    this.pointsBalance,
  });

  /// Sequential, resets every day (see KioskState._nextTicketNumber).
  final int number;
  final DateTime date;
  final OrderMode mode;
  final List<CartLine> lines;
  final double total;
  final String? customerPhone;
  final bool paid;

  /// Compte fidélité du client (le même que dans l'application), s'il s'est
  /// identifié sur la borne — la commande apparaît alors dans ses
  /// "Mes commandes" sur l'application.
  final String? userId;
  final String? customerName;
  final int pointsEarned;

  /// Récompense fidélité échangée (offerte en plus, pas une remise).
  final String? appliedRewardLabel;

  /// Solde de points après la commande — affichage du ticket uniquement.
  int? pointsBalance;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  Map<String, dynamic> toJson() => {
        'number': number,
        'date': date.toIso8601String(),
        'mode': mode.name,
        'lines': lines
            .map((l) => {
                  'itemName': l.itemName,
                  'sizeLabel': l.sizeLabel,
                  'unitPrice': l.unitPrice,
                  'quantity': l.quantity,
                  'supplements': l.supplements.map((s) => {'name': s.name, 'price': s.price}).toList(),
                })
            .toList(),
        'total': total,
        'customerPhone': customerPhone,
        'paid': paid,
        'userId': userId,
        'customerName': customerName,
        'pointsEarned': pointsEarned,
        'appliedRewardLabel': appliedRewardLabel,
      };

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        number: json['number'] as int,
        date: DateTime.parse(json['date'] as String),
        mode: OrderMode.values.byName(json['mode'] as String),
        lines: (json['lines'] as List<dynamic>)
            .map(
              (l) => CartLine(
                itemName: l['itemName'] as String,
                sizeLabel: l['sizeLabel'] as String?,
                unitPrice: (l['unitPrice'] as num).toDouble(),
                quantity: l['quantity'] as int,
                supplements: (l['supplements'] as List<dynamic>? ?? [])
                    .map((s) => CartSupplement(name: s['name'] as String, price: (s['price'] as num).toDouble()))
                    .toList(),
              ),
            )
            .toList(),
        total: (json['total'] as num).toDouble(),
        customerPhone: json['customerPhone'] as String?,
        paid: json['paid'] as bool? ?? false,
        userId: json['userId'] as String?,
        customerName: json['customerName'] as String?,
        pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
        appliedRewardLabel: json['appliedRewardLabel'] as String?,
      );
}
