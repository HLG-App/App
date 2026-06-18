import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/data/repositories/goal_repository.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

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
            const _SystemHeroHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: HLGColors.warmCream,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    const _GoalsPreviewCard(),
                    const SizedBox(height: 14),

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

class _SystemHeroHeader extends StatelessWidget {
  const _SystemHeroHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: HLGColors.creamWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HLGColors.deepSage.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Her ',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: HLGColors.textBody,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'SYSTEM',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: HLGColors.crownGold,
                      letterSpacing: 3.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Everything you need — in one place.',
              style: HLGTextStyles.body(color: HLGColors.textMuted).copyWith(height: 1.5),
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
                        color: HLGColors.night,
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
                  color: HLGColors.midSage,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HLGColors.midSage),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalsPreviewCard extends StatelessWidget {
  const _GoalsPreviewCard();

  Future<List<Goal>> _load() async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) return const [];
    return GoalRepository().getGoals(uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Goal>>(
      future: _load(),
      builder: (context, snapshot) {
        final goals = snapshot.data ?? const <Goal>[];
        final count = goals.length;
        final latest = count > 0 ? goals.first.label : null;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: HLGColors.petal,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: HLGColors.antiqueRose.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.flag_outlined, color: HLGColors.antiqueRose, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your goals', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                    const SizedBox(height: 4),
                    Text(
                      count == 0
                          ? 'Add goals from any tool. Her will turn them into next steps.'
                          : '$count saved · Latest: ${latest ?? 'Goal'}',
                      style: HLGTextStyles.body(color: HLGColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => context.push(AppRoutes.direction),
                style: TextButton.styleFrom(foregroundColor: HLGColors.deepSage),
                child: const Text('View'),
              ),
            ],
          ),
        );
      },
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
              Icon(icon, color: HLGColors.midSage, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: HLGTextStyles.body(color: HLGColors.textBody))),
              Icon(Icons.chevron_right_rounded, color: HLGColors.midSage),
            ],
          ),
        ),
      ),
    );
  }
}
