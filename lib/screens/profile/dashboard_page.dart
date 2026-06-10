import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/data/repositories/tool_repository.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  ToolRepository get _toolRepo => ToolRepository();

  Future<List<ToolState>> _loadToolStates() async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) return const [];
    try {
      return await _toolRepo.getLatestToolStates(userId: uid);
    } catch (e) {
      debugPrint('[DashboardPage] Failed to load tool_states: $e');
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
        title: Text('Dashboard', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ToolState>>(
          future: _loadToolStates(),
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
                      Expanded(child: Text('Couldn\'t load dashboard right now.', style: HLGTextStyles.body(color: HLGColors.textBody))),
                    ],
                  ),
                ),
              );
            }

            final items = snapshot.data ?? const <ToolState>[];
            if (items.isEmpty) {
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
                      const Icon(Icons.dashboard_outlined, color: HLGColors.deepSage),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Nothing saved yet. Tap “Save to my dashboard” in any tool.', style: HLGTextStyles.body(color: HLGColors.textBody))),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: AppSpacing.paddingLg,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final row = items[i];
                final toolCode = row.toolCode;
                final outputs = row.outputs;
                final summary = _summarize(outputs);
                return Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: HLGColors.petal,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HLGColors.deepSage.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calculate_outlined, color: HLGColors.deepSage),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(toolCode.isEmpty ? 'Tool' : toolCode, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                            const SizedBox(height: 4),
                            Text(summary, style: HLGTextStyles.body(color: HLGColors.midSage), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  String _summarize(dynamic outputs) {
    if (outputs is Map) {
      // Heuristic: show up to 2 key values.
      final entries = outputs.entries.take(2).toList();
      if (entries.isEmpty) return 'Saved calculation';
      return entries.map((e) => '${e.key}: ${e.value}').join(' · ');
    }
    return 'Saved calculation';
  }
}
