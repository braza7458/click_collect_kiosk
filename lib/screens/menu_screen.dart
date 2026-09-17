import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_line.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import '../widgets/item_options_dialog.dart';
import '../widgets/menu_icons.dart';
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
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Continuer ma commande')),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelOrder(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Flexible(
                child: Text('La carte', style: textTheme.headlineSmall, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(kioskState.mode?.icon ?? Icons.storefront_outlined, size: 16, color: AppColors.orange),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          kioskState.mode?.label ?? '',
                          style: textTheme.labelLarge?.copyWith(color: AppColors.orange, letterSpacing: 0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _cancelOrder(context),
              child: const Text('Annuler la commande', style: TextStyle(color: AppColors.red)),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          top: false,
          child: kioskState.menuCategories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CategoryRail(
                      categories: kioskState.menuCategories,
                      selected: _selectedCategory.clamp(0, kioskState.menuCategories.length - 1),
                      onSelected: (i) => setState(() => _selectedCategory = i),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _ItemGrid(
                        category: kioskState
                            .menuCategories[_selectedCategory.clamp(0, kioskState.menuCategories.length - 1)],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    const SizedBox(width: 380, child: _CartPanel()),
                  ],
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
    return SizedBox(
      width: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final category = categories[i];
          final isSelected = i == selected;
          return InkWell(
            onTap: () => onSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceAlt : Colors.transparent,
                border: Border(left: BorderSide(color: isSelected ? AppColors.orange : Colors.transparent, width: 4)),
              ),
              child: Row(
                children: [
                  Icon(category.icon.icon, size: 22, color: isSelected ? AppColors.orange : AppColors.creamMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: isSelected ? AppColors.cream : AppColors.creamMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({required this.category});

  final MenuCategory category;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.92,
      ),
      itemCount: category.items.length,
      itemBuilder: (context, i) => _ItemCard(item: category.items[i]),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Opacity(
        opacity: item.isOrderable ? 1 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.restaurant_outlined, color: AppColors.orange, size: 26),
            ),
            const Spacer(),
            Text(item.name, style: textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (item.note != null) ...[
              const SizedBox(height: 4),
              Text(item.note!, style: textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.priceLabel,
                    style: textTheme.titleSmall?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w700),
                  ),
                ),
                if (item.isOrderable) const Icon(Icons.add_circle_outline, color: AppColors.orange, size: 22),
              ],
            ),
          ],
        ),
      ),
    );

    if (!item.isOrderable) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => showItemOptionsDialog(context, item),
      child: content,
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
      color: AppColors.charcoalSoft,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.orange),
                const SizedBox(width: 10),
                Text('Ma commande', style: textTheme.titleLarge),
              ],
            ),
          ),
          Expanded(
            child: kioskState.cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Touchez un plat pour l\'ajouter',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: kioskState.cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _CartLineTile(line: kioskState.cart[i]),
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Total', style: textTheme.titleLarge)),
                    Text(formatPrice(kioskState.cartTotal), style: textTheme.headlineSmall?.copyWith(color: AppColors.orange)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: kioskState.cart.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            ),
                    child: const Text('Valider ma commande'),
                  ),
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
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.sizeLabel != null ? '${line.itemName} (${line.sizeLabel})' : line.itemName,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (line.supplements.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '+ ${line.supplements.map((s) => s.name).join(', ')}',
                      style: textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StepperButton(icon: Icons.remove, onTap: () => kioskState.updateQuantity(line.id, line.quantity - 1)),
                    SizedBox(width: 30, child: Text('${line.quantity}', textAlign: TextAlign.center, style: textTheme.bodyLarge)),
                    _StepperButton(icon: Icons.add, onTap: () => kioskState.updateQuantity(line.id, line.quantity + 1)),
                    const Spacer(),
                    Text(formatPrice(line.lineTotal), style: textTheme.bodyLarge?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => kioskState.removeFromCart(line.id),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: AppColors.creamMuted),
            ),
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
      color: AppColors.charcoalSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 15, color: AppColors.cream),
        ),
      ),
    );
  }
}
