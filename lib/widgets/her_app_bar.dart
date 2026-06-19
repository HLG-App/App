import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/app_back_button.dart';

/// Standard app bar that keeps the brand mark visible in the top-left.
///
/// - Root screens: shows the logo as the leading widget.
/// - Back-stack screens: shows back arrow + logo together in the leading area.
///
/// This avoids “bare” top corners while preserving go_router navigation
/// (via [AppBackButton]).
class HerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HerAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions,
    this.showBack = false,
    this.fallbackRoute,
    this.onBackPressed,
    this.backButtonColor,
    this.backgroundColor,
    this.surfaceTintColor,
    this.centerTitle,
    this.toolbarHeight,
  }) : assert(title == null || titleText == null, 'Provide either title or titleText, not both.');

  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;

  /// If true, renders a back arrow (go_router-safe) plus logo in the leading.
  final bool showBack;

  /// Used by [AppBackButton] when there is no back stack.
  final String? fallbackRoute;

  /// Optional override for back button behaviour. When provided, this is called
  /// instead of the default go_router pop behaviour.
  final VoidCallback? onBackPressed;

  /// Optional back button color override (useful on dark backgrounds).
  final Color? backButtonColor;

  final Color? backgroundColor;
  final Color? surfaceTintColor;
  final bool? centerTitle;
  final double? toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final titleWidget = title ?? (titleText == null ? const SizedBox.shrink() : Text(titleText!));

    // The app uses Cream as the dominant surface. Only a small number of
    // screens should ever place AppBar text on a dark panel.
    final resolvedBg = backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final isDarkBrandPanel = resolvedBg == HLGColors.deepSage;
    final titleColor = isDarkBrandPanel ? HLGColors.warmCream : HLGColors.textBody;

    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      leadingWidth: showBack ? 132 : 72,
      leading: showBack ? _BackAndLogo(fallbackRoute: fallbackRoute, backButtonColor: backButtonColor, onPressed: onBackPressed) : const _CornerLogo(),
      title: DefaultTextStyle(style: Theme.of(context).textTheme.titleMedium?.copyWith(color: titleColor) ?? TextStyle(color: titleColor), child: titleWidget),
      actions: actions,
    );
  }
}

/// Standard top-right logout affordance used across main tabs.
///
/// Keeps the interaction calm by using a confirmation bottom sheet.
class HerLogoutIconButton extends StatelessWidget {
  const HerLogoutIconButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Log out',
      onPressed: () => _showLogoutSheet(context),
      icon: Icon(Icons.logout_rounded, size: 20, color: color ?? HLGColors.textMuted),
    );
  }

  Future<void> _showLogoutSheet(BuildContext context) async {
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: HLGColors.warmCream,
      builder: (sheetContext) {
        bool isSigningOut = false;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> onConfirm() async {
              if (isSigningOut) return;
              setState(() => isSigningOut = true);
              try {
                await SupabaseConfig.auth.signOut();
                AppRuntimeState.clear();
                if (!sheetContext.mounted) return;
                sheetContext.pop();
                if (!context.mounted) return;
                context.go(AppRoutes.auth);
              } catch (e) {
                debugPrint('[HerLogoutIconButton] Sign out failed: $e');
                if (!sheetContext.mounted) return;
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  SnackBar(
                    content: Text('Could not log out. Please try again.', style: HLGTextStyles.body(color: HLGColors.warmCream)),
                    backgroundColor: HLGColors.deepSage,
                  ),
                );
              } finally {
                if (sheetContext.mounted) setState(() => isSigningOut = false);
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log out', style: HLGTextStyles.lessonHeading(color: HLGColors.textBody)),
                  const SizedBox(height: 8),
                  Text('You can sign back in any time.', style: HLGTextStyles.body(color: HLGColors.textMuted)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSigningOut ? null : () => sheetContext.pop(),
                          child: Text('Cancel', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: isSigningOut ? null : onConfirm,
                          child: Text(isSigningOut ? 'Logging out…' : 'Log out', style: HLGTextStyles.labelMedium(color: HLGColors.warmCream)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CornerLogo extends StatelessWidget {
  const _CornerLogo();

  static const String _logoAsset = 'assets/images/Her_Long_Game-01_2.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(_logoAsset, height: 24, fit: BoxFit.contain),
      ),
    );
  }
}

class _BackAndLogo extends StatelessWidget {
  const _BackAndLogo({this.fallbackRoute, this.backButtonColor, this.onPressed});

  final String? fallbackRoute;
  final Color? backButtonColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBackButton(color: backButtonColor ?? HLGColors.textBody, fallbackRoute: fallbackRoute, onPressed: onPressed),
          const SizedBox(width: 6),
          Image.asset(_CornerLogo._logoAsset, height: 20, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
