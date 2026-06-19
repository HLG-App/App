import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/theme.dart';

/// Shared header for the five main bottom-nav tabs:
/// Home, Her (System), Learn, Wisdom, Profile.
///
/// Visual pattern (locked in by brand):
///   - Eyebrow row: italic "Her" + spaced uppercase [tabLabel] in crown gold
///   - Display title: large italic Playfair, ink color
///   - Optional subtitle: muted DM Sans body
///   - Thin crown-gold rule beneath, full bleed within the page padding
///
/// Sits BELOW the `HerAppBar` (which keeps the logo + logout) so the brand
/// mark in the top-left and the tab identity here reinforce each other
/// without duplicating the wordmark.
class HerTabHeader extends StatelessWidget {
  const HerTabHeader({
    super.key,
    this.tabLabel,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(20, 14, 20, 18),
  });

  /// Short uppercase label for the tab, e.g. "HOME", "SYSTEM", "LEARN".
  final String? tabLabel;

  /// Large italic display title, e.g. "Welcome back" or "Your path".
  final String title;

  /// Optional short subtitle / orienting line beneath the title.
  final String? subtitle;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tabLabel != null && tabLabel!.trim().isNotEmpty) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Her',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: HLGColors.textBody,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tabLabel!.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.2,
                    color: HLGColors.crownGold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: HLGColors.textBody,
              height: 1.15,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                color: HLGColors.textMuted,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(height: 2, color: HLGColors.crownGold.withValues(alpha: 0.85)),
        ],
      ),
    );
  }
}
