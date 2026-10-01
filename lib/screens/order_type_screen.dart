import 'package:flutter/material.dart';

import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
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
        top: false,
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
                      const FadeSlideIn(child: Eyebrow('Étape 1 sur 3')),
                      const SizedBox(height: 10),
                      FadeSlideIn(
                        index: 1,
                        child: Text(
                          'Sur place ou à emporter ?',
                          style: textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 28,
                        runSpacing: 28,
                        children: [
                          for (final mode in OrderMode.values)
                            FadeSlideIn(
                              index: 2 + mode.index,
                              offset: 30,
                              child: _ModeCard(mode: mode, onTap: () => _choose(context, mode)),
                            ),
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
    return SizedBox(
      width: 320,
      child: GlassCard(
        onTap: onTap,
        radius: AppRadius.xxl,
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 28),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFAD5C), AppColors.orange, AppColors.orangeDark],
                ),
                boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.45), blurRadius: 40)],
              ),
              child: Icon(mode.icon, color: AppColors.charcoal, size: 56),
            ),
            const SizedBox(height: 26),
            Text(mode.label, style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(mode.description, style: textTheme.bodyLarge?.copyWith(color: AppColors.creamMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
