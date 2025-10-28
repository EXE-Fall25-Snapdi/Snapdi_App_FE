import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snapdi/features/auth/presentation/screens/account_type_selection_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/login_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/PhotographerSignUpStage1Screen.dart';
import 'package:snapdi/features/auth/presentation/screens/welcome_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/splash_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/profile_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/photographer_profile_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/manage_portfolio_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:snapdi/features/chat/presentation/screens/chat_screen.dart';
import 'package:snapdi/features/shared/presentation/screens/main_navigation_screen.dart';
import 'package:snapdi/features/home/presentation/screens/home_screen.dart';
import 'package:snapdi/features/booking/presentation/screens/my_booking_screen.dart';
import 'package:snapdi/features/snap/presentation/screens/snap_screen.dart';
import 'package:snapdi/features/snap/presentation/screens/booking_status_screen.dart';
import 'package:snapdi/core/constants/app_theme.dart';
import 'package:snapdi/features/snap/presentation/screens/photographer_welcome_screen.dart';
import 'package:snapdi/features/snap/presentation/screens/photographer_snap_screen.dart';

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
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/signup',
      builder: (context, state) =>
          const SignUpScreen(accountType: AccountType.user),
    ),
    GoRoute(
      path: '/photographer-signup',
      builder: (context, state) => const PhotographerSignUpStage1Screen(
        accountType: AccountType.snapper,
      ),
    ),
    GoRoute(
      path: '/select-account-type',
      builder: (context, state) => const AccountTypeSelectionScreen(),
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
          path: '/photographer-welcome',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const PhotographerWelcomeScreen(),
          ),
        ),
        GoRoute(
          path: '/photographer-snap',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const PhotographerSnapScreen(),
          ),
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
          path: '/bookings',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const MyBookingScreen(),
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
        GoRoute(
          path: '/booking/:id/status',
          pageBuilder: (context, state) {
            final idStr = state.pathParameters['id'];
            final id = idStr != null ? int.tryParse(idStr) : null;
            return NoTransitionPage(
              key: state.pageKey,
              child: BookingStatusScreen(bookingId: id),
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

    // Provide a top-level route for /bookings so it's resolvable from any context.
    GoRoute(
      path: '/bookings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MyBookingScreen(),
    ),

    // Booking status route (booking detail / status tracker)
    // (moved under ShellRoute so it shows inside the main navigation shell)

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

    // --- Photographer Profile Route (without navigation bar) ---
    GoRoute(
      path: '/photographer-profile/:userId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final userIdStr = state.pathParameters['userId'];
        final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
        return PhotographerProfileScreen(userId: userId ?? 0);
      },
    ),

    // --- Chat Route (without navigation bar) ---
    GoRoute(
      path: '/chat/:conversationId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final conversationIdStr = state.pathParameters['conversationId'];
        final conversationId = conversationIdStr != null
            ? int.tryParse(conversationIdStr)
            : null;
        final otherUserName = state.extra as String?;
        return ChatScreen(
          conversationId: conversationId ?? 0,
          otherUserName: otherUserName,
        );
      },
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
