import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Financial wellbeing onboarding diagnostic.
///
/// Notes:
/// - Copy is centralized in [_FinancialWellbeingDiagnosticCopy] to make future
///   Remote Config integration straightforward.
/// - Responses are stored locally in memory only (no backend integration yet).
/// - Uses a subtle fade + slide transition between questions.
class FinancialWellbeingDiagnosticScreen extends StatefulWidget {
  const FinancialWellbeingDiagnosticScreen({super.key});

  @override
  State<FinancialWellbeingDiagnosticScreen> createState() => _FinancialWellbeingDiagnosticScreenState();
}

class _FinancialWellbeingDiagnosticScreenState extends State<FinancialWellbeingDiagnosticScreen> {
  final _copy = _FinancialWellbeingDiagnosticCopy();
  final _responses = FinancialWellbeingDiagnosticResponses.empty();

  int _index = 0;
  bool _showCompletion = false;

  _FinancialWellbeingQuestion get _current => _copy.questions[_index];

  bool get _canContinue {
    final r = _responses.answerFor(_current.id);
    return r != null && r.isNotEmpty;
  }

  void _toggleSelection(String optionId) {
    HapticFeedback.selectionClick();
    setState(() {
      final current = _current;
      final existing = _responses.answerFor(current.id) ?? <String>{};

      if (current.isMultiSelect) {
        final next = {...existing};
        if (next.contains(optionId)) {
          next.remove(optionId);
        } else {
          if (optionId == current.noneOptionId) {
            next
              ..clear()
              ..add(optionId);
          } else {
            next.remove(current.noneOptionId);
            next.add(optionId);
          }
        }
        _responses.setAnswer(current.id, next);
      } else {
        _responses.setAnswer(current.id, {optionId});
      }
    });
  }

  void _continue() {
    if (!_canContinue) return;

    if (_index < _copy.questions.length - 1) {
      setState(() => _index++);
      return;
    }

    setState(() => _showCompletion = true);
  }

  @override
  Widget build(BuildContext context) {
    final bg = HLGColors.deepForest;

    if (_showCompletion) {
      final result = FinancialWellbeingDiagnosticScoring.score(copy: _copy, responses: _responses);
      final baselineSet = _responses.answerFor(FinancialWellbeingQuestionId.financialWellbeing);
      final selectedBaseline = baselineSet == null || baselineSet.isEmpty ? null : baselineSet.first;
      final scores = <String, dynamic>{
        'overall': result.overall,
        'financial_wellbeing': result.financialWellbeingScore,
        'financial_confidence': result.financialConfidenceScore,
        'financial_behaviour': result.financialBehaviourScore,
      };
      return _CompletionScreen(archetype: result.archetype, selectedBaseline: selectedBaseline, scores: scores);
    }

    final question = _current;
    final selected = _responses.answerFor(question.id) ?? <String>{};
    final radius = BorderRadius.circular(max(14.0, AppRadius.md));

    return Scaffold(
      backgroundColor: bg,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/welcome',
        backButtonColor: HLGColors.warmCream,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Row(
                children: [
                  Text(
                    'Question ${_index + 1} of ${_copy.questions.length}',
                    style: HLGTextStyles.uiElement(color: HLGColors.warmCream.withValues(alpha: 0.78)).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _copy.questions.length,
                  minHeight: 4,
                  backgroundColor: HLGColors.warmCream.withValues(alpha: 0.10),
                  valueColor: const AlwaysStoppedAnimation<Color>(HLGColors.crownGold),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(animation);
                  return SlideTransition(position: slide, child: FadeTransition(opacity: animation, child: child));
                },
                child: _QuestionBody(
                  key: ValueKey(question.id),
                  question: question,
                  selectedOptionIds: selected,
                  radius: radius,
                  onOptionTap: _toggleSelection,
                ),
              ),
            ),
            _BottomContinueBar(
              enabled: _canContinue,
              label: _index < _copy.questions.length - 1 ? 'Continue' : 'See my results',
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    super.key,
    required this.question,
    required this.selectedOptionIds,
    required this.radius,
    required this.onOptionTap,
  });

  final _FinancialWellbeingQuestion question;
  final Set<String> selectedOptionIds;
  final BorderRadius radius;
  final ValueChanged<String> onOptionTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.heading,
            style: HLGTextStyles.h3SubheadItalic(color: HLGColors.warmCream).copyWith(fontSize: 20, height: 1.4),
          ),
          const SizedBox(height: 22),
          Text(
            question.question,
            style: HLGTextStyles.h2Section(color: HLGColors.warmCream).copyWith(fontSize: 26, fontWeight: FontWeight.w600, height: 1.18),
          ),
          if (question.instructionText != null) ...[
            const SizedBox(height: 10),
            Text(
              question.instructionText!,
              style: HLGTextStyles.body(color: HLGColors.warmCream.withValues(alpha: 0.78)).copyWith(fontSize: 14, height: 1.5),
            ),
          ],
          const SizedBox(height: 26),
          for (final option in question.options) ...[
            _SelectionCard(
              label: option.label,
              selected: selectedOptionIds.contains(option.id),
              radius: radius,
              onTap: () => onOptionTap(option.id),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.label,
    required this.selected,
    required this.radius,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final BorderRadius radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseFill = HLGColors.warmCream.withValues(alpha: 0.06);
    final selectedFill = HLGColors.crownGold.withValues(alpha: 0.12);
    final borderColor = selected ? HLGColors.crownGold : HLGColors.warmCream.withValues(alpha: 0.10);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? selectedFill : baseFill,
            borderRadius: radius,
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: HLGTextStyles.body(
                    color: selected ? HLGColors.warmCream : HLGColors.warmCream.withValues(alpha: 0.86),
                  ).copyWith(fontSize: 15, height: 1.45),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? HLGColors.crownGold : HLGColors.warmCream.withValues(alpha: 0.18),
                    width: 2,
                  ),
                  color: selected ? HLGColors.crownGold : Colors.transparent,
                ),
                child: selected ? const Icon(Icons.check, size: 14, color: HLGColors.deepForest) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomContinueBar extends StatelessWidget {
  const _BottomContinueBar({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                enabled ? HLGColors.crownGold : HLGColors.warmCream.withValues(alpha: 0.10),
              ),
              foregroundColor: WidgetStatePropertyAll(
                enabled ? HLGColors.deepForest : HLGColors.warmCream.withValues(alpha: 0.45),
              ),
              iconColor: WidgetStatePropertyAll(
                enabled ? HLGColors.deepForest : HLGColors.warmCream.withValues(alpha: 0.45),
              ),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
              overlayColor: WidgetStatePropertyAll(HLGColors.warmCream.withValues(alpha: 0.12)),
            ),
            child: Text(
              label,
              style: HLGTextStyles.homeCta15(
                color: enabled ? HLGColors.deepForest : HLGColors.warmCream.withValues(alpha: 0.45),
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionScreen extends StatelessWidget {
  const _CompletionScreen({required this.archetype, required this.selectedBaseline, required this.scores});

  final FinancialWellbeingArchetype archetype;
  final String? selectedBaseline;
  final Map<String, dynamic> scores;

  Future<void> _saveAndGoHome(BuildContext context) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('[Diagnostic] completion blocked: no user');
        context.go(AppRoutes.auth);
        return;
      }

      await client.from('users').update({
        'diagnostic_complete': true,
        'emotional_baseline': selectedBaseline,
        'diagnostic_archetype': archetype.name,
        'diagnostic_scores': scores,
      }).eq('id', userId);

      if (context.mounted) context.go(AppRoutes.home);
    } catch (e) {
      debugPrint('[Diagnostic] completion save failed: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not save diagnostic. Please try again.'),
        backgroundColor: Color(0xFFD4621A),
        duration: Duration(seconds: 4),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = archetype.info;
    return Scaffold(
      backgroundColor: HLGColors.deepForest,
      appBar: const HerAppBar(
        showBack: true,
        fallbackRoute: '/welcome',
        backButtonColor: HLGColors.warmCream,
        backgroundColor: HLGColors.deepForest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: HLGColors.crownGold, width: 2),
                  color: HLGColors.crownGold.withValues(alpha: 0.10),
                ),
                child: const Icon(Icons.south_east_rounded, size: 34, color: HLGColors.crownGold),
              ),
              const SizedBox(height: 26),
              Text(
                info.title,
                textAlign: TextAlign.center,
                style: HLGTextStyles.h2Section(color: HLGColors.warmCream).copyWith(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                info.description,
                textAlign: TextAlign.center,
                style: HLGTextStyles.body(color: HLGColors.warmCream.withValues(alpha: 0.90)).copyWith(fontSize: 16, height: 1.6),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(HLGColors.crownGold),
                    foregroundColor: const WidgetStatePropertyAll(HLGColors.deepForest),
                    iconColor: const WidgetStatePropertyAll(HLGColors.deepForest),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
                    overlayColor: WidgetStatePropertyAll(HLGColors.warmCream.withValues(alpha: 0.12)),
                  ),
                  onPressed: () {
                    _saveAndGoHome(context);
                  },
                  child: Text(
                    'Go to Home',
                    style: HLGTextStyles.homeCta15(color: HLGColors.deepForest).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Models + copy
// ─────────────────────────────────────────────────────────────────────────────

enum FinancialWellbeingQuestionId {
  financialWellbeing,
  financialBehaviour,
  financialAttitudes,
  financialConfidence,
  financialInclusion,
}

@immutable
class _FinancialWellbeingOption {
  const _FinancialWellbeingOption({required this.id, required this.label, this.score});

  final String id;
  final String label;
  final double? score;
}

@immutable
class _FinancialWellbeingQuestion {
  const _FinancialWellbeingQuestion({
    required this.id,
    required this.heading,
    required this.question,
    required this.options,
    this.instructionText,
    required this.isMultiSelect,
    this.noneOptionId,
  });

  final FinancialWellbeingQuestionId id;
  final String heading;
  final String question;
  final String? instructionText;
  final List<_FinancialWellbeingOption> options;
  final bool isMultiSelect;
  final String? noneOptionId;
}

class _FinancialWellbeingDiagnosticCopy {
  List<_FinancialWellbeingQuestion> get questions => const [
        _FinancialWellbeingQuestion(
          id: FinancialWellbeingQuestionId.financialWellbeing,
          isMultiSelect: false,
          heading: 'Money can feel emotional as much as practical.',
          question: 'How do you currently feel when you think about your finances?',
          options: [
            _FinancialWellbeingOption(id: 'calm', label: 'Calm and in control', score: 5),
            _FinancialWellbeingOption(id: 'worry', label: 'Mostly okay, but I worry sometimes', score: 4),
            _FinancialWellbeingOption(id: 'stressed', label: 'Often stressed or overwhelmed', score: 2),
            _FinancialWellbeingOption(id: 'avoidant', label: 'Avoidant — I try not to think about it', score: 1),
            _FinancialWellbeingOption(id: 'mixed', label: 'Confident in some areas, unsure in others', score: 3),
          ],
        ),
        _FinancialWellbeingQuestion(
          id: FinancialWellbeingQuestionId.financialBehaviour,
          isMultiSelect: false,
          heading: "There's no perfect way to manage money.",
          question: 'Which statement sounds most like you right now?',
          options: [
            _FinancialWellbeingOption(id: 'track', label: 'I actively track and plan my money', score: 5),
            _FinancialWellbeingOption(id: 'generally_know', label: 'I generally know where my money goes', score: 4),
            _FinancialWellbeingOption(id: 'improving', label: "I'm trying to improve my habits", score: 3),
            _FinancialWellbeingOption(id: 'reactive', label: 'I often feel reactive with money', score: 2),
            _FinancialWellbeingOption(id: 'avoid', label: 'I avoid budgeting or checking balances', score: 1),
          ],
        ),
        _FinancialWellbeingQuestion(
          id: FinancialWellbeingQuestionId.financialAttitudes,
          isMultiSelect: false,
          heading: 'Your relationship with the future shapes financial decisions.',
          question: 'When making money decisions, what feels most true for you?',
          options: [
            _FinancialWellbeingOption(id: 'long_term', label: 'I think long-term and plan ahead', score: 5),
            _FinancialWellbeingOption(id: 'balance', label: 'I balance today and the future', score: 4),
            _FinancialWellbeingOption(id: 'immediate', label: 'I focus mostly on immediate needs', score: 3),
            _FinancialWellbeingOption(id: 'overwhelming', label: 'Long-term planning feels overwhelming', score: 2),
            _FinancialWellbeingOption(id: 'start', label: "I don't know where to start", score: 1),
          ],
        ),
        _FinancialWellbeingQuestion(
          id: FinancialWellbeingQuestionId.financialConfidence,
          isMultiSelect: false,
          heading: 'Confidence matters just as much as knowledge.',
          question: 'How confident do you feel making financial decisions on your own?',
          options: [
            _FinancialWellbeingOption(id: 'very', label: 'Very confident', score: 5),
            _FinancialWellbeingOption(id: 'fairly', label: 'Fairly confident', score: 4),
            _FinancialWellbeingOption(id: 'some', label: 'Confident in some areas only', score: 3),
            _FinancialWellbeingOption(id: 'reassurance', label: 'I usually seek reassurance from others', score: 2),
            _FinancialWellbeingOption(id: 'intimidated', label: 'I often feel unsure or intimidated', score: 1),
          ],
        ),
        _FinancialWellbeingQuestion(
          id: FinancialWellbeingQuestionId.financialInclusion,
          isMultiSelect: true,
          heading: 'Most people were never formally taught this stuff.',
          question: 'Which areas of money management have you explored before?',
          instructionText: 'Select all that apply.',
          noneOptionId: 'none',
          options: [
            _FinancialWellbeingOption(id: 'savings', label: 'Savings accounts'),
            _FinancialWellbeingOption(id: 'budgeting', label: 'Budgeting tools or apps'),
            _FinancialWellbeingOption(id: 'investing', label: 'Investing'),
            _FinancialWellbeingOption(id: 'super', label: 'Superannuation management'),
            _FinancialWellbeingOption(id: 'insurance', label: 'Insurance'),
            _FinancialWellbeingOption(id: 'adviser', label: 'Financial adviser or accountant support'),
            _FinancialWellbeingOption(id: 'loans', label: 'Loans or mortgages'),
            _FinancialWellbeingOption(id: 'none', label: 'None of the above or not sure'),
          ],
        ),
      ];
}

class FinancialWellbeingDiagnosticResponses {
  FinancialWellbeingDiagnosticResponses._(this._answers);

  factory FinancialWellbeingDiagnosticResponses.empty() => FinancialWellbeingDiagnosticResponses._(<FinancialWellbeingQuestionId, Set<String>>{});

  final Map<FinancialWellbeingQuestionId, Set<String>> _answers;

  Set<String>? answerFor(FinancialWellbeingQuestionId id) => _answers[id];

  void setAnswer(FinancialWellbeingQuestionId id, Set<String> optionIds) => _answers[id] = optionIds;
}

enum FinancialWellbeingArchetype {
  creatingClarity,
  growingConfidence,
  thinkingAhead;

  ArchetypeInfo get info {
    switch (this) {
      case FinancialWellbeingArchetype.creatingClarity:
        return const ArchetypeInfo(
          title: 'Creating Clarity',
          description:
              "You're beginning to build a clearer relationship with money — one grounded in awareness, self-trust and small meaningful steps forward.",
        );
      case FinancialWellbeingArchetype.growingConfidence:
        return const ArchetypeInfo(
          title: 'Growing Confidence',
          description:
              'You already have some helpful foundations in place. This journey is about strengthening confidence, building consistency and feeling more supported in your financial decisions.',
        );
      case FinancialWellbeingArchetype.thinkingAhead:
        return const ArchetypeInfo(
          title: 'Thinking Ahead',
          description:
              "You're already reflecting thoughtfully about your future and the role money plays in it. This next chapter is about deepening clarity, intention and long-term confidence.",
        );
    }
  }
}

@immutable
class ArchetypeInfo {
  const ArchetypeInfo({required this.title, required this.description});

  final String title;
  final String description;
}

@immutable
class FinancialWellbeingDiagnosticResult {
  const FinancialWellbeingDiagnosticResult({
    required this.archetype,
    required this.overall,
    required this.financialWellbeingScore,
    required this.financialConfidenceScore,
    required this.financialBehaviourScore,
  });

  final FinancialWellbeingArchetype archetype;
  final double overall;
  final double? financialWellbeingScore;
  final double? financialConfidenceScore;
  final double? financialBehaviourScore;
}

class FinancialWellbeingDiagnosticScoring {
  static FinancialWellbeingDiagnosticResult score({
    required _FinancialWellbeingDiagnosticCopy copy,
    required FinancialWellbeingDiagnosticResponses responses,
  }) {
    double? scoreForSingle(FinancialWellbeingQuestionId id) {
      final q = copy.questions.firstWhere((q) => q.id == id);
      final selected = responses.answerFor(id);
      if (selected == null || selected.isEmpty) return null;
      final option = q.options.firstWhere((o) => o.id == selected.first);
      return option.score;
    }

    double? scoreForInclusion() {
      final q = copy.questions.firstWhere((q) => q.id == FinancialWellbeingQuestionId.financialInclusion);
      final selected = responses.answerFor(q.id);
      if (selected == null || selected.isEmpty) return null;
      if (q.noneOptionId != null && selected.contains(q.noneOptionId)) return 0;
      return min(5, selected.length).toDouble();
    }

    final q1 = scoreForSingle(FinancialWellbeingQuestionId.financialWellbeing);
    final q2 = scoreForSingle(FinancialWellbeingQuestionId.financialBehaviour);
    final q3 = scoreForSingle(FinancialWellbeingQuestionId.financialAttitudes);
    final q4 = scoreForSingle(FinancialWellbeingQuestionId.financialConfidence);
    final q5 = scoreForInclusion();

    final scored = [q1, q2, q3, q4, q5].whereType<double>().toList(growable: false);
    final rawOverall = scored.isEmpty ? 1.0 : scored.reduce((a, b) => a + b) / scored.length;
    final overall = rawOverall.clamp(1.0, 5.0);

    final archetype = switch (overall) {
      <= 2.4 => FinancialWellbeingArchetype.creatingClarity,
      <= 3.7 => FinancialWellbeingArchetype.growingConfidence,
      _ => FinancialWellbeingArchetype.thinkingAhead,
    };

    return FinancialWellbeingDiagnosticResult(
      archetype: archetype,
      overall: overall,
      financialWellbeingScore: q1,
      financialConfidenceScore: q4,
      financialBehaviourScore: q2,
    );
  }
}
