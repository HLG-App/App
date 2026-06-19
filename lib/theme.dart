import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Spacing tokens used across the app.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
}

/// Border radius tokens used across the app.
class AppRadius {
  // Design: buttons/inputs 0.5rem (8px), cards 0.75rem (12px).
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 24;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
}

/// Her Long Game brand colors.
///
/// Source of truth: `DESIGN.md` (v5.0, 2026-06-17).
class HLGColors {
  // Primary
  static const Color deepSage = Color(0xFF5C7A62); // Primary · CTAs · Key UI
  static const Color sage = Color(0xFF7A9279); // Secondary · Hover · Gradients
  static const Color sageMid = Color(0xFF8A9E8D); // Placeholders + muted captions ONLY

  // Accent / Neutrals
  static const Color crownGold = Color(0xFFB8923A); // Gold accent
  static const Color warmCream = Color(0xFFF7F5F0); // Primary surface
  static const Color creamWarm = Color(0xFFF2EFE8); // Input fields

  /// Soft surface tint derived from the core palette.
  ///
  /// This avoids introducing extra “mystery hex” colors while still giving
  /// cards/panels enough separation from [warmCream].
  static Color get petal => Color.lerp(warmCream, sage, 0.14)!;

  // Signal
  static const Color growth = Color(0xFF7ECFA0); // Positive indicators
  static const Color horizonOrange = Color(0xFFD4621A); // Accent only
  static const Color antiqueRose = Color(0xFFC4756A);

  // Derived / utility
  static Color get sagePale => Color.lerp(warmCream, sage, 0.22)!;

  /// Primary readable text on cream.
  static const Color textBody = deepSage;

  /// Muted captions and placeholder-like text only.
  static const Color textMuted = sageMid;

  /// Structural border/tint token (rgba(92,122,98,0.12)).
  static Color get sageTint => deepSage.withValues(alpha: 0.12);
  static const Color white = Color(0xFFFFFFFF);
}

/// Her Long Game typography.
///
/// Source of truth: `DESIGN.md` (Typography v5.0).
class HLGTextStyles {
  // Playfair Display — emotion
  static TextStyle h1Display({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: color,
  );

  static TextStyle h2Section({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: color,
  );

  static TextStyle h3SubheadItalic({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    height: 1.25,
    color: color,
  );

  /// Learn module title (Playfair Display 24pt).
  static TextStyle moduleTitle({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: color,
  );

  /// Lesson screen heading (Playfair Display 28pt).
  static TextStyle lessonHeading({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.22,
    color: color,
  );

  /// Lesson cover title (Playfair Display 36pt).
  static TextStyle lessonCoverTitle({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.12,
    color: color,
  );

  /// Lesson cover principle line (DM Sans 15pt italic).
  static TextStyle lessonPrinciple({Color? color}) => GoogleFonts.dmSans(
    fontSize: 15,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  static TextStyle quoteItalic({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: color,
  );

  // DM Sans — information
  static TextStyle body({Color? color}) => GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, height: 1.55, color: color);

  static TextStyle labelMedium({Color? color}) => GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, height: 1.35, color: color);

  /// Home: portrait card heading (Playfair Display 28pt italic).
  static TextStyle homePortraitHeading({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    height: 1.25,
    color: color,
  );

  /// Home: body text (DM Sans 14pt).
  static TextStyle homeBody14({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: color,
  );

  /// Home: small meta (DM Sans 13pt).
  static TextStyle homeMeta13({Color? color}) => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: color,
  );

  /// Home: CTA label (DM Sans 15pt medium).
  static TextStyle homeCta15({Color? color}) => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.25,
    color: color,
  );

  /// Home: reflection question (Playfair Display 20pt italic).
  static TextStyle homeReflectionQuestion({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: color,
  );

  /// Pills: lesson code (DM Sans 12pt bold).
  static TextStyle lessonCodePill({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: color,
  );

  static TextStyle uiElement({Color? color}) => GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w400, height: 1.25, color: color);

  static TextStyle eyebrowAllCaps({Color? color}) => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    height: 1.2,
    color: color ?? HLGColors.crownGold,
  );

  /// Wordmark: "Her" (Playfair Display 20pt italic).
  static TextStyle wordmarkHer({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: color ?? HLGColors.horizonOrange,
  );

  /// Wordmark: " Long Game" (DM Sans 11pt with tracking).
  static TextStyle wordmarkLongGame({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 2.5,
    height: 1.1,
    color: color ?? HLGColors.deepSage,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final cs = ColorScheme(
      brightness: Brightness.light,
      primary: HLGColors.deepSage,
      onPrimary: HLGColors.white,
      secondary: HLGColors.sage,
      onSecondary: HLGColors.white,
      tertiary: HLGColors.crownGold,
      onTertiary: HLGColors.deepSage,
      // Brand rule (architecture.md): avoid clinical red; use Antique Rose for human-warning moments.
      // Note: keep Antique Rose usage sparse at the screen level (do not use for CTAs/nav).
      error: HLGColors.antiqueRose,
      onError: HLGColors.white,
      surface: HLGColors.warmCream,
      onSurface: HLGColors.textBody,
    );

    final textTheme = TextTheme(
      displayLarge: HLGTextStyles.h1Display(color: HLGColors.textBody),
      headlineLarge: HLGTextStyles.h2Section(color: HLGColors.textBody),
      headlineMedium: HLGTextStyles.h3SubheadItalic(color: HLGColors.textBody),
      titleLarge: HLGTextStyles.h3SubheadItalic(color: HLGColors.textBody),
      bodyLarge: HLGTextStyles.body(color: HLGColors.textBody),
      bodyMedium: HLGTextStyles.body(color: HLGColors.textBody),
      labelLarge: HLGTextStyles.labelMedium(color: HLGColors.textBody),
      labelMedium: HLGTextStyles.uiElement(color: HLGColors.textBody),
      labelSmall: HLGTextStyles.eyebrowAllCaps(),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      scaffoldBackgroundColor: HLGColors.warmCream,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: HLGColors.textBody),
      appBarTheme: const AppBarTheme(
        backgroundColor: HLGColors.warmCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: HLGColors.textBody,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        // App: cards should *lift* from the cream reading surface without
        // becoming another green block.
        color: HLGColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md), side: BorderSide(color: HLGColors.deepSage.withValues(alpha: 0.12))),
        shadowColor: HLGColors.deepSage.withValues(alpha: 0.06),
      ),
      dividerTheme: DividerThemeData(color: HLGColors.deepSage.withValues(alpha: 0.12), space: 1, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          foregroundColor: const WidgetStatePropertyAll(HLGColors.white),
          iconColor: const WidgetStatePropertyAll(HLGColors.white),
          textStyle: WidgetStatePropertyAll(HLGTextStyles.labelMedium(color: HLGColors.white)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm))),
          overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          iconColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          textStyle: WidgetStatePropertyAll(HLGTextStyles.labelMedium(color: HLGColors.deepSage)),
          overlayColor: WidgetStatePropertyAll(HLGColors.deepSage.withValues(alpha: 0.08)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          iconColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          side: const WidgetStatePropertyAll(BorderSide(color: HLGColors.deepSage, width: 1.5)),
          textStyle: WidgetStatePropertyAll(HLGTextStyles.labelMedium(color: HLGColors.deepSage)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm))),
          overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: HLGColors.creamWarm,
        selectedColor: HLGColors.deepSage.withValues(alpha: 0.12),
        disabledColor: HLGColors.creamWarm,
        secondarySelectedColor: HLGColors.deepSage.withValues(alpha: 0.12),
        checkmarkColor: HLGColors.deepSage,
        labelStyle: HLGTextStyles.labelMedium(color: HLGColors.textBody),
        secondaryLabelStyle: HLGTextStyles.labelMedium(color: HLGColors.deepSage),
        side: BorderSide(color: HLGColors.deepSage.withValues(alpha: 0.16), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HLGColors.creamWarm,
        hintStyle: HLGTextStyles.body(color: HLGColors.textMuted),
        labelStyle: HLGTextStyles.labelMedium(color: HLGColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: HLGColors.deepSage.withValues(alpha: 0.35), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: HLGColors.deepSage.withValues(alpha: 0.35), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: const BorderSide(color: HLGColors.deepSage, width: 1.5)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HLGColors.deepSage,
        contentTextStyle: HLGTextStyles.body(color: HLGColors.warmCream),
        actionTextColor: HLGColors.crownGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HLGColors.warmCream,
        selectedItemColor: HLGColors.deepSage,
        unselectedItemColor: HLGColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
