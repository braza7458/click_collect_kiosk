/// A kiosk is a physical terminal installed inside one specific restaurant —
/// unlike the mobile app, it never needs to ask "which restaurant?". Point
/// this at the right location when installing a terminal.
class KioskConfig {
  static const restaurantLocationName = 'Les Poulets de Mamie — Centre Ville';
  static const restaurantAddress = '12 Rue de la République';

  /// Idle time before an abandoned order is cleared and the kiosk returns to
  /// the attract screen.
  static const inactivityTimeout = Duration(seconds: 90);

  /// How long the "commande enregistrée" ticket screen stays up before
  /// auto-returning to the attract screen.
  static const ticketDisplayDuration = Duration(seconds: 20);

  /// PIN staff enter (via a hidden long-press on the footer) to leave kiosk
  /// mode or view today's order log. Change before deploying a terminal.
  static const staffPin = '1957';
}
