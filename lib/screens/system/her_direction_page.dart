import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/data/repositories/goal_repository.dart';
import 'package:her_long_game/nav.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

/// HerDirection (pillar)
///
/// The place where saved goals become a supportive, actionable plan.
///
/// - Goals can be created from Tools.
/// - When a goal is saved from a Tool, we also write a `GOAL_SUMMARY` row into
///   `her_notes` so HerDirection can render a practical “what this means + what
///   next” card.
class HerDirectionPage extends StatefulWidget {
  const HerDirectionPage({super.key});

  @override
  State<HerDirectionPage> createState() => _HerDirectionPageState();
}

class _HerDirectionPageState extends State<HerDirectionPage> {
  bool _isLoading = true;
  String? _error;
  List<Goal> _goals = const [];
  Map<String, HerGoalSummary> _summariesByGoalCode = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _goals = const [];
      _summariesByGoalCode = const {};
    });

    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _isLoading = false;
          _error = 'Please sign in to view your goals.';
        });
        return;
      }

      final goals = await GoalRepository().getGoals(uid);
      final summaryRows = await SupabaseConfig.client
          .from('her_notes')
          .select('response, created_at')
          .eq('user_id', uid)
          .eq('prompt', 'GOAL_SUMMARY')
          .order('created_at', ascending: false);

      final summaries = <String, HerGoalSummary>{};
      for (final raw in (summaryRows as List)) {
        if (raw is! Map) continue;
        final response = raw['response'];
        if (response is! String || response.trim().isEmpty) continue;
        final parsed = _safeJson(response);
        if (parsed == null) continue;
        final goalCode = (parsed['goal_code'] ?? '').toString();
        if (goalCode.isEmpty) continue;
        summaries.putIfAbsent(goalCode, () => HerGoalSummary.fromJson(parsed));
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _goals = goals;
        _summariesByGoalCode = summaries;
      });
    } catch (e) {
      debugPrint('[HerDirectionPage] load FAILED: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load your direction right now.';
      });
    }
  }

  Map<String, dynamic>? _safeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: HLGColors.deepSage))
            : (_error != null)
                ? _DirectionError(message: _error!, onRetry: _load)
                : (_goals.isEmpty)
                    ? const _DirectionEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _goals.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () => context.push(AppRoutes.profileGoals),
                                icon: const Icon(Icons.flag_outlined, color: HLGColors.deepSage),
                                label: Text(
                                  'View my goals (Profile)',
                                  style: HLGTextStyles.body(color: HLGColors.deepSage).copyWith(fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: HLGColors.deepSage.withValues(alpha: 0.7), width: 1.4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  backgroundColor: HLGColors.warmCream,
                                ),
                              ),
                            );
                          }

                          final goal = _goals[i - 1];
                          final summary = _summariesByGoalCode[goal.goalCode];
                          return _GoalSummaryCard(goal: goal, summary: summary);
                        },
                      ),
      ),
    );
  }
}

class HerGoalSummary {
  const HerGoalSummary({required this.goalCode, required this.goalLabel, this.linkedTool, this.meaning, this.nextStep, this.longGameLink});

  final String goalCode;
  final String goalLabel;
  final String? linkedTool;
  final String? meaning;
  final String? nextStep;
  final String? longGameLink;

  factory HerGoalSummary.fromJson(Map<String, dynamic> json) => HerGoalSummary(
        goalCode: (json['goal_code'] ?? '').toString(),
        goalLabel: (json['goal_label'] ?? '').toString(),
        linkedTool: (json['linked_tool'] as Object?)?.toString(),
        meaning: (json['meaning'] as Object?)?.toString(),
        nextStep: (json['next_step'] as Object?)?.toString(),
        longGameLink: (json['long_game_link'] as Object?)?.toString(),
      );
}

class _GoalSummaryCard extends StatelessWidget {
  const _GoalSummaryCard({required this.goal, required this.summary});

  final Goal goal;
  final HerGoalSummary? summary;

  @override
  Widget build(BuildContext context) {
    final title = (goal.label.trim().isEmpty) ? 'Saved goal' : goal.label.trim();
    final tool = (goal.linkedTool ?? '').trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: HLGColors.sagePale, borderRadius: BorderRadius.circular(14), border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.25))),
                child: const Icon(Icons.flag_rounded, color: HLGColors.deepSage),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: HLGTextStyles.moduleTitle(color: HLGColors.textBody))),
            ],
          ),
          const SizedBox(height: 10),
          if (tool.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: HLGColors.warmCream, borderRadius: BorderRadius.circular(999), border: Border.all(color: HLGColors.crownGold.withValues(alpha: 0.45))),
              child: Text('Created from a tool', style: HLGTextStyles.labelMedium(color: HLGColors.deepSage)),
            ),
          if (tool.isNotEmpty) const SizedBox(height: 10),
          if ((summary?.meaning ?? '').trim().isNotEmpty) ...[
            Text('What this means', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.sageMid)),
            const SizedBox(height: 6),
            Text(summary!.meaning!, style: HLGTextStyles.quoteItalic(color: HLGColors.textBody).copyWith(height: 1.55)),
            const SizedBox(height: 12),
          ],
          if ((summary?.nextStep ?? '').trim().isNotEmpty) ...[
            Text('Your next step', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.sageMid)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 8, right: 10), decoration: const BoxDecoration(color: HLGColors.crownGold, shape: BoxShape.circle)),
                Expanded(child: Text(summary!.nextStep!, style: HLGTextStyles.body(color: HLGColors.textBody).copyWith(height: 1.55))),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if ((summary?.longGameLink ?? '').trim().isNotEmpty) ...[
            Text('How this connects to your long game', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.sageMid)),
            const SizedBox(height: 6),
            Text(summary!.longGameLink!, style: HLGTextStyles.homeBody14(color: HLGColors.textMuted).copyWith(height: 1.55)),
          ] else
            Text(
              'If you want, turn this into one repeatable action this week. That’s how the long game becomes real.',
              style: HLGTextStyles.homeBody14(color: HLGColors.textMuted).copyWith(height: 1.55),
            ),
        ],
      ),
    );
  }
}

class _DirectionEmpty extends StatelessWidget {
  const _DirectionEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: HLGColors.petal,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(height: 40, width: 40, decoration: BoxDecoration(color: HLGColors.sagePale, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.route_rounded, color: HLGColors.deepSage)),
                const SizedBox(width: 12),
                Expanded(child: Text('Your goals become a plan here.', style: HLGTextStyles.body(color: HLGColors.textBody))),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Add a goal from any tool (tap “Add to my goals”). When you do, Her Direction will translate it into a practical next step.',
              style: HLGTextStyles.homeBody14(color: HLGColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionError extends StatelessWidget {
  const _DirectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: HLGTextStyles.body(color: HLGColors.textBody), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: HLGColors.deepSage, foregroundColor: HLGColors.white),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
