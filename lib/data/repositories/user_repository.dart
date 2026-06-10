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
      await _client.from('users').upsert({
        'id': userId,
        if (email != null) 'email': email,
        if (name != null) ...{
          'name': name,
          'display_name': name,
        },
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
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
