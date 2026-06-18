import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/data/lesson_names.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:her_long_game/utils/lesson_flow.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/principles_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final LessonRepository _lessonRepo = LessonRepository();

  // V4 lesson duration estimates (minutes). Mirrors lesson_list_page.dart.
  static const Map<String, int> _lessonMinutes = {
    // ── Welcome / Onboarding ────────────────────────────────────────────────
    'O1': 5,
    'O2': 5,
    'O3': 5,
    'O4': 5,
    'O5': 4,

    // ── The Past ────────────────────────────────────────────────────────────
    'P1': 7,
    'P2': 8,
    'P3': 7,
    'P4': 7,
    'P5': 8,
    'P6': 9,

    // ── The Present ─────────────────────────────────────────────────────────
    'N1': 8,
    'N2': 8,
    'N3': 7,
    'N4': 7,
    'N5': 7,
    'N6': 8,
    'N7': 7,
    'N8': 7,
    'N9': 7,
    'N10': 7,
    'N11': 8,
    'N12': 7,
    'N13': 7,

    // ── The Future ──────────────────────────────────────────────────────────
    'F1': 8,
    'F2': 8,
    'F3': 8,
    'F4': 8,
    'F5': 8,
    'F6': 7,
    'F7': 9,
    'F8': 8,
  };

  bool _isLoading = true;
  String? _error;
  _NextLesson? _next;
  bool _hasStartedLongGame = false;
  final Map<String, String> _displayNameByCode = {};

  List<Map<String, dynamic>> _goalsSnapshot = const [];

  @override
  void initState() {
    super.initState();
    _loadNextLesson();
    _loadGoalsSnapshot();
  }

  Future<void> _loadGoalsSnapshot() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        setState(() => _goalsSnapshot = const []);
        return;
      }

      final rows = await Supabase.instance.client
          .from('goals')
          .select('id, label, goal_type, completed_at, target_date')
          .eq('user_id', userId)
          .is_('archived_at', null)
          .is_('completed_at', null)
          .order('created_at', ascending: false)
          .limit(12);

      // Deduplicate by label so repeated saves of the same goal don't clutter Home.
      final seen = <String>{};
      final unique = <Map<String, dynamic>>[];
      for (final row in (rows as List).cast<Map<String, dynamic>>()) {
        final label = (row['label'] ?? '').toString().trim();
        final key = label.toLowerCase();
        if (seen.contains(key)) continue;
        seen.add(key);
        unique.add(row);
        if (unique.length >= 3) break;
      }

      if (!mounted) return;
      setState(() => _goalsSnapshot = unique);
    } catch (e) {
      debugPrint('[HomePage] Failed to load goals snapshot: $e');
      if (!mounted) return;
      setState(() => _goalsSnapshot = const []);
    }
  }

  Future<void> _loadNextLesson() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'You are not signed in.';
        });
        return;
      }

      final progress = await _lessonRepo.getAllProgress(userId: uid);
      final progressByCode = <String, String>{for (final e in progress.entries) e.key: e.value.status};

      // "Started" = any lesson has been marked in_progress or complete.
      final hasStarted = progressByCode.values.any((s) => s == 'in_progress' || s == 'complete');

      _NextLesson? next;
      next = _computeNextFromProgress(progressByCode);

      if (next != null) {
        try {
          final row = await SupabaseConfig.client
              .from('lesson_screens')
              .select('display_name')
              .eq('lesson_code', next.code)
              .eq('screen_index', 0)
              .maybeSingle();
          final name = (row?['display_name'] ?? '').toString().trim();
          if (name.isNotEmpty) _displayNameByCode[next.code] = name;
        } catch (e) {
          debugPrint('[HomePage] Failed to load display_name for ${next.code} (fallback used): $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _next = next;
        _hasStartedLongGame = hasStarted;
      });
    } catch (e) {
      debugPrint('[HomePage] Failed to load next lesson: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load your progress.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: HLGColors.warmCream,
        appBar: const HerAppBar(actions: [HerLogoutIconButton()]),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([_loadNextLesson(), _loadGoalsSnapshot()]);
            },
            color: HLGColors.deepSage,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  _NextLessonSection(
                    isLoading: _isLoading,
                    error: _error,
                    next: _next,
                    hasStartedLongGame: _hasStartedLongGame,
                    titleFor: (c) => _displayNameByCode[c] ?? (lessonDisplayNames[c] ?? c),
                    minutesFor: (c) => _lessonMinutes[c],
                  ),
                  const SizedBox(height: 8),
                  _GoalsSnapshotSection(goals: _goalsSnapshot),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: PrinciplesCard(),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension _SupabaseFilterCompat on PostgrestFilterBuilder {
  /// Compatibility shim: some Supabase Dart versions expose `isFilter` instead
  /// of `is_`. The Home goals query uses the `is_` name.
  PostgrestFilterBuilder is_(String column, Object? value) => filter(column, 'is', value);
}

_NextLesson? _computeNextFromProgress(Map<String, String> progressByLessonCode) {
  // Product rule:
  // - Prefer lessons over checkpoints for the primary "Up Next" action.
  // - However, if there are *no remaining lessons* and the user is blocked on a
  //   checkpoint (e.g. CK3), we must surface that checkpoint instead of showing
  //   "course finished."

  // Pass 1: first incomplete lesson.
  for (final code in LessonFlow.lessonSequence) {
    if (code.startsWith('CK')) continue;

    final status = progressByLessonCode[code];
    if (status != 'complete') return _NextLesson(code: code, status: status);
  }

  // Pass 2: first incomplete checkpoint.
  for (final code in LessonFlow.lessonSequence) {
    if (!code.startsWith('CK')) continue;

    final status = progressByLessonCode[code];
    if (status != 'complete') return _NextLesson(code: code, status: status);
  }

  return null;
}

class _NextLessonSection extends StatelessWidget {
  const _NextLessonSection({
    required this.isLoading,
    required this.error,
    required this.next,
    required this.hasStartedLongGame,
    required this.titleFor,
    required this.minutesFor,
  });

  final bool isLoading;
  final String? error;
  final _NextLesson? next;
  final bool hasStartedLongGame;
  final String Function(String code) titleFor;
  final int? Function(String code) minutesFor;

  @override
  Widget build(BuildContext context) {
    final child = () {
      if (isLoading) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
        );
      }

      if (error != null) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Text(error!, style: HLGTextStyles.body(color: HLGColors.midSage)),
        );
      }

      if (next == null) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'You have completed the course.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.quoteItalic(color: HLGColors.deepSage),
            ),
          ),
        );
      }

      final minutes = minutesFor(next!.code);
      final bool isCheckpoint = next!.code.startsWith('CK');
      final microLabel = lessonMicroLabels[next!.code];

      // Product rule:
      // - On the user's first Home landing (before starting), we only show the
      //   "Begin" experience (no "Continue" anywhere on the screen).
      // - After they've started, we show "Continue" when applicable.
      final buttonLabel = !hasStartedLongGame
          ? 'Begin'
          : (next!.status == 'in_progress' ? 'Continue' : 'Begin');

      final VoidCallback onPressed = () {
        if (isCheckpoint) {
          final n = int.tryParse(next!.code.substring(2));
          if (n != null) context.push('/checkpoint/$n');
          return;
        }
        context.push('/lesson/${next!.code}');
      };

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UP NEXT', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.midSage)),
            const SizedBox(height: 12),
             if (microLabel != null && microLabel.trim().isNotEmpty) ...[
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                 decoration: BoxDecoration(
                   color: HLGColors.horizonOrange,
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(
                   microLabel,
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                   style: HLGTextStyles.lessonCodePill(color: HLGColors.white),
                 ),
               ),
               const SizedBox(height: 12),
             ],
            Text(
              isCheckpoint ? 'Checkpoint ${next!.code.substring(2)}' : titleFor(next!.code),
              style: HLGTextStyles.moduleTitle(color: HLGColors.night),
            ),
            const SizedBox(height: 8),
            Text(
              isCheckpoint ? 'Quick reset' : (minutes == null ? '' : '$minutes min'),
              style: HLGTextStyles.homeMeta13(color: HLGColors.midSage),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(HLGColors.deepSage),
                  foregroundColor: const WidgetStatePropertyAll(HLGColors.white),
                  textStyle: WidgetStatePropertyAll(HLGTextStyles.homeCta15(color: HLGColors.white)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.18)),
                ),
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      );
    }();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _GoalsSnapshotSection extends StatelessWidget {
  const _GoalsSnapshotSection({required this.goals});

  final List<Map<String, dynamic>> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('THIS WEEK', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.horizonOrange))),
              GestureDetector(
                onTap: () => context.push(AppRoutes.direction),
                child: Text('See all →', style: GoogleFonts.dmSans(fontSize: 12, color: HLGColors.midSage)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...goals.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: HLGColors.midSage, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      (g['label'] ?? '').toString(),
                      style: GoogleFonts.dmSans(fontSize: 14, color: HLGColors.textBody),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextLesson {
  const _NextLesson({required this.code, required this.status});

  final String code;
  final String? status;
}