import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

/// First-time onboarding flow.
///
/// Design note: The repo currently does not include a `Design.md` file.
/// This implementation follows the existing HLG theme + branded header system.
class OnboardingIntroFlowPage extends StatefulWidget {
  const OnboardingIntroFlowPage({super.key, required this.isReplay});

  final bool isReplay;

  @override
  State<OnboardingIntroFlowPage> createState() => _OnboardingIntroFlowPageState();
}

class _OnboardingIntroFlowPageState extends State<OnboardingIntroFlowPage> {
  // This page is now the practical "App Guide" (not the manifesto onboarding).
  // It intentionally contains only:
  // - App map
  // - How to get the most out of the app
  static const int _totalSteps = 2;

  int _step = 0;
  bool _saving = false;

  Future<void> _finish({required bool goToLearn}) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (!mounted) return;
      if (widget.isReplay) {
        context.pop();
        return;
      }
      if (goToLearn) {
        context.go('${AppRoutes.learn}?welcome=1');
      } else {
        // First-run home card should appear once after onboarding.
        context.go('${AppRoutes.home}?welcome=1');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skipAll() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (!mounted) return;
      // If they skip, we still don’t block them later. Gentle reminder can be shown on Home.
      context.go('${AppRoutes.home}?baseline_reminder=1');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goNext() {
    if (_step >= _totalSteps - 1) return;
    setState(() => _step += 1);
  }

  void _goBack() {
    if (_step <= 0) return;
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: HerAppBar(
        showBack: _step > 0,
        onBackPressed: _goBack,
        useBrandBand: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(
              stepIndex: _step,
              totalSteps: _totalSteps,
              onBack: _step > 0 ? _goBack : null,
              onSkip: _saving ? null : _skipAll,
              isReplay: widget.isReplay,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Padding(
                  key: ValueKey<int>(_step),
                  padding: AppSpacing.paddingLg,
                  child: _OnboardingStepBody(
                    step: _step,
                    moneyFeels: null,
                    onMoneyFeelsChanged: (_) {},
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).viewPadding.bottom),
              decoration: BoxDecoration(color: cs.surface, border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)))),
              child: _OnboardingActions(
                step: _step,
                isSaving: _saving,
                moneyFeels: null,
                onPrimaryPressed: () async {
                  switch (_step) {
                      case 0:
                        _goNext();
                        return;
                      case 1:
                        await _finish(goToLearn: false);
                        return;
                  }
                },
                onSecondaryPressed: () async {
                  switch (_step) {
                    case 0:
                        // Only offer "Skip" for non-replay entry points.
                        if (!widget.isReplay) await _skipAll();
                      return;
                      case 1:
                        await _finish(goToLearn: true);
                      return;
                    default:
                      // No-op for steps without a secondary action.
                      return;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.stepIndex,
    required this.totalSteps,
    required this.onBack,
    required this.onSkip,
    required this.isReplay,
  });

  final int stepIndex;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final bool isReplay;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Step ${stepIndex + 1} of $totalSteps',
              style: t.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          if (!isReplay)
            TextButton(
              onPressed: onSkip,
              child: Text('Skip', style: t.textTheme.labelLarge?.copyWith(color: cs.primary)),
            )
          else
            const SizedBox(width: 72),
        ],
      ),
    );
  }
}

class _OnboardingStepBody extends StatelessWidget {
  const _OnboardingStepBody({required this.step, required this.moneyFeels, required this.onMoneyFeelsChanged});

  final int step;
  final String? moneyFeels;
  final ValueChanged<String> onMoneyFeelsChanged;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return const _AppMapStep();
      case 1:
        return const _BestOutOfAppStep();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.title, required this.body, this.footerNote});

  final String title;
  final List<Widget> body;
  final Widget? footerNote;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.titleLarge),
            const SizedBox(height: 12),
            ...body,
            if (footerNote != null) ...[
              const SizedBox(height: 16),
              footerNote!,
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _StepScaffold(
      title: 'Welcome to Her Long Game',
      body: [
        Text('This is financial education for women who want to understand money, build confidence, and stop feeling behind.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('You do not need to know everything before you start.', style: t.bodyMedium),
        const SizedBox(height: 6),
        Text('You just need a place to start.', style: t.bodyMedium),
      ],
    );
  }
}

// ignore: unused_element
class _WhyThisExistsStep extends StatelessWidget {
  const _WhyThisExistsStep();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _StepScaffold(
      title: 'Why this exists',
      body: [
        Text('Women are expected to make financial decisions every day.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('Budgeting. Debt. Super. Investing. Property. Career breaks. Family decisions. Retirement.', style: t.bodyMedium),
        const SizedBox(height: 12),
        Text('But most of us were never properly taught how the system works.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('Her Long Game was built to close that gap.', style: t.bodyMedium),
        const SizedBox(height: 14),
        Text('Not with hype.', style: t.bodyMedium),
        const SizedBox(height: 6),
        Text('Not with shame.', style: t.bodyMedium),
        const SizedBox(height: 6),
        Text('Not with financial advice.', style: t.bodyMedium),
        const SizedBox(height: 14),
        Text('With plain English education, context, tools and space to build confidence over time.', style: t.bodyMedium),
      ],
    );
  }
}

class _WhatItDoesStep extends StatelessWidget {
  const _WhatItDoesStep();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _StepScaffold(
      title: 'What Her Long Game helps you do',
      body: [
        Text('Her Long Game helps you understand how money works.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('You will learn the language, history, principles and systems behind financial decisions.', style: t.bodyMedium),
        const SizedBox(height: 14),
        _BulletList(items: const [
          'Follow structured lessons',
          'Use simple tools',
          'Save notes and reflections',
          'Build your own financial goals',
          'Return to what matters later',
          'Learn from wisdom passed on by other women',
        ]),
        const SizedBox(height: 12),
        Text('This is about building understanding before pressure.', style: t.bodyMedium),
      ],
    );
  }
}

class _WhatItDoesNotDoStep extends StatelessWidget {
  const _WhatItDoesNotDoStep();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return _StepScaffold(
      title: 'What this app does not do',
      body: [
        Text('Her Long Game does not give personal financial advice.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('It will not tell you what to buy, sell, invest in, borrow, cancel or choose.', style: t.bodyMedium),
        const SizedBox(height: 6),
        Text('It does not know your full financial situation.', style: t.bodyMedium),
        const SizedBox(height: 12),
        Text('The app is here to help you understand money more clearly so you can ask better questions, make more informed decisions, and seek professional advice where needed.', style: t.bodyMedium),
      ],
      footerNote: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
        ),
        child: Text(
          'General financial education only. Not personal financial advice.',
          style: t.labelLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _StartingPointStep extends StatelessWidget {
  const _StartingPointStep({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  static const List<String> _options = [
    'Overwhelming',
    'Confusing',
    'Avoided',
    'Okay, but unclear',
    'Something I want to understand',
    'Something I feel confident with',
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return _StepScaffold(
      title: 'Start where you are',
      body: [
        Text('Money can feel different depending on your life stage, income, family, past experiences and confidence.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('Before you begin, we may ask a few questions about how money feels for you right now.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('This helps the app understand your starting point and personalise what you see.', style: t.bodyMedium),
        const SizedBox(height: 16),
        Text('Right now, money feels:', style: t.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final opt in _options)
              ChoiceChip(
                label: Text(opt, overflow: TextOverflow.ellipsis),
                selected: selected == opt,
                onSelected: (_) => onSelected(opt),
                labelStyle: t.labelLarge,
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
          ],
        ),
      ],
    );
  }
}

class _AppMapStep extends StatelessWidget {
  const _AppMapStep();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _StepScaffold(
      title: 'How the app is organised',
      body: [
        Text('Her Long Game has five main spaces.', style: t.bodyMedium),
        const SizedBox(height: 6),
        Text('Each one has a different job.', style: t.bodyMedium),
        const SizedBox(height: 16),
        const _AppMapCarousel(),
      ],
    );
  }
}

class _AppMapCarousel extends StatefulWidget {
  const _AppMapCarousel();

  @override
  State<_AppMapCarousel> createState() => _AppMapCarouselState();
}

class _AppMapCarouselState extends State<_AppMapCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _index = 0;

  static const List<_AppMapCardData> _cards = [
    _AppMapCardData(
      title: 'Home',
      body: 'Your starting point each time you open the app.\n\nUse Home to see what to do next, continue learning, return to tools, and keep track of your progress.',
      icon: Icons.home_rounded,
    ),
    _AppMapCardData(
      title: 'Her',
      body: 'Your personal space.\n\nUse Her to see your reflections, saved notes, goals, current focus and the pieces you want to carry forward.',
      icon: Icons.favorite_rounded,
    ),
    _AppMapCardData(
      title: 'Learn',
      body: 'Your lesson library.\n\nUse Learn to follow the Her Long Game curriculum, build your financial foundations and understand the system step by step.',
      icon: Icons.school_rounded,
    ),
    _AppMapCardData(
      title: 'Wisdom',
      body: 'Your plain-English money library.\n\nUse Wisdom for explainers, field notes, definitions, community insights and the things women wish they had been taught earlier.',
      icon: Icons.menu_book_rounded,
    ),
    _AppMapCardData(
      title: 'Profile',
      body: 'Your account and settings.\n\nUse Profile to manage your details, privacy, preferences, progress and support options.',
      icon: Icons.person_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _controller,
            itemCount: _cards.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _AppMapCard(data: _cards[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Dots(count: _cards.length, index: _index),
      ],
    );
  }
}

class _AppMapCardData {
  const _AppMapCardData({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;
}

class _AppMapCard extends StatelessWidget {
  const _AppMapCard({required this.data});

  final _AppMapCardData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7))),
            child: Icon(data.icon, color: cs.primary),
          ),
          const SizedBox(height: 12),
          Text(data.title, style: t.titleMedium),
          const SizedBox(height: 8),
          Expanded(child: Text(data.body, style: t.bodyMedium)),
        ],
      ),
    );
  }
}

class _BestOutOfAppStep extends StatelessWidget {
  const _BestOutOfAppStep();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _StepScaffold(
      title: 'How to get the best out of Her Long Game',
      body: [
        Text('You do not need to rush.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('The best way to use Her Long Game is to move through it slowly and honestly.', style: t.bodyMedium),
        const SizedBox(height: 14),
        _BulletList(items: const [
          'Start with one lesson',
          'Save the ideas that land',
          'Use tools with real numbers when you can',
          'Write notes in your own words',
          'Come back when life changes',
          'Use what you learn to ask better questions',
        ]),
        const SizedBox(height: 14),
        Text('This is not about being perfect with money.', style: t.bodyMedium),
        const SizedBox(height: 6),
        Text('It is about understanding the game you are already in.', style: t.bodyMedium),
      ],
    );
  }
}

// ignore: unused_element
class _FinalStep extends StatelessWidget {
  const _FinalStep();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _StepScaffold(
      title: 'Start where you are',
      body: [
        Text('You are not behind.', style: t.bodyMedium),
        const SizedBox(height: 10),
        Text('You are learning the system that was not always explained to you.', style: t.bodyMedium),
        const SizedBox(height: 12),
        Text('Start with Home, continue into Learn, and use Her to keep track of what matters to you.', style: t.bodyMedium),
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 6),
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(s, style: t.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 7,
            width: i == index ? 18 : 7,
            decoration: BoxDecoration(
              color: i == index ? cs.primary : cs.outlineVariant.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.step,
    required this.isSaving,
    required this.moneyFeels,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final int step;
  final bool isSaving;
  final String? moneyFeels;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  String get _primaryLabel => switch (step) {
        0 => 'Next',
        1 => 'Done',
        _ => 'Continue',
      };

  String? get _secondaryLabel => switch (step) {
        0 => 'Skip for now',
        1 => 'Start with Learn',
        _ => null,
      };

  bool get _primaryEnabled => !isSaving;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _primaryEnabled ? onPrimaryPressed : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: isSaving
                ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: cs.onPrimary))
                : Text(_primaryLabel),
          ),
        ),
        if (_secondaryLabel != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isSaving ? null : onSecondaryPressed,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
              child: Text(_secondaryLabel!),
            ),
          ),
        ],
      ],
    );
  }
}
