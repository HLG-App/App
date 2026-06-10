import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/data/learning_catalog.dart';
import 'package:her_long_game/screens/learn/learn_page.dart' show ModuleCard; // reuse UI
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class LearnPhasePage extends StatefulWidget {
  const LearnPhasePage({super.key, required this.phaseId});

  final int phaseId;

  @override
  State<LearnPhasePage> createState() => _LearnPhasePageState();
}

class _LearnPhasePageState extends State<LearnPhasePage> {
  final LessonRepository _lessonRepo = LessonRepository();

  bool _isLoading = true;
  String? _error;
  final Map<String, String> _statusByLessonCode = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
      debugPrint('[LearnPhasePage] Failed to load: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load phase.';
      });
    }
  }

  bool _isComplete(String lessonCode) => _statusByLessonCode[lessonCode] == 'complete';

  @override
  Widget build(BuildContext context) {
    final phase = LearningCatalog.instance.maybeGetPhase(widget.phaseId);
    if (phase == null) {
      return Scaffold(
        appBar: const HerAppBar(showBack: true, fallbackRoute: '/learn', titleText: 'Learn'),
        body: const Center(child: Text('Unknown phase.')),
      );
    }

    final modules = [
      for (final id in phase.moduleIds)
        ...[LearningCatalog.instance.maybeGetModule(id)].whereType<Module>(),
    ];

    // Auto-show phase entry only on first visit (disabled for now to fix navigation)
    // Users can manually access it via the info button in the app bar
    // if (!_isLoading && _error == null && !_entrySeen && !_promptedEntry) {
    //   _promptedEntry = true;
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;
    //     context.push('entry');
    //   });
    // }

    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/learn',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text(phase.title, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
        actions: [
          IconButton(tooltip: 'Phase framing', onPressed: () => context.push('entry?revisit=1'), icon: const Icon(Icons.info_outline, color: HLGColors.textBody)),
          IconButton(onPressed: _isLoading ? null : _load, icon: const Icon(Icons.refresh, color: HLGColors.textBody), tooltip: 'Refresh'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!, style: Theme.of(context).textTheme.bodyLarge))
              : ListView.separated(
                  itemCount: modules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final m = modules[index];
                    final codes = [for (final item in m.items) item.code];
                    final completed = codes.where(_isComplete).length;
                    final total = codes.length;
                    final percent = total == 0 ? 0.0 : completed / total;
                    final unlocked = m.unlockRule(_statusByLessonCode);
                    final started = completed > 0;
                    return ModuleCard(
                      moduleLabel: m.label,
                      title: m.title,
                      completed: completed,
                      total: total,
                      progress: percent,
                      unlocked: unlocked,
                      started: started,
                      onTap: unlocked ? () => context.push('/learn/module/${m.index}') : null,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
