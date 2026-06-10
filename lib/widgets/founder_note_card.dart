import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/screens/auth/founder_note_screen.dart';
import 'package:her_long_game/theme.dart';

class FounderNoteCard extends StatelessWidget {
  const FounderNoteCard({super.key});

  static Future<void> showBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FounderNoteBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showBottomSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HLGColors.night,
            borderRadius: BorderRadius.circular(16),
            border: const Border(top: BorderSide(color: HLGColors.horizonOrange, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A NOTE FROM THE FOUNDER',
                style: GoogleFonts.dmSans(fontSize: 9, letterSpacing: 6.0, color: HLGColors.crownGold),
              ),
              const SizedBox(height: 8),
              Text(
                'From as early as I can remember, people in my life have asked me for advice.',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontStyle: FontStyle.italic, color: HLGColors.warmCream),
              ),
              const SizedBox(height: 12),
              Text(
                'Tamara, Founder · Her Long Game',
                style: GoogleFonts.dmSans(fontSize: 12, color: HLGColors.midSage),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Read the full note →',
                      style: GoogleFonts.dmSans(fontSize: 13, color: HLGColors.horizonOrange),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: HLGColors.horizonOrange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FounderNoteBottomSheet extends StatelessWidget {
  const FounderNoteBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Container(
      height: h * 0.92,
      decoration: const BoxDecoration(
        color: HLGColors.night,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HLGColors.midSage.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Founder\'s Note',
                    style: GoogleFonts.playfairDisplay(fontSize: 16, fontStyle: FontStyle.italic, color: HLGColors.warmCream),
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close_rounded, color: HLGColors.midSage),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          Container(height: 1, color: HLGColors.crownGold.withValues(alpha: 0.35)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 24, bottom: 40),
              child: const FounderNoteContent(showPrimaryButton: false, isDarkSurface: true),
            ),
          ),
        ],
      ),
    );
  }
}
