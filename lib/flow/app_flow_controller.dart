import 'package:her_long_game/app.dart' show AppRoutes;
import 'package:her_long_game/flow/onboarding_flow_controller.dart';
import 'package:her_long_game/flow/user_progress.dart';
import 'package:her_long_game/flow/user_state.dart';

/// AppFlowController (MASTER ENTRY LOGIC)
///
/// - Singleton
/// - Contains no UI code
/// - Makes no network/database calls directly
/// - Uses injected services/repositories when a higher-level orchestration method
///   is needed.
class AppFlowController {
  AppFlowController._();

  static final AppFlowController instance = AppFlowController._();

  /// Determines the correct landing route based on user state.
  ///
  /// Order of operations:
  /// - signed out -> /auth
  /// - not welcomed -> /welcome
  /// - founder note not seen -> /founder-note
  /// - diagnostic not complete -> /onboarding/diagnostic
  /// - else -> /home
  String getInitialRoute(UserState state) {
    if (!state.isAuthenticated) return AppRoutes.auth;

    // Delegate onboarding branching to the onboarding flow controller.
    final progress = UserProgress.fromUserState(state);
    return OnboardingFlowController.instance.resumeOnboarding(progress);
  }
}
