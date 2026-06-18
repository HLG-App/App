import 'package:flutter/foundation.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  UserRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getUserRow(String userId) async {
    try {
      return await _client.from('users').select('*').eq('id', userId).maybeSingle();
    } catch (e) {
      debugPrint('[UserRepository] getUserRow FAILED: $e');
      return null;
    }
  }

  Future<void> upsertProfile({required String userId, String? email, String? name}) async {
    try {
      final nowIso = DateTime.now().toIso8601String();
      final payload = <String, dynamic>{
        'id': userId,
        if (email != null) 'email': email,
        if (name != null) ...{'name': name, 'display_name': name},
        'updated_at': nowIso,
        'created_at': nowIso,
      };

      try {
        await _client.from('users').upsert(payload, onConflict: 'id');
        return;
      } on PostgrestException catch (e) {
        // Degrade gracefully when the connected project schema hasn't caught up.
        // This prevents auth/onboarding flows from breaking on optional profile columns.
        final msg = e.message.toLowerCase();
        final emailMissing = msg.contains("'email'") && msg.contains('could not find');
        final nameMissing = (msg.contains("'name'") && msg.contains('could not find')) || (msg.contains('name') && msg.contains('does not exist'));
        final displayNameMissing = (msg.contains("'display_name'") && msg.contains('could not find')) || (msg.contains('display_name') && msg.contains('does not exist'));

        if (!emailMissing && !nameMissing && !displayNameMissing) rethrow;

        debugPrint('[UserRepository] upsertProfile retrying with minimal columns (schema mismatch): ${e.message}');
        // Minimal safe shape: only columns that virtually all profiles tables contain.
        // If even timestamps are missing, the outer catch will surface it.
        final fallback = <String, dynamic>{'id': userId, 'updated_at': nowIso, 'created_at': nowIso};
        await _client.from('users').upsert(fallback, onConflict: 'id');
        return;
      }
    } catch (e) {
      debugPrint('[UserRepository] upsertProfile FAILED: $e');
      rethrow;
    }
  }

  Future<void> updateEmotionalBaseline({required String userId, required String? baseline}) async {
    try {
      await _client.from('users').update({'emotional_baseline': baseline}).eq('id', userId);
    } catch (e) {
      debugPrint('[UserRepository] updateEmotionalBaseline FAILED: $e');
      rethrow;
    }
  }
}
