import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/menu_data.dart';
import '../data/menu_repository.dart';
import '../data/orders_repository.dart';
import '../models/cart_line.dart';
import '../models/order_mode.dart';
import '../models/ticket.dart';

export '../models/order_mode.dart';

const _storageKey = 'kiosk_state_v1';

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// State for one kiosk terminal. The menu is shared (read from Firestore —
/// the same catalog the mobile app reads). Today's tickets and the daily
/// order counter still live in `shared_preferences` on this device only, and
/// reset at midnight — that's the next seam to move to a shared backend.
class KioskState extends ChangeNotifier {
  OrderMode? mode;
  List<CartLine> cart = [];
  String? customerPhone;

  /// Today's placed orders, most recent first.
  List<Ticket> todaysTickets = [];

  List<MenuCategory> menuCategories = [];

  int _counter = 0;
  SharedPreferences? _prefs;

  double get cartTotal => cart.fold(0.0, (sum, l) => sum + l.lineTotal);
  int get cartItemCount => cart.fold(0, (sum, l) => sum + l.quantity);
  bool get hasActiveSession => mode != null || cart.isNotEmpty;

  /// The "Suppléments bowls" items, for the bowl customization dialog.
  List<MenuItem> get bowlSupplements => menuCategories
      .firstWhere(
        (c) => c.title == 'Suppléments bowls',
        orElse: () => const MenuCategory(title: '', icon: IconIdentifier.addOn, items: []),
      )
      .items;

  Future<void> loadCatalog() async {
    try {
      menuCategories = await MenuRepository.fetchMenu();
    } catch (_) {
      // Offline, or Firestore unreachable — keep whatever menu is already
      // loaded rather than taking the kiosk down.
    }
    notifyListeners();
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final storedDay = json['day'] as String?;
      if (storedDay != _dateKey(DateTime.now())) {
        // New day — start today's log and counter fresh.
        return;
      }
      _counter = json['counter'] as int? ?? 0;
      todaysTickets = (json['tickets'] as List<dynamic>? ?? [])
          .map((t) => Ticket.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted local data — start clean rather than crash.
    }
  }

  void _persist() {
    final json = {
      'day': _dateKey(DateTime.now()),
      'counter': _counter,
      'tickets': todaysTickets.map((t) => t.toJson()).toList(),
    };
    _prefs?.setString(_storageKey, jsonEncode(json));
  }

  void setMode(OrderMode value) {
    mode = value;
    notifyListeners();
  }

  void addToCart(CartLine line) {
    final existing = cart.where((l) => l.id == line.id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += line.quantity;
    } else {
      cart.add(line);
    }
    notifyListeners();
  }

  void updateQuantity(String lineId, int quantity) {
    if (quantity <= 0) {
      cart.removeWhere((l) => l.id == lineId);
    } else {
      final line = cart.where((l) => l.id == lineId).toList();
      if (line.isNotEmpty) line.first.quantity = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(String lineId) {
    cart.removeWhere((l) => l.id == lineId);
    notifyListeners();
  }

  void setCustomerPhone(String? phone) {
    customerPhone = (phone == null || phone.trim().isEmpty) ? null : phone.trim();
    notifyListeners();
  }

  /// Places the current cart as a ticket. There is no payment terminal wired
  /// in yet — the confirmation screen is explicit that payment happens at
  /// the register, referencing the ticket number.
  Future<Ticket> placeOrder() async {
    assert(mode != null && cart.isNotEmpty);
    _counter += 1;
    final ticket = Ticket(
      number: _counter,
      date: DateTime.now(),
      mode: mode!,
      lines: List.of(cart),
      total: cartTotal,
      customerPhone: customerPhone,
    );
    todaysTickets.insert(0, ticket);
    _persist();
    try {
      await OrdersRepository.submitTicket(ticket);
    } catch (_) {
      // Offline — the ticket still prints locally; it just won't appear in
      // the shared orders collection until connectivity returns.
    }
    return ticket;
  }

  /// Clears the current customer's order — used after a ticket is issued, or
  /// when the kiosk returns to the attract screen after a period of
  /// inactivity or abandonment.
  void resetSession() {
    mode = null;
    cart = [];
    customerPhone = null;
    notifyListeners();
  }
}

/// Exposes a single [KioskState] instance to the widget tree.
class KioskStateScope extends InheritedNotifier<KioskState> {
  const KioskStateScope({super.key, required KioskState state, required super.child})
      : super(notifier: state);

  static KioskState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KioskStateScope>();
    assert(scope != null, 'No KioskStateScope found in context');
    return scope!.notifier!;
  }
}
