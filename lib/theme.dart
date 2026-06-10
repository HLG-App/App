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
  static const double sm = 10;
  static const double md = 16;
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
/// Source of truth: `arhitecture.md` (Colour palette v5.0).
class HLGColors {
  // Primary
  static const Color deepSage = Color(0xFF5C7A62); // Primary · CTAs · Key UI
  static const Color sage = Color(0xFF7A9279); // Secondary · Hover · Gradients
  static const Color midSage = Color(0xFF8A9E8D); // Body text · Labels

  // Accent / Neutrals
  static const Color crownGold = Color(0xFFB8923A); // Gold accent
  static const Color warmCream = Color(0xFFF7F5F0); // Primary background
  static const Color petal = Color(0xFFEDE0D4); // Cards · Warm panels

  // Dark & Signal
  static const Color night = Color(0xFF161E17); // Dark headers · Statements · Nav bar
  static const Color growth = Color(0xFF7ECFA0); // Positive indicators
  static const Color horizonOrange = Color(0xFFD4621A); // Accent only
  static const Color antiqueRose = Color(0xFFC4756A);

  // Onboarding / dark surfaces
  /// Deep forest green used for premium onboarding screens.
  static const Color deepForest = Color(0xFF1E2E20);
  static const Color deepForestSurface = Color(0xFF1A2E1C);

  // Derived / utility
  static const Color sagePale = Color(0xFFD4E0D6); // Light backgrounds
  static const Color textBody = Color(0xFF2A3A2C); // Dark body text
  static const Color textMuted = Color(0xFF6A7E6C); // Secondary/muted text
  static const Color white = Color(0xFFFFFFFF);
}

/// Her Long Game typography.
///
/// Source of truth: `arhitecture.md` (Typography v5.0).
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
  static TextStyle body({Color? color}) => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: color,
  );

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

  static TextStyle uiElement({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.25,
    color: color,
  );

  static TextStyle eyebrowAllCaps({Color? color}) => GoogleFonts.dmSans(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 2.0,
    height: 1.2,
    color: color,
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
    color: color ?? HLGColors.night,
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
      onTertiary: HLGColors.night,
      error: const Color(0xFFB00020),
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
      labelSmall: HLGTextStyles.eyebrowAllCaps(color: HLGColors.textMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: HLGColors.warmCream,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: HLGColors.textBody,
      ),
      cardTheme: CardThemeData(
        color: HLGColors.petal,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: HLGColors.night.withValues(alpha: 0.08), space: 1, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          foregroundColor: const WidgetStatePropertyAll(HLGColors.white),
          iconColor: const WidgetStatePropertyAll(HLGColors.white),
          textStyle: WidgetStatePropertyAll(HLGTextStyles.labelMedium(color: HLGColors.white)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
          overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          iconColor: const WidgetStatePropertyAll(HLGColors.deepSage),
          side: const WidgetStatePropertyAll(BorderSide(color: HLGColors.deepSage, width: 1)),
          textStyle: WidgetStatePropertyAll(HLGTextStyles.labelMedium(color: HLGColors.deepSage)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
          overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HLGColors.white,
        hintStyle: HLGTextStyles.body(color: HLGColors.textMuted),
        labelStyle: HLGTextStyles.labelMedium(color: HLGColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HLGColors.deepSage, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HLGColors.night,
        selectedItemColor: HLGColors.horizonOrange,
        unselectedItemColor: HLGColors.midSage,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
