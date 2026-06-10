import 'package:flutter/foundation.dart';
import 'package:her_long_game/flow/phase_progress_repository.dart';

/// Flow controller for non-UI phase progress actions.
///
/// This keeps Supabase writes out of the router and widgets.
class PhaseProgressController {
  PhaseProgressController._(this._repo);

  static PhaseProgressController instance = PhaseProgressController._(const SupabasePhaseProgressRepository());

  final PhaseProgressRepository _repo;

  Future<void> markSeen({required int phaseId, required bool revisit}) async {
    // No branching in widgets/router; branching lives here.
    if (revisit) return;
    try {
      await _repo.markSeen(phaseId: phaseId);
    } catch (e) {
      debugPrint('[PhaseProgressController] Failed to mark phase seen: $e');
    }
  }
}
