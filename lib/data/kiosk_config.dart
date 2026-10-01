/// A kiosk is a physical terminal installed inside one specific restaurant —
/// unlike the mobile app, it never needs to ask "which restaurant?". Point
/// this at the right location when installing a terminal.
class KioskConfig {
  static const restaurantLocationName = 'Les Poulets de Mamie';
  static const restaurantAddress = '250 Rue du Galupe, 64170 Artix';
  static const restaurantPhone = '07 61 85 18 31';

  /// Idle time before an abandoned order is cleared and the kiosk returns to
  /// the attract screen.
  static const inactivityTimeout = Duration(seconds: 90);

  /// How long the "commande enregistrée" ticket screen stays up before
  /// auto-returning to the attract screen.
  static const ticketDisplayDuration = Duration(seconds: 20);

  /// PIN staff enter (via a hidden long-press on the footer) to leave kiosk
  /// mode or view today's order log. Change before deploying a terminal.
  static const staffPin = '1957';

  /// Animations d'ambiance en boucle (zoom lent de la photo, halo du
  /// bouton) sur l'écran d'accueil. Désactivées dans les tests de widgets,
  /// où une animation infinie empêcherait `pumpAndSettle` de se terminer.
  static bool ambientAnimations = true;
}
