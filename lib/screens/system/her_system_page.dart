import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/her_tab_header.dart';

/// “Her System” is the organising layer for the app.
///
/// It maps *existing* features into a clear pillar structure without removing or
/// rebuilding them.
class HerSystemPage extends StatelessWidget {
  const HerSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: const HerAppBar(
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        actions: [HerLogoutIconButton(color: HLGColors.textBody)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HerTabHeader(
              tabLabel: 'SYSTEM',
              title: 'Everything in one place',
              subtitle: 'Your notes, bookmarks, tools, direction, and perspective.',
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: HLGColors.warmCream,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    _PillarCard(
              number: '01',
              icon: Icons.edit_note_rounded,
              title: 'Her Notes',
              subtitle: 'Your private notes from every lesson. Revisit anytime.',
              accentColor: HLGColors.deepSage,
              onTap: () => context.push(AppRoutes.profileNotes),
            ),
            const SizedBox(height: 10),
            _PillarCard(
              number: '02',
              icon: Icons.bookmark_rounded,
              title: 'Her Bookmarks',
              subtitle: 'Save the takeaways that resonate. Build your own library.',
              accentColor: HLGColors.crownGold,
              onTap: () => context.push(AppRoutes.bookmarks),
            ),
            const SizedBox(height: 10),
            _PillarCard(
              number: '03',
              icon: Icons.calculate_rounded,
              title: 'Her Tools',
              subtitle: 'Interactive calculators. What-ifs. The concepts made real with your numbers.',
              accentColor: HLGColors.horizonOrange,
              onTap: () => context.push(AppRoutes.tools),
            ),
            const SizedBox(height: 10),
            _PillarCard(
              number: '04',
              icon: Icons.track_changes_rounded,
              title: 'Her Direction',
              subtitle: 'Your goals, your progress, what you are building toward.',
              accentColor: HLGColors.antiqueRose,
              onTap: () => context.push(AppRoutes.direction),
            ),
            const SizedBox(height: 10),
            _PillarCard(
              number: '05',
              icon: Icons.people_outline_rounded,
              title: 'Her Perspective',
              subtitle: 'Reflections from other women in the app – if they choose to share.',
              accentColor: HLGColors.sage,
              onTap: () => context.push(AppRoutes.perspective),
            ),
            const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final String number;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HLGColors.warmCream,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: HLGColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: HLGColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                number,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: HLGColors.sageMid,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HLGColors.sageMid),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _SoftLinkRow extends StatelessWidget {
  const _SoftLinkRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              Icon(icon, color: HLGColors.sageMid, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: HLGTextStyles.body(color: HLGColors.textBody))),
              Icon(Icons.chevron_right_rounded, color: HLGColors.sageMid),
            ],
          ),
        ),
      ),
    );
  }
}
