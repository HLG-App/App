import 'package:flutter/material.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

/// HerDirection (pillar)
///
/// A structured goal/progression layer.
///
/// For now this page is intentionally minimal and *does not* change any existing
/// goal creation flows (e.g., tool "Add goal" buttons). This keeps current
/// behavior intact while establishing the organising layer.
class HerDirectionPage extends StatelessWidget {
  const HerDirectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/system',
        title: Text('Her Direction', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: HLGColors.petal,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.35)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: HLGColors.sagePale,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.route_outlined, color: HLGColors.deepSage),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Your goals and progress—held gently.', style: HLGTextStyles.body(color: HLGColors.textBody))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'You can already add goals from tools. This pillar will bring them together into a simple, supportive plan view (without changing what you’ve saved).',
                  style: HLGTextStyles.homeBody14(color: HLGColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
