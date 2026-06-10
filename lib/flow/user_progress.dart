import 'package:flutter/foundation.dart';
import 'package:her_long_game/flow/user_state.dart';

/// Minimal onboarding progress snapshot used for onboarding flow decisions.
///
/// Kept separate from [UserState] so onboarding can be reasoned about without
/// auth/session concerns.
@immutable
class UserProgress {
  final bool welcomed;
  final bool founderNoteSeen;
  final bool diagnosticComplete;

  const UserProgress({required this.welcomed, required this.founderNoteSeen, required this.diagnosticComplete});

  factory UserProgress.fromUserState(UserState state) {
    return UserProgress(
      welcomed: state.welcomedAt != null,
      founderNoteSeen: state.founderNoteSeen,
      diagnosticComplete: state.diagnosticComplete,
    );
  }
}
