import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/flow/lesson_entry_controller.dart';
import 'package:her_long_game/theme.dart';

/// Lesson entry route.
///
/// This page contains no business logic. It delegates decisions to
/// [LessonEntryController] and immediately routes into `/lesson/:code/screen`.
class LessonPage extends StatefulWidget {
  const LessonPage({super.key, required this.lessonCode});

  final String lessonCode;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final target = await LessonEntryController.instance.getEntryRoute(lessonCode: widget.lessonCode);
      if (!mounted) return;
      context.go(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(999),
                    color: cs.primary,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Loading lesson…', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
