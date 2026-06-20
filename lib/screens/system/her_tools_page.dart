import 'package:flutter/material.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/her_tab_header.dart';
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
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HerTabHeader(
              tabLabel: 'SYSTEM',
              title: 'Tools that make it real',
              subtitle: 'Calculators and what‑ifs — so the concepts land in your numbers.',
              padding: EdgeInsets.fromLTRB(20, 12, 20, 18),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  const _ToolsIntroCard(),
                  const SizedBox(height: 18),
                  for (final section in _sections) ...[
                    _ToolsSectionHeader(title: section.title, subtitle: section.subtitle),
                    const SizedBox(height: 12),
                    for (final category in section.categoryOrder)
                      for (final tool in (toolsByCategory[category] ?? const <_ToolEntry>[])) ...[
                        _ToolCard(
                          entry: tool,
                          onTap: () => ToolBottomSheet.show(context, toolCode: tool.code, lessonCode: 'SYSTEM'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
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
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: HLGColors.deepSage.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: HLGColors.warmCream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HLGColors.deepSage.withValues(alpha: 0.12)),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: HLGColors.deepSage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tools — in one place', style: HLGTextStyles.moduleTitle(color: HLGColors.textBody)),
                const SizedBox(height: 4),
                Text('Same tools as inside lessons. Here for quick, calm access.', style: HLGTextStyles.homeBody14(color: HLGColors.textMuted)),
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

  Color get _accent {
    switch (entry.category) {
      case _ToolCategory.clarity:
        return HLGColors.crownGold;
      case _ToolCategory.spending:
        return HLGColors.horizonOrange;
      case _ToolCategory.security:
        return HLGColors.deepSage;
      case _ToolCategory.growth:
        return HLGColors.sage;
      case _ToolCategory.debt:
        return HLGColors.antiqueRose;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HLGColors.warmCream,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Row(
            children: [
              Container(width: 5, height: 124, color: _accent.withValues(alpha: 0.85)),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: _accent.withValues(alpha: 0.18), width: 1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(entry.icon, color: _accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.brandedName,
                              style: HLGTextStyles.quoteItalic(color: HLGColors.textBody).copyWith(fontWeight: FontWeight.w600, height: 1.25),
                            ),
                            const SizedBox(height: 4),
                            Text(entry.functionalTitle, style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
                            const SizedBox(height: 10),
                            Text(
                              entry.bringsToAttention,
                              style: HLGTextStyles.homeBody14(color: HLGColors.textBody).copyWith(height: 1.55),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HLGColors.sageMid),
                    ],
                  ),
                ),
              ),
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
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.crownGold)),
          const SizedBox(height: 6),
          Text(title, style: HLGTextStyles.lessonHeading(color: HLGColors.textBody).copyWith(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: HLGTextStyles.homeBody14(color: HLGColors.textMuted).copyWith(height: 1.55)),
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
