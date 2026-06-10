import 'package:her_long_game/app.dart' show AppRoutes;
import 'package:her_long_game/flow/user_progress.dart';

/// OnboardingFlowController
///
/// Replaces all onboarding route branching logic embedded in widgets/router.
///
/// Rules:
/// - No UI code
/// - No Supabase calls
/// - Sole source of truth for onboarding step order + resume decisions
class OnboardingFlowController {
  OnboardingFlowController._();

  static final OnboardingFlowController instance = OnboardingFlowController._();

  static const List<String> _orderedSteps = <String>[
    AppRoutes.welcome,
    AppRoutes.founderNote,
    AppRoutes.financialWellbeingDiagnostic,
  ];

  /// Returns the next onboarding route after [currentStep].
  ///
  /// If [currentStep] is unknown, we fall back to the first step.
  String nextOnboardingStep(String currentStep) {
    final idx = _orderedSteps.indexOf(currentStep);
    if (idx < 0) return _orderedSteps.first;
    if (idx >= _orderedSteps.length - 1) return AppRoutes.home;
    return _orderedSteps[idx + 1];
  }

  /// Returns the correct onboarding resume route based on persisted progress.
  ///
  /// This method is the single place that decides whether onboarding is done.
  String resumeOnboarding(UserProgress progress) {
    // 1) Not welcomed
    if (!progress.welcomed) return AppRoutes.welcome;

    // 2) Founder note not seen
    if (!progress.founderNoteSeen) return AppRoutes.founderNote;

    // 3) Diagnostic not complete — show ONCE only
    if (!progress.diagnosticComplete) return AppRoutes.financialWellbeingDiagnostic;

    // 4) Everything done
    return AppRoutes.home;
  }
}
