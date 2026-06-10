import 'package:flutter/material.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/supabase/supabase_config.dart';

/// Main entry point for the application
///
/// This sets up:
/// - go_router navigation
/// - Material 3 theming with light/dark modes
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const App());
}
