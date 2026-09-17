import 'package:flutter/material.dart';

import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import 'menu_screen.dart';

class OrderTypeScreen extends StatelessWidget {
  const OrderTypeScreen({super.key});

  void _choose(BuildContext context, OrderMode mode) {
    KioskStateScope.of(context).setMode(mode);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MenuScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Annuler',
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Comment souhaitez-vous être servi ?', style: textTheme.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final mode in OrderMode.values) ...[
                            _ModeCard(mode: mode, onTap: () => _choose(context, mode)),
                            if (mode != OrderMode.values.last) const SizedBox(width: 24),
                          ],
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
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});

  final OrderMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.charcoalSoft,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(mode.icon, color: AppColors.orange, size: 40),
            ),
            const SizedBox(height: 20),
            Text(mode.label, style: textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(mode.description, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
