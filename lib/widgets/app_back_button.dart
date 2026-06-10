import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/theme.dart';

/// Standardised back button for consistent navigation across the app.
///
/// Provides:
/// - Consistent visual styling (subdued, premium, minimal)
/// - Haptic feedback on tap
/// - Safe navigation behavior (pops if possible, fallback to home if needed)
/// - 44x44 minimum touch target
///
/// Usage:
/// ```dart
/// AppBar(
///   automaticallyImplyLeading: false,
///   leading: const AppBackButton(),
/// )
/// ```
///
/// For custom positioned back buttons (non-AppBar contexts):
/// ```dart
/// SafeArea(
///   child: Padding(
///     padding: const EdgeInsets.all(16),
///     child: Align(
///       alignment: Alignment.topLeft,
///       child: AppBackButton(color: HLGColors.warmCream),
///     ),
///   ),
/// )
/// ```
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.color,
    this.onPressed,
    this.fallbackRoute,
  });

  /// Optional color override. If null, uses HLGColors.night (default).
  final Color? color;

  /// Optional custom onPressed handler. If null, uses default navigation logic.
  final VoidCallback? onPressed;

  /// Optional fallback route if navigation stack is empty.
  /// Defaults to '/home' if not specified.
  final String? fallbackRoute;

  void _handleBack(BuildContext context) {
    // Light haptic feedback for premium feel
    HapticFeedback.lightImpact();

    if (onPressed != null) {
      onPressed!();
      return;
    }

    // Prefer true "back" behavior.
    // Note: Many screens previously navigated forward with `context.go()`, which
    // replaces history and makes `canPop == false`. We still attempt to pop
    // first, then only fall back when there is genuinely no back stack.
    final router = GoRouter.of(context);
    final canPop = router.canPop();
    if (canPop) {
      router.pop();
      return;
    }

    // Fallback route if navigation stack is empty.
    final target = fallbackRoute ?? '/home';
    debugPrint('AppBackButton: no back stack; falling back to $target');
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _handleBack(context),
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 20,
        color: color ?? HLGColors.night,
      ),
      tooltip: 'Back',
      // Ensure minimum touch target size (44x44)
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      // Subtle, calm interaction
      splashRadius: 20,
      padding: const EdgeInsets.all(12),
    );
  }
}
