import 'package:flutter/material.dart';

import '../data/kiosk_config.dart';
import '../data/menu_data.dart';
import '../theme/app_theme.dart';
import 'order_type_screen.dart';
import 'staff/staff_panel_screen.dart';
import 'staff/staff_pin_dialog.dart';

/// The idle screen a kiosk shows between customers. Tapping anywhere starts
/// an order; a long-press on the footer is the hidden entry point for staff.
class AttractScreen extends StatelessWidget {
  const AttractScreen({super.key});

  Future<void> _openStaffAccess(BuildContext context) async {
    final ok = await showStaffPinDialog(context);
    if (ok == true && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffPanelScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderTypeScreen()),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.charcoalSoft,
                                border: Border.all(color: AppColors.orange, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.orangeDark.withValues(alpha: 0.28),
                                    blurRadius: 32,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const ClipOval(
                                child: Image(image: AssetImage('assets/images/logo.jpg'), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Text(
                              restaurantName,
                              style: textTheme.displayLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              restaurantTagline,
                              style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 56),
                            _PulsingCta(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: GestureDetector(
                  onLongPress: () => _openStaffAccess(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      KioskConfig.restaurantLocationName,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.creamMuted.withValues(alpha: 0.35)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingCta extends StatefulWidget {
  @override
  State<_PulsingCta> createState() => _PulsingCtaState();
}

class _PulsingCtaState extends State<_PulsingCta> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // A one-shot entrance fade — not a repeating pulse, so it doesn't keep
    // ticking (and burning a little CPU) for as long as this screen stays
    // in the navigation stack underneath the rest of the order flow.
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.55, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_outlined, color: AppColors.charcoal),
            const SizedBox(width: 12),
            Text(
              'Touchez l\'écran pour commander',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }
}
