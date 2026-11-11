import 'package:go_router/go_router.dart';
import 'auth_state.dart';
import 'nav_shell.dart';
import 'screens/about_screen.dart';
import 'screens/create_game_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/help_screen.dart';
import 'screens/home_screen.dart';
import 'screens/live_scoreboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/manage_teams_screen.dart';
import 'screens/my_teams_screen.dart';
import 'screens/organizer_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/standings_screen.dart';
import 'screens/team_details_screen.dart';
import 'screens/update_score_screen.dart';
import 'screens/verify_email_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  refreshListenable: auth,

  // THE RULES: who can go where
  redirect: (context, state) {
    final loc = state.matchedLocation;
    const publicPages = ['/splash', '/login', '/register', '/forgot-password'];

    if (loc == '/splash') return null;
    if (!auth.isLoggedIn) return publicPages.contains(loc) ? null : '/login';
    if (!auth.isEmailVerified) return '/verify-email';
    if (publicPages.contains(loc) || loc == '/verify-email') return '/home';
    // Only organizers can open the organizer screens
    if (loc.startsWith('/organizer') && !auth.isOrganizer) return '/home';
    return null;
  },

  routes: [
    // ---- No bottom bar ----
    GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
    GoRoute(path: '/verify-email', builder: (c, s) => const VerifyEmailScreen()),
    GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
    GoRoute(path: '/about', builder: (c, s) => const AboutScreen()),

    // ---- Organizer only (no bottom bar) ----
    GoRoute(path: '/organizer', builder: (c, s) => const OrganizerScreen()),
    GoRoute(
      path: '/organizer/score/:matchId',
      builder: (c, s) => UpdateScoreScreen(matchId: s.pathParameters['matchId']!),
    ),
    GoRoute(path: '/organizer/create-game', builder: (c, s) => const CreateGameScreen()),
    GoRoute(path: '/organizer/teams', builder: (c, s) => const ManageTeamsScreen()),

    // ---- With bottom bar ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => NavShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/schedule', builder: (c, s) => const ScheduleScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/standings',
            builder: (c, s) => const StandingsScreen(),
            routes: [
              GoRoute(
                path: 'live/:matchId',
                builder: (c, s) => LiveScoreboardScreen(matchId: s.pathParameters['matchId']!),
              ),
              GoRoute(
                path: 'team/:teamId',
                builder: (c, s) => TeamDetailsScreen(teamId: s.pathParameters['teamId']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/more',
            builder: (c, s) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'my-teams', builder: (c, s) => const MyTeamsScreen()),
              GoRoute(path: 'settings', builder: (c, s) => const SettingsScreen()),
              GoRoute(path: 'help', builder: (c, s) => const HelpScreen()),
            ],
          ),
        ]),
      ],
    ),
  ],
);
