class CartSupplement {
  const CartSupplement({required this.name, required this.price});

  final String name;
  final double price;
}

/// One configured item in the order (a menu item, at a given size, with a
/// given set of supplements). [id] is derived from that configuration so
/// adding the same configuration twice increments its quantity instead of
/// creating a duplicate line.
class CartLine {
  CartLine({
    required this.itemName,
    this.sizeLabel,
    required this.unitPrice,
    this.supplements = const [],
    this.quantity = 1,
  });

  final String itemName;
  final String? sizeLabel;
  final double unitPrice;
  final List<CartSupplement> supplements;
  int quantity;

  String get id => [
        itemName,
        sizeLabel ?? '',
        (supplements.map((s) => s.name).toList()..sort()).join(','),
      ].join('|');

  double get supplementsTotal => supplements.fold(0.0, (sum, s) => sum + s.price);
  double get unitTotal => unitPrice + supplementsTotal;
  double get lineTotal => unitTotal * quantity;
}
