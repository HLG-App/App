import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/app_back_button.dart';

/// Standard app bar.
///
/// This app previously rendered a wordmark/logo in the leading area. The
/// leading area now only shows a back button when requested.
class HerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HerAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions,
    this.showBack = false,
    this.useBrandBand = false,
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

  /// Adds a subtle on-brand band behind the logo to ensure contrast across
  /// the primary tab screens.
  ///
  /// When enabled and [backgroundColor] is not provided, the AppBar background
  /// defaults to [HLGColors.petal] and a soft bottom border is applied.
  final bool useBrandBand;

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
    final defaultTitleStyle = Theme.of(context).textTheme.titleMedium;
    final titleWidget = title ??
        (titleText == null
            ? const SizedBox.shrink()
            : Text(
                titleText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: defaultTitleStyle,
              ));

    // The app uses Cream as the dominant surface. Only a small number of
    // screens should ever place AppBar text on a dark panel.
    final resolvedBg = backgroundColor ?? (useBrandBand ? HLGColors.petal : null) ?? Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final isDarkBrandPanel = resolvedBg == HLGColors.deepSage;
    final titleColor = isDarkBrandPanel ? HLGColors.warmCream : HLGColors.textBody;

    return AppBar(
      backgroundColor: backgroundColor ?? (useBrandBand ? HLGColors.petal : null),
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle ?? false,
      titleSpacing: 0,
      toolbarHeight: toolbarHeight,
      shape: useBrandBand ? Border(bottom: BorderSide(color: HLGColors.sageTint, width: 1)) : null,
      leadingWidth: showBack ? kToolbarHeight : 0,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 6),
              child: AppBackButton(
                color: backButtonColor ?? (isDarkBrandPanel ? HLGColors.warmCream : HLGColors.textBody),
                fallbackRoute: fallbackRoute,
                onPressed: onBackPressed,
              ),
            )
          : const SizedBox.shrink(),
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

