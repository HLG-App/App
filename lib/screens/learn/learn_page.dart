import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/data/learning_catalog.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/her_tab_header.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final LessonRepository _lessonRepo = LessonRepository();

  bool _isLoading = true;
  String? _error;
  final Map<String, String> _statusByLessonCode = {};
  final Set<int> _seenPhaseIds = {};
  bool _printedCurriculumReport = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _printCurriculumCompletenessReport() async {
    if (!kDebugMode) return;
    if (_printedCurriculumReport) return;
    _printedCurriculumReport = true;

    try {
      final allLessonCodes = <String>{
        for (final m in LearningCatalog.instance.modules) for (final item in m.items) item.code,
      }.toList()
        ..sort();

      if (allLessonCodes.isEmpty) {
        debugPrint('[CurriculumCompleteness] No lesson codes found in LearningCatalog.');
        return;
      }

      // Fetch all lesson_screens rows for the curriculum lesson codes and compute counts locally.
      // This stays fast because the curriculum is small.
      final rows = await SupabaseConfig.client
          .from('lesson_screens')
          .select('lesson_code')
          .inFilter('lesson_code', allLessonCodes);

      final counts = <String, int>{};
      for (final r in rows) {
        final code = (r['lesson_code'] ?? '').toString();
        if (code.isEmpty) continue;
        counts[code] = (counts[code] ?? 0) + 1;
      }

      debugPrint('');
      debugPrint('========== Curriculum Completeness (Supabase lesson_screens) ==========');
      int missingTotal = 0;

      for (final module in LearningCatalog.instance.modules) {
        debugPrint('');
        debugPrint('[Module ${module.index}] ${module.label} - ${module.title}');
        for (final item in module.items) {
          final code = item.code;
          final c = counts[code] ?? 0;
          final missing = c == 0;
          if (missing) missingTotal++;
          debugPrint('  \u2022 $code: ${missing ? 'MISSING' : '$c screen row(s)'}');
        }
      }

      debugPrint('');
      debugPrint('Missing lesson_screens for $missingTotal lesson/checkpoint code(s).');
      debugPrint('=======================================================================');
      debugPrint('');
    } catch (e) {
      // Most common causes: table missing, RLS policy, or network.
      debugPrint('[CurriculumCompleteness] Failed to query lesson_screens: $e');
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

      final seen = <int>{};
      try {
        final phaseRows = await SupabaseConfig.client.from('phase_progress').select('phase_id').eq('user_id', uid);
        for (final r in phaseRows) {
          final id = int.tryParse((r['phase_id'] ?? '').toString());
          if (id != null) seen.add(id);
        }
      } catch (e) {
        debugPrint('[LearnPage] phase_progress not available yet: $e');
      }

      if (!mounted) return;
      setState(() {
        _statusByLessonCode
          ..clear()
          ..addAll(map);
        _seenPhaseIds
          ..clear()
          ..addAll(seen);
        _isLoading = false;
      });

      // Debug-only: print a module-by-module completeness report once per app run.
      // Non-blocking; never affects UI.
      // ignore: unawaited_futures
      _printCurriculumCompletenessReport();
    } catch (e) {
      debugPrint('[LearnPage] Failed to load lesson_progress: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load lessons.';
      });
    }
  }

  bool _isComplete(String lessonCode) => _statusByLessonCode[lessonCode] == 'complete';

  Widget _buildPhaseCard(BuildContext context, Phase phase) {
    final modules = [
      for (final id in phase.moduleIds)
        ...[LearningCatalog.instance.maybeGetModule(id)].whereType<Module>(),
    ];
    final lessonCodes = [for (final m in modules) for (final item in m.items) item.code];
    final completed = lessonCodes.where(_isComplete).length;
    final total = lessonCodes.length;
    final percent = total == 0 ? 0.0 : completed / total;
    final unlocked = modules.isEmpty ? false : modules.first.unlockRule(_statusByLessonCode);
    final started = completed > 0;
    final seen = _seenPhaseIds.contains(phase.id);

    return PhaseCard(
      phase: phase,
      completed: completed,
      total: total,
      progress: percent,
      unlocked: unlocked,
      started: started,
      seen: seen,
      // Use an absolute push for reliability under ShellRoute.
      onTap: unlocked ? () => context.push('/learn/phase/${phase.id}') : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final phases = LearningCatalog.instance.phases;

    return Scaffold(
      appBar: HerAppBar(
        useBrandBand: true,
        actions: [
          IconButton(onPressed: _isLoading ? null : _loadProgress, icon: const Icon(Icons.refresh, color: HLGColors.textBody), tooltip: 'Refresh'),
          const HerLogoutIconButton(),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _LearnErrorState(message: _error!, onRetry: _loadProgress)
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const HerTabHeader(
                        tabLabel: 'LEARN',
                        showEyebrow: false,
                        title: 'Learn',
                        subtitle: 'Your curriculum, progress, and next steps — at your pace.',
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            if (!(_statusByLessonCode['O5'] == 'complete') && LearningCatalog.instance.maybeGetModule('0') != null) ...[
                              _WelcomeCard(
                                module: LearningCatalog.instance.maybeGetModule('0')!,
                                statusByLessonCode: _statusByLessonCode,
                                onTap: () => context.push('/learn/module/0'),
                              ),
                              const SizedBox(height: 14),
                            ],
                            for (var i = 0; i < phases.length; i++) ...[
                              _buildPhaseCard(context, phases[i]),
                              if (i < phases.length - 1) const SizedBox(height: 14),
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

class PhaseCard extends StatelessWidget {
  const PhaseCard({
    super.key,
    required this.phase,
    required this.completed,
    required this.total,
    required this.progress,
    required this.unlocked,
    required this.started,
    required this.seen,
    required this.onTap,
  });

  final Phase phase;
  final int completed;
  final int total;
  final double progress;
  final bool unlocked;
  final bool started;
  final bool seen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = started ? HLGColors.petal : HLGColors.warmCream;
    final baseChild = Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(phase.title, style: HLGTextStyles.eyebrowAllCaps(color: phase.accentColor))),
              if (!unlocked) const Icon(Icons.lock, color: HLGColors.sageMid, size: 18),
              if (unlocked && !seen) const Icon(Icons.fiber_new_rounded, color: HLGColors.horizonOrange, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(phase.subtitle, style: HLGTextStyles.moduleTitle(color: HLGColors.textBody)),
          const SizedBox(height: 10),
          Text(phase.learnerFeels, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
          const SizedBox(height: 12),
          Text('$completed of $total', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: HLGColors.creamWarm,
              valueColor: const AlwaysStoppedAnimation<Color>(HLGColors.crownGold),
            ),
          ),
        ],
      ),
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: onTap,
          overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.12)),
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: HLGColors.sageMid, width: 1), borderRadius: BorderRadius.circular(16)),
            child: baseChild,
          ),
        ),
      ),
    );

    return unlocked ? card : Opacity(opacity: 0.55, child: card);
  }
}

/// Standalone card shown above the phase list in LearnPage until O5 is complete.
///
/// The Welcome module (O1\u2013O5) is NOT part of any phase. It is onboarding \u2014
/// always unlocked, always first, disappears once the user finishes it.
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.module,
    required this.statusByLessonCode,
    required this.onTap,
  });

  final Module module;
  final Map<String, String> statusByLessonCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lessonCodes = [for (final item in module.items) item.code];
    final completed = lessonCodes.where((c) => statusByLessonCode[c] == 'complete').length;
    final total = lessonCodes.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final started = completed > 0;

    final baseChild = Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('BEFORE WE BEGIN', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.horizonOrange)),
              ),
              if (started && completed < total)
                const Icon(Icons.fiber_new_rounded, color: HLGColors.horizonOrange, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text('Start here', style: HLGTextStyles.moduleTitle(color: HLGColors.textBody)),
          const SizedBox(height: 10),
          Text(
            'Five short lessons to set the scene before your long game begins.',
            style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
          ),
          const SizedBox(height: 12),
          Text('$completed of $total', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: HLGColors.creamWarm,
              valueColor: const AlwaysStoppedAnimation<Color>(HLGColors.horizonOrange),
            ),
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: started ? HLGColors.petal : HLGColors.warmCream,
        child: InkWell(
          onTap: onTap,
          overlayColor: WidgetStatePropertyAll(HLGColors.horizonOrange.withValues(alpha: 0.08)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: HLGColors.horizonOrange.withValues(alpha: 0.55), width: 1.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: baseChild,
          ),
        ),
      ),
    );
  }
}

class _LearnErrorState extends StatelessWidget {
  const _LearnErrorState({required this.message, required this.onRetry});

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

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.moduleLabel,
    required this.title,
    required this.completed,
    required this.total,
    required this.progress,
    required this.unlocked,
    required this.started,
    required this.onTap,
  });

  final String moduleLabel;
  final String title;
  final int completed;
  final int total;
  final double progress;
  final bool unlocked;
  final bool started;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = started ? HLGColors.petal : HLGColors.warmCream;
    final baseChild = Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(moduleLabel.toUpperCase(), style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.crownGold))),
              if (!unlocked) const Icon(Icons.lock, color: HLGColors.sageMid, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: HLGTextStyles.moduleTitle(color: HLGColors.textBody)),
          const SizedBox(height: 12),
          Text('$completed of $total', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: HLGColors.sagePale,
              valueColor: const AlwaysStoppedAnimation<Color>(HLGColors.deepSage),
            ),
          ),
        ],
      ),
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: onTap,
          overlayColor: WidgetStatePropertyAll(HLGColors.sage.withValues(alpha: 0.12)),
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: HLGColors.sageMid, width: 1), borderRadius: BorderRadius.circular(12)),
            child: baseChild,
          ),
        ),
      ),
    );

    return unlocked ? card : Opacity(opacity: 0.55, child: card);
  }
}
