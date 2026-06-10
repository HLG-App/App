import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/data/lesson_names.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/utils/lesson_flow.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class LearningProgressOverviewPage extends StatefulWidget {
  const LearningProgressOverviewPage({super.key});

  @override
  State<LearningProgressOverviewPage> createState() => _LearningProgressOverviewPageState();
}

class _LearningProgressOverviewPageState extends State<LearningProgressOverviewPage> {
  final LessonRepository _lessonRepo = LessonRepository();
  bool _isLoading = true;
  String? _error;
  int _completed = 0;
  int _total = 0;
  String? _nextItem;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static List<String> _lessonCodesInSequence() => LessonFlow.lessonSequence.where((s) => s.startsWith('L')).toList(growable: false);

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _completed = 0;
          _total = _lessonCodesInSequence().length;
          _nextItem = LessonFlow.lessonSequence.isNotEmpty ? LessonFlow.lessonSequence.first : null;
        });
        return;
      }

      final lessonCodes = _lessonCodesInSequence();
      _total = lessonCodes.length;

      final progress = await _lessonRepo.getAllProgress(userId: uid);
      final statusByCode = <String, String>{for (final e in progress.entries) e.key: e.value.status};

      int completed = 0;
      for (final code in lessonCodes) {
        if (statusByCode[code] == 'complete') completed++;
      }

      String? next;
      for (final item in LessonFlow.lessonSequence) {
        if (item.startsWith('L')) {
          if (statusByCode[item] != 'complete') {
            next = item;
            break;
          }
        } else {
          // checkpoints: surface if prior lesson is complete.
          next ??= item;
        }
      }
      next ??= LessonFlow.lessonSequence.isNotEmpty ? LessonFlow.lessonSequence.last : null;

      setState(() {
        _completed = completed;
        _total = lessonCodes.length;
        _nextItem = next;
      });
    } catch (e) {
      debugPrint('[LearningProgressOverviewPage] Load failed: $e');
      setState(() {
        _error = 'Could not load your progress.';
        _completed = 0;
        _total = _lessonCodesInSequence().length;
        _nextItem = LessonFlow.lessonSequence.isNotEmpty ? LessonFlow.lessonSequence.first : null;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_total <= 0) ? 0.0 : (_completed / _total).clamp(0.0, 1.0);
    final nextLabel = () {
      final next = _nextItem;
      if (next == null) return null;
      if (next.startsWith('CK')) {
        final n = int.tryParse(next.substring(2));
        return n == null ? 'Checkpoint' : 'Checkpoint $n';
      }
      return lessonDisplayNames[next] ?? lessonMicroLabels[next];
    }();
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/profile',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text('Learning progress', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
        actions: [
          IconButton(tooltip: 'Refresh', onPressed: _isLoading ? null : _load, icon: const Icon(Icons.refresh, color: HLGColors.midSage)),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HLGColors.petal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: HLGTextStyles.lessonHeading(color: HLGColors.night)),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    Text('Loading…', style: HLGTextStyles.body(color: HLGColors.midSage))
                  else if (_error != null)
                    Text(_error!, style: HLGTextStyles.body(color: HLGColors.horizonOrange))
                  else
                    Text('Completed $_completed of $_total', style: HLGTextStyles.body(color: HLGColors.textBody)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: HLGColors.warmCream,
                      valueColor: const AlwaysStoppedAnimation<Color>(HLGColors.deepSage),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HLGColors.warmCream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_outline, color: HLGColors.deepSage),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nextLabel == null ? 'No next step found.' : 'Up next: $nextLabel',
                            style: HLGTextStyles.body(color: HLGColors.textBody),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => context.go('/learn'),
                    style: FilledButton.styleFrom(
                      backgroundColor: HLGColors.deepSage,
                      foregroundColor: HLGColors.warmCream,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                    icon: const Icon(Icons.menu_book_outlined, color: HLGColors.warmCream),
                    label: Text('Go to Learn', style: HLGTextStyles.labelMedium(color: HLGColors.warmCream)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
