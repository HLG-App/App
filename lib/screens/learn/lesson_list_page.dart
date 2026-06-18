import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/data/learning_catalog.dart';
import 'package:her_long_game/data/lesson_names.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class LessonListPage extends StatefulWidget {
  const LessonListPage({super.key, required this.moduleIndex});

  final int moduleIndex;

  @override
  State<LessonListPage> createState() => _LessonListPageState();
}

class _LessonListPageState extends State<LessonListPage> {
  final LessonRepository _lessonRepo = LessonRepository();

  bool _isLoading = true;
  String? _error;
  final Map<String, String> _statusByLessonCode = {};
  final Map<String, String> _displayNameByLessonCode = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _loadLessonDisplayNames();
  }

  Future<void> _loadLessonDisplayNames() async {
    try {
      final module = LearningCatalog.instance.maybeGetModule(widget.moduleIndex.toString());
      final codes = module == null ? const <String>[] : [for (final i in module.items) i.code];

      // Batched fetch to avoid per-row queries.
      final rows = await SupabaseConfig.client
          .from('lesson_screens')
          .select('lesson_code, display_name')
          .eq('screen_index', 0)
          .inFilter('lesson_code', codes);

      final map = <String, String>{};
      for (final r in rows) {
        final code = (r['lesson_code'] ?? '').toString();
        final name = (r['display_name'] ?? '').toString().trim();
        if (code.isEmpty || name.isEmpty) continue;
        map[code] = name;

      }

      if (!mounted) return;
      setState(() {
        _displayNameByLessonCode
          ..clear()
          ..addAll(map);
      });
    } catch (e) {
      debugPrint('[LessonListPage] Failed to load display names (fallback to lessonDisplayNames): $e');
    }
  }

  Future<void> _loadProgress() async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _error = 'You are signed out.';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final progress = await _lessonRepo.getAllProgress(userId: uid);
      final map = <String, String>{for (final e in progress.entries) e.key: e.value.status};

      if (!mounted) return;
      setState(() {
        _statusByLessonCode
          ..clear()
          ..addAll(map);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[LessonListPage] Failed to load lesson_progress: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load lessons.';
      });
    }
  }

  bool _isComplete(String lessonCode) => _statusByLessonCode[lessonCode] == 'complete';

  static bool _isCheckpoint(String code) => code.startsWith('CK');

  static int? _checkpointNumber(String code) {
    if (!code.startsWith('CK')) return null;
    return int.tryParse(code.substring(2));
  }

  @override
  Widget build(BuildContext context) {
    final module = LearningCatalog.instance.maybeGetModule(widget.moduleIndex.toString());
    if (module == null) {
      return Scaffold(
        backgroundColor: HLGColors.warmCream,
        appBar: HerAppBar(
          showBack: true,
          fallbackRoute: '/learn',
          backgroundColor: HLGColors.warmCream,
          surfaceTintColor: Colors.transparent,
          title: Text('Module', style: HLGTextStyles.moduleTitle(color: HLGColors.textBody)),
        ),
        body: const Center(child: Text('Unknown module.')),
      );
    }
    final moduleUnlocked = module.unlockRule(_statusByLessonCode);

    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/learn',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text(module.title, style: HLGTextStyles.moduleTitle(color: HLGColors.textBody)),
        actions: [IconButton(onPressed: _isLoading ? null : _loadProgress, icon: const Icon(Icons.refresh, color: HLGColors.textBody), tooltip: 'Refresh')],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _LessonListErrorState(message: _error!, onRetry: _loadProgress)
              : ListView.separated(
                  itemCount: module.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final lessonCode = module.items[i].code;
                    final moduleCodes = [for (final it in module.items) it.code];
                    final unlocked = _isLessonUnlockedInModule(moduleUnlocked: moduleUnlocked, moduleLessonCodes: moduleCodes, lessonIndex: i);
                    final status = _statusByLessonCode[lessonCode] ?? '';

                    final isCheckpoint = _isCheckpoint(lessonCode);
                    final checkpointNumber = _checkpointNumber(lessonCode);
                    return LessonCard(
                      lessonCode: lessonCode,
                      title: _displayNameByLessonCode[lessonCode] ?? (lessonDisplayNames[lessonCode] ?? lessonCode),
                      minutes: isCheckpoint ? null : _lessonMinutes(lessonCode),
                      status: status,
                      unlocked: unlocked,
                      isCheckpoint: isCheckpoint,
                      onTap: unlocked
                          ? () {
                              if (isCheckpoint && checkpointNumber != null) {
                                context.push('/checkpoint/$checkpointNumber');
                              } else {
                                context.push('/lesson/$lessonCode');
                              }
                            }
                          : null,
                    );
                  },
                ),
        ),
      ),
    );
  }

  bool _isLessonUnlockedInModule({required bool moduleUnlocked, required List<String> moduleLessonCodes, required int lessonIndex}) {
    if (!moduleUnlocked) return false;
    if (lessonIndex <= 0) return true;

    final lessonCode = moduleLessonCodes[lessonIndex];
    final isCheckpoint = _isCheckpoint(lessonCode);
    if (isCheckpoint) {
      // Checkpoints unlock when all non-checkpoint lessons in this module are complete.
      final nonCheckpoint = moduleLessonCodes.where((c) => !_isCheckpoint(c)).toList();
      final moduleComplete = nonCheckpoint.every(_isComplete);
      if (!moduleComplete) return false;

      // Additional prerequisites for checkpoints.
      final extraPrereqs = _checkpointPrereqs[lessonCode] ?? const <String>[];
      return extraPrereqs.every(_isComplete);
    }

    final prevCode = moduleLessonCodes[lessonIndex - 1];
    return _isComplete(prevCode);
  }
}

class _LessonListErrorState extends StatelessWidget {
  const _LessonListErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lessonCode,
    required this.title,
    required this.minutes,
    required this.status,
    required this.unlocked,
    required this.isCheckpoint,
    required this.onTap,
  });

  final String lessonCode;
  final String title;
  final int? minutes;
  final String status;
  final bool unlocked;
  final bool isCheckpoint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveTap = unlocked ? onTap : null;
    final pillLabel = isCheckpoint
        ? (() {
            final n = int.tryParse(lessonCode.replaceFirst('CK', ''));
            return n == null ? 'Checkpoint' : 'Checkpoint $n';
          })()
        : lessonMicroLabels[lessonCode];
    final base = Container(
      decoration: BoxDecoration(
        color: HLGColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HLGColors.deepSage.withValues(alpha: 0.12), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (pillLabel != null && pillLabel.trim().isNotEmpty) ...[
                      _LessonLabelPill(label: pillLabel, isCheckpoint: isCheckpoint),
                      const SizedBox(width: 10),
                    ],
                    if (minutes != null)
                      Text('${minutes}m', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: HLGTextStyles.body(color: HLGColors.textBody),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _LessonStatusIcon(status: status, unlocked: unlocked),
        ],
      ),
    );

    if (!unlocked) return Opacity(opacity: 0.6, child: base);

    return InkWell(
      onTap: effectiveTap,
      overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.10)),
      borderRadius: BorderRadius.circular(12),
      child: base,
    );
  }
}

class _LessonLabelPill extends StatelessWidget {
  const _LessonLabelPill({required this.label, required this.isCheckpoint});
  final String label;
  final bool isCheckpoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: isCheckpoint ? HLGColors.crownGold : HLGColors.horizonOrange, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: HLGTextStyles.uiElement(color: HLGColors.white)),
    );
  }
}

class _LessonStatusIcon extends StatelessWidget {
  const _LessonStatusIcon({required this.status, required this.unlocked});

  final String status;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    if (!unlocked) return const Icon(Icons.lock, color: HLGColors.textMuted, size: 20);
    if (status == 'complete') return const Icon(Icons.check_circle, color: HLGColors.crownGold, size: 20);
    if (status == 'in_progress') {
      return const Icon(Icons.radio_button_unchecked, color: HLGColors.horizonOrange, size: 20);
    }
    return const Icon(Icons.circle_outlined, color: HLGColors.textMuted, size: 20);
  }
}

const Map<String, List<String>> _checkpointPrereqs = {
  // V4: no additional cross-module prereqs needed here.
  // Module unlock rules in LearningCatalog and sequential lesson gating in
  // _isLessonUnlockedInModule already cover all prerequisites.
};


int? _lessonMinutes(String code) => _lessonMinutesMap[code];

// Lesson names are centralized in lib/data/lesson_names.dart

const Map<String, int> _lessonMinutesMap = {
  // ── Welcome / Onboarding ────────────────────────────────────────────────
  'O1': 5, 'O2': 5, 'O3': 5, 'O4': 5, 'O5': 4,

  // ── The Past ────────────────────────────────────────────────────────────
  'P1': 7, 'P2': 8, 'P3': 7, 'P4': 7, 'P5': 8, 'P6': 9,

  // ── The Present ─────────────────────────────────────────────────────────
  'N1': 8, 'N2': 8, 'N3': 7, 'N4': 7, 'N5': 7, 'N6': 8, 'N7': 7, 'N8': 7,
  'N9': 7, 'N10': 7, 'N11': 8, 'N12': 7, 'N13': 7,

  // ── The Future ──────────────────────────────────────────────────────────
  'F1': 8, 'F2': 8, 'F3': 8, 'F4': 8, 'F5': 8, 'F6': 7, 'F7': 9, 'F8': 8,
};