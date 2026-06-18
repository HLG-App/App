import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/theme.dart';

/// Tool widget: "Emergency Fund Fortress" (T5).
///
/// This is a lightweight, UI-forward tool that produces a simple savings plan
/// and hands back a serializable payload via [onSave].
class FortressWidget extends StatefulWidget {
  const FortressWidget({
    super.key,
    required this.monthlyExpenses,
    required this.currentSavings,
    required this.initialContribution,
    required this.onSave,
    required this.onAddGoal,
  });

  final double monthlyExpenses;
  final double currentSavings;
  final double initialContribution;
  final void Function(Map<String, dynamic> payload) onSave;
  final void Function(String goalText) onAddGoal;

  @override
  State<FortressWidget> createState() => _FortressWidgetState();
}

class _FortressWidgetState extends State<FortressWidget> {
  static const List<int> _targets = [1, 3, 6];

  int _monthsTarget = 3;
  double _monthlyContribution = 150;

  @override
  void initState() {
    super.initState();
    _monthlyContribution = widget.initialContribution;
  }

  @override
  Widget build(BuildContext context) {
    final targetAmount = widget.monthlyExpenses * _monthsTarget;
    final remaining = (targetAmount - widget.currentSavings).clamp(0, double.infinity).toDouble();
    final monthsToGoal = _monthlyContribution <= 0 ? double.infinity : remaining / _monthlyContribution;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('T5 · EMERGENCY FUND FORTRESS', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.horizonOrange)),
          const SizedBox(height: AppSpacing.sm),
          Text('Build a buffer that buys you time.', style: HLGTextStyles.h3SubheadItalic(color: HLGColors.textBody)),
          const SizedBox(height: AppSpacing.lg),
          _FortressSummaryCard(
            monthlyExpenses: widget.monthlyExpenses,
            currentSavings: widget.currentSavings,
            monthsTarget: _monthsTarget,
            targetAmount: targetAmount,
            remaining: remaining,
            monthlyContribution: _monthlyContribution,
            monthsToGoal: monthsToGoal,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Choose your fortress size', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _targets.map((m) {
              final selected = m == _monthsTarget;
              return ChoiceChip(
                selected: selected,
                showCheckmark: false,
                label: Text('$m months', style: HLGTextStyles.labelMedium(color: selected ? HLGColors.warmCream : HLGColors.textBody)),
                selectedColor: HLGColors.deepSage,
                backgroundColor: HLGColors.petal,
                side: BorderSide(color: selected ? HLGColors.deepSage : HLGColors.sagePale),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                onSelected: (_) => setState(() => _monthsTarget = m),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Monthly contribution', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: HLGColors.horizonOrange,
              inactiveTrackColor: HLGColors.sagePale,
              thumbColor: HLGColors.horizonOrange,
              overlayColor: HLGColors.horizonOrange.withValues(alpha: 0.12),
              valueIndicatorColor: HLGColors.night,
              valueIndicatorTextStyle: HLGTextStyles.labelMedium(color: HLGColors.warmCream),
            ),
            child: Slider(
              min: 0,
              max: 1000,
              divisions: 40,
              value: _monthlyContribution.clamp(0, 1000).toDouble(),
              label: _formatCurrency(_monthlyContribution),
              onChanged: (v) => setState(() => _monthlyContribution = v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: HLGColors.deepSage,
              foregroundColor: HLGColors.warmCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              final payload = {
                'tool': 'emergency_fund_fortress',
                'monthly_expenses': widget.monthlyExpenses,
                'current_savings': widget.currentSavings,
                'months_target': _monthsTarget,
                'target_amount': targetAmount,
                'remaining_to_target': remaining,
                'monthly_contribution': _monthlyContribution,
                'estimated_months_to_goal': monthsToGoal.isFinite ? monthsToGoal : null,
                'saved_at': DateTime.now().toIso8601String(),
              };
              debugPrint('[FortressWidget] onSave payload=$payload');
              widget.onSave(payload);
            },
            child: Text('Save', style: HLGTextStyles.homeCta15(color: HLGColors.warmCream)),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: HLGColors.deepSage,
              side: BorderSide(color: HLGColors.deepSage.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              const goal = 'Build my emergency fund this month';
              debugPrint('[FortressWidget] onAddGoal: $goal');
              widget.onAddGoal(goal);
            },
            child: Text('Add Goal', style: HLGTextStyles.homeCta15(color: HLGColors.deepSage)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Illustrative only. Adjust target size and contribution to fit your real cashflow.',
            style: HLGTextStyles.uiElement(color: HLGColors.midSage),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double v) {
    final rounded = v.round();
    final str = rounded.toString();
    final buff = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final idxFromEnd = str.length - i;
      buff.write(str[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buff.write(',');
    }
    return '\$${buff.toString()}';
  }
}

class _FortressSummaryCard extends StatelessWidget {
  const _FortressSummaryCard({
    required this.monthlyExpenses,
    required this.currentSavings,
    required this.monthsTarget,
    required this.targetAmount,
    required this.remaining,
    required this.monthlyContribution,
    required this.monthsToGoal,
  });

  final double monthlyExpenses;
  final double currentSavings;
  final int monthsTarget;
  final double targetAmount;
  final double remaining;
  final double monthlyContribution;
  final double monthsToGoal;

  @override
  Widget build(BuildContext context) {
    final pct = targetAmount <= 0 ? 0.0 : (currentSavings / targetAmount).clamp(0, 1).toDouble();
    final monthsLabel = monthsToGoal.isFinite ? monthsToGoal.ceil().toString() : '-';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: HLGColors.sagePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('$monthsTarget-month fortress', style: HLGTextStyles.h3SubheadItalic(color: HLGColors.textBody))),
              Text('${(pct * 100).round()}%', style: HLGTextStyles.labelMedium(color: HLGColors.deepSage).copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: HLGColors.warmCream,
              valueColor: const AlwaysStoppedAnimation(HLGColors.horizonOrange),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(label: 'Monthly expenses', value: _fmt(monthlyExpenses)),
          _MetricRow(label: 'Target amount', value: _fmt(targetAmount)),
          _MetricRow(label: 'Current savings', value: _fmt(currentSavings)),
          _MetricRow(label: 'Remaining', value: _fmt(remaining)),
          _MetricRow(label: 'Contribution / month', value: _fmt(monthlyContribution)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            monthsToGoal.isFinite
                ? 'At this pace: ~${monthsLabel} month${monthsLabel == '1' ? '' : 's'} to target.'
                : 'Set a monthly contribution to estimate time to target.',
            style: HLGTextStyles.body(color: HLGColors.textBody).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    final rounded = v.round();
    final str = rounded.toString();
    final buff = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final idxFromEnd = str.length - i;
      buff.write(str[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buff.write(',');
    }
    return '\$${buff.toString()}';
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: HLGTextStyles.uiElement(color: HLGColors.textMuted))),
          Text(value, style: HLGTextStyles.uiElement(color: HLGColors.textBody).copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
