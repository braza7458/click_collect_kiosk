import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Le fond de toute l'application : la photo `fond_flou.jpg` (déjà floutée
/// et assombrie à l'export — aucun flou calculé à l'exécution), un voile
/// dégradé pour la lisibilité et une lueur de braise en haut à gauche.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.charcoal),
        Image.asset(
          'assets/images/fond_flou.jpg',
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.charcoal.withValues(alpha: 0.30),
                AppColors.charcoal.withValues(alpha: 0.55),
                AppColors.charcoal.withValues(alpha: 0.90),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.9, -1.05),
              radius: 1.0,
              colors: [AppColors.orange.withValues(alpha: 0.18), AppColors.orange.withValues(alpha: 0)],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Transition de page qui glisse [AppBackdrop] sous chaque route : chaque
/// page est donc opaque (pas de "fantôme" de la page précédente pendant la
/// transition) tout en partageant le même fond photo. La nouvelle page
/// apparaît en fondu en remontant légèrement ; l'ancienne recule un peu.
class BackdropPageTransitionsBuilder extends PageTransitionsBuilder {
  const BackdropPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(parent: animation, curve: AppMotion.curve, reverseCurve: Curves.easeInCubic);
    final exit = CurvedAnimation(parent: secondaryAnimation, curve: AppMotion.curve);
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.96).animate(exit),
      child: FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.035), end: Offset.zero).animate(enter),
          child: AppBackdrop(child: child),
        ),
      ),
    );
  }
}

/// Une surface de "verre fumé" posée sur le fond photo : remplissage
/// translucide, liseré clair, reflet discret en haut, ombre douce.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = AppRadius.lg,
    this.onTap,
    this.color,
    this.gradient,
    this.borderColor,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? AppColors.glassBorder),
    );
    final content = Padding(padding: padding, child: child);
    final card = Container(
      margin: margin,
      decoration: ShapeDecoration(
        shape: shape,
        color: gradient == null ? (color ?? AppColors.glass) : null,
        gradient: gradient,
        shadows: shadow
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 28, offset: const Offset(0, 14))]
            : null,
      ),
      foregroundDecoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Colors.white.withValues(alpha: 0.045), Colors.white.withValues(alpha: 0)],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
    return onTap == null ? card : Pressable(child: card);
  }
}

/// Léger enfoncement (échelle 0,97) sous le doigt. Écoute les pointeurs sans
/// entrer dans l'arène des gestes : les InkWell/boutons enfants marchent
/// exactement comme avant.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = 0.97});

  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  Offset _origin = Offset.zero;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        _origin = e.position;
        _set(true);
      },
      // Le doigt glisse (défilement d'une liste) : on relâche tout de suite.
      onPointerMove: (e) {
        if ((e.position - _origin).distance > 8) _set(false);
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Le bouton d'action principal : dégradé braise, halo chaud, enfoncement.
class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
    this.height = kKioskTapHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: enabled ? AppColors.charcoal : AppColors.creamMuted.withValues(alpha: 0.5),
        );
    return Pressable(
      child: AnimatedContainer(
        duration: AppMotion.medium,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFAD5C), AppColors.orange, Color(0xFFE06D27)],
                )
              : null,
          color: enabled ? null : AppColors.glass,
          border: enabled ? null : Border.all(color: AppColors.glassBorder),
          boxShadow: enabled
              ? [BoxShadow(color: AppColors.orange.withValues(alpha: 0.38), blurRadius: 26, offset: const Offset(0, 10))]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.cream),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: textStyle?.color),
                          const SizedBox(width: 10),
                        ],
                        Flexible(child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Petit sur-titre en capitales espacées ("EN CE MOMENT", "VOTRE COMMANDE").
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = AppColors.orange});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, letterSpacing: 1.6),
    );
  }
}

/// Titre de section en serif, avec un lien optionnel à droite.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.eyebrow, this.actionLabel, this.onAction});

  final String title;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 4)],
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// Pastille de statut : point lumineux + libellé.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 13, color: color)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 6)],
              ),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastille ronde avec une icône — remplace les "cercles orange à 12 %".
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.color = AppColors.orange, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.10)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Apparition en fondu + légère montée, décalée selon [index] pour un
/// effet "cascade" à l'ouverture d'un écran. Une seule animation par
/// élément, sans minuterie (compatible avec les tests).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0, this.offset = 18});

  final Widget child;
  final int index;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  static const _stepMs = 60;
  static const _runMs = 420;

  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    final delay = (widget.index.clamp(0, 10)) * _stepMs;
    final total = delay + _runMs;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: total))..forward();
    _t = CurvedAnimation(parent: _controller, curve: Interval(delay / total, 1, curve: AppMotion.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(offset: Offset(0, (1 - _t.value) * widget.offset), child: child),
      ),
    );
  }
}

/// Nombre qui "compte" jusqu'à sa valeur (points de fidélité…).
class CountUpText extends StatelessWidget {
  const CountUpText(this.value, {super.key, this.style});

  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}

/// Le logo dans un anneau braise → miel, avec un halo chaud.
class BrandSeal extends StatelessWidget {
  const BrandSeal({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.035),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [AppColors.honey, AppColors.orange, AppColors.orangeDark, AppColors.orange, AppColors.honey],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.orange.withValues(alpha: 0.45), blurRadius: size * 0.45, spreadRadius: 1),
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(size * 0.03),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.charcoal),
        child: const ClipOval(
          child: Image(image: AssetImage('assets/images/logo.jpg'), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// État vide illustré (panier vide, aucune commande…).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glass,
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.18), blurRadius: 40)],
          ),
          child: Icon(icon, size: 38, color: AppColors.orange),
        ),
        const SizedBox(height: 18),
        Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(message!, style: textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
        if (action != null) ...[const SizedBox(height: 22), action!],
      ],
    );
  }
}
