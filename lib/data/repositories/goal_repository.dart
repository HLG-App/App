import 'package:flutter/foundation.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalRepository {
  GoalRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Enforces uniqueness on (user_id, goal_code) via upsert.
  ///
  /// - If the goal exists, its label will be updated.
  /// - If it doesn't exist, it will be created.
  Future<void> upsertGoal(String userId, String goalCode, String label, {String? sourceLesson, String? linkedTool}) async {
    try {
      await _client
          .from('goals')
          .upsert({
            'user_id': userId,
            'goal_code': goalCode,
            'label': label,
            if (sourceLesson != null) 'source_lesson': sourceLesson,
            if (linkedTool != null) 'linked_tool': linkedTool,
            'updated_at': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,goal_code');
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
