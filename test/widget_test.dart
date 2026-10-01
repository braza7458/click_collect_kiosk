import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:click_collect_kiosk/data/kiosk_config.dart';
import 'package:click_collect_kiosk/data/menu_data.dart';
import 'package:click_collect_kiosk/main.dart';
import 'package:click_collect_kiosk/state/kiosk_state.dart';

/// The menu now lives in Firestore, which isn't reachable from a widget
/// test — inject a small fixture instead of hitting the network.
/// `loadCatalog()` fails silently offline and keeps this untouched.
KioskState _testKioskState() => KioskState()
  ..menuCategories = const [
    MenuCategory(
      title: 'Poulets rôtis',
      icon: IconIdentifier.chicken,
      items: [MenuItem(name: 'Le Poulet Rôti', price: 20.50)],
    ),
  ];

/// Taille d'écran réaliste pour une borne en paysage.
Future<void> _useKioskScreen(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1280, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  setUp(() {
    // Pas d'animation d'ambiance infinie : pumpAndSettle ne finirait jamais.
    KioskConfig.ambientAnimations = false;
    // KioskState persists to shared_preferences on every change — the test
    // environment has no real platform storage, so mock it empty.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Attract screen shows the restaurant name and a call to action', (WidgetTester tester) async {
    await _useKioskScreen(tester);
    await tester.pumpWidget(ClickCollectKioskApp(kioskState: _testKioskState()));
    await tester.pumpAndSettle();

    expect(find.text('Les Poulets de Mamie'), findsOneWidget);
    expect(find.text('Touchez l\'écran pour commander'), findsOneWidget);
  });

  testWidgets('A customer can order a chicken and reach a ticket number', (WidgetTester tester) async {
    await _useKioskScreen(tester);
    await tester.pumpWidget(ClickCollectKioskApp(kioskState: _testKioskState()));
    await tester.pumpAndSettle();

    // Attract -> order type.
    await tester.tap(find.text('Touchez l\'écran pour commander'));
    await tester.pumpAndSettle();

    // Order type -> menu.
    await tester.tap(find.text('Sur place'));
    await tester.pumpAndSettle();

    expect(find.text('Le Poulet Rôti'), findsOneWidget);

    // Add an item.
    await tester.tap(find.text('Le Poulet Rôti'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Ajouter ·'));
    await tester.pumpAndSettle();

    expect(find.text('Le Poulet Rôti'), findsWidgets); // in the cart panel too

    // Cart -> checkout -> pay at the register (no live Stripe backend in a
    // widget test, so this exercises the non-Stripe path).
    await tester.tap(find.text('Valider ma commande'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Payer 20,50'), findsOneWidget); // paiement carte proposé
    await tester.ensureVisible(find.text('Payer en caisse'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payer en caisse'));
    await tester.pumpAndSettle();

    expect(find.text('Commande enregistrée'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // first ticket of the day
  });
}
