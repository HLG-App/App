import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/auth/auth_manager.dart';
import 'package:her_long_game/models/user.dart' as app;
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  @override
  Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signOut failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    // Deleting a user requires admin privileges (service role) and should be done
    // server-side via an Edge Function.
    throw UnimplementedError(
      'User deletion must be implemented via a Supabase Edge Function (service role).',
    );
  }

  @override
  Future<void> updateEmail({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.updateUser(sb.UserAttributes(email: email));
    } catch (e) {
      debugPrint('Supabase updateEmail failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Supabase resetPassword failed: $e');
      rethrow;
    }
  }

  @override
  Future<app.User?> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      final res = await SupabaseConfig.auth.signInWithPassword(email: email, password: password);
      final user = res.user;
      if (user == null) return null;
      return _toAppUser(user);
    } catch (e) {
      debugPrint('Supabase signInWithEmail failed: $e');
      rethrow;
    }
  }

  @override
  Future<app.User?> createAccountWithEmail(BuildContext context, String email, String password) async {
    try {
      final res = await SupabaseConfig.auth.signUp(email: email, password: password);
      final user = res.user;
      if (user == null) return null;
      return _toAppUser(user);
    } catch (e) {
      debugPrint('Supabase createAccountWithEmail failed: $e');
      rethrow;
    }
  }

  app.User _toAppUser(sb.User user) {
    final createdAt = DateTime.tryParse(user.createdAt) ?? DateTime.now();
    return app.User(
      id: user.id,
      email: user.email,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
