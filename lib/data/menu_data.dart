String formatPrice(double value) => '${value.toStringAsFixed(2).replaceAll('.', ',')} €';

class MenuItemSize {
  const MenuItemSize({required this.label, required this.price});

  final String label;
  final double price;

  Map<String, dynamic> toMap() => {'label': label, 'price': price};

  factory MenuItemSize.fromMap(Map<String, dynamic> map) => MenuItemSize(
        label: map['label'] as String,
        price: (map['price'] as num).toDouble(),
      );
}

class MenuItem {
  const MenuItem({
    required this.name,
    this.price,
    this.sizes = const [],
    this.note,
    this.allowsSupplements = false,
    this.isAddOn = false,
    this.isInfoOnly = false,
    this.infoLabel,
  });

  final String name;
  final double? price;
  final List<MenuItemSize> sizes;
  final String? note;

  /// Whether this item can be customized with items from "Suppléments bowls".
  final bool allowsSupplements;

  /// Whether this item is itself a bowl supplement (its price is shown as "+X €").
  final bool isAddOn;

  /// Descriptive-only items (e.g. what a barquette includes) that aren't sold on their own.
  final bool isInfoOnly;
  final String? infoLabel;

  bool get hasSizes => sizes.isNotEmpty;

  /// False only for items whose price is genuinely unknown — kept visible on
  /// the menu but not addable to an order until a real price is confirmed.
  bool get isOrderable => !isInfoOnly && (hasSizes || price != null);

  double get startingPrice => hasSizes ? sizes.first.price : (price ?? 0);

  String get priceLabel {
    if (isInfoOnly) return infoLabel ?? 'Inclus';
    if (hasSizes) return sizes.map((s) => formatPrice(s.price)).join(' / ');
    if (price == null) return 'Prix à définir';
    return isAddOn ? '+${formatPrice(price!)}' : formatPrice(price!);
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'sizes': sizes.map((s) => s.toMap()).toList(),
        'note': note,
        'allowsSupplements': allowsSupplements,
        'isAddOn': isAddOn,
        'isInfoOnly': isInfoOnly,
        'infoLabel': infoLabel,
      };

  factory MenuItem.fromMap(Map<String, dynamic> map) => MenuItem(
        name: map['name'] as String,
        price: (map['price'] as num?)?.toDouble(),
        sizes: (map['sizes'] as List<dynamic>? ?? [])
            .map((s) => MenuItemSize.fromMap(Map<String, dynamic>.from(s as Map)))
            .toList(),
        note: map['note'] as String?,
        allowsSupplements: map['allowsSupplements'] as bool? ?? false,
        isAddOn: map['isAddOn'] as bool? ?? false,
        isInfoOnly: map['isInfoOnly'] as bool? ?? false,
        infoLabel: map['infoLabel'] as String?,
      );
}

class MenuCategory {
  const MenuCategory({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconIdentifier icon;
  final List<MenuItem> items;

  Map<String, dynamic> toMap() => {
        'title': title,
        'icon': icon.name,
        'items': items.map((i) => i.toMap()).toList(),
      };

  factory MenuCategory.fromMap(Map<String, dynamic> map) => MenuCategory(
        title: map['title'] as String,
        icon: IconIdentifier.values.byName(map['icon'] as String? ?? 'chicken'),
        items: (map['items'] as List<dynamic>? ?? [])
            .map((i) => MenuItem.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList(),
      );
}

/// A tiny enum so menu_data.dart doesn't need to import `flutter/material.dart`
/// just to reference an [IconData] — kept as data, resolved to an icon by the UI.
enum IconIdentifier { chicken, bowl, addOn, side, special, dessert }

const restaurantName = 'Les Poulets de Mamie';
const restaurantTagline = 'Rôtisserie artisanale — Poulet Fermier Label Rouge';
