import 'package:flutter/foundation.dart';
import 'package:her_long_game/supabase/supabase_config.dart';

abstract class LessonEntryRepository {
  Future<bool> lessonHasAnyScreens({required String lessonCode});

  /// Returns resume index if status is in_progress.
  Future<int?> getResumeScreenIndex({required String lessonCode});

  /// Finds the first screen_index >= [afterIndexInclusive].
  Future<int?> getFirstScreenIndexAfter({required String lessonCode, required int afterIndexInclusive});
}

class SupabaseLessonEntryRepository implements LessonEntryRepository {
  const SupabaseLessonEntryRepository();

  @override
  Future<bool> lessonHasAnyScreens({required String lessonCode}) async {
    try {
      final rows = await SupabaseConfig.client.from('lesson_screens').select('screen_index').eq('lesson_code', lessonCode).limit(1);
      return rows.isNotEmpty;
    } catch (e) {
      debugPrint('[SupabaseLessonEntryRepository] lessonHasAnyScreens failed: $e');
      // Treat as hasScreens=true so we don't skip unexpectedly.
      return true;
    }
  }

  @override
  Future<int?> getResumeScreenIndex({required String lessonCode}) async {
    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) return null;

      final row = await SupabaseConfig.client
          .from('lesson_progress')
          .select('status,current_screen')
          .eq('user_id', uid)
          .eq('lesson_code', lessonCode)
          .maybeSingle();
      if (row == null) return null;

      final status = (row['status'] ?? '').toString().trim();
      if (status != 'in_progress') return null;

      final raw = row['current_screen'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw is String) return int.tryParse(raw);
      return null;
    } catch (e) {
      debugPrint('[SupabaseLessonEntryRepository] getResumeScreenIndex failed: $e');
      return null;
    }
  }

  @override
  Future<int?> getFirstScreenIndexAfter({required String lessonCode, required int afterIndexInclusive}) async {
    try {
      final rows = await SupabaseConfig.client
          .from('lesson_screens')
          .select('screen_index')
          .eq('lesson_code', lessonCode)
          .gte('screen_index', afterIndexInclusive)
          .order('screen_index', ascending: true)
          .limit(1);
      if (rows.isEmpty) return null;
      final raw = (rows.first)['screen_index'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      return int.tryParse(raw?.toString() ?? '');
    } catch (e) {
      debugPrint('[SupabaseLessonEntryRepository] getFirstScreenIndexAfter failed: $e');
      return null;
    }
  }
}
