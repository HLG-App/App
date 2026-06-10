import 'package:flutter/foundation.dart';

/// Immutable snapshot of what the app needs to decide the correct landing route.
///
/// This is intentionally UI-agnostic and persistence-agnostic.
@immutable
class UserState {
  final bool isAuthenticated;
  final DateTime? welcomedAt;
  final bool founderNoteSeen;
  final bool diagnosticComplete;
  final bool onboardingComplete;

  const UserState({
    required this.isAuthenticated,
    required this.welcomedAt,
    required this.founderNoteSeen,
    required this.diagnosticComplete,
    required this.onboardingComplete,
  });

  const UserState.signedOut()
      : isAuthenticated = false,
        welcomedAt = null,
        founderNoteSeen = false,
        diagnosticComplete = false,
        onboardingComplete = false;

  UserState copyWith({
    bool? isAuthenticated,
    DateTime? welcomedAt,
    bool? founderNoteSeen,
    bool? diagnosticComplete,
    bool? onboardingComplete,
  }) {
    return UserState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      welcomedAt: welcomedAt ?? this.welcomedAt,
      founderNoteSeen: founderNoteSeen ?? this.founderNoteSeen,
      diagnosticComplete: diagnosticComplete ?? this.diagnosticComplete,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
