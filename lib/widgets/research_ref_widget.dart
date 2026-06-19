import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:her_long_game/data/research_refs.dart';
import 'package:her_long_game/theme.dart';

class ResearchRefWidget extends StatelessWidget {
  final String refId;

  const ResearchRefWidget({super.key, required this.refId});

  static const Color _crownGold = HLGColors.crownGold;
  static const Color _warmCream = HLGColors.warmCream;
  static const Color _night = HLGColors.textBody;
  static const Color _midSage = HLGColors.sageMid;
  static const Color _textBody = HLGColors.textBody;

  void _showSheet(BuildContext context) {
    final ref = researchRefs[refId];
    if (ref == null) return;

    HapticFeedback.selectionClick();
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
                decoration: BoxDecoration(
                  color: _midSage.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'THE RESEARCH',
              style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: _crownGold, letterSpacing: 2.0),
            ),
            const SizedBox(height: 8),
            Text(
              '${ref.source} · ${ref.year}',
              style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: _night),
            ),
            const SizedBox(height: 12),
            Text(ref.plainSummary, style: GoogleFonts.dmSans(fontSize: 15, color: _textBody, height: 1.6)),
            const SizedBox(height: 16),
            Container(height: 1, color: _crownGold.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Want to read more?',
                    style: GoogleFonts.dmSans(fontSize: 13, fontStyle: FontStyle.italic, color: _midSage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(ref.url.trim());
                if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: Text(
                ref.url.trim().replaceFirst('https://', ''),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: HLGColors.horizonOrange,
                  decoration: TextDecoration.underline,
                  decorationColor: HLGColors.horizonOrange,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text('Got it', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: HLGColors.deepSage)),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _crownGold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _crownGold.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ref', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: _crownGold, letterSpacing: 0.5)),
            const SizedBox(width: 3),
            const Icon(Icons.north_east_rounded, size: 10, color: _crownGold),
          ],
        ),
      ),
    );
  }
}
