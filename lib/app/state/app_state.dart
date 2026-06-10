/// Immutable snapshot of the current app session.
///
/// Rule: UI must not mutate this directly. Controllers own updates.
class AppState {
  const AppState({
    required this.onboardingState,
    this.currentPhaseId,
    this.currentModuleId,
    this.currentLessonCode,
    this.toolContext,
    this.goalSnapshot,
  });

  final OnboardingState onboardingState;

  /// Phase id from LearningCatalog (e.g. 1..3)
  final String? currentPhaseId;

  /// Module id from LearningCatalog (e.g. "0".."4")
  final String? currentModuleId;

  /// Lesson code from LearningCatalog (e.g. "L0")
  final String? currentLessonCode;

  /// Arbitrary current tool context (toolCode + last inputs/outputs, etc.)
  final Map<String, dynamic>? toolContext;

  /// Lightweight goals preview for the current user session.
  final List<Map<String, dynamic>>? goalSnapshot;

  AppState copyWith({
    OnboardingState? onboardingState,
    String? currentPhaseId,
    String? currentModuleId,
    String? currentLessonCode,
    Map<String, dynamic>? toolContext,
    List<Map<String, dynamic>>? goalSnapshot,
  }) => AppState(
    onboardingState: onboardingState ?? this.onboardingState,
    currentPhaseId: currentPhaseId ?? this.currentPhaseId,
    currentModuleId: currentModuleId ?? this.currentModuleId,
    currentLessonCode: currentLessonCode ?? this.currentLessonCode,
    toolContext: toolContext ?? this.toolContext,
    goalSnapshot: goalSnapshot ?? this.goalSnapshot,
  );
}

enum OnboardingState { unknown, welcome, founderNote, diagnostic, complete }
