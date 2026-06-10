import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class CheckpointPage extends StatefulWidget {
  const CheckpointPage({super.key, required this.checkpointNumber});

  /// 1..4
  final int checkpointNumber;

  @override
  State<CheckpointPage> createState() => _CheckpointPageState();
}

class _CheckpointPageState extends State<CheckpointPage> {
  final LessonRepository _lessonRepo = LessonRepository();
  final _pageController = PageController();

  int _pageIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  String? _emotionalBaseline;
  String? _habitAwareness;
  Map<String, dynamic>? _checkpointProgress;

  final _q1Controller = TextEditingController();
  final _q2Controller = TextEditingController();
  final _q3Controller = TextEditingController();

  final TextEditingController _notesController = TextEditingController();
  bool _isNotesSaving = false;
  String? _notesError;

  String? _forwardChip;

  bool get _hasKnowledgeCheck => widget.checkpointNumber == 1 || widget.checkpointNumber == 2;

  bool get _requiresForwardSelection => true;

  String? _stringFromSupabaseValue(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is Map) {
      final dynamic selection = value['selection'] ?? value['value'] ?? value['answer'] ?? value['text'];
      if (selection is String) {
        final trimmed = selection.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _q1Controller.dispose();
    _q2Controller.dispose();
    _q3Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _checkpointCode => 'CK${widget.checkpointNumber}';

  static const Map<String, String> _checkpointHerNotesPrompts = {
    'CK1': "What's the one thing you learned in Module 1 that you wish someone had told you ten years ago?",
    'CK2': 'What did you learn in Module 2 that changed something you thought was your fault — and what do you want to do differently because of it?',
    'CK3': "What is the one financial thing you used to avoid looking at — that you've now looked at? What did it feel like to see it clearly?",
    'CK4': 'What is the one thing you will do differently with your money — starting this week — because of what you learned here?',
  };

  String? get _herNotesPrompt => _checkpointHerNotesPrompts[_checkpointCode];

  Future<void> _insertHerNote({required String prompt, String? response}) async {
    if (_isNotesSaving) return;
    setState(() {
      _isNotesSaving = true;
      _notesError = null;
    });

    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      await SupabaseConfig.client.from('her_notes').insert({
        'user_id': uid,
        'lesson_code': _checkpointCode,
        'prompt': prompt,
        'response': (response == null || response.trim().isEmpty) ? null : response.trim(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to Her Notes', style: TextStyle(color: HLGColors.warmCream)),
          backgroundColor: HLGColors.growth,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('[CheckpointPage] Save failed (her_notes insert): $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Save failed — please try again', style: TextStyle(color: HLGColors.warmCream)),
            backgroundColor: HLGColors.horizonOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (mounted) setState(() => _notesError = 'Could not save. Please try again.');
    } finally {
      if (mounted) setState(() => _isNotesSaving = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      final l0Progress = await SupabaseService.selectSingle(
        'lesson_progress',
        filters: {'lesson_code': 'L0', 'user_id': userId},
      );
      final checkpointProgress = await SupabaseService.selectSingle(
        'lesson_progress',
        filters: {'lesson_code': _checkpointCode, 'user_id': userId},
      );
      final userRow = await SupabaseService.selectSingle(
        'users',
        filters: {'id': userId},
      );

      debugPrint('[CheckpointPage] Loaded L0 progress=$l0Progress');
      debugPrint('[CheckpointPage] Loaded $_checkpointCode progress=$checkpointProgress');
      debugPrint('[CheckpointPage] Loaded user row=$userRow');

      setState(() {
        _checkpointProgress = checkpointProgress;
        final habitAwarenessRaw = userRow?['habit_awareness'];
        if (habitAwarenessRaw is String) {
          _habitAwareness = habitAwarenessRaw.trim();
        } else if (habitAwarenessRaw == null) {
          _habitAwareness = null;
        } else {
          // Supabase returns json/jsonb columns as Map/List on Dart side.
          _habitAwareness = jsonEncode(habitAwarenessRaw);
        }
        final userBaseline = _stringFromSupabaseValue(userRow?['emotional_baseline']);
        final l0Baseline = _stringFromSupabaseValue(l0Progress?['s4_response']);
        _emotionalBaseline = userBaseline ?? l0Baseline;
      });
    } catch (e) {
      debugPrint('[CheckpointPage] Failed to load checkpoint data: $e');
      setState(() => _error = 'Failed to load this checkpoint. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onContinue() async {
    if (_isSaving) return;

    if (_pageIndex == 1 && _hasKnowledgeCheck) {
      // Save knowledge check responses to s7_response as JSON.
      await _saveKnowledgeCheck();
      return;
    }

    if (_pageIndex == 3) {
      if (_requiresForwardSelection && (_forwardChip ?? '').trim().isEmpty) {
        setState(() => _error = 'Please choose one option to continue.');
        return;
      }
      await _completeCheckpoint();
      return;
    }

    _goToPage(_pageIndex + 1);
  }

  void _goToPage(int index) {
    final next = index.clamp(0, 3);
    setState(() {
      _pageIndex = next;
      _error = null;
    });
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _saveKnowledgeCheck() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      final payload = {
        'knowledge_check': {
          'answers': [
            _q1Controller.text.trim(),
            _q2Controller.text.trim(),
            _q3Controller.text.trim(),
          ],
        },
      };

      await _lessonRepo.saveProgress(
        userId: userId,
        lessonCode: _checkpointCode,
        status: 'in_progress',
        extra: {
          // lesson_progress.s7_response is jsonb; store a JSON object (not a string).
          's7_response': payload,
        },
      );

      _goToPage(_pageIndex + 1);
    } catch (e) {
      debugPrint('[CheckpointPage] Failed to save knowledge check: $e');
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _completeCheckpoint() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      final now = DateTime.now().toUtc().toIso8601String();

      final Map<String, dynamic> progressRow = {
        'user_id': userId,
        'lesson_code': _checkpointCode,
        'status': 'complete',
        'completed_at': now,
        'current_screen': 3,
      };

      if (_hasKnowledgeCheck || (_forwardChip ?? '').trim().isNotEmpty) {
        final Map<String, dynamic> s7 = {};
        if (_hasKnowledgeCheck) {
          s7['knowledge_check'] = {
            'answers': [
              _q1Controller.text.trim(),
              _q2Controller.text.trim(),
              _q3Controller.text.trim(),
            ],
          };
        }
        if ((_forwardChip ?? '').trim().isNotEmpty) {
          s7['forward_set'] = {'selection': _forwardChip};
        }
        progressRow['s7_response'] = s7;
      }

      await _lessonRepo.saveProgress(
        userId: userId,
        lessonCode: _checkpointCode,
        status: 'complete',
        currentScreen: 3,
        extra: {
          'completed_at': now,
          if (progressRow.containsKey('s7_response')) 's7_response': progressRow['s7_response'],
        },
      );

      if (widget.checkpointNumber == 4) {
        await SupabaseConfig.client.from('users').update({'emotional_current': _forwardChip}).eq('id', userId);
      }

      if (!mounted) return;
      if (widget.checkpointNumber == 4) {
        // Replace the checkpoint with Home, but keep prior navigation history
        // so the global back button behaves consistently.
        context.pushReplacement('/home');
      } else {
        // Replace the checkpoint with Learn (modules unlock flow).
        context.pushReplacement('/learn');
      }
    } catch (e) {
      debugPrint('[CheckpointPage] Failed to complete checkpoint: $e');
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Important: avoid showing the full-screen error state for *validation*
    // errors (e.g. "Please choose one option..."). Only use the error state
    // for genuine load failures.
    final shouldShowLoadErrorState = !_isLoading && _error != null && _checkpointProgress == null;

    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : shouldShowLoadErrorState
            ? _CheckpointErrorState(message: _error!, onRetry: _load)
            : _CheckpointScaffold(
                pageIndex: _pageIndex,
                isFinal: _pageIndex == 3,
                isSaving: _isSaving,
                error: _error,
                onContinue: _onContinue,
                continueLabel: _pageIndex == 3
                    ? (widget.checkpointNumber == 1 ? 'Complete Module 1' : 'Complete Module ${widget.checkpointNumber}')
                    : 'Continue',
                continueIsPrimary: _pageIndex != 3,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() {
                    _pageIndex = i;
                    _error = null;
                  }),
                  children: [
                    _buildScreen1(),
                    _buildScreen2(),
                    _buildScreen3(),
                    _buildScreen4(),
                  ],
                ),
              );

    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: const HerAppBar(
        showBack: true,
        fallbackRoute: '/learn',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildScreen1() {
    final baseline = (_emotionalBaseline ?? '').trim();

    if (widget.checkpointNumber == 1) {
      return _CheckpointScreen(
        screenNumberLabel: '1 of 4',
        heading: 'When you started, you said:',
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: HLGColors.crownGold, width: 4)),
              color: HLGColors.warmCream,
            ),
            child: Text(
              baseline.isEmpty ? 'Complete L0 to unlock this.' : baseline,
              textAlign: TextAlign.center,
              style: HLGTextStyles.h3SubheadItalic(color: HLGColors.horizonOrange),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'You have completed Module 1. The system has a history. Money is a tool. Your income is not fixed.',
            style: HLGTextStyles.body(color: HLGColors.midSage),
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 2) {
      final habit = (_habitAwareness ?? '').trim();
      return _CheckpointScreen(
        screenNumberLabel: '1 of 4',
        heading: 'This time, notice the pattern.',
        children: [
          if (baseline.isNotEmpty) ...[
            Text('Your baseline:', style: HLGTextStyles.labelMedium(color: HLGColors.midSage)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: HLGColors.crownGold, width: 4)),
                color: HLGColors.warmCream,
              ),
              child: Text(
                baseline,
                textAlign: TextAlign.center,
                style: HLGTextStyles.h3SubheadItalic(color: HLGColors.horizonOrange),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            'You have completed Module 2. This module is about structure: inflation, pay, and the systems underneath the story you were told.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 14),
          Text(
            habit.isEmpty
                ? 'If you noticed a money habit or reflex during Module 2, hold it gently. We will use it next.'
                : 'Your current habit awareness: $habit',
            style: HLGTextStyles.body(color: HLGColors.midSage),
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 3) {
      return _CheckpointScreen(
        screenNumberLabel: '1 of 4',
        heading: 'Pause. Breathe. Look at what you did.',
        children: [
          if (baseline.isNotEmpty) ...[
            Text('Your baseline:', style: HLGTextStyles.labelMedium(color: HLGColors.midSage)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: HLGColors.crownGold, width: 4)),
                color: HLGColors.warmCream,
              ),
              child: Text(
                baseline,
                textAlign: TextAlign.center,
                style: HLGTextStyles.h3SubheadItalic(color: HLGColors.horizonOrange),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            'You completed Module 3. This is where momentum begins: naming patterns, choosing levers, and building a system that holds you without guilt.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 4) {
      return _CheckpointScreen(
        screenNumberLabel: '1 of 4',
        heading: 'The course is complete.',
        children: [
          Text(
            'You built a long-game lens. Not perfection. Not punishment. A way to see clearly, choose deliberately, and keep going.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 12),
          Text(
            'This checkpoint is about integration: what you will carry forward, and how you want to feel in your money from here.',
            style: HLGTextStyles.body(color: HLGColors.midSage),
          ),
        ],
      );
    }

    return _PlaceholderCheckpointScreen(
      title: 'Checkpoint ${widget.checkpointNumber}',
      body: 'This checkpoint screen is not yet configured.',
    );
  }

  Widget _buildScreen2() {
    InputDecoration fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: HLGTextStyles.body(color: HLGColors.midSage),
      filled: true,
      fillColor: HLGColors.petal,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: HLGColors.deepSage, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );


    if (widget.checkpointNumber == 1) {
      return _CheckpointScreen(
        screenNumberLabel: '2 of 4',
        heading: 'Three questions. No pressure.',
        children: [
          Text(
            'What are the three functions of money? What happened to the money supply in August 1971? Name one lever that could increase your income. There is no grade. This is information for you.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _q1Controller,
            style: HLGTextStyles.body(color: HLGColors.textBody),
            decoration: fieldDecoration('Answer 1'),
            textInputAction: TextInputAction.next,
            maxLines: null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _q2Controller,
            style: HLGTextStyles.body(color: HLGColors.textBody),
            decoration: fieldDecoration('Answer 2'),
            textInputAction: TextInputAction.next,
            maxLines: null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _q3Controller,
            style: HLGTextStyles.body(color: HLGColors.textBody),
            decoration: fieldDecoration('Answer 3'),
            textInputAction: TextInputAction.done,
            maxLines: null,
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 2) {
      return _CheckpointScreen(
        screenNumberLabel: '2 of 4',
        heading: 'Three quick checks.',
        children: [
          Text(
            'No grade. Just signal. Answer in your own words.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 18),
          Text(
            '1) What is inflation, mechanically?',
            style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _q1Controller,
            style: HLGTextStyles.body(color: HLGColors.textBody),
            decoration: fieldDecoration('Your answer'),
            textInputAction: TextInputAction.next,
            maxLines: null,
          ),
          const SizedBox(height: 14),
          Text(
            '2) Name one structural factor that can shape earnings over time.',
            style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _q2Controller,
            style: HLGTextStyles.body(color: HLGColors.textBody),
            decoration: fieldDecoration('Your answer'),
            textInputAction: TextInputAction.next,
            maxLines: null,
          ),
          const SizedBox(height: 14),
          Text(
            '3) What is one lever you can pull this month to protect purchasing power?',
            style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _q3Controller,
            style: HLGTextStyles.body(color: HLGColors.textBody),
            decoration: fieldDecoration('Your answer'),
            textInputAction: TextInputAction.done,
            maxLines: null,
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 3) {
      return _CheckpointScreen(
        screenNumberLabel: '2 of 4',
        heading: 'One gentle question.',
        children: [
          Text(
            "What is the one thing you used to avoid looking at — that you've now looked at?",
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 10),
          Text(
            'You do not have to write anything here. Just notice the answer in your body.',
            style: HLGTextStyles.body(color: HLGColors.midSage),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HLGColors.petal,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.55)),
            ),
            child: Text(
              'If you want to capture it, you can write it in Her Notes on the final screen.',
              style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
            ),
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 4) {
      return _CheckpointScreen(
        screenNumberLabel: '2 of 4',
        heading: 'What is different now?',
        children: [
          Text(
            'Not what you know — what you do. What you notice. What you choose faster.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HLGColors.petal,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.55)),
            ),
            child: Text(
              'On the final screen, choose the feeling you want to carry forward. You can also save a note to Her Notes if you want.',
              style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
            ),
          ),
        ],
      );
    }

    return _PlaceholderCheckpointScreen(
      title: 'Checkpoint ${widget.checkpointNumber}',
      body: 'This checkpoint screen is not yet configured.',
    );
  }

  Widget _buildScreen3() {
    Widget tile(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: HLGColors.deepSage, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
            ),
          ),
        ],
      ),
    );


    if (widget.checkpointNumber == 1) {
      return _CheckpointScreen(
        screenNumberLabel: '3 of 4',
        heading: "What you've looked at.",
        children: [
          Text(
            "Money as a tool. The system that changed in 1971. How banks actually work. Your income as a spectrum. Each of these was a gap in your education — not your character.",
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.9,
            children: [
              tile('What money is'),
              tile('1971 and purchasing power'),
              tile('How banks work'),
              tile('Your income spectrum'),
            ],
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 2) {
      return _CheckpointScreen(
        screenNumberLabel: '3 of 4',
        heading: "What you've named.",
        children: [
          Text(
            'Inflation is not a personal failure. Pay gaps are not moral verdicts. Systems produce outcomes, and outcomes can be navigated.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.9,
            children: [
              tile('Inflation and purchasing power'),
              tile('Pay as a structure'),
              tile('Taxes and incentives'),
              tile('Protection levers'),
            ],
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 3) {
      return _CheckpointScreen(
        screenNumberLabel: '3 of 4',
        heading: "What you've built.",
        children: [
          Text(
            'Not a personality transplant. A scaffold. A way to keep going with less shame and more strategy.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.9,
            children: [
              tile('Awareness without guilt'),
              tile('A lever you can pull'),
              tile('A system you can repeat'),
              tile('A calmer baseline'),
            ],
          ),
        ],
      );
    }

    if (widget.checkpointNumber == 4) {
      return _CheckpointScreen(
        screenNumberLabel: '3 of 4',
        heading: "What you've earned.",
        children: [
          Text(
            'Clarity. Language. Options. And a long-game orientation that will compound over time.',
            style: HLGTextStyles.body(color: HLGColors.textBody),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.9,
            children: [
              tile('A money lens'),
              tile('A weekly rhythm'),
              tile('Long-game goals'),
              tile('Tools you can reuse'),
            ],
          ),
        ],
      );
    }

    return _PlaceholderCheckpointScreen(
      title: 'Checkpoint ${widget.checkpointNumber}',
      body: 'This checkpoint screen is not yet configured.',
    );
  }

  Widget _buildScreen4() {

    List<String> options;
    String heading;
    String intro;
    if (widget.checkpointNumber == 1) {
      heading = 'Module 2 is next.';
      intro =
          "You'll learn how inflation silently erodes your savings, why the gender pay gap is structural not personal, and what the tax system holds for you that nobody told you about.";
      options = const [
        'Checked my savings interest rate',
        'Started thinking about my money story',
        "Had a money conversation I'd been avoiding",
        "Nothing yet — I'll start in Module 2",
      ];
    } else if (widget.checkpointNumber == 2) {
      heading = 'Module 3 is next.';
      intro =
          'Next is momentum: habits, structures, and the long game. This is where the small actions become a system.';
      options = const [
        'Reviewed my pay or benefits situation',
        'Tracked one spending pattern for a week',
        'Set one protection lever (rate, debt, or budget)',
        'Nothing yet — I will start in Module 3',
      ];
    } else if (widget.checkpointNumber == 3) {
      heading = 'Module 4 is next.';
      intro =
          'Next is integration: your portrait, your long-game goals, and the system you will actually live inside. Small. Specific. Repeatable.';
      options = const [
        'Chose one weekly goal and wrote it down',
        'Noticed one pattern without shaming myself',
        'Used a tool to model a decision',
        'Nothing yet — I will start in Module 4',
      ];
    } else if (widget.checkpointNumber == 4) {
      heading = 'Choose what you want to feel now.';
      intro =
          'This is not a performance review. Choose the feeling you want to anchor. You can change it any time.';
      options = const [
        'Calm',
        'Clear',
        'Capable',
        'In motion',
      ];
    } else {
      return _PlaceholderCheckpointScreen(
        title: 'Checkpoint ${widget.checkpointNumber}',
        body: 'This checkpoint screen is not yet configured.',
      );
    }

    return _CheckpointScreen(
      screenNumberLabel: '4 of 4',
      heading: heading,
      children: [
        Text(intro, style: HLGTextStyles.body(color: HLGColors.textBody)),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: _forwardChip == option,
                onSelected: _isSaving
                    ? null
                    : (v) {
                        if (!v) return;
                        setState(() {
                          _forwardChip = option;
                          _error = null;
                        });
                      },
                labelStyle: HLGTextStyles.labelMedium(
                  color: _forwardChip == option ? HLGColors.white : HLGColors.night,
                ),
                selectedColor: HLGColors.deepSage,
                backgroundColor: HLGColors.petal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.55)),
                ),
                showCheckmark: false,
              ),
          ],
        ),

        if (_herNotesPrompt != null) ...[
          const SizedBox(height: 18),
          Text(
            'HER NOTES',
            style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.crownGold).copyWith(letterSpacing: 2.0),
          ),
          const SizedBox(height: 8),
          Text(
            _herNotesPrompt!,
            style: HLGTextStyles.quoteItalic(color: HLGColors.deepSage),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            minLines: 3,
            maxLines: 8,
            style: HLGTextStyles.body(color: HLGColors.textBody),
            decoration: InputDecoration(
              filled: true,
              fillColor: HLGColors.petal,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.55)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: HLGColors.deepSage, width: 1.2),
              ),
              hintText: 'Write here…',
              hintStyle: HLGTextStyles.body(color: HLGColors.midSage),
            ),
          ),
          const SizedBox(height: 10),
          if ((_notesError ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_notesError!, style: HLGTextStyles.labelMedium(color: HLGColors.horizonOrange)),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isNotesSaving ? null : () => _insertHerNote(prompt: _herNotesPrompt!, response: _notesController.text),
              style: FilledButton.styleFrom(
                backgroundColor: HLGColors.deepSage,
                foregroundColor: HLGColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save to Her Notes', style: HLGTextStyles.labelMedium(color: HLGColors.white)),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _isNotesSaving ? null : () => _insertHerNote(prompt: _herNotesPrompt!, response: null),
              style: TextButton.styleFrom(
                foregroundColor: HLGColors.deepSage,
                textStyle: HLGTextStyles.labelMedium(color: HLGColors.deepSage),
              ),
              child: const Text('Write later'),
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckpointScaffold extends StatelessWidget {
  const _CheckpointScaffold({
    required this.pageIndex,
    required this.isFinal,
    required this.isSaving,
    required this.error,
    required this.onContinue,
    required this.continueLabel,
    required this.continueIsPrimary,
    required this.child,
  });

  final int pageIndex;
  final bool isFinal;
  final bool isSaving;
  final String? error;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool continueIsPrimary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = (pageIndex + 1) / 4;

    return Column(
      children: [
        Container(height: 4, width: double.infinity, color: HLGColors.crownGold),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: HLGColors.crownGold,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${pageIndex + 1} of 4',
                      style: HLGTextStyles.uiElement(color: HLGColors.night),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: HLGColors.petal,
                  valueColor: const AlwaysStoppedAnimation(HLGColors.crownGold),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(
            children: [
              if ((error ?? '').trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    error!,
                    style: HLGTextStyles.labelMedium(color: HLGColors.horizonOrange),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isSaving ? null : onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: isFinal ? HLGColors.petal : HLGColors.crownGold,
                    foregroundColor: isFinal ? HLGColors.deepSage : HLGColors.night,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: HLGTextStyles.homeCta15(color: isFinal ? HLGColors.deepSage : HLGColors.night),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(continueLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckpointScreen extends StatelessWidget {
  const _CheckpointScreen({required this.screenNumberLabel, required this.heading, required this.children});

  final String screenNumberLabel;
  final String heading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: HLGTextStyles.lessonHeading(color: HLGColors.night)),
          const SizedBox(height: 14),
          ...children,
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _PlaceholderCheckpointScreen extends StatelessWidget {
  const _PlaceholderCheckpointScreen({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _CheckpointScreen(
      screenNumberLabel: '',
      heading: title,
      children: [
        Text(body, style: HLGTextStyles.body(color: HLGColors.textBody)),
      ],
    );
  }
}

class _CheckpointErrorState extends StatelessWidget {
  const _CheckpointErrorState({required this.message, required this.onRetry});

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
            style: FilledButton.styleFrom(
              backgroundColor: HLGColors.crownGold,
              foregroundColor: HLGColors.night,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Try again', style: HLGTextStyles.labelMedium(color: HLGColors.night)),
          ),
        ],
      ),
    );
  }
}
