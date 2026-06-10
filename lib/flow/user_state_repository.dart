import 'package:flutter/foundation.dart';
import 'package:her_long_game/flow/user_state.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository interface so the flow controller/router can depend on abstractions.
abstract class UserStateRepository {
  Future<UserState> load();
}

/// Supabase-backed implementation.
///
/// NOTE: This repository is allowed to call Supabase. Widgets and flow controller
/// are not.
class SupabaseUserStateRepository implements UserStateRepository {
  const SupabaseUserStateRepository();

  @override
  Future<UserState> load() async {
    // On web, opening the app in a different origin (e.g., exported preview) can
    // leave behind a stale refresh token. Supabase will log a refresh error, but
    // `currentSession` may still be non-null until we explicitly clear it.
    //
    // To keep routing predictable, treat refresh failures as signed-out.
    try {
      await SupabaseConfig.auth.refreshSession();
    } catch (e) {
      debugPrint('[UserStateRepository] refreshSession failed; clearing local auth: $e');
      try {
        await SupabaseConfig.auth.signOut(scope: SignOutScope.local);
      } catch (e2) {
        debugPrint('[UserStateRepository] signOut(local) after refresh failure also failed: $e2');
      }
      return const UserState.signedOut();
    }

    final session = SupabaseConfig.auth.currentSession;
    if (session == null) return const UserState.signedOut();

    final uid = session.user.id;

    try {
      Map<String, dynamic>? row;
      try {
        row = await SupabaseService.selectSingle(
          'users',
          select: 'welcomed_at,founder_note_seen,diagnostic_complete,onboarding_complete',
          filters: {'id': uid},
        );
      } on PostgrestException catch (e) {
        // If migrations aren't applied yet, degrade gracefully.
        final msg = e.message.toLowerCase();
        if (msg.contains('welcomed_at') && msg.contains('does not exist')) {
          debugPrint('[UserStateRepository] welcomed_at missing; treating as not welcomed.');
          return UserState(
            isAuthenticated: true,
            welcomedAt: null,
            founderNoteSeen: false,
            diagnosticComplete: false,
            onboardingComplete: false,
          );
        }
        if (msg.contains('founder_note_seen') && msg.contains('does not exist')) {
          debugPrint('[UserStateRepository] founder_note_seen missing; treating as not seen.');
          return UserState(
            isAuthenticated: true,
            welcomedAt: DateTime.now(),
            founderNoteSeen: false,
            diagnosticComplete: false,
            onboardingComplete: false,
          );
        }
        if (msg.contains('diagnostic_complete') && msg.contains('does not exist')) {
          debugPrint('[UserStateRepository] diagnostic_complete missing; treating as incomplete.');
          return UserState(
            isAuthenticated: true,
            welcomedAt: DateTime.now(),
            founderNoteSeen: true,
            diagnosticComplete: false,
            onboardingComplete: false,
          );
        }
        if (msg.contains('onboarding_complete') && msg.contains('does not exist')) {
          debugPrint('[UserStateRepository] onboarding_complete missing; treating as incomplete.');
          return UserState(
            isAuthenticated: true,
            welcomedAt: DateTime.now(),
            founderNoteSeen: true,
            diagnosticComplete: false,
            onboardingComplete: false,
          );
        }
        rethrow;
      }

      final welcomedAtRaw = row?['welcomed_at'];
      DateTime? welcomedAt;
      if (welcomedAtRaw is String) welcomedAt = DateTime.tryParse(welcomedAtRaw);
      // Postgrest sometimes returns DateTime already.
      if (welcomedAtRaw is DateTime) welcomedAt = welcomedAtRaw;

      final founderNoteSeen = row?['founder_note_seen'] == true;
      final diagnosticComplete = row?['diagnostic_complete'] == true;
      final onboardingComplete = row?['onboarding_complete'] == true;

      return UserState(
        isAuthenticated: true,
        welcomedAt: welcomedAt,
        founderNoteSeen: founderNoteSeen,
        diagnosticComplete: diagnosticComplete,
        onboardingComplete: onboardingComplete,
      );
    } catch (e) {
      debugPrint('[UserStateRepository] load failed: $e');
      // Fail safe to auth.
      return const UserState.signedOut();
    }
  }
}
