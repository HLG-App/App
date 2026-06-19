import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/theme.dart';

/// Compact card surfacing the Welcome / "Before We Begin" module (O1–O5).
///
/// Sits OUTSIDE the three curriculum phases. Hidden once all O lessons
/// are complete (caller decides via [completed] / [total]).
class WelcomeModuleCard extends StatelessWidget {
  const WelcomeModuleCard({
    super.key,
    required this.completed,
    required this.total,
    this.dense = false,
  });

  /// Number of O1–O5 lessons completed by the user.
  final int completed;

  /// Always 5 in V4, but kept as a param for safety.
  final int total;

  /// When true, uses tighter padding (suitable for Home).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final started = completed > 0;
    final EdgeInsets padding =
        dense ? const EdgeInsets.fromLTRB(18, 16, 18, 16) : const EdgeInsets.all(18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/learn/module/0'),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: HLGColors.warmCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HLGColors.crownGold.withValues(alpha: 0.55), width: 1),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'WELCOME',
                        style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.crownGold),
                      ),
                    ),
                    Icon(
                      started ? Icons.play_arrow_rounded : Icons.auto_awesome,
                      color: HLGColors.crownGold,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Before We Begin', style: HLGTextStyles.moduleTitle(color: HLGColors.night)),
                const SizedBox(height: 6),
                Text(
                  'A short welcome before the long game.',
                  style: HLGTextStyles.body(color: HLGColors.midSage),
                ),
                const SizedBox(height: 12),
                Text(
                  '$completed of $total',
                  style: HLGTextStyles.homeMeta13(color: HLGColors.midSage),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: HLGColors.sage.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(HLGColors.crownGold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
