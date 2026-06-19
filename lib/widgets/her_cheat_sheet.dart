import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:her_long_game/data/term_glossary.dart';
import 'package:her_long_game/theme.dart';

class HerCheatSheet extends StatelessWidget {
  final String term;
  final String displayText;

  const HerCheatSheet({super.key, required this.term, required this.displayText});

  void _showSheet(BuildContext context) {
    final entry = termGlossary[term.toLowerCase()] ?? termGlossary[term];
    if (entry == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: HLGColors.warmCream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: HLGColors.sageMid.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              'HER CHEAT SHEET',
              style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: HLGColors.crownGold, letterSpacing: 2.0),
            ),
            const SizedBox(height: 8),
            Text(
              displayText,
              style: GoogleFonts.playfairDisplay(fontSize: 22, fontStyle: FontStyle.italic, color: HLGColors.deepSage),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: HLGColors.crownGold),
            const SizedBox(height: 16),
            Text(entry.plainEnglish, style: GoogleFonts.dmSans(fontSize: 16, color: HLGColors.textBody, height: 1.6)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HLGColors.petal,
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: HLGColors.horizonOrange, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUT THE CRAP',
                    style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: HLGColors.horizonOrange, letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.cutTheCrap,
                    style: GoogleFonts.dmSans(fontSize: 14, fontStyle: FontStyle.italic, color: HLGColors.sageMid, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(foregroundColor: HLGColors.deepSage),
                child: Text(
                  'Got it',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: HLGColors.deepSage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: HLGColors.crownGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  displayText,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: HLGColors.textBody,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
