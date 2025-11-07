import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snapdi/features/auth/presentation/screens/account_type_selection_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/login_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/PhotographerSignUpStage1Screen.dart';
import 'package:snapdi/features/auth/presentation/screens/welcome_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/splash_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/verify_code_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:snapdi/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:snapdi/features/payment/presentation/screens/PaymentStatusScreen.dart';
import 'package:snapdi/features/profile/presentation/screens/profile_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/photographer_profile_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/manage_portfolio_screen.dart';
import 'package:snapdi/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:snapdi/features/chat/presentation/screens/chat_screen.dart';
import 'package:snapdi/features/shared/presentation/screens/main_navigation_screen.dart';
import 'package:snapdi/features/home/presentation/screens/home_screen.dart';
import 'package:snapdi/features/booking/presentation/booking_schedule_screen.dart';
import 'package:snapdi/features/booking/presentation/booking_history_screen.dart';
import 'package:snapdi/features/snap/presentation/screens/snap_screen.dart';
import 'package:snapdi/features/snap/presentation/screens/booking_status_screen.dart';
import 'package:snapdi/features/snap/presentation/screens/completed_bookings_screen.dart';
import 'package:snapdi/core/constants/app_theme.dart';
import 'package:snapdi/core/storage/token_storage.dart';
import 'package:snapdi/features/auth/data/models/user.dart';
import 'dart:convert';
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
      path: '/verify-code',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String? ?? '';
        final password = extra?['password'] as String? ?? '';
        return VerifyCodeScreen(email: email, password: password);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String? ?? '';
        return ResetPasswordScreen(email: email);
      },
    ),
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
            child: const BookingScheduleScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const HistoryScreenWrapper(),
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
      builder: (context, state) => const BookingScheduleScreen(),
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

    // --- PayOS handler---
    GoRoute(
      // 1. Path này phải khớp chính xác với path trong deep link
      path: '/result',
      builder: (context, state) {
        // 2. Lấy các query parameters từ deep link
        final status = state.uri.queryParameters['status'] ?? "cancelled";

        // 3. Trả về màn hình tương ứng với các tham số đã lấy
        return PaymentStatusScreen(
          status: status,
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

// Wrapper widget that shows different history screens based on role
class HistoryScreenWrapper extends StatefulWidget {
  const HistoryScreenWrapper({super.key});

  @override
  State<HistoryScreenWrapper> createState() => _HistoryScreenWrapperState();
}

class _HistoryScreenWrapperState extends State<HistoryScreenWrapper> {
  final _tokenStorage = TokenStorage.instance;
  int? _roleId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final userInfoJson = await _tokenStorage.getUserInfo();
      
      if (userInfoJson != null) {
        final userMap = jsonDecode(userInfoJson);
        final user = User.fromJson(userMap);
        if (mounted) {
          setState(() {
            _roleId = user.roleId;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // If photographer (roleId == 3), show CompletedBookingsScreen
    // Otherwise, show BookingHistoryScreen
    if (_roleId == 3) {
      return const CompletedBookingsScreen();
    } else {
      return const BookingHistoryScreen();
    }
  }
}
