import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

/// App-level kiosk hardening: fullscreen, no system chrome, screen never
/// sleeps, and — on desktop — the window can't be closed without the staff
/// PIN (see [StaffExitGate]).
///
/// This covers everything reachable from Flutter. It is NOT a substitute for
/// OS-level lockdown (Windows Assigned Access / a dedicated kiosk user
/// account, or Android's Device Owner + Lock Task Mode): those stop a user
/// from getting to the Windows desktop or Android home screen at all, which
/// no in-app code can guarantee. Configure that once, on the physical
/// terminal, alongside this.
Future<void> enableKioskMode() async {
  if (kIsWeb) return;

  try {
    await WakelockPlus.enable();
  } catch (_) {
    // Not supported on this platform — non-fatal for a kiosk still under test.
  }

  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      fullScreen: true,
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: Color(0xFF14110D),
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setFullScreen(true);
      await windowManager.setResizable(false);
      // Intercepted by StaffExitGate, which asks for the staff PIN instead
      // of letting Alt+F4 / the title bar's X close the kiosk outright.
      await windowManager.setPreventClose(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

/// Leaves kiosk mode after the staff PIN has been confirmed.
Future<void> exitKioskMode() async {
  if (kIsWeb) return;
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemNavigator.pop();
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }
}
