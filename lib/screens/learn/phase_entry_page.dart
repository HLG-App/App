import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/data/learning_catalog.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class PhaseEntryPage extends StatelessWidget {
  const PhaseEntryPage({super.key, required this.phaseId, required this.onContinue, this.canClose = false});

  final int phaseId;
  final bool canClose;

  /// Called when the user acknowledges the phase framing.
  ///
  /// This is intentionally required so the caller can persist "seen" state.
  final Future<void> Function() onContinue;

  static String _phaseEyebrow(int phaseId) {
    switch (phaseId) {
      case 1:
        return 'PHASE 1 · THE PAST';
      case 2:
        return 'PHASE 2 · THE PRESENT';
      case 3:
        return 'PHASE 3 · THE FUTURE';
      default:
        return 'YOUR LONG GAME';
    }
  }

  static String _phaseHeading(int phaseId) {
    switch (phaseId) {
      case 1:
        return 'Context and curiosity.';
      case 2:
        return 'Clarity and foundations.';
      case 3:
        return 'Ownership and growth.';
      default:
        return 'Your long game.';
    }
  }

  static String _phaseBody(int phaseId) {
    switch (phaseId) {
      case 1:
        return 'You did not miss a memo. The financial system has a history — and most of it was never explained to you.\n\nThis phase covers where money came from, how the rules changed in 1971, what banks are actually doing with your deposits, and why women have always been capable with money even when the system made it harder.\n\nBy the end you will not feel behind. You will feel like someone finally told you the truth.';
      case 2:
        return 'This is where the foundations get personal.\n\nYou will look at your actual money situation — clearly, without judgment. Your income, your spending, your debt, your super. Not to shame you into changing everything. To show you what you are actually working with.\n\nAwareness is not the same as action. But you cannot take meaningful action without it.';
      case 3:
        return 'This is the long game in practice.\n\nCompound growth. Index funds. Sound money. The future self portrait. The tools that turn principles into a plan that is specifically, deliberately yours.\n\nBy the end you will not just understand money. You will have a view of your long game — and the tools to build it.';
      default:
        return 'The foundations you were never taught — in the order that makes them land.';
    }
  }

  static String _phasePromise(int phaseId) {
    switch (phaseId) {
      case 1:
        return 'The gap was never in you. The gap was in what you were given.';
      case 2:
        return 'You cannot change what you cannot see. This phase makes it visible.';
      case 3:
        return 'This is not the end of the course. It is the beginning of the long game.';
      default:
        return 'Use these principles as yours. Not ours.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = LearningCatalog.instance.maybeGetPhase(phaseId);
    if (phase == null) {
      return Scaffold(
        appBar: const HerAppBar(showBack: true, fallbackRoute: '/learn', titleText: 'Phase'),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Text('Unknown phase ($phaseId).', style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: canClose,
        fallbackRoute: '/learn',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text(phase.title, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: HLGColors.petal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.4), width: 1),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _phaseEyebrow(phaseId),
                      style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.crownGold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _phaseHeading(phaseId),
                      style: HLGTextStyles.h2Section(color: HLGColors.night),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: HLGColors.crownGold.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      _phaseBody(phaseId),
                      style: HLGTextStyles.body(color: HLGColors.textBody).copyWith(height: 1.7),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: HLGColors.warmCream,
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          left: BorderSide(color: HLGColors.crownGold, width: 3),
                        ),
                      ),
                      child: Text(
                        _phasePromise(phaseId),
                        style: HLGTextStyles.quoteItalic(color: HLGColors.deepSage),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await onContinue();
                    } finally {
                      if (context.mounted) context.pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: HLGColors.horizonOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text("I'm ready →", style: HLGTextStyles.uiElement(color: HLGColors.white)),
                ),
              ),
              const SizedBox(height: 10),
              Text('You can revisit this any time from the Learn tab.', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
