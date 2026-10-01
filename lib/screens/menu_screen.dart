import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_line.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import '../widgets/item_options_dialog.dart';
import '../widgets/menu_icons.dart';
import '../widgets/ui.dart';
import 'checkout_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategory = 0;

  Future<void> _cancelOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: const Text('Les articles ajoutés seront supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continuer ma commande'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      KioskStateScope.of(context).resetSession();
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kioskState = KioskStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final categories = kioskState.menuCategories;
    final selected = categories.isEmpty ? 0 : _selectedCategory.clamp(0, categories.length - 1);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelOrder(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 24,
          title: Row(
            children: [
              const BrandSeal(size: 44),
              const SizedBox(width: 14),
              Flexible(
                child: Text('La carte', style: textTheme.headlineMedium, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 16),
              if (kioskState.mode != null)
                StatusPill(label: kioskState.mode!.label, color: AppColors.orange, icon: kioskState.mode!.icon),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _cancelOrder(context),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Annuler la commande'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          top: false,
          child: categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CategoryRail(
                        categories: categories,
                        selected: selected,
                        onSelected: (i) => setState(() => _selectedCategory = i),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ItemGrid(key: ValueKey(selected), category: categories[selected]),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(width: 380, child: _CartPanel()),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.categories, required this.selected, required this.onSelected});

  final List<MenuCategory> categories;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, i) {
          final category = categories[i];
          final isSelected = i == selected;
          return AnimatedContainer(
            duration: AppMotion.medium,
            curve: AppMotion.curve,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => onSelected(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Row(
                    children: [
                      Icon(category.icon.icon, size: 24, color: isSelected ? AppColors.charcoal : AppColors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.title,
                          style: textTheme.bodyLarge?.copyWith(
                            color: isSelected ? AppColors.charcoal : AppColors.cream,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({super.key, required this.category});

  final MenuCategory category;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: category.items.length,
      itemBuilder: (context, i) => FadeSlideIn(
        index: i,
        child: _ItemCard(item: category.items[i], iconId: category.icon),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.iconId});

  final MenuItem item;
  final IconIdentifier iconId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final image = menuItemImage(item.name, category: iconId);
    return Opacity(
      opacity: item.isOrderable || item.isInfoOnly ? 1 : 0.5,
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: item.isOrderable ? () => showItemOptionsDialog(context, item, category: iconId) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // L'image prend la place restante : le texte garde sa hauteur
            // naturelle et ne déborde jamais.
            Expanded(
              child: image != null
                  ? Image.asset(image, fit: BoxFit.cover)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.orange.withValues(alpha: 0.32),
                            AppColors.secondary.withValues(alpha: 0.12),
                          ],
                        ),
                      ),
                      child: Icon(iconId.icon, color: AppColors.orange, size: 52),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.name, style: textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (item.note != null) ...[
                    const SizedBox(height: 2),
                    Text(item.note!, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.priceLabel,
                          style: textTheme.titleSmall?.copyWith(
                            color: item.isInfoOnly ? AppColors.creamMuted : AppColors.orange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (item.isOrderable)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.4), blurRadius: 12)],
                          ),
                          child: const Icon(Icons.add_rounded, color: AppColors.charcoal),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel();

  @override
  Widget build(BuildContext context) {
    final kioskState = KioskStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassStrong,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                const IconBadge(Icons.shopping_bag_rounded, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text('Ma commande', style: textTheme.titleLarge)),
                if (kioskState.cartItemCount > 0)
                  StatusPill(
                    label: '${kioskState.cartItemCount} article${kioskState.cartItemCount > 1 ? 's' : ''}',
                    color: AppColors.orange,
                  ),
              ],
            ),
          ),
          Expanded(
            child: kioskState.cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, size: 44, color: AppColors.orange.withValues(alpha: 0.7)),
                          const SizedBox(height: 12),
                          Text(
                            'Touchez un plat pour l\'ajouter',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    itemCount: kioskState.cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _CartLineTile(line: kioskState.cart[i]),
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Total', style: textTheme.titleLarge)),
                    Text(
                      formatPrice(kioskState.cartTotal),
                      style: textTheme.headlineMedium?.copyWith(color: AppColors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlowButton(
                  label: 'Valider ma commande',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: kioskState.cart.isEmpty
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final kioskState = KioskStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.charcoal.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.sizeLabel != null ? '${line.itemName} · ${line.sizeLabel}' : line.itemName,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (line.supplements.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('+ ${line.supplements.map((s) => s.name).join(', ')}', style: textTheme.bodySmall),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StepperButton(
                icon: line.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                onTap: () => kioskState.updateQuantity(line.id, line.quantity - 1),
              ),
              SizedBox(
                width: 36,
                child: Text('${line.quantity}', textAlign: TextAlign.center, style: textTheme.titleMedium),
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                onTap: () => kioskState.updateQuantity(line.id, line.quantity + 1),
              ),
              const Spacer(),
              Text(formatPrice(line.lineTotal), style: textTheme.titleMedium?.copyWith(color: AppColors.orange)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glass,
      shape: const CircleBorder(side: BorderSide(color: AppColors.glassBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.cream),
        ),
      ),
    );
  }
}
