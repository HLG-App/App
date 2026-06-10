import 'package:flutter/material.dart';
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

    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      leadingWidth: showBack ? 132 : 72,
      leading: showBack ? _BackAndLogo(fallbackRoute: fallbackRoute, backButtonColor: backButtonColor) : const _CornerLogo(),
      title: titleWidget,
      actions: actions,
    );
  }
}

class _CornerLogo extends StatelessWidget {
  const _CornerLogo();

  static const String _logoAsset = 'assets/images/Her_Long_Game-01.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(_logoAsset, height: 22, fit: BoxFit.contain),
      ),
    );
  }
}

class _BackAndLogo extends StatelessWidget {
  const _BackAndLogo({this.fallbackRoute, this.backButtonColor});

  final String? fallbackRoute;
  final Color? backButtonColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBackButton(color: backButtonColor ?? HLGColors.night, fallbackRoute: fallbackRoute),
          const SizedBox(width: 6),
          Image.asset(_CornerLogo._logoAsset, height: 20, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
