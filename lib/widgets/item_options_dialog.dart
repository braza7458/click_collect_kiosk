import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_line.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';

Future<void> showItemOptionsDialog(BuildContext context, MenuItem item) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surfaceAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _ItemOptionsContent(item: item),
      ),
    ),
  );
}

class _ItemOptionsContent extends StatefulWidget {
  const _ItemOptionsContent({required this.item});

  final MenuItem item;

  @override
  State<_ItemOptionsContent> createState() => _ItemOptionsContentState();
}

class _ItemOptionsContentState extends State<_ItemOptionsContent> {
  int _sizeIndex = 0;
  final Set<String> _selectedSupplements = {};
  int _quantity = 1;

  double get _basePrice =>
      widget.item.hasSizes ? widget.item.sizes[_sizeIndex].price : (widget.item.price ?? 0);

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.name, style: textTheme.headlineSmall)),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.cream),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          if (item.note != null) ...[
            const SizedBox(height: 4),
            Text(item.note!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.hasSizes) ...[
                    Text('TAILLE', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var i = 0; i < item.sizes.length; i++)
                          ChoiceChip(
                            label: Text('${item.sizes[i].label} · ${formatPrice(item.sizes[i].price)}'),
                            selected: _sizeIndex == i,
                            onSelected: (_) => setState(() => _sizeIndex = i),
                            selectedColor: AppColors.orange,
                            backgroundColor: AppColors.charcoalSoft,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                            labelStyle: textTheme.labelLarge?.copyWith(
                              color: _sizeIndex == i ? AppColors.charcoal : AppColors.cream,
                              letterSpacing: 0,
                            ),
                            side: BorderSide(color: _sizeIndex == i ? AppColors.orange : AppColors.divider),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                  ],
                  if (item.allowsSupplements) ...[
                    Text('SUPPLÉMENTS', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                    ...bowlSupplements.map((s) {
                      final selected = _selectedSupplements.contains(s.name);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (v) => setState(() {
                          if (v ?? false) {
                            _selectedSupplements.add(s.name);
                          } else {
                            _selectedSupplements.remove(s.name);
                          }
                        }),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(s.name, style: textTheme.bodyLarge),
                        secondary: Text(s.priceLabel, style: textTheme.bodyMedium?.copyWith(color: AppColors.orange)),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QUANTITÉ', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
              Row(
                children: [
                  _QtyButton(icon: Icons.remove, onTap: _quantity > 1 ? () => setState(() => _quantity--) : null),
                  SizedBox(width: 44, child: Text('$_quantity', textAlign: TextAlign.center, style: textTheme.headlineSmall)),
                  _QtyButton(icon: Icons.add, onTap: () => setState(() => _quantity++)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
              child: Text(item.isOrderable ? 'Ajouter · ${formatPrice(_total(bowlSupplements))}' : 'Bientôt disponible'),
            ),
          ),
        ],
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
    return Material(
      color: AppColors.charcoalSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 22, color: enabled ? AppColors.cream : AppColors.creamMuted.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
