import 'package:flutter/foundation.dart';
import 'package:her_long_game/flow/lesson_entry_repository.dart';
import 'package:her_long_game/utils/lesson_flow.dart';

/// Centralizes the logic for entering a lesson.
///
/// Used by the `/lesson/:code` route (LessonPage) to decide whether to:
/// - resume at a screen index
/// - start at 0 (or special-cased indices)
/// - skip forward when there is no authored content
class LessonEntryController {
  LessonEntryController._(this._repo);

  static LessonEntryController instance = LessonEntryController._(const SupabaseLessonEntryRepository());

  final LessonEntryRepository _repo;

  Future<String> getEntryRoute({required String lessonCode}) async {
    try {
      final hasScreens = await _repo.lessonHasAnyScreens(lessonCode: lessonCode);
      if (!hasScreens) {
        debugPrint('[LessonEntryController] No screens for $lessonCode; skipping forward.');
        return LessonFlowController.instance.nextRouteAfterLesson(lessonCode);
      }

      final start = await _repo.getResumeScreenIndex(lessonCode: lessonCode) ?? 0;

      return '/lesson/$lessonCode/screen?start=$start';
    } catch (e) {
      debugPrint('[LessonEntryController] Failed to compute entry route for $lessonCode: $e');
      return '/lesson/$lessonCode/screen?start=0';
    }
  }
}
