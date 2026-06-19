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
      functionalTitle: 'Inflation Reality Check Tool',
      brandedName: 'The Bubble O\' Bill Index',
      bringsToAttention: 'Whether your gains are real \u2013 or just keeping up with rising prices.',
      category: _ToolCategory.growth,
      icon: Icons.trending_up_rounded,
    ),
    _ToolEntry(
      code: 'T1',
      functionalTitle: 'Inflation Impact Tool',
      brandedName: 'Inflation Thief',
      bringsToAttention: 'What inflation quietly erodes in your day-to-day buying power.',
      category: _ToolCategory.clarity,
      icon: Icons.remove_circle_outline_rounded,
    ),
    _ToolEntry(
      code: 'T2',
      functionalTitle: 'Raise Impact Tool',
      brandedName: 'Salary Ripple',
      bringsToAttention: 'The real long-tail impact of a raise (and what it unlocks).',
      category: _ToolCategory.growth,
      icon: Icons.waves_rounded,
    ),
    _ToolEntry(
      code: 'T3',
      functionalTitle: 'Habit Compounding Tool',
      brandedName: 'Coffee Shop Time Machine',
      bringsToAttention: 'How small habits compound over time \u2013 and what they become instead.',
      category: _ToolCategory.spending,
      icon: Icons.timelapse_rounded,
    ),
    _ToolEntry(
      code: 'T3b',
      functionalTitle: 'Compounding Curve Tool',
      brandedName: 'The Curve',
      bringsToAttention: 'Momentum \u2013 when you\'re flat, and when you\'re finally compounding.',
      category: _ToolCategory.growth,
      icon: Icons.show_chart_rounded,
    ),
    _ToolEntry(
      code: 'T4',
      functionalTitle: 'Debt Payoff Strategy Tool',
      brandedName: 'Debt Race',
      bringsToAttention: 'Which payoff strategy wins \u2013 and how much time/interest you save.',
      category: _ToolCategory.debt,
      icon: Icons.flag_rounded,
    ),
    _ToolEntry(
      code: 'T4b',
      functionalTitle: 'Spending Tradeoff Tool',
      brandedName: 'True Cost Calculator',
      bringsToAttention: 'Purchases translated into time, tradeoffs, and what they cost you next.',
      category: _ToolCategory.spending,
      icon: Icons.receipt_long_rounded,
    ),
    _ToolEntry(
      code: 'T5',
      functionalTitle: 'Emergency Fund Sizing Tool',
      brandedName: 'Emergency Fund Fortress',
      bringsToAttention: 'Your runway \u2013 how safe you are if income dips, and what covers you.',
      category: _ToolCategory.security,
      icon: Icons.shield_rounded,
    ),
    _ToolEntry(
      code: 'T6',
      functionalTitle: 'Start Now vs Wait Tool',
      brandedName: 'Super Time Warp',
      bringsToAttention: 'The cost of waiting \u2013 and the difference a small start makes.',
      category: _ToolCategory.security,
      icon: Icons.hourglass_bottom_rounded,
    ),
    _ToolEntry(
      code: 'T7',
      functionalTitle: 'Hidden Costs Audit Tool',
      brandedName: 'Invisible Invoice',
      bringsToAttention: 'The hidden costs you\'re already paying (without noticing).',
      category: _ToolCategory.clarity,
      icon: Icons.visibility_off_rounded,
    ),
    // T8 requires the `generate_portrait` Edge Function \u2014 activate after deployment.
    _ToolEntry(
      code: 'T8',
      functionalTitle: 'Financial Life Portrait Tool',
      brandedName: 'Your Portrait',
      bringsToAttention: 'What your financial life needs to look like \u2014 built entirely around yours.',
      category: _ToolCategory.growth,
      icon: Icons.person_outline_rounded,
    ),
  ];

  static const List<_ToolsSection> _sections = [
    _ToolsSection(
      title: 'Start here (quick clarity)',
      subtitle: 'The fastest tools to surface leaks and blind spots.',
      categoryOrder: [_ToolCategory.clarity],
    ),
    _ToolsSection(
      title: 'Spend with intention',
      subtitle: 'Make everyday decisions feel lighter (and more honest).',
      categoryOrder: [_ToolCategory.spending],
    ),
    _ToolsSection(
      title: 'Stability & protection',
      subtitle: 'Build buffers so one surprise doesn\u2019t undo momentum.',
      categoryOrder: [_ToolCategory.security],
    ),
    _ToolsSection(
      title: 'Growth & momentum',
      subtitle: 'See compounding in a way that actually motivates action.',
      categoryOrder: [_ToolCategory.growth],
    ),
    _ToolsSection(
      title: 'Debt & clean-up',
      subtitle: 'Compare strategies and pick the path that ends sooner.',
      categoryOrder: [_ToolCategory.debt],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final toolsByCategory = <_ToolCategory, List<_ToolEntry>>{};
    for (final t in _tools) {
      toolsByCategory.putIfAbsent(t.category, () => []).add(t);
    }

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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _ToolsIntroCard(),
            const SizedBox(height: 16),
            for (final section in _sections) ...[
              _ToolsSectionHeader(title: section.title, subtitle: section.subtitle),
              const SizedBox(height: 10),
              for (final category in section.categoryOrder)
                for (final tool in (toolsByCategory[category] ?? const <_ToolEntry>[])) ...[
                  _ToolCard(
                    entry: tool,
                    onTap: () => ToolBottomSheet.show(context, toolCode: tool.code, lessonCode: 'SYSTEM'),
                  ),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 6),
            ],
          ],
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
                Text('Tools \u2013 in one place', style: HLGTextStyles.moduleTitle(color: HLGColors.night)),
                const SizedBox(height: 4),
                Text('These are the same tools you see inside lessons, surfaced here for quick access.', style: HLGTextStyles.homeBody14(color: HLGColors.textMuted)),
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
                decoration: BoxDecoration(
                  color: HLGColors.sagePale,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.22)),
                ),
                child: Icon(entry.icon, color: HLGColors.deepSage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.functionalTitle, style: HLGTextStyles.moduleTitle(color: HLGColors.night)),
                    const SizedBox(height: 4),
                    Text(
                      entry.brandedName,
                      style: HLGTextStyles.labelMedium(color: HLGColors.crownGold).copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text('What it brings to your attention: ${entry.bringsToAttention}', style: HLGTextStyles.homeBody14(color: HLGColors.textMuted)),
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

class _ToolsSectionHeader extends StatelessWidget {
  const _ToolsSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: HLGTextStyles.moduleTitle(color: HLGColors.night)),
          const SizedBox(height: 4),
          Text(subtitle, style: HLGTextStyles.homeBody14(color: HLGColors.textMuted)),
        ],
      ),
    );
  }
}

class _ToolsSection {
  const _ToolsSection({required this.title, required this.subtitle, required this.categoryOrder});

  final String title;
  final String subtitle;
  final List<_ToolCategory> categoryOrder;
}

enum _ToolCategory { clarity, spending, security, growth, debt }

class _ToolEntry {
  const _ToolEntry({
    required this.code,
    required this.functionalTitle,
    required this.brandedName,
    required this.bringsToAttention,
    required this.category,
    required this.icon,
  });

  final String code;
  final String functionalTitle;
  final String brandedName;
  final String bringsToAttention;
  final _ToolCategory category;
  final IconData icon;
}
