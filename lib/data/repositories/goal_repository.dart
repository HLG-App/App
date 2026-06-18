import 'package:flutter/foundation.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalRepository {
  GoalRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Saves a goal row.
  ///
  /// Important: We intentionally do NOT rely on `upsert(... onConflict: ...)` here.
  /// Some Supabase projects backing Dreamflow apps don't have a matching UNIQUE
  /// constraint for the provided `onConflict` target, which causes:
  /// `there is no unique or exclusion constraint matching the ON CONFLICT specification`.
  ///
  /// Instead we:
  /// 1) try `insert`
  /// 2) if it fails due to a duplicate key, we `update` by (user_id, goal_code)
  Future<void> upsertGoal(String userId, String goalCode, String label, {String? sourceLesson, String? linkedTool}) async {
    try {
      final basePayload = <String, dynamic>{
        'user_id': userId,
        'goal_code': goalCode,
        'label': label,
        if (sourceLesson != null) 'source_lesson': sourceLesson,
        if (linkedTool != null) 'linked_tool': linkedTool,
      };

      // Some Supabase environments used in Dreamflow projects may not have
      // optional columns like goal_type/updated_at/created_at. We try the
      // richest payload first, then progressively retry with fewer columns.
      final now = DateTime.now().toIso8601String();
      final attempts = <Map<String, dynamic>>[
        <String, dynamic>{...basePayload, 'goal_type': 'weekly', 'updated_at': now, 'created_at': now},
        <String, dynamic>{...basePayload, 'updated_at': now, 'created_at': now},
        <String, dynamic>{...basePayload, 'created_at': now},
        <String, dynamic>{...basePayload},
      ];

      Object? lastError;
      for (final attempt in attempts) {
        try {
          await _client.from('goals').insert(attempt);
          return;
        } on PostgrestException catch (e) {
          lastError = e;

          // If the project *does* enforce uniqueness (via PK or a unique index)
          // and we're inserting an already-existing goal, update it instead.
          final isDuplicate = (e.code == '23505') || e.message.toLowerCase().contains('duplicate key');
          if (isDuplicate) {
            try {
              await _client
                  .from('goals')
                  .update(<String, dynamic>{...attempt, 'label': label, 'updated_at': now})
                  .eq('user_id', userId)
                  .eq('goal_code', goalCode);
              return;
            } catch (updateError) {
              lastError = updateError;
              debugPrint('[GoalRepository] upsertGoal update fallback FAILED: $updateError');
            }
          }

          // Otherwise, retry with fewer columns (e.g., missing updated_at).
          debugPrint('[GoalRepository] upsertGoal retry with fewer columns: $e');
        } catch (e) {
          lastError = e;
          debugPrint('[GoalRepository] upsertGoal retry with fewer columns: $e');
        }
      }

      // If we got here, everything failed.
      throw lastError ?? Exception('Unknown error saving goal');
    } catch (e) {
      debugPrint('[GoalRepository] upsertGoal FAILED: $e');
      rethrow;
    }
  }

  Future<List<Goal>> getGoals(String userId) async {
    try {
      final rows = await _client.from('goals').select('*').eq('user_id', userId).order('created_at', ascending: false);
      return rows.map<Goal>((r) => Goal.fromJson(r)).toList(growable: false);
    } catch (e) {
      debugPrint('[GoalRepository] getGoals FAILED: $e');
      return [];
    }
  }
}

class Goal {
  const Goal({
    required this.userId,
    required this.goalCode,
    required this.label,
    this.sourceLesson,
    this.linkedTool,
    this.createdAt,
    this.raw,
  });

  final String userId;
  final String goalCode;
  final String label;
  final String? sourceLesson;
  final String? linkedTool;
  final DateTime? createdAt;
  final Map<String, dynamic>? raw;

  factory Goal.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'];
    return Goal(
      userId: (json['user_id'] ?? '').toString(),
      goalCode: (json['goal_code'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      sourceLesson: json['source_lesson']?.toString(),
      linkedTool: json['linked_tool']?.toString(),
      createdAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
      raw: json,
    );
  }
}
