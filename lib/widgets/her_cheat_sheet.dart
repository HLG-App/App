import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:her_long_game/data/term_glossary.dart';

class HerCheatSheet extends StatelessWidget {
  final String term;
  final String displayText;

  const HerCheatSheet({super.key, required this.term, required this.displayText});

  static const Color _deepSage = Color(0xFF5C7A62);
  static const Color _crownGold = Color(0xFFB8923A);
  static const Color _horizonOrange = Color(0xFFD4621A);
  static const Color _warmCream = Color(0xFFF7F5F0);
  static const Color _midSage = Color(0xFF8A9E8D);
  static const Color _textBody = Color(0xFF2A3A2C);
  static const Color _petal = Color(0xFFEDE0D4);

  void _showSheet(BuildContext context) {
    final entry = termGlossary[term.toLowerCase()] ?? termGlossary[term];
    if (entry == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: _warmCream,
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
                decoration: BoxDecoration(color: _midSage.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              'HER CHEAT SHEET',
              style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: _crownGold, letterSpacing: 2.0),
            ),
            const SizedBox(height: 8),
            Text(
              displayText,
              style: GoogleFonts.playfairDisplay(fontSize: 22, fontStyle: FontStyle.italic, color: _deepSage),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: _crownGold),
            const SizedBox(height: 16),
            Text(entry.plainEnglish, style: GoogleFonts.dmSans(fontSize: 16, color: _textBody, height: 1.6)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _petal,
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: _horizonOrange, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUT THE CRAP',
                    style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: _horizonOrange, letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.cutTheCrap,
                    style: GoogleFonts.dmSans(fontSize: 14, fontStyle: FontStyle.italic, color: _midSage, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(foregroundColor: _deepSage),
                child: Text(
                  'Got it',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: _deepSage),
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
                  color: const Color(0xFFB8923A).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  displayText,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A3A2C),
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
