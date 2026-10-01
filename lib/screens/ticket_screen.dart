import 'dart:async';

import 'package:flutter/material.dart';

import '../data/kiosk_config.dart';
import '../models/ticket.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

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
    final total = KioskConfig.ticketDisplayDuration.inSeconds;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.elasticOut,
                          builder: (context, t, child) => Transform.scale(scale: 0.4 + 0.6 * t, child: child),
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.green,
                              boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.5), blurRadius: 40)],
                            ),
                            child: const Icon(Icons.check_rounded, color: AppColors.charcoal, size: 56),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeSlideIn(index: 1, child: Text('Commande enregistrée', style: textTheme.headlineLarge)),
                        const SizedBox(height: 28),
                        FadeSlideIn(
                          index: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 26),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.xxl),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFD98A), AppColors.honey, AppColors.orange],
                              ),
                              boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.45), blurRadius: 50)],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'VOTRE NUMÉRO',
                                  style: textTheme.labelLarge?.copyWith(color: AppColors.charcoal, letterSpacing: 3),
                                ),
                                Text(
                                  '${ticket.number}',
                                  style: textTheme.displayLarge?.copyWith(color: AppColors.charcoal, fontSize: 120, height: 1.05),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FadeSlideIn(
                          index: 3,
                          child: Text(
                            ticket.paid
                                ? 'Merci, votre paiement a bien été reçu !\nPrésentez ce numéro au comptoir.'
                                : 'Rendez-vous en caisse pour régler votre commande\nen indiquant ce numéro.',
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                        if (ticket.customerName != null) ...[
                          const SizedBox(height: 14),
                          StatusPill(
                            label: '${ticket.customerName} : +${ticket.pointsEarned} points'
                                '${ticket.pointsBalance != null ? ' · solde ${ticket.pointsBalance} pts' : ''}'
                                '${ticket.appliedRewardLabel != null ? ' · ${ticket.appliedRewardLabel} offert' : ''}',
                            color: AppColors.honey,
                            icon: Icons.workspace_premium_rounded,
                          ),
                        ],
                        if (ticket.customerPhone != null) ...[
                          const SizedBox(height: 12),
                          StatusPill(
                            label: 'SMS envoyé au ${ticket.customerPhone} quand ce sera prêt',
                            color: AppColors.honey,
                            icon: Icons.sms_rounded,
                          ),
                        ],
                        const SizedBox(height: 36),
                        SizedBox(
                          width: 360,
                          child: GlowButton(label: 'Terminer', onPressed: _returnToStart),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                value: (_secondsLeft / total).clamp(0.0, 1.0),
                                strokeWidth: 3,
                                backgroundColor: AppColors.glassBorder,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Retour automatique dans $_secondsLeft s', style: textTheme.bodyMedium),
                          ],
                        ),
                      ],
                    ),
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
