class ToolEvent {
  const ToolEvent({required this.id, required this.toolCode, required this.type, required this.payload, required this.createdAt});

  final String id;
  final String toolCode;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  factory ToolEvent.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'];
    DateTime createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    final payload = json['payload'];
    return ToolEvent(
      id: (json['id'] ?? '').toString(),
      toolCode: (json['tool_code'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      payload: payload is Map<String, dynamic> ? payload : <String, dynamic>{},
      createdAt: createdAt,
    );
  }
}
