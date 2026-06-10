import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/data/repositories/goal_repository.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class GoalsSnapshotPage extends StatelessWidget {
  const GoalsSnapshotPage({super.key});

  GoalRepository get _goalRepo => GoalRepository();

  Future<List<Goal>> _loadGoals() async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) return const [];
    try {
      return await _goalRepo.getGoals(uid);
    } catch (e) {
      debugPrint('[GoalsSnapshotPage] Failed to load goals: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/profile',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text('Goals', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Goal>>(
          future: _loadGoals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: HLGColors.deepSage));
            }
            if (snapshot.hasError) {
              return Padding(
                padding: AppSpacing.paddingLg,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HLGColors.petal,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: HLGColors.horizonOrange),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Couldn\'t load goals right now.', style: HLGTextStyles.body(color: HLGColors.textBody))),
                    ],
                  ),
                ),
              );
            }

            final goals = snapshot.data ?? const <Goal>[];
            if (goals.isEmpty) {
              return Padding(
                padding: AppSpacing.paddingLg,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HLGColors.petal,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: HLGColors.deepSage),
                      const SizedBox(width: 10),
                      Expanded(child: Text('No goals yet. Add one from any tool.', style: HLGTextStyles.body(color: HLGColors.textBody))),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: AppSpacing.paddingLg,
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final g = goals[i];
                final label = g.label;
                final tool = g.linkedTool ?? '';
                final lesson = g.sourceLesson ?? '';
                return Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: HLGColors.petal,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: HLGColors.deepSage),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label.isEmpty ? 'Goal' : label, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                            const SizedBox(height: 4),
                            Text(
                              [if (lesson.isNotEmpty) 'From $lesson', if (tool.isNotEmpty) 'Tool $tool'].join(' · '),
                              style: HLGTextStyles.body(color: HLGColors.midSage),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
