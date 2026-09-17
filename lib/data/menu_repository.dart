import 'package:cloud_firestore/cloud_firestore.dart';

import 'menu_data.dart';

/// Reads the live menu from Firestore — the same `menuCategories`
/// collection the mobile app reads, so both surfaces always show the same
/// carte. Categories are ordered by their `order` field.
class MenuRepository {
  const MenuRepository._();

  static Future<List<MenuCategory>> fetchMenu() async {
    final snapshot = await FirebaseFirestore.instance.collection('menuCategories').orderBy('order').get();
    return snapshot.docs.map((doc) => MenuCategory.fromMap(doc.data())).toList();
  }
}
