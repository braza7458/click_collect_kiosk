import 'cart_line.dart';
import 'order_mode.dart';

/// A placed kiosk order. There's no kitchen display system or payment
/// terminal wired in yet, so a ticket is simply the record shown to the
/// customer and kept in the on-terminal log for staff — payment happens at
/// the register, referencing the ticket number.
class Ticket {
  Ticket({
    required this.number,
    required this.date,
    required this.mode,
    required this.lines,
    required this.total,
    this.customerPhone,
  });

  /// Sequential, resets every day (see KioskState._nextTicketNumber).
  final int number;
  final DateTime date;
  final OrderMode mode;
  final List<CartLine> lines;
  final double total;
  final String? customerPhone;

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
      );
}
