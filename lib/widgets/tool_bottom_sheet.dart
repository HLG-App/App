import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/data/repositories/goal_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'tools/salary_ripple_widget.dart';
import 'tools/time_machine_widget.dart';
import 'tools/the_curve_widget.dart';
import 'tools/debt_race_widget.dart';
import 'tools/true_cost_widget.dart';
import 'tools/invisible_invoice_widget.dart';
import 'tools/fortress_widget.dart';
import 'tools/super_warp_widget.dart';
import 'tools/inflation_thief_widget.dart';
import 'tools/bubble_index_widget.dart';
import 'tools/portrait_builder_widget.dart';

/// Central routing bottom sheet for all "What If" tools.
///
/// Pass a [toolCode] like "T5" and the correct tool widget will be rendered.
class ToolBottomSheet extends StatelessWidget {
  const ToolBottomSheet({super.key, required this.toolCode, required this.lessonCode});

  final String toolCode;
  final String lessonCode;


  static Future<void> show(
    BuildContext context, {
    required String toolCode,
    required String lessonCode,
  }) {
    debugPrint('[ToolBottomSheet] show called: toolCode=$toolCode lessonCode=$lessonCode');
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ToolBottomSheet(toolCode: toolCode, lessonCode: lessonCode),
    );
  }

  String _toolName() {
    const names = {
      'T0': 'The Bubble O\' Bill Index',
      'T1': 'Inflation Thief',
      'T2': 'Salary Ripple',
      'T3': 'Coffee Shop Time Machine',
      'T3b': 'The Curve',
      'T4': 'Debt Race',
      'T4b': 'True Cost Calculator',
      'T5': 'Emergency Fund Fortress',
      'T6': 'Super Time Warp',
      'T7': 'Invisible Invoice',
      'T8': 'Your Portrait',
    };
    return names[toolCode] ?? toolCode;
  }


  Future<void> _saveToolState(
    BuildContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> outputs,
  ) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      debugPrint('[ToolSave] START - toolCode=$toolCode userId=$userId');

      if (userId == null) {
        debugPrint('[ToolSave] BLOCKED - no authenticated user');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to save'),
              backgroundColor: HLGColors.horizonOrange,
            ),
          );
        }
        return;
      }

      debugPrint('[ToolSave] attempting upsert to tool_states...');
      debugPrint('[ToolSave] inputs: $inputs');
      debugPrint('[ToolSave] outputs: $outputs');

      await client.from('tool_states').upsert(
        {
          'user_id': userId,
          'tool_code': toolCode,
          'inputs': inputs,
          'outputs': outputs,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,tool_code',
      );

      debugPrint('[ToolSave] SUCCESS');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to your dashboard'),
            backgroundColor: HLGColors.deepSage,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('[ToolSave] FAILED: $e');
      debugPrint('[ToolSave] stack: $stack');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: ${e.toString()}'),
            backgroundColor: HLGColors.horizonOrange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _addGoal(BuildContext context, String goalLabel) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      debugPrint('[GoalSave] START - toolCode=$toolCode label=$goalLabel userId=$userId');

      if (userId == null) {
        debugPrint('[GoalSave] BLOCKED - no authenticated user');
        return;
      }

      final goalCode = '${toolCode.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';

      // 1) Persist the goal.
      await GoalRepository(client: client).upsertGoal(
        userId,
        goalCode,
        goalLabel,
        sourceLesson: lessonCode,
        linkedTool: toolCode,
      );

      // 2) Create a supportive, practical "Her Direction" summary item.
      // We store it in `her_notes` with a dedicated prompt so it can be rendered
      // as an actionable feed inside the Her pillar (and hidden from Her Notes).
      final summary = _buildHerGoalSummary(toolCode: toolCode, goalLabel: goalLabel);
      await client.from('her_notes').insert({
        'user_id': userId,
        'lesson_code': lessonCode,
        'prompt': 'GOAL_SUMMARY',
        'response': jsonEncode({
          'goal_code': goalCode,
          'goal_label': goalLabel,
          'linked_tool': toolCode,
          'meaning': summary.meaning,
          'next_step': summary.nextStep,
          'long_game_link': summary.longGameLink,
        }),
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('[GoalSave] SUCCESS');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to your goals'),
            backgroundColor: HLGColors.deepSage,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('[GoalSave] FAILED: $e');
      debugPrint('[GoalSave] stack: $stack');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal save failed: ${e.toString()}'),
            backgroundColor: HLGColors.horizonOrange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: HLGColors.warmCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HLGColors.sageMid.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: HLGColors.horizonOrange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(toolCode, style: HLGTextStyles.labelMedium(color: HLGColors.warmCream).copyWith(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(_toolName(), style: HLGTextStyles.h3SubheadItalic(color: HLGColors.textBody))),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: HLGColors.textMuted),
                  iconSize: 20,
                  splashRadius: 18,
                ),
              ],
            ),
          ),
          Container(height: 1, color: HLGColors.horizonOrange.withValues(alpha: 0.3)),
          Expanded(child: _buildTool(context)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            color: HLGColors.creamWarm,
            child: Text(
              'General financial education only. Not personal financial advice. Individual outcomes vary.',
              style: HLGTextStyles.uiElement(color: HLGColors.textMuted).copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTool(BuildContext context) {
    switch (toolCode) {
      case 'T0':
        return BubbleIndexWidget(
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T1':
        return InflationThiefWidget(
          cashAmount: 20000,
          onSave: (outputs) => _saveToolState(context, {'cash_amount': 20000}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T2':
        return SalaryRippleWidget(
          initialSalary: 75000,
          currentAge: 35,
          onSave: (inputs, outputs) => _saveToolState(context, inputs, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T3':
        return TimeMachineWidget(
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T3b':
        return TheCurveWidget(
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T4':
        return DebtRaceWidget(
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T4b':
        return TrueCostWidget(
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T5':
        return FortressWidget(
          monthlyExpenses: 3200,
          currentSavings: 0,
          initialContribution: 150,
          onSave: (outputs) => _saveToolState(context, {'monthly_expenses': 3200, 'current_savings': 0, 'initial_contribution': 150}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T6':
        return SuperWarpWidget(
          currentAge: 35,
          superBalance: 45000,
          annualSalary: 75000,
          currentOption: 'Balanced',
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      case 'T7':
        return InvisibleInvoiceWidget(
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      // T8: Portrait Builder — requires the `generate_portrait` Supabase Edge Function.
      // Deploy supabase/functions/generate_portrait/ before activating this tool
      // in lesson_screens (set tool_code = 'T8' on F8 action screen).
      case 'T8':
        return PortraitBuilderWidget(
          onSave: (outputs) => _saveToolState(context, <String, dynamic>{}, outputs),
          onAddGoal: (label) => _addGoal(context, label),
        );
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(toolCode, style: HLGTextStyles.h1Display(color: HLGColors.sagePale)),
                const SizedBox(height: 16),
                Text(
                  '${_toolName()} is coming soon.',
                  style: HLGTextStyles.body(color: HLGColors.sageMid).copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }

  _HerGoalSummary _buildHerGoalSummary({required String toolCode, required String goalLabel}) {
    // Simple, clarity-first heuristics. The goal is "supportive and practical",
    // not clever.
    switch (toolCode) {
      case 'T5':
        return const _HerGoalSummary(
          meaning: 'You\u2019re building stability: a buffer that turns surprises into admin \u2013 not emergencies.',
          nextStep: 'Pick a target (1 month to start) and schedule one automatic transfer today.',
          longGameLink: 'This is the foundation that makes every other long game move feel safer.',
        );
      case 'T4':
        return const _HerGoalSummary(
          meaning: 'You\u2019re choosing time back: paying down debt reduces pressure and restores options.',
          nextStep: 'Choose one payoff method (snowball or avalanche) and set a weekly payment you can repeat.',
          longGameLink: 'Less debt = more bandwidth to invest, negotiate, and plan longer.',
        );
      case 'T2':
        return const _HerGoalSummary(
          meaning: 'You\u2019re increasing earning power \u2013 the lever that accelerates everything else.',
          nextStep: 'Book one action: prepare your case, update your market benchmarks, or schedule the conversation.',
          longGameLink: 'Higher income widens your choices: saving, investing, and freedom timelines.',
        );
      case 'T6':
        return const _HerGoalSummary(
          meaning: 'You\u2019re prioritising starting over perfection \u2013 momentum beats waiting for certainty.',
          nextStep: 'Set the smallest "I will do this monthly" amount and automate it now.',
          longGameLink: 'Compounding rewards consistency. The point is to start and stay in the game.',
        );
      case 'T3':
      case 'T3b':
        return const _HerGoalSummary(
          meaning: 'You\u2019re turning a habit into a long-term win \u2013 redirecting small choices into future outcomes.',
          nextStep: 'Pick one habit to redirect and set a simple rule you can follow this week.',
          longGameLink: 'This is how the long game is built: repeated, small, honest choices.',
        );
      case 'T7':
        return const _HerGoalSummary(
          meaning: 'You\u2019re surfacing hidden costs \u2013 the money that leaks quietly is the easiest to reclaim.',
          nextStep: 'Find one subscription or "default spend" to pause or renegotiate in the next 48 hours.',
          longGameLink: 'Less leakage = more room for savings, investing, and calm.',
        );
      case 'T1':
      case 'T0':
        return const _HerGoalSummary(
          meaning: 'You\u2019re making your plan realistic \u2013 protecting buying power and keeping progress honest.',
          nextStep: 'Choose one number to track monthly (expenses, savings rate, or investing contribution).',
          longGameLink: 'Reality-based planning prevents quiet drift and keeps you moving forward.',
        );
      default:
        return _HerGoalSummary(
          meaning: 'This goal is a decision to pay attention \u2013 and build momentum from where you are.',
          nextStep: 'Define the next smallest action you can take in the next 7 days.',
          longGameLink: 'The long game is built through repeatable actions, not perfect plans.',
        );
    }
  }
}

class _HerGoalSummary {
  const _HerGoalSummary({required this.meaning, required this.nextStep, required this.longGameLink});

  final String meaning;
  final String nextStep;
  final String longGameLink;
}
