import 'package:cloud_functions/cloud_functions.dart';

/// Creates a Stripe PaymentIntent for [amountCents] via the shared
/// `createPaymentIntent` Cloud Function (see
/// click_collect_app/functions/index.js — the borne uses the exact same
/// function as the app, same Stripe account) and returns its client secret.
Future<String> fetchPaymentIntentClientSecret({
  required int amountCents,
  String currency = 'eur',
}) async {
  final result = await FirebaseFunctions.instance.httpsCallable('createPaymentIntent').call<Map<String, dynamic>>({
    'amountCents': amountCents,
    'currency': currency,
  });
  return result.data['clientSecret'] as String;
}
