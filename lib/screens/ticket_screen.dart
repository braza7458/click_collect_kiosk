import 'dart:async';

import 'package:flutter/material.dart';

import '../data/kiosk_config.dart';
import '../models/ticket.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key, required this.ticket});

  final Ticket ticket;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late int _secondsLeft = KioskConfig.ticketDisplayDuration.inSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) _returnToStart();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _returnToStart() {
    _timer?.cancel();
    KioskStateScope.of(context).resetSession();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ticket = widget.ticket;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green.withValues(alpha: 0.14)),
                        child: const Icon(Icons.check_rounded, color: AppColors.green, size: 54),
                      ),
                      const SizedBox(height: 28),
                      Text('Commande enregistrée', style: textTheme.headlineMedium),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Column(
                          children: [
                            Text('VOTRE NUMÉRO', style: textTheme.labelLarge?.copyWith(color: AppColors.charcoal)),
                            Text(
                              '${ticket.number}',
                              style: textTheme.displayLarge?.copyWith(color: AppColors.charcoal, fontSize: 72),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Rendez-vous en caisse pour régler votre commande\nen indiquant ce numéro.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _returnToStart,
                        child: const Text('Terminer'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Retour automatique dans $_secondsLeft s',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
