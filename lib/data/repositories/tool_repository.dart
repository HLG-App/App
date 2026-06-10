import 'package:flutter/foundation.dart';
import 'package:her_long_game/data/repositories/goal_repository.dart';
import 'package:her_long_game/domain/tools/tool_action.dart';
import 'package:her_long_game/domain/tools/tool_event.dart' as domain;
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRequiredException implements Exception {
  const AuthRequiredException();

  @override
  String toString() => 'AuthRequiredException';
}

class ToolRepository {
  ToolRepository({SupabaseClient? client, GoalRepository? goalRepository})
    : _client = client ?? SupabaseConfig.client,
      _goalRepository = goalRepository ?? GoalRepository(client: client);

  final SupabaseClient _client;
  final GoalRepository _goalRepository;

  Future<void> handleActionForCurrentUser({required ToolAction action}) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) throw const AuthRequiredException();
    return handleAction(userId: userId, action: action);
  }

  /// Core event handler.
  ///
  /// UI should only emit [ToolAction]s; this repository decides persistence.
  ///
  /// Tables:
  /// - `tool_states`: latest snapshot per (user_id, tool_code)
  /// - `tool_state_events`: append-only history
  Future<void> handleAction({required String userId, required ToolAction action}) async {
    try {
      switch (action.type) {
        case 'save_goal':
          {
            final goalCode = (action.payload['goal_code'] ?? '').toString();
            final label = (action.payload['label'] ?? '').toString();
            if (goalCode.isNotEmpty) {
              await _goalRepository.upsertGoal(userId, goalCode, label);
            }
            await _insertToolEvent(userId: userId, toolCode: action.toolCode, type: action.type, payload: action.payload);
            return;
          }

        case 'save_dashboard':
        case 'save_state':
          {
            final inputs = (action.payload['inputs'] is Map) ? (action.payload['inputs'] as Map).cast<String, dynamic>() : <String, dynamic>{};
            final outputs = (action.payload['outputs'] is Map) ? (action.payload['outputs'] as Map).cast<String, dynamic>() : <String, dynamic>{};
            await saveToolState(userId: userId, toolCode: action.toolCode, inputs: inputs, outputs: outputs);
            await _insertToolEvent(userId: userId, toolCode: action.toolCode, type: action.type, payload: action.payload);
            return;
          }

        default:
          {
            // Generic event: log it and opportunistically update snapshot if provided.
            if (action.payload.containsKey('inputs') || action.payload.containsKey('outputs')) {
              final inputs = (action.payload['inputs'] is Map) ? (action.payload['inputs'] as Map).cast<String, dynamic>() : <String, dynamic>{};
              final outputs = (action.payload['outputs'] is Map) ? (action.payload['outputs'] as Map).cast<String, dynamic>() : <String, dynamic>{};
              await saveToolState(userId: userId, toolCode: action.toolCode, inputs: inputs, outputs: outputs);
            }
            await _insertToolEvent(userId: userId, toolCode: action.toolCode, type: action.type, payload: action.payload);
            return;
          }
      }
    } catch (e) {
      debugPrint('[ToolRepository] handleAction FAILED: $e');
      rethrow;
    }
  }

  Future<void> saveToolState({
    required String userId,
    required String toolCode,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> outputs,
  }) async {
    try {
      await _client.from('tool_states').upsert({
        'user_id': userId,
        'tool_code': toolCode,
        'inputs': inputs,
        'outputs': outputs,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,tool_code');
    } catch (e) {
      debugPrint('[ToolRepository] saveToolState FAILED: $e');
      rethrow;
    }
  }

  Future<List<ToolState>> getLatestToolStates({required String userId, int limit = 50}) async {
    try {
      final rows = await _client
          .from('tool_states')
          .select('*')
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(limit);
      return rows.map<ToolState>((r) => ToolState.fromJson(r)).toList(growable: false);
    } catch (e) {
      debugPrint('[ToolRepository] getLatestToolStates FAILED: $e');
      return [];
    }
  }

  /// History API (append-only).
  ///
  /// Expects a `tool_state_events` table. If it doesn't exist, it returns an empty list.
  Future<List<domain.ToolEvent>> getToolHistory({required String userId, required String toolCode, int limit = 100}) async {
    try {
      final rows = await _client
          .from('tool_state_events')
          .select('*')
          .eq('user_id', userId)
          .eq('tool_code', toolCode)
          .order('created_at', ascending: false)
          .limit(limit);
      return rows.map<domain.ToolEvent>((r) => domain.ToolEvent.fromJson(r)).toList(growable: false);
    } catch (e) {
      debugPrint('[ToolRepository] getToolHistory skipped/FAILED: $e');
      return [];
    }
  }

  Future<void> _insertToolEvent({required String userId, required String toolCode, required String type, required Map<String, dynamic> payload}) async {
    try {
      await _client.from('tool_state_events').insert({
        'user_id': userId,
        'tool_code': toolCode,
        'type': type,
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Never block UX on history logging.
      debugPrint('[ToolRepository] _insertToolEvent skipped/FAILED: $e');
    }
  }
}

class ToolState {
  const ToolState({
    required this.userId,
    required this.toolCode,
    required this.inputs,
    required this.outputs,
    this.updatedAt,
    this.raw,
  });

  final String userId;
  final String toolCode;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> outputs;
  final DateTime? updatedAt;
  final Map<String, dynamic>? raw;

  factory ToolState.fromJson(Map<String, dynamic> json) {
    final updatedAt = json['updated_at'];
    return ToolState(
      userId: (json['user_id'] ?? '').toString(),
      toolCode: (json['tool_code'] ?? '').toString(),
      inputs: (json['inputs'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      outputs: (json['outputs'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      updatedAt: updatedAt is String ? DateTime.tryParse(updatedAt) : null,
      raw: json,
    );
  }
}

// ToolEvent is now a domain model: lib/domain/tools/tool_event.dart
