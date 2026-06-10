import 'package:flutter/material.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/tool_bottom_sheet.dart';

/// HerTools (pillar)
///
/// This page surfaces the existing lesson tools in one place.
///
/// IMPORTANT:
/// - Embedded tools in lessons remain exactly where they are.
/// - This is an additional access point (organising layer), not a rebuild.
class HerToolsPage extends StatelessWidget {
  const HerToolsPage({super.key});

  static const List<_ToolEntry> _tools = [
    _ToolEntry(
      code: 'T0',
      title: 'Bubble O\' Bill Index',
      subtitle: 'See your asset growth measured in real purchasing power.',
    ),
    _ToolEntry(code: 'T1', title: 'Inflation Thief', subtitle: 'See what inflation quietly takes.'),
    _ToolEntry(code: 'T2', title: 'Salary Ripple', subtitle: 'Explore the long game impact of a raise.'),
    _ToolEntry(code: 'T3', title: 'Coffee Shop Time Machine', subtitle: 'Tiny choices, compounding outcomes.'),
    _ToolEntry(code: 'T3b', title: 'The Curve', subtitle: 'Visualise momentum over time.'),
    _ToolEntry(code: 'T4', title: 'Debt Race', subtitle: 'Compare strategies and timelines.'),
    _ToolEntry(code: 'T4b', title: 'True Cost Calculator', subtitle: 'Translate purchases into time + tradeoffs.'),
    _ToolEntry(code: 'T5', title: 'Emergency Fund Fortress', subtitle: 'Build stability with a simple runway.'),
    _ToolEntry(code: 'T6', title: 'Super Time Warp', subtitle: 'See what time does for retirement savings.'),
    _ToolEntry(code: 'T7', title: 'Invisible Invoice', subtitle: 'Find the hidden costs you’re already paying.'),
    _ToolEntry(code: 'T8', title: 'Future Self Portrait', subtitle: 'Make the future feel emotionally real.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/system',
        title: Text('Her Tools', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: _tools.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) return const _ToolsIntroCard();
            final tool = _tools[index - 1];
            return _ToolCard(
              entry: tool,
              onTap: () => ToolBottomSheet.show(context, toolCode: tool.code, lessonCode: 'SYSTEM'),
            );
          },
        ),
      ),
    );
  }
}

class _ToolsIntroCard extends StatelessWidget {
  const _ToolsIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        // Make the intro card visually distinct from the tool cards.
        color: HLGColors.sagePale,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: HLGColors.crownGold.withValues(alpha: 0.55), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(color: HLGColors.petal, borderRadius: BorderRadius.circular(14), border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.25))),
            child: const Icon(Icons.auto_awesome_rounded, color: HLGColors.deepSage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tools — in one place', style: HLGTextStyles.moduleTitle(color: HLGColors.night)),
                const SizedBox(height: 4),
                Text('These are the same tools you see inside lessons—surfaced here for quick access.', style: HLGTextStyles.homeBody14(color: HLGColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.entry, required this.onTap});

  final _ToolEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HLGColors.petal,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(color: HLGColors.sagePale, borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text(entry.code, style: HLGTextStyles.labelMedium(color: HLGColors.deepSage).copyWith(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: HLGTextStyles.moduleTitle(color: HLGColors.night)),
                    const SizedBox(height: 4),
                    Text(entry.subtitle, style: HLGTextStyles.homeBody14(color: HLGColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: HLGColors.midSage),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolEntry {
  const _ToolEntry({required this.code, required this.title, required this.subtitle});

  final String code;
  final String title;
  final String subtitle;
}
