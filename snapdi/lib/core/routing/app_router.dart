import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snapdi/features/auth/presentation/screens/account_type_selection_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/login_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/photographer_sign_up_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/welcome_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/splash_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/profile_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/manage_portfolio_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:snapdi/features/shared/presentation/screens/main_navigation_screen.dart';
import 'package:snapdi/features/home/presentation/screens/home_screen.dart';
import 'package:snapdi/features/snap/presentation/screens/snap_screen.dart';
import 'package:snapdi/core/constants/app_theme.dart';

// Global key for navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // --- Splash Screen (checks auth and redirects) ---
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    
    // --- Auth Routes (without navigation bar) ---
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const PhotographerSignUpScreen(
        // Passing a default value as it was in the original WelcomeScreen code
        accountType: AccountType.snapper,
      ),
    ),

    // --- Main App Routes (with navigation bar) ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainNavigationScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
        ),
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const PlaceholderScreen(
              title: 'Explore',
              icon: Icons.explore,
            ),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const PlaceholderScreen(
              title: 'History',
              icon: Icons.history,
            ),
          ),
        ),
        GoRoute(
          path: '/profile/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return NoTransitionPage(
              key: state.pageKey,
              child: ProfileScreen(userId: id),
            );
          },
        ),
      ],
    ),

    // --- SNAP Flow Routes (without navigation bar) ---
    GoRoute(
      path: '/snap',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SnapScreen(),
    ),

    // --- Portfolio Management Route (without navigation bar) ---
    GoRoute(
      path: '/manage-portfolio',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ManagePortfolioScreen(),
    ),

    // --- Account Settings Route (without navigation bar) ---
    GoRoute(
      path: '/account-settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AccountSettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
);

// Placeholder screen widget
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
