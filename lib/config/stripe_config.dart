/// Stripe configuration — same Stripe account as click_collect_app, so the
/// borne's card/Apple Pay/Google Pay payments land in the same place as the
/// app's.
///
/// [publishableKey] is safe to ship in client code — unlike the Stripe
/// *secret* key, which must never appear in either app and only ever lives
/// server-side (the `createPaymentIntent` Cloud Function in
/// click_collect_app/functions, shared by both apps).
class StripeConfig {
  const StripeConfig._();

  static const publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51UFoKXE4fctyB2XUgiEWHyezDh4tDztRCfdJhFMgoa4N358RUNRIzx435gyaWZhzxV2Jp2LZ9QzQCR7Gi6Oo81Wy00l0QxbaF4',
  );

  static bool get isConfigured => publishableKey.isNotEmpty;

  /// Whether [publishableKey] is a Stripe test-mode key — drives whether
  /// Google Pay asks for its test environment.
  static bool get isTestMode => publishableKey.startsWith('pk_test_');

  static const merchantCountryCode = 'FR';
}
