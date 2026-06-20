import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/screens/wisdom/principles_page.dart';
import 'package:her_long_game/screens/auth/auth_page.dart';
import 'package:her_long_game/screens/auth/founder_note_screen.dart';
import 'package:her_long_game/screens/auth/welcome_screen.dart';
import 'package:her_long_game/screens/checkpoint/checkpoint_page.dart';
import 'package:her_long_game/screens/learn/home/home_page.dart';
import 'package:her_long_game/flow/phase_progress_controller.dart';
import 'package:her_long_game/screens/lesson/lesson_page.dart';
import 'package:her_long_game/screens/lesson/lesson_close_page.dart';
import 'package:her_long_game/screens/lesson/lesson_screen_page.dart';
import 'package:her_long_game/screens/learn/learn_page.dart';
import 'package:her_long_game/screens/learn/learn_phase_page.dart';
import 'package:her_long_game/screens/learn/lesson_list_page.dart';
import 'package:her_long_game/screens/learn/phase_entry_page.dart';
import 'package:her_long_game/screens/now/now_page.dart';
import 'package:her_long_game/screens/onboarding/financial_wellbeing_diagnostic_screen.dart';
import 'package:her_long_game/screens/onboarding/onboarding_intro_flow_page.dart';
import 'package:her_long_game/screens/profile/profile_page.dart';
import 'package:her_long_game/screens/profile/her_notes_page.dart';
import 'package:her_long_game/screens/profile/account_settings_page.dart';
import 'package:her_long_game/screens/profile/dashboard_page.dart';
import 'package:her_long_game/screens/profile/goals_snapshot_page.dart';
import 'package:her_long_game/screens/profile/learning_progress_overview_page.dart';
import 'package:her_long_game/screens/profile/payment_page.dart';
import 'package:her_long_game/screens/profile/referral_page.dart';
import 'package:her_long_game/screens/system/her_bookmarks_page.dart';
import 'package:her_long_game/screens/system/her_direction_page.dart';
import 'package:her_long_game/screens/system/her_perspective_page.dart';
import 'package:her_long_game/screens/system/her_system_page.dart';
import 'package:her_long_game/screens/system/her_tools_page.dart';
import 'package:her_long_game/screens/splash/splash_page.dart';
import 'package:her_long_game/screens/wisdom/wisdom_page.dart';
import 'package:her_long_game/theme.dart';

/// Main app widget.
///
/// Owns the router + theming.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Her Long Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}

/// Named route configuration requested.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, name: 'splash', pageBuilder: (context, state) => const NoTransitionPage(child: SplashPage())),
      GoRoute(path: AppRoutes.auth, name: 'auth', pageBuilder: (context, state) => const MaterialPage(child: AuthPage())),

      GoRoute(
        path: AppRoutes.onboardingIntro,
        name: 'onboardingIntro',
        pageBuilder: (context, state) {
          final replay = (state.uri.queryParameters['replay'] ?? '').trim() == '1';
          return MaterialPage(child: OnboardingIntroFlowPage(isReplay: replay));
        },
      ),

      // Welcome flow: shown once after account creation.
      GoRoute(path: AppRoutes.welcome, name: 'welcome', pageBuilder: (context, state) => const MaterialPage(child: WelcomeScreen())),

      GoRoute(path: AppRoutes.founderNote, name: 'founderNote', pageBuilder: (context, state) => const MaterialPage(child: FounderNoteScreen())),

      GoRoute(
        path: AppRoutes.financialWellbeingDiagnostic,
        name: 'financialWellbeingDiagnostic',
        pageBuilder: (context, state) => const MaterialPage(child: FinancialWellbeingDiagnosticScreen()),
      ),

      // Lesson + checkpoint flows are intentionally outside the tab shell so the
      // bottom navigation bar is not visible.
      GoRoute(
        path: AppRoutes.lessonCover,
        name: 'lessonCover',
        pageBuilder: (context, state) {
          final lessonCode = state.pathParameters['code'] ?? 'LA';
          return MaterialPage(child: LessonPage(lessonCode: lessonCode));
        },
      ),
      GoRoute(
        path: AppRoutes.lessonScreen,
        name: 'lessonScreen',
        pageBuilder: (context, state) {
          final lessonCode = state.pathParameters['code'] ?? 'LA';
          final startRaw = state.uri.queryParameters['start'];
          final start = int.tryParse((startRaw ?? '').trim()) ?? 0;
          return MaterialPage(child: LessonScreenPage(lessonCode: lessonCode, initialScreenIndex: start));
        },
      ),
      GoRoute(
        path: AppRoutes.lessonClose,
        name: 'lessonClose',
        pageBuilder: (context, state) {
          final lessonCode = state.pathParameters['code'] ?? 'LA';
          return MaterialPage(child: LessonClosePage(lessonCode: lessonCode));
        },
      ),
      GoRoute(
        path: AppRoutes.checkpoint,
        name: 'checkpoint',
        pageBuilder: (context, state) {
          final num = int.tryParse(state.pathParameters['num'] ?? '1') ?? 1;
          return MaterialPage(child: CheckpointPage(checkpointNumber: num));
        },
      ),

      /// Main tab shell: shows bottom navigation on Home/Learn/Now/Wisdom/Profile
      /// and on Learn subroutes like /learn/module/:moduleIndex.
      ShellRoute(
        builder: (context, state, child) => _TabScaffold(state: state, child: child),
        routes: [
          GoRoute(path: AppRoutes.system, name: 'system', pageBuilder: (context, state) => const NoTransitionPage(child: HerSystemPage())),
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) {
              final showWelcome = (state.uri.queryParameters['welcome'] ?? '').trim() == '1';
              final showBaselineReminder = (state.uri.queryParameters['baseline_reminder'] ?? '').trim() == '1';
              return NoTransitionPage(child: HomePage(showFirstRunWelcomeCard: showWelcome, showBaselineReminder: showBaselineReminder));
            },
          ),

          GoRoute(
            path: '/principles',
            name: 'principles',
            pageBuilder: (context, state) => const MaterialPage(child: PrinciplesPage()),
          ),

          GoRoute(
            path: AppRoutes.learn,
            name: 'learn',
            pageBuilder: (context, state) => const NoTransitionPage(child: LearnPage()),
            routes: [
              GoRoute(
                path: 'phase/:phaseId',
                name: 'learnPhase',
                pageBuilder: (context, state) {
                  final raw = state.pathParameters['phaseId'] ?? '1';
                  final phaseId = int.tryParse(raw) ?? 1;
                  return MaterialPage(child: LearnPhasePage(phaseId: phaseId));
                },
                routes: [
                  GoRoute(
                    path: 'entry',
                    name: 'learnPhaseEntry',
                    pageBuilder: (context, state) {
                      final raw = state.pathParameters['phaseId'] ?? '1';
                      final phaseId = int.tryParse(raw) ?? 1;
                      final revisit = (state.uri.queryParameters['revisit'] ?? '').trim() == '1';
                      return MaterialPage(
                        fullscreenDialog: true,
                        child: PhaseEntryPage(
                          phaseId: phaseId,
                          canClose: revisit,
                          onContinue: () => PhaseProgressController.instance.markSeen(phaseId: phaseId, revisit: revisit),
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'module/:moduleIndex',
                name: 'learnModule',
                pageBuilder: (context, state) {
                  final raw = state.pathParameters['moduleIndex'] ?? '0';
                  final moduleIndex = int.tryParse(raw) ?? 0;
                  return MaterialPage(child: LessonListPage(moduleIndex: moduleIndex));
                },
              ),
            ],
          ),
           GoRoute(
             path: AppRoutes.now,
             name: 'now',
             pageBuilder: (context, state) => const NoTransitionPage(child: NowPage()),
           ),
          GoRoute(path: AppRoutes.wisdom, name: 'wisdom', pageBuilder: (context, state) => const NoTransitionPage(child: WisdomPage())),
          GoRoute(path: AppRoutes.tools, name: 'tools', pageBuilder: (context, state) => const MaterialPage(child: HerToolsPage())),
          GoRoute(path: AppRoutes.perspective, name: 'perspective', pageBuilder: (context, state) => const MaterialPage(child: HerPerspectivePage())),
          GoRoute(path: AppRoutes.profile, name: 'profile', pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage())),
          GoRoute(
            path: AppRoutes.profileNotes,
            name: 'profileNotes',
            pageBuilder: (context, state) => const MaterialPage(child: HerNotesPage()),
          ),
          GoRoute(
            path: AppRoutes.profileAccount,
            name: 'profileAccount',
            pageBuilder: (context, state) => const MaterialPage(child: AccountSettingsPage()),
          ),
          GoRoute(
            path: AppRoutes.profilePayment,
            name: 'profilePayment',
            pageBuilder: (context, state) => const MaterialPage(child: PaymentPage()),
          ),
          GoRoute(
            path: AppRoutes.profileProgress,
            name: 'profileProgress',
            pageBuilder: (context, state) => const MaterialPage(child: LearningProgressOverviewPage()),
          ),
          GoRoute(
            path: AppRoutes.profileDashboard,
            name: 'profileDashboard',
            pageBuilder: (context, state) => const MaterialPage(child: DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.profileGoals,
            name: 'profileGoals',
            pageBuilder: (context, state) => const MaterialPage(child: GoalsSnapshotPage()),
          ),
          GoRoute(
            path: AppRoutes.profileReferral,
            name: 'profileReferral',
            pageBuilder: (context, state) => const MaterialPage(child: ReferralPage()),
          ),
          GoRoute(path: AppRoutes.bookmarks, name: 'bookmarks', pageBuilder: (context, state) => const MaterialPage(child: HerBookmarksPage())),
           GoRoute(
             path: AppRoutes.direction,
             name: 'direction',
             pageBuilder: (context, state) => const MaterialPage(child: HerDirectionPage()),
           ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      debugPrint('GoRouter error: ${state.error}');
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Page not found', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(state.uri.toString(), style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.splash),
                  child: const Text('Go to start'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Route path constants.
class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String onboardingIntro = '/onboarding/intro';
  static const String welcome = '/welcome';
  static const String founderNote = '/founder-note';
  static const String financialWellbeingDiagnostic = '/onboarding/diagnostic';
  static const String lessonCover = '/lesson/:code';
  static const String lessonScreen = '/lesson/:code/screen';
  static const String lessonClose = '/lesson/:code/close';
  static const String checkpoint = '/checkpoint/:num';
  static const String system = '/system';
  static const String home = '/home';
  static const String learn = '/learn';
  static const String learnModule = '/learn/module/:moduleIndex';
  static const String now = '/now';
  static const String wisdom = '/wisdom';
  static const String tools = '/tools';
  static const String profile = '/profile';
  static const String profileNotes = '/profile/notes';
  static const String profileAccount = '/profile/account';
  static const String profilePayment = '/profile/payment';
  static const String profileProgress = '/profile/progress';
  static const String profileDashboard = '/profile/dashboard';
  static const String profileGoals = '/profile/goals';
  static const String profileReferral = '/profile/referral';
  static const String bookmarks = '/bookmarks';
  static const String direction = '/direction';
  static const String perspective = '/perspective';
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  static int _indexForLocation(String location) {
    // Bottom nav order: Home, System, Learn, Perspective, Profile.
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.system)) return 1;
    if (location.startsWith(AppRoutes.bookmarks)) return 1;
    if (location.startsWith(AppRoutes.direction)) return 1;
    if (location.startsWith(AppRoutes.perspective)) return 1;
    if (location.startsWith(AppRoutes.now)) return 1;
    if (location.startsWith(AppRoutes.learn)) return 2;
    if (location.startsWith(AppRoutes.wisdom)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;

    // Routes no longer represented in the bottom nav.
    if (location.startsWith(AppRoutes.tools)) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = state.uri.toString();
    final currentIndex = _indexForLocation(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              // "Her" tab is the pillar hub (Tools, Notes, Bookmarks, Direction).
              context.go(AppRoutes.system);
              break;
            case 2:
              context.go(AppRoutes.learn);
              break;
            case 3:
              context.go(AppRoutes.wisdom);
              break;
            case 4:
              context.go(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Her'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'Wisdom'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Notifies GoRouter when a stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
