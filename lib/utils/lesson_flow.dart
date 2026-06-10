import 'package:flutter/foundation.dart';
import 'package:her_long_game/data/learning_catalog.dart';

/// Centralized lesson progression logic.
///
/// This controller intentionally contains **no UI code**.
/// It is designed to be the single source of truth for:
/// - Progression between lessons and checkpoints
/// - Skipping lessons that have no content
/// - Module boundary transitions
///
/// Note: `shouldSkipLesson` is synchronous by requirement. To support that
/// while using Supabase, populate [setSkippableLessons] from a repository
/// elsewhere (e.g., at app start / Learn load).
class LessonFlowController {
  LessonFlowController._();

  static final LessonFlowController instance = LessonFlowController._();

  final Set<String> _skippableLessonCodes = <String>{};

  /// Canonical sequence of items (lessons + checkpoints) in order.
  ///
  /// Derived from [LearningCatalog] so the curriculum can’t drift.
  List<String> get lessonSequence {
    return LearningCatalog.instance.lessonSequence;
  }

  /// Supply a set of lesson codes that should be skipped (no screens in Supabase).
  ///
  /// Example values: `{ 'L7b', 'L8a' }`.
  void setSkippableLessons(Set<String> lessonCodes) {
    _skippableLessonCodes
      ..clear()
      ..addAll(lessonCodes);
  }

  bool shouldSkipLesson(String lessonCode) => _skippableLessonCodes.contains(lessonCode);

  /// Returns the first lesson code in a module.
  ///
  /// [moduleId] is currently expected to be the module index as a string
  /// (e.g. "0", "1"). If the module contains checkpoints, the first *lesson*
  /// (starting with 'L') is returned.
  String firstLessonInModule(String moduleId) {
    final module = LearningCatalog.instance.maybeGetModule(moduleId);
    if (module == null) return 'LA';

    for (final item in module.items) {
      if (item.code.startsWith('L')) return item.code;
    }
    return module.items.isNotEmpty ? module.items.first.code : 'LA';
  }

  /// Determine the next route after a lesson completes.
  ///
  /// - Looks up [lessonCode] within [lessonSequence]
  /// - Advances to the next item (lesson or checkpoint)
  /// - Automatically skips lessons that [shouldSkipLesson]
  /// - Returns `/home` at the end of the sequence
  ///
  /// [currentIndex] is included for forward compatibility (e.g. branching
  /// within a lesson). It is not used yet.
  String nextAfterLesson({required String lessonCode, required int currentIndex, required List<String> lessonSequence}) {
    final idx = lessonSequence.indexOf(lessonCode);
    if (idx < 0) {
      debugPrint('LessonFlowController.nextAfterLesson: unknown lessonCode=$lessonCode');
      return '/learn';
    }

    var nextIdx = idx + 1;
    while (true) {
      if (nextIdx >= lessonSequence.length) return '/home';
      final nextCode = lessonSequence[nextIdx];

      if (nextCode.startsWith('CK')) {
        final n = int.tryParse(nextCode.substring(2));
        return n == null ? '/learn' : '/checkpoint/$n';
      }

      if (shouldSkipLesson(nextCode)) {
        debugPrint('LessonFlowController: skipping lesson with no content: $nextCode');
        nextIdx++;
        continue;
      }
      return '/lesson/$nextCode';
    }
  }

  /// Convenience helper matching the previous API: uses canonical sequence.

  /// Completing a lesson should always route to the close experience first.
  String nextRouteAfterLesson(String lessonCode) => '/lesson/$lessonCode/close';

  /// Determine the next route after the close experience (legacy progression logic).
  String nextRouteAfterClose(String lessonCode) => nextAfterLesson(lessonCode: lessonCode, currentIndex: -1, lessonSequence: lessonSequence);
}

/// Backwards-compatible wrapper for legacy call sites.
///
/// Prefer using [LessonFlowController.instance] directly.
@Deprecated('Use LessonFlowController.instance')
class LessonFlow {
  static List<String> get lessonSequence => LessonFlowController.instance.lessonSequence;

  /// Completing a lesson routes to the close experience.
  static String nextRouteAfterLesson(String lessonCode) => LessonFlowController.instance.nextRouteAfterLesson(lessonCode);

  /// After close, advance to the next lesson/checkpoint.
  static String nextRouteAfterClose(String lessonCode) => LessonFlowController.instance.nextRouteAfterClose(lessonCode);
}
