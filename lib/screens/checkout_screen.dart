import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import 'ticket_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _submitting = true);
    final kioskState = KioskStateScope.of(context);
    kioskState.setCustomerPhone(_phoneController.text);
    final ticket = await kioskState.placeOrder();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TicketScreen(ticket: ticket)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kioskState = KioskStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Récapitulatif')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalSoft,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(kioskState.mode!.icon, color: AppColors.orange),
                            const SizedBox(width: 10),
                            Text(kioskState.mode!.label, style: textTheme.titleLarge),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        ...kioskState.cart.map(
                          (line) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${line.quantity} ×', style: textTheme.bodyLarge?.copyWith(color: AppColors.creamMuted)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        line.sizeLabel != null ? '${line.itemName} (${line.sizeLabel})' : line.itemName,
                                        style: textTheme.bodyLarge,
                                      ),
                                      if (line.supplements.isNotEmpty)
                                        Text(
                                          '+ ${line.supplements.map((s) => s.name).join(', ')}',
                                          style: textTheme.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                                Text(formatPrice(line.lineTotal), style: textTheme.bodyLarge),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text('Total', style: textTheme.headlineSmall)),
                            Text(formatPrice(kioskState.cartTotal), style: textTheme.headlineSmall?.copyWith(color: AppColors.orange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: const Border(left: BorderSide(color: AppColors.orange, width: 3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.orange, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Le paiement se fait en caisse, en indiquant votre numéro de commande.',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Programme fidélité (facultatif)', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Indiquez votre numéro de téléphone pour rattacher cette commande à votre compte fidélité.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.cream),
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitting ? null : () => _confirm(context),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.charcoal),
                          )
                        : const Text('Confirmer ma commande'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Retour à la carte'),
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
