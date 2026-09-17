import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../screens/staff/staff_pin_dialog.dart';
import '../services/kiosk_mode.dart';

/// On desktop, intercepts the window's close button / Alt+F4 (enabled via
/// `windowManager.setPreventClose(true)` in [enableKioskMode]) and asks for
/// the staff PIN before actually closing — so a customer can't back out of
/// kiosk mode by accident.
class StaffExitGate extends StatefulWidget {
  const StaffExitGate({super.key, required this.child, required this.navigatorKey});

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<StaffExitGate> createState() => _StaffExitGateState();
}

class _StaffExitGateState extends State<StaffExitGate> with WindowListener {
  bool _dialogShowing = false;

  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  void initState() {
    super.initState();
    if (_isDesktop) windowManager.addListener(this);
  }

  @override
  void dispose() {
    if (_isDesktop) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (_dialogShowing) return;
    final context = widget.navigatorKey.currentContext;
    if (context == null) return;
    _dialogShowing = true;
    final ok = await showStaffPinDialog(context, title: 'Fermer le kiosque');
    _dialogShowing = false;
    if (ok == true) {
      await exitKioskMode();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
