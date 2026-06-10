class ToolAction {
  const ToolAction({required this.toolCode, required this.type, required this.payload});

  /// Tool identifier (e.g. salary_ripple)
  final String toolCode;

  /// Event type (e.g. save_goal, save_dashboard, note, toggle)
  final String type;

  /// Arbitrary event payload. Should be JSON-serializable.
  final Map<String, dynamic> payload;
}
