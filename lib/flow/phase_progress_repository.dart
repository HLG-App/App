import 'package:her_long_game/supabase/supabase_config.dart';

abstract class PhaseProgressRepository {
  Future<void> markSeen({required int phaseId});
}

class SupabasePhaseProgressRepository implements PhaseProgressRepository {
  const SupabasePhaseProgressRepository();

  @override
  Future<void> markSeen({required int phaseId}) async {
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) return;

    await SupabaseConfig.client.from('phase_progress').upsert({
      'user_id': uid,
      'phase_id': phaseId,
      'seen_at': DateTime.now().toIso8601String(),
    });
  }
}
