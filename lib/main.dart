import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'config/stripe_config.dart';
import 'data/kiosk_config.dart';
import 'firebase_options.dart';
import 'screens/attract_screen.dart';
import 'services/kiosk_mode.dart';
import 'state/kiosk_state.dart';
import 'theme/app_theme.dart';
import 'widgets/inactivity_guard.dart';
import 'widgets/staff_exit_gate.dart';
import 'widgets/ui.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (StripeConfig.isConfigured) {
    // Paiement sur la borne (carte / Apple Pay / Google Pay), comme le mode
    // Borne du terminal — même compte Stripe que l'application.
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }
  try {
    // The terminal signs in anonymously (once — Firebase Auth persists the
    // session) so Firestore's `orders` rule, which requires *some*
    // authenticated caller, accepts tickets from this kiosk.
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (_) {
    // Offline on first launch, or anonymous sign-in disabled on the
    // project — the kiosk still runs, tickets just won't sync until this
    // succeeds.
  }
  await enableKioskMode();
  runApp(const ClickCollectKioskApp());
}

class ClickCollectKioskApp extends StatefulWidget {
  /// [kioskState] lets tests inject a pre-seeded state (e.g. with a menu
  /// already set) instead of hitting the real Firestore backend.
  const ClickCollectKioskApp({super.key, KioskState? kioskState}) : _injectedState = kioskState;

  final KioskState? _injectedState;

  @override
  State<ClickCollectKioskApp> createState() => _ClickCollectKioskAppState();
}

class _ClickCollectKioskAppState extends State<ClickCollectKioskApp> {
  late final _kioskState = widget._injectedState ?? KioskState();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.wait([_kioskState.load(), _kioskState.loadCatalog()]).then((_) {
      if (mounted) setState(() => _loaded = true);
    });
  }

  void _handleInactivityTimeout() {
    if (!_kioskState.hasActiveSession) return;
    _kioskState.resetSession();
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return KioskStateScope(
      state: _kioskState,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Les Poulets de Mamie — Borne',
        debugShowCheckedModeBanner: false,
        theme: buildKioskTheme(),
        scrollBehavior: const KioskScrollBehavior(),
        home: _loaded ? const AttractScreen() : const _SplashScreen(),
        builder: (context, child) {
          return StaffExitGate(
            navigatorKey: navigatorKey,
            child: InactivityGuard(
              timeout: KioskConfig.inactivityTimeout,
              onTimeout: _handleInactivityTimeout,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: BrandSeal(size: 140)),
    );
  }
}
