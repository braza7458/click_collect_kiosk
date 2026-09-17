import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps the app and calls [onTimeout] after [timeout] of no touch/pointer
/// activity anywhere on screen — an abandoned order shouldn't sit on screen
/// for the next customer.
class InactivityGuard extends StatefulWidget {
  const InactivityGuard({
    super.key,
    required this.child,
    required this.timeout,
    required this.onTimeout,
  });

  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;

  @override
  State<InactivityGuard> createState() => _InactivityGuardState();
}

class _InactivityGuardState extends State<InactivityGuard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerSignal: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
