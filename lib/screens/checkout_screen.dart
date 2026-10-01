import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/stripe_config.dart';
import '../data/menu_data.dart';
import '../data/kiosk_config.dart';
import '../services/payment_intent_service.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import '../widgets/loyalty_dialog.dart';
import '../widgets/ui.dart';
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

  Future<void> _finish({required bool paid}) async {
    final kioskState = KioskStateScope.of(context);
    kioskState.setCustomerPhone(_phoneController.text);
    final ticket = await kioskState.placeOrder(paid: paid);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TicketScreen(ticket: ticket)),
    );
  }

  /// Pays with Stripe's PaymentSheet — card, plus Apple Pay / Google Pay
  /// where the device supports them — right on the terminal, instead of at
  /// the register.
  Future<void> _payNow() async {
    if (!StripeConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement par carte indisponible — utilisez « Payer en caisse ».')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final kioskState = KioskStateScope.of(context);
      final clientSecret = await fetchPaymentIntentClientSecret(
        amountCents: (kioskState.cartTotal * 100).round(),
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: KioskConfig.restaurantLocationName,
          // PAS de paramètre applePay : il exige un Apple merchantIdentifier
          // (jamais configuré, et la borne tourne sur Android) — sa seule
          // présence faisait échouer initPaymentSheet avant même d'afficher
          // le formulaire carte. Google Pay suffit sur Android.
          billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
            address: AddressCollectionMode.never,
          ),
          // Carte uniquement : pas de bouton "Pay with Link".
          linkDisplayParams: const LinkDisplayParams(linkDisplay: LinkDisplay.never),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: StripeConfig.merchantCountryCode,
            currencyCode: 'EUR',
            testEnv: StripeConfig.isTestMode,
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;
      await _finish(paid: true);
    } on StripeException catch (e) {
      if (!mounted) return;
      final message = e.error.localizedMessage ?? 'Le paiement a été annulé.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Le paiement a échoué côté serveur — réessayez.')),
      );
    } catch (e, stack) {
      // L'erreur réelle, dans les logs ET à l'écran : sans elle, impossible
      // de savoir pourquoi un paiement échoue sur la borne.
      debugPrint('Paiement borne échoué : $e');
      debugPrintStack(stackTrace: stack);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le paiement a échoué : $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kioskState = KioskStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    final recap = GlassCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Eyebrow('Votre commande')),
              StatusPill(label: kioskState.mode!.label, color: AppColors.orange, icon: kioskState.mode!.icon),
            ],
          ),
          const SizedBox(height: 16),
          ...kioskState.cart.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 34),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '${line.quantity}×',
                      textAlign: TextAlign.center,
                      style: textTheme.labelLarge?.copyWith(color: AppColors.orange),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.sizeLabel != null ? '${line.itemName} · ${line.sizeLabel}' : line.itemName,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (line.supplements.isNotEmpty)
                          Text('+ ${line.supplements.map((s) => s.name).join(', ')}', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(formatPrice(line.lineTotal), style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          if (kioskState.selectedReward != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, color: AppColors.honey, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${kioskState.selectedReward!.label} (fidélité)',
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.honey),
                    ),
                  ),
                  Text('offert', style: textTheme.bodyLarge?.copyWith(color: AppColors.honey)),
                ],
              ),
            ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('Total', style: textTheme.headlineSmall)),
              Text(
                formatPrice(kioskState.cartTotal),
                style: textTheme.displaySmall?.copyWith(color: AppColors.orange),
              ),
            ],
          ),
        ],
      ),
    );

    final payment = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LoyaltyPanel(),
        const SizedBox(height: 18),
        GlassCard(
          radius: AppRadius.xl,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconBadge(Icons.sms_rounded, color: AppColors.honey),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prévenu par SMS (facultatif)', style: textTheme.titleMedium),
                        Text('On vous envoie un SMS dès que votre commande est prête.', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: textTheme.titleLarge,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        GlowButton(
          icon: Icons.contactless_rounded,
          busy: _submitting,
          label: 'Payer ${formatPrice(kioskState.cartTotal)}',
          onPressed: _payNow,
        ),
        const SizedBox(height: 10),
        Text(
          'Carte bancaire ou Google Pay.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _submitting ? null : () => _finish(paid: false),
          icon: const Icon(Icons.point_of_sale_rounded),
          label: const Text('Payer en caisse'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.creamMuted),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Retour à la carte'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Étape 3 sur 3'),
            Text('Récapitulatif', style: textTheme.headlineSmall),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 1200 : 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: FadeSlideIn(child: recap)),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: FadeSlideIn(index: 1, child: payment)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [recap, const SizedBox(height: 24), payment],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
