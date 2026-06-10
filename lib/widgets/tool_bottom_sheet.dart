import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tools/salary_ripple_widget.dart';
import 'tools/time_machine_widget.dart';
import 'tools/the_curve_widget.dart';
import 'tools/debt_race_widget.dart';
import 'tools/true_cost_widget.dart';
import 'tools/invisible_invoice_widget.dart';
import 'tools/portrait_builder_widget.dart';
import 'tools/fortress_widget.dart';
import 'tools/super_warp_widget.dart';
import 'tools/inflation_thief_widget.dart';
import 'tools/bubble_index_widget.dart';

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
      'T8': 'Future Self Portrait',
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

      debugPrint('[ToolSave] START — toolCode=$toolCode userId=$userId');

      if (userId == null) {
        debugPrint('[ToolSave] BLOCKED — no authenticated user');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to save'),
              backgroundColor: Color(0xFFD4621A),
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
            backgroundColor: Color(0xFF5C7A62),
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
            backgroundColor: const Color(0xFFD4621A),
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

      debugPrint('[GoalSave] START — toolCode=$toolCode label=$goalLabel userId=$userId');

      if (userId == null) {
        debugPrint('[GoalSave] BLOCKED — no authenticated user');
        return;
      }

      await client.from('goals').insert({
        'user_id': userId,
        'goal_code': '${toolCode.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        'label': goalLabel,
        'goal_type': 'weekly',
        'linked_tool': toolCode,
        'source_lesson': lessonCode,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('[GoalSave] SUCCESS');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to your goals'),
            backgroundColor: Color(0xFF5C7A62),
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
            backgroundColor: const Color(0xFFD4621A),
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
              color: HLGColors.midSage.withValues(alpha: 0.4),
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
                  icon: const Icon(Icons.close, color: HLGColors.midSage),
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
            color: HLGColors.petal,
            child: Text(
              'General financial education only. Not personal financial advice. Individual outcomes vary.',
              style: HLGTextStyles.uiElement(color: HLGColors.midSage).copyWith(fontStyle: FontStyle.italic),
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
        );
      case 'T1':
        return InflationThiefWidget(
          cashAmount: 20000,
          onSave: (outputs) => _saveToolState(context, {'cash_amount': 20000}, outputs),
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
                  style: HLGTextStyles.body(color: HLGColors.midSage).copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }
}
