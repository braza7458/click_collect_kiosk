import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Braise Dorée" design system — ported from the Les Poulets de Mamie
/// mobile app so the kiosk reads as the same brand. Component sizing is
/// tuned for a large touchscreen viewed from arm's length (bigger tap
/// targets, bigger type) rather than a phone.
class AppColors {
  static const orange = Color(0xFFC9A227);
  static const orangeDark = Color(0xFF8C6B14);
  static const secondary = Color(0xFF9C5A34);
  static const badgeAmber = Color(0xFFD4A24E);

  static const charcoal = Color(0xFF14110D);
  static const charcoalSoft = Color(0xFF1E1912);
  static const surfaceAlt = Color(0xFF2A2318);

  static const cream = Color(0xFFF3ECE0);
  static const creamMuted = Color(0xFFB8AFA0);

  static const red = Color(0xFFE0605A);
  static const green = Color(0xFF5C9F6E);

  static const divider = Color(0x14F3ECE0);
  static const overlayScrim = Color(0x73000000);
}

class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 28.0;
  static const pill = 999.0;
}

/// Minimum touch-target height for primary kiosk controls — larger than a
/// phone's 48dp minimum because the screen is used from a standing position,
/// often through a protective glass overlay.
const kKioskTapHeight = 64.0;

ThemeData buildKioskTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
      primary: AppColors.orange,
      onPrimary: AppColors.charcoal,
      secondary: AppColors.secondary,
      onSecondary: AppColors.cream,
      surface: AppColors.charcoal,
      onSurface: AppColors.cream,
      surfaceContainerHighest: AppColors.surfaceAlt,
      error: AppColors.red,
      onError: AppColors.charcoal,
    ),
    scaffoldBackgroundColor: AppColors.charcoal,
  );

  final display = GoogleFonts.frauncesTextTheme(base.textTheme);
  final body = GoogleFonts.interTextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    displayMedium: display.displayMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    headlineLarge: display.headlineLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, fontSize: 40),
    headlineMedium: display.headlineMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, fontSize: 30),
    headlineSmall: display.headlineSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w500, fontSize: 24),
    titleLarge: display.titleLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w500, letterSpacing: 0.2, fontSize: 22),
    titleMedium: body.titleMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, fontSize: 18),
    titleSmall: body.titleSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    bodyLarge: body.bodyLarge?.copyWith(color: AppColors.cream, fontSize: 17),
    bodyMedium: body.bodyMedium?.copyWith(color: AppColors.creamMuted, fontSize: 15),
    bodySmall: body.bodySmall?.copyWith(color: AppColors.creamMuted),
    labelLarge: body.labelLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, letterSpacing: 0.4, fontSize: 16),
  );

  final outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide.none,
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.cream, size: 28),
      titleTextStyle: textTheme.headlineSmall,
      toolbarHeight: 72,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.charcoalSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      labelStyle: const TextStyle(color: AppColors.creamMuted, fontSize: 17),
      hintStyle: TextStyle(color: AppColors.creamMuted.withValues(alpha: 0.6)),
      errorStyle: const TextStyle(color: AppColors.red),
      border: outlineBorder,
      enabledBorder: outlineBorder.copyWith(
        borderSide: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.2)),
      ),
      focusedBorder: outlineBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.orange, width: 2),
      ),
      errorBorder: outlineBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.red, width: 1.2),
      ),
      focusedErrorBorder: outlineBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.red, width: 2),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.orange;
        return Colors.transparent;
      }),
      side: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.6), width: 1.4),
      checkColor: const WidgetStatePropertyAll(AppColors.charcoal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orange,
      linearTrackColor: AppColors.charcoalSoft,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceAlt,
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceAlt,
      modalBackgroundColor: AppColors.surfaceAlt,
      modalBarrierColor: AppColors.overlayScrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: const TextStyle(color: AppColors.cream, fontSize: 16),
      actionTextColor: AppColors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.charcoal,
        disabledBackgroundColor: AppColors.charcoalSoft,
        disabledForegroundColor: AppColors.creamMuted.withValues(alpha: 0.5),
        minimumSize: const Size.fromHeight(kKioskTapHeight),
        elevation: 4,
        shadowColor: AppColors.orangeDark.withValues(alpha: 0.22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size(0, 56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size(0, kKioskTapHeight),
        side: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.35)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    ),
  );
}
