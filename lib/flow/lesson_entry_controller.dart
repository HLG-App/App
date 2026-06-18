import 'package:flutter/foundation.dart';
import 'package:her_long_game/flow/lesson_entry_repository.dart';

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
        // IMPORTANT:
        // Skipping forward creates a “dead end” UX when the curriculum expects
        // a lesson to exist (e.g., L0) but the DB isn’t populated yet.
        // Route into the lesson screen page, which will show a proper
        // “Coming soon” fallback instead.
        debugPrint('[LessonEntryController] No screens for $lessonCode; showing coming-soon fallback.');
        return '/lesson/$lessonCode/screen?start=0';
      }

      final start = await _repo.getResumeScreenIndex(lessonCode: lessonCode) ?? 0;

      return '/lesson/$lessonCode/screen?start=$start';
    } catch (e) {
      debugPrint('[LessonEntryController] Failed to compute entry route for $lessonCode: $e');
      return '/lesson/$lessonCode/screen?start=0';
    }
  }
}
