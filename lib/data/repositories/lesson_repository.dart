import 'package:flutter/foundation.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Canonical repository for lesson progress + checkpoint tracking.
///
/// This layer is the only place that should read/write `lesson_progress`.
/// UI code should call this repository (directly or via controllers).
class LessonRepository {
  LessonRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<LessonProgress?> getProgress({required String userId, required String lessonCode}) async {
    try {
      final row = await _client
          .from('lesson_progress')
          .select('*')
          .eq('user_id', userId)
          .eq('lesson_code', lessonCode)
          .maybeSingle();
      if (row == null) return null;
      return LessonProgress.fromJson(row);
    } catch (e) {
      debugPrint('[LessonRepository] getProgress FAILED: $e');
      return null;
    }
  }

  /// Returns a map keyed by lesson_code for a user's entire progress.
  Future<Map<String, LessonProgress>> getAllProgress({required String userId}) async {
    try {
      final rows = await _client.from('lesson_progress').select('*').eq('user_id', userId);
      final map = <String, LessonProgress>{};
      for (final r in rows) {
        final p = LessonProgress.fromJson(r);
        map[p.lessonCode] = p;
      }
      return map;
    } catch (e) {
      debugPrint('[LessonRepository] getAllProgress FAILED: $e');
      return {};
    }
  }

  Future<void> saveProgress({
    required String userId,
    required String lessonCode,
    required String status,
    int? currentScreen,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final payload = <String, dynamic>{
        'user_id': userId,
        'lesson_code': lessonCode,
        'status': status,
      };
      if (currentScreen != null) payload['current_screen'] = currentScreen;
      if (extra != null) payload.addAll(extra);

      // Backwards/forwards compatible:
      // Some environments include `updated_at` on lesson_progress; others don't.
      // We *prefer* to write it when available, but we must not break the lesson
      // flow if the column is missing.
      final withUpdatedAt = <String, dynamic>{...payload, 'updated_at': DateTime.now().toIso8601String()};
      try {
        await _client.from('lesson_progress').upsert(withUpdatedAt, onConflict: 'user_id,lesson_code');
      } catch (e) {
        final msg = e.toString().toLowerCase();
        final isMissingUpdatedAt = msg.contains("updated_at") && (msg.contains('does not exist') || msg.contains('schema cache'));
        if (!isMissingUpdatedAt) rethrow;
        debugPrint('[LessonRepository] saveProgress retrying without updated_at (column missing)');
        await _client.from('lesson_progress').upsert(payload, onConflict: 'user_id,lesson_code');
      }
    } catch (e) {
      debugPrint('[LessonRepository] saveProgress FAILED: $e');
      rethrow;
    }
  }

  Future<void> completeLesson({
    required String userId,
    required String lessonCode,
    int? finalScreenIndex,
  }) async {
    await saveProgress(
      userId: userId,
      lessonCode: lessonCode,
      status: 'complete',
      currentScreen: finalScreenIndex,
      extra: {'completed_at': DateTime.now().toIso8601String()},
    );
  }
}

class LessonProgress {
  const LessonProgress({
    required this.userId,
    required this.lessonCode,
    required this.status,
    this.currentScreen,
    this.updatedAt,
    this.raw,
  });

  final String userId;
  final String lessonCode;
  final String status;
  final int? currentScreen;
  final DateTime? updatedAt;
  final Map<String, dynamic>? raw;

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    final updatedAt = json['updated_at'];
    return LessonProgress(
      userId: (json['user_id'] ?? '').toString(),
      lessonCode: (json['lesson_code'] ?? '').toString(),
      status: (json['status'] ?? 'not_started').toString(),
      currentScreen: json['current_screen'] is int ? json['current_screen'] as int : int.tryParse('${json['current_screen']}'),
      updatedAt: updatedAt is String ? DateTime.tryParse(updatedAt) : null,
      raw: json,
    );
  }
}
