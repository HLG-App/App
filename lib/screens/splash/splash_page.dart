import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/flow/user_state.dart';
import 'package:her_long_game/flow/user_state_repository.dart';
import 'package:her_long_game/theme.dart';

/// Initial page that checks auth state and routes accordingly.
///
/// Rules (in order):
/// - no session -> `/auth`
/// - session + onboarding_complete=false -> `/onboarding/intro`
/// - session + onboarding_complete=true -> `/home`
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _resolveInitialRoute(UserState state) {
    // 1. Not authenticated
    if (!state.isAuthenticated) return AppRoutes.auth;

    // 2. New onboarding intro flow (shown once; can be replayed later from Profile)
    if (!state.onboardingComplete) return AppRoutes.onboardingIntro;

    // 3. Everything done — go home
    return AppRoutes.home;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final state = await const SupabaseUserStateRepository().load();
        final target = _resolveInitialRoute(state);
        if (!mounted) return;
        context.go(target);
      } catch (e) {
        debugPrint('[SplashPage] Failed to resolve initial route: $e');
        if (!mounted) return;
        context.go(AppRoutes.auth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                  ),
                  child: Icon(Icons.auto_awesome, color: cs.onPrimary),
                ),
                const SizedBox(height: 18),
                Semantics(
                  label: 'Her Long Game',
                  image: true,
                  child: Image.asset('assets/images/Her_Long_Game-01.png', height: 44, fit: BoxFit.contain),
                ),
                const SizedBox(height: 8),
                Text('Loading your journey…', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 22),
                SizedBox(
                  width: 220,
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(999),
                    color: cs.primary,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
