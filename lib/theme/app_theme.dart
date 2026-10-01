import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/ui.dart';

/// "Feu de Bois" — le système de design de Les Poulets de Mamie, version
/// grand écran tactile (borne / terminal). Mêmes couleurs que l'application
/// mobile (click_collect_app/lib/theme/app_theme.dart) pour que la marque se
/// lise pareil partout ; tailles de texte et zones tactiles agrandies car
/// l'écran est utilisé debout, à bout de bras, parfois à travers une vitre.
///
/// L'idée : la chaleur d'une rôtisserie le soir. Un fond photo flouté (la
/// table, le poulet doré) sur lequel flottent des surfaces de "verre fumé",
/// une couleur braise reprise du logo pour l'action, et un or miel réservé à
/// la fidélité. Les noms historiques des jetons (`orange`, `charcoal`…) sont
/// conservés pour que tout l'existant compile ; seules les valeurs et les
/// nouveaux jetons (`honey`, `glass`…) changent.
class AppColors {
  // --- Accents ---
  /// Braise — la couleur d'action (CTA, onglet actif, prix). Reprise du logo.
  /// Texte posé dessus : toujours [charcoal] (≈ 8:1).
  static const orange = Color(0xFFF28C38);

  /// Braise appuyée / ombre chaude derrière les CTA.
  static const orangeDark = Color(0xFFB9541A);

  /// Terre cuite — accent secondaire, dégradés.
  static const secondary = Color(0xFFA8492A);

  /// Or miel — réservé à la fidélité (points, récompenses, badges).
  static const honey = Color(0xFFF6C35B);

  /// Alias historique de [honey] pour le système de badges.
  static const badgeAmber = honey;

  // --- Fonds & surfaces ---
  /// Encre fumée — fond de base, et texte sur braise/miel.
  static const charcoal = Color(0xFF120D09);

  /// Surface pleine niveau 1 (rarement utilisée seule : préférer [glass]).
  static const charcoalSoft = Color(0xFF1E1711);

  /// Surface pleine niveau 2 — feuilles modales, dialogues.
  static const surfaceAlt = Color(0xFF2A2019);

  /// Verre fumé : carte posée sur le fond photo flouté.
  static const glass = Color(0xA6150F0B);

  /// Verre plus opaque : barres de navigation, éléments très lus.
  static const glassStrong = Color(0xD9150F0B);

  /// Liseré clair du verre (bord supérieur qui "accroche" la lumière).
  static const glassBorder = Color(0x24FFE9D2);

  // --- Texte ---
  static const cream = Color(0xFFFFF4E6);
  static const creamMuted = Color(0xFFD3C3B0);

  // --- Statuts ---
  static const red = Color(0xFFFF6E61);
  static const green = Color(0xFF72D28F);

  // --- Structure ---
  static const divider = Color(0x1AFFF4E6);
  static const overlayScrim = Color(0x99000000);
}

/// Échelle de rayons — rectangles francs, pilules réservées aux étiquettes.
class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 26.0;
  static const xxl = 32.0;
  static const pill = 999.0;
}

/// Durées d'animation partagées.
/// Hauteur minimale d'une commande tactile principale sur la borne.
const kKioskTapHeight = 64.0;

/// Le glisser à la souris fait défiler les listes aussi (terminal Windows
/// utilisé à la souris ou au pavé tactile, pas seulement au doigt).
class KioskScrollBehavior extends MaterialScrollBehavior {
  const KioskScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

class AppMotion {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 600);
  static const curve = Curves.easeOutCubic;
}

ThemeData buildKioskTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
      primary: AppColors.orange,
      onPrimary: AppColors.charcoal,
      secondary: AppColors.honey,
      onSecondary: AppColors.charcoal,
      surface: AppColors.charcoal,
      onSurface: AppColors.cream,
      surfaceContainerHighest: AppColors.surfaceAlt,
      error: AppColors.red,
      onError: AppColors.charcoal,
    ),
    // Transparent : chaque page est peinte par-dessus [AppBackdrop], que la
    // transition de page ci-dessous glisse sous chaque route.
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: AppColors.charcoal,
  );

  // Fraunces (serif chaleureux, "fait maison") pour les titres ; Plus
  // Jakarta Sans (grotesque ronde et nette) pour tout ce qui se lit vite.
  final display = GoogleFonts.frauncesTextTheme(base.textTheme);
  final body = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, height: 1.0),
    displayMedium: display.displayMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, height: 1.0),
    displaySmall: display.displaySmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700),
    headlineLarge: display.headlineLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, height: 1.1, fontSize: 42),
    headlineMedium: display.headlineMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, height: 1.15, fontSize: 32),
    headlineSmall: display.headlineSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, fontSize: 26),
    titleLarge: display.titleLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, fontSize: 23),
    titleMedium: body.titleMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, fontSize: 18),
    titleSmall: body.titleSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, fontSize: 16),
    bodyLarge: body.bodyLarge?.copyWith(color: AppColors.cream, height: 1.4, fontSize: 17),
    bodyMedium: body.bodyMedium?.copyWith(color: AppColors.creamMuted, height: 1.45, fontSize: 15),
    bodySmall: body.bodySmall?.copyWith(color: AppColors.creamMuted, height: 1.4, fontSize: 13.5),
    labelLarge: body.labelLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, letterSpacing: 0.2, fontSize: 16),
    labelMedium: body.labelMedium?.copyWith(color: AppColors.creamMuted, fontWeight: FontWeight.w600, fontSize: 14),
    labelSmall: body.labelSmall?.copyWith(color: AppColors.creamMuted, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 12),
  );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: const BorderSide(color: AppColors.glassBorder),
  );

  return base.copyWith(
    textTheme: textTheme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: BackdropPageTransitionsBuilder(),
        TargetPlatform.iOS: BackdropPageTransitionsBuilder(),
        TargetPlatform.windows: BackdropPageTransitionsBuilder(),
        TargetPlatform.macOS: BackdropPageTransitionsBuilder(),
        TargetPlatform.linux: BackdropPageTransitionsBuilder(),
        TargetPlatform.fuchsia: BackdropPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineSmall,
      toolbarHeight: 76,
      iconTheme: const IconThemeData(color: AppColors.cream, size: 28),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glass,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      labelStyle: const TextStyle(color: AppColors.creamMuted),
      floatingLabelStyle: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: AppColors.creamMuted.withValues(alpha: 0.6)),
      prefixIconColor: AppColors.creamMuted,
      errorStyle: const TextStyle(color: AppColors.red),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: AppColors.orange, width: 1.6)),
      errorBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: AppColors.red, width: 1.2)),
      focusedErrorBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: AppColors.red, width: 1.6)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.orange : Colors.transparent,
      ),
      side: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.6), width: 1.4),
      checkColor: const WidgetStatePropertyAll(AppColors.charcoal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orange,
      linearTrackColor: AppColors.glassBorder,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceAlt,
      modalBackgroundColor: AppColors.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: AppColors.overlayScrim,
      showDragHandle: true,
      dragHandleColor: AppColors.glassBorder,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cream,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.w600),
      actionTextColor: AppColors.orangeDark,
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.glass,
      selectedColor: AppColors.orange,
      side: const BorderSide(color: AppColors.glassBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      labelStyle: textTheme.labelLarge,
      showCheckmark: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.charcoal,
        disabledBackgroundColor: AppColors.glass,
        disabledForegroundColor: AppColors.creamMuted.withValues(alpha: 0.45),
        minimumSize: const Size.fromHeight(kKioskTapHeight),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: textTheme.labelLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.orange,
        minimumSize: const Size(0, 56),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        backgroundColor: AppColors.glass,
        minimumSize: const Size(0, kKioskTapHeight),
        side: const BorderSide(color: AppColors.glassBorder),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.surfaceAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
  );
}
