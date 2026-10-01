import 'package:flutter/material.dart';

import '../data/kiosk_config.dart';
import '../data/menu_data.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'order_type_screen.dart';
import 'staff/staff_panel_screen.dart';
import 'staff/staff_pin_dialog.dart';

/// L'écran de veille de la borne, entre deux clients : grande photo qui
/// "respire", la marque, deux plats mis en avant et l'invitation à toucher
/// l'écran. Un appui long sur l'adresse (en bas) ouvre l'espace équipe.
class AttractScreen extends StatelessWidget {
  const AttractScreen({super.key});

  Future<void> _openStaffAccess(BuildContext context) async {
    final ok = await showStaffPinDialog(context);
    if (ok == true && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const StaffPanelScreen()),
      );
    }
  }

  void _start(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderTypeScreen()));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 1000;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _start(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BreathingPhoto(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.charcoal.withValues(alpha: 0.95),
                    AppColors.charcoal.withValues(alpha: 0.75),
                    AppColors.charcoal.withValues(alpha: 0.25),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(56, 40, 56, 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FadeSlideIn(child: BrandSeal(size: 120)),
                            const SizedBox(height: 32),
                            const FadeSlideIn(
                              index: 1,
                              child: Eyebrow('Rôtisserie artisanale · Artix', color: AppColors.honey),
                            ),
                            const SizedBox(height: 14),
                            FadeSlideIn(
                              index: 2,
                              child: Text(
                                restaurantName,
                                style: textTheme.displayLarge?.copyWith(fontSize: wide ? 76 : 56, letterSpacing: -1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              index: 3,
                              child: Text(
                                restaurantTagline,
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.creamMuted,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 44),
                            const FadeSlideIn(index: 4, child: _PulsingCta()),
                          ],
                        ),
                      ),
                    ),
                    if (wide) ...[
                      const SizedBox(width: 40),
                      const Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeSlideIn(
                              index: 3,
                              offset: 40,
                              child: _DishCard(
                                image: 'assets/images/tasty_cheddar.jpg',
                                tag: 'Nouveau',
                                title: 'Crousty Cheddar',
                                price: 'dès 8,50 €',
                                angle: -0.03,
                              ),
                            ),
                            SizedBox(height: 24),
                            FadeSlideIn(
                              index: 5,
                              offset: 40,
                              child: _DishCard(
                                image: 'assets/images/tajine.jpg',
                                tag: 'Le mercredi',
                                title: 'Tajine',
                                price: '11,50 €',
                                angle: 0.025,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(
                child: GestureDetector(
                  onLongPress: () => _openStaffAccess(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      KioskConfig.restaurantAddress,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.creamMuted.withValues(alpha: 0.45)),
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

/// La photo de fond, qui zoome très lentement d'avant en arrière.
class _BreathingPhoto extends StatefulWidget {
  const _BreathingPhoto();

  @override
  State<_BreathingPhoto> createState() => _BreathingPhotoState();
}

class _BreathingPhotoState extends State<_BreathingPhoto> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 18));

  @override
  void initState() {
    super.initState();
    if (KioskConfig.ambientAnimations) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: 1.0 + 0.08 * Curves.easeInOut.transform(_controller.value),
        alignment: const Alignment(0.4, 0.2),
        child: child,
      ),
      child: Image.asset('assets/images/fond.jpg', fit: BoxFit.cover, alignment: const Alignment(0, 0.25)),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.image,
    required this.tag,
    required this.title,
    required this.price,
    required this.angle,
  });

  final String image;
  final String tag;
  final String title;
  final String price;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Transform.rotate(
      angle: angle,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.glassBorder, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 40, offset: const Offset(0, 20))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl - 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.charcoal.withValues(alpha: 0.9)],
                    stops: const [0.4, 1],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.honey, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(tag.toUpperCase(), style: textTheme.labelSmall?.copyWith(color: AppColors.charcoal)),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Row(
                  children: [
                    Expanded(child: Text(title, style: textTheme.headlineSmall)),
                    Text(price, style: textTheme.titleLarge?.copyWith(color: AppColors.orange)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingCta extends StatefulWidget {
  const _PulsingCta();

  @override
  State<_PulsingCta> createState() => _PulsingCtaState();
}

class _PulsingCtaState extends State<_PulsingCta> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    if (KioskConfig.ambientAnimations) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFAD5C), AppColors.orange, Color(0xFFE06D27)]),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35 + 0.3 * t),
                blurRadius: 24 + 26 * t,
                spreadRadius: 2 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app_rounded, color: AppColors.charcoal, size: 30),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              'Touchez l\'écran pour commander',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
