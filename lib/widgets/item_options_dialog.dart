import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_line.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import 'menu_icons.dart';
import 'ui.dart';

Future<void> showItemOptionsDialog(BuildContext context, MenuItem item, {IconIdentifier? category}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: _ItemOptionsContent(item: item, category: category),
      ),
    ),
  );
}

class _ItemOptionsContent extends StatefulWidget {
  const _ItemOptionsContent({required this.item, this.category});

  final MenuItem item;

  /// Catégorie du plat (pour choisir sa photo) — voir menu_icons.dart.
  final IconIdentifier? category;

  @override
  State<_ItemOptionsContent> createState() => _ItemOptionsContentState();
}

class _ItemOptionsContentState extends State<_ItemOptionsContent> {
  int _sizeIndex = 0;
  final Set<String> _selectedSupplements = {};
  int _quantity = 1;

  double get _basePrice => widget.item.hasSizes ? widget.item.sizes[_sizeIndex].price : (widget.item.price ?? 0);

  List<CartSupplement> _supplements(List<MenuItem> bowlSupplements) => bowlSupplements
      .where((s) => _selectedSupplements.contains(s.name))
      .map((s) => CartSupplement(name: s.name, price: s.price!))
      .toList();

  double _unitTotal(List<MenuItem> bowlSupplements) =>
      _basePrice + _supplements(bowlSupplements).fold(0.0, (sum, s) => sum + s.price);
  double _total(List<MenuItem> bowlSupplements) => _unitTotal(bowlSupplements) * _quantity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    final bowlSupplements = KioskStateScope.of(context).bowlSupplements;
    final image = menuItemImage(item.name);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (image != null)
          SizedBox(
            // Plus basse sur les petits écrans, pour laisser la place au bouton.
            height: (MediaQuery.sizeOf(context).height * 0.25).clamp(90.0, 200.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(image, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.surfaceAlt.withValues(alpha: 0.95)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(28, image != null ? 0 : 24, 16, 0),
          child: Row(
            children: [
              Expanded(child: Text(item.name, style: textTheme.headlineMedium)),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.cream),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        if (item.note != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 2, 28, 0),
            child: Text(item.note!, style: textTheme.bodyLarge?.copyWith(color: AppColors.creamMuted)),
          ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.hasSizes) ...[
                  const Eyebrow('Taille'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < item.sizes.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _BigOption(
                            title: 'Taille ${item.sizes[i].label}',
                            subtitle: formatPrice(item.sizes[i].price),
                            selected: _sizeIndex == i,
                            onTap: () => setState(() => _sizeIndex = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),
                ],
                if (item.allowsSupplements && bowlSupplements.isNotEmpty) ...[
                  const Eyebrow('Suppléments'),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3.2,
                    children: [
                      for (final s in bowlSupplements)
                        _BigOption(
                          title: s.name,
                          subtitle: s.priceLabel,
                          image: menuItemImage(s.name),
                          selected: _selectedSupplements.contains(s.name),
                          check: true,
                          onTap: () => setState(() {
                            if (!_selectedSupplements.remove(s.name)) _selectedSupplements.add(s.name);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                ],
                Row(
                  children: [
                    const Expanded(child: Eyebrow('Quantité')),
                    _QtyButton(icon: Icons.remove_rounded, onTap: _quantity > 1 ? () => setState(() => _quantity--) : null),
                    SizedBox(width: 56, child: Text('$_quantity', textAlign: TextAlign.center, style: textTheme.headlineMedium)),
                    _QtyButton(icon: Icons.add_rounded, onTap: () => setState(() => _quantity++)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
          child: GlowButton(
            icon: Icons.add_shopping_cart_rounded,
            label: item.isOrderable ? 'Ajouter · ${formatPrice(_total(bowlSupplements))}' : 'Bientôt disponible',
            onPressed: !item.isOrderable
                ? null
                : () {
                    KioskStateScope.of(context).addToCart(
                      CartLine(
                        itemName: item.name,
                        sizeLabel: item.hasSizes ? item.sizes[_sizeIndex].label : null,
                        unitPrice: _basePrice,
                        supplements: _supplements(bowlSupplements),
                        quantity: _quantity,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
          ),
        ),
      ],
    );
  }
}

class _BigOption extends StatelessWidget {
  const _BigOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.check = false,
    this.image,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool check;

  /// Petite photo à gauche (suppléments).
  final String? image;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: selected ? AppColors.orange.withValues(alpha: 0.16) : AppColors.glass,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.orange : AppColors.glassBorder, width: selected ? 2 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  if (image != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.asset(image!, width: 44, height: 44, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (check) ...[
                    Icon(
                      selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: selected ? AppColors.orange : AppColors.creamMuted,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: check ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(color: selected ? AppColors.orange : AppColors.cream),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(subtitle, style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return IconButton(
      onPressed: onTap,
      iconSize: 28,
      style: IconButton.styleFrom(
        fixedSize: const Size(56, 56),
        backgroundColor: enabled ? AppColors.glass : Colors.transparent,
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      icon: Icon(icon, color: enabled ? AppColors.cream : AppColors.creamMuted.withValues(alpha: 0.4)),
    );
  }
}
