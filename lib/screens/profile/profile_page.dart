import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/utils/lesson_flow.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/her_tab_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final LessonRepository _lessonRepo = LessonRepository();

  bool _isLoading = true;

  int _lessonsCompleted = 0;
  int _lessonsTotal = 0;
  bool _hasStartedLearning = false;

// 3 lessons + 4 checkpoints

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _lessonsCompleted = 0;
          _hasStartedLearning = false;
          _lessonsTotal = LessonFlow.lessonSequence.where((s) => s.startsWith('L')).length;
        });
        return;
      }

      int completed = 0;
      bool started = false;
      final lessonCodes = LessonFlow.lessonSequence.where((s) => s.startsWith('L')).toList(growable: false);
      final total = lessonCodes.length;
      try {
        final progress = await _lessonRepo.getAllProgress(userId: uid);
        for (final p in progress.values) {
          if (p.status == 'in_progress' || p.status == 'complete') started = true;
        }
        for (final code in lessonCodes) {
          if (progress[code]?.status == 'complete') completed++;
        }
      } catch (e) {
        debugPrint('[ProfilePage] Failed to load lesson_progress: $e');
      }

      setState(() {
        _lessonsCompleted = completed;
        _lessonsTotal = total;
        _hasStartedLearning = started;
      });
    } catch (e) {
      debugPrint('[ProfilePage] Failed to load her_notes counts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_lessonsTotal <= 0) ? 0.0 : (_lessonsCompleted / _lessonsTotal).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: const HerAppBar(useBrandBand: true, actions: [HerLogoutIconButton()]),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const HerTabHeader(
              tabLabel: 'PROFILE',
              showEyebrow: false,
              title: 'Your account',
              subtitle: 'Settings, learning progress, and what you\'ve saved.',
            ),
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Text('Account', style: HLGTextStyles.lessonHeading(color: HLGColors.textBody)),
            const SizedBox(height: 10),
            _ProfileMenuCard(
              icon: Icons.person_outline,
              title: 'Username, email & password',
              subtitle: 'Manage your login details.',
              onTap: () => context.push('/profile/account'),
            ),
            const SizedBox(height: 12),
            _ProfileMenuCard(
              icon: Icons.credit_card,
              title: 'Payment',
              subtitle: 'Subscription and billing.',
              onTap: () => context.push('/profile/payment'),
            ),
            const SizedBox(height: 22),

            Text('Learning', style: HLGTextStyles.lessonHeading(color: HLGColors.textBody)),
            const SizedBox(height: 10),
            _ProfileMenuCard(
              icon: Icons.insights,
              title: 'Learning progress overview',
              subtitle: _isLoading
                  ? 'Loading…'
                  : _hasStartedLearning
                      ? 'Completed $_lessonsCompleted of $_lessonsTotal'
                      : 'Not started yet – begin with THE PAST',
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${(progress * 100).round()}%', style: HLGTextStyles.labelMedium(color: HLGColors.sageMid)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 86,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: HLGColors.warmCream,
                        valueColor: const AlwaysStoppedAnimation<Color>(HLGColors.deepSage),
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => context.push('/profile/progress'),
            ),
            const SizedBox(height: 12),
            _ProfileMenuCard(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              subtitle: 'Saved tool results and snapshots.',
              onTap: () => context.push('/profile/dashboard'),
            ),
            const SizedBox(height: 12),
            _ProfileMenuCard(
              icon: Icons.flag_outlined,
              title: 'Goals snapshot',
              subtitle: 'A quick view of what you’re working toward.',
              onTap: () => context.push('/profile/goals'),
            ),
            const SizedBox(height: 12),
            _ProfileMenuCard(
              icon: Icons.card_giftcard,
              title: 'Referral',
              subtitle: 'Invite a friend and share your code.',
              onTap: () => context.push('/profile/referral'),
            ),
            const SizedBox(height: 22),

            Text('Support', style: HLGTextStyles.lessonHeading(color: HLGColors.textBody)),
            const SizedBox(height: 10),
            _ProfileMenuCard(
              icon: Icons.replay_rounded,
              title: 'App Guide',
              subtitle: 'A practical guide: app map + how to get the most out of it.',
              onTap: () => context.push('${AppRoutes.onboardingIntro}?replay=1'),
            ),
            const SizedBox(height: 22),

            Text('Financial wellbeing', style: HLGTextStyles.lessonHeading(color: HLGColors.textBody)),
            const SizedBox(height: 10),
            _ProfileMenuCard(
              icon: Icons.favorite_border,
              title: 'Retake diagnostic',
              subtitle: 'See how your money feels have changed over time.',
              onTap: () => context.push('${AppRoutes.financialWellbeingDiagnostic}?from=profile'),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: HLGColors.petal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            Icon(icon, color: HLGColors.deepSage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HLGTextStyles.body(color: HLGColors.sageMid),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            const Icon(Icons.chevron_right, color: HLGColors.sageMid),
          ],
        ),
      ),
    );
  }
}
