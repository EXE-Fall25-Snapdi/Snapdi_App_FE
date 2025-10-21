import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snapdi/core/storage/token_storage.dart';
import 'package:snapdi/core/constants/app_theme.dart';

/// Splash screen that checks authentication status and redirects accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  /// Check if user has a valid token and redirect to appropriate screen
  Future<void> _checkAuthAndRedirect() async {
    // Add a small delay for better UX (show splash screen briefly)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check if user has valid authentication token
      final tokenStorage = TokenStorage.instance;
      final isLoggedIn = await tokenStorage.isLoggedIn();
      final accessToken = await tokenStorage.getAccessToken();

      if (!mounted) return;

      // If user is logged in and has a valid token, go to home
      if (isLoggedIn && accessToken != null && accessToken.isNotEmpty) {
        context.go('/home');
      } else {
        // Otherwise, show welcome screen
        context.go('/welcome');
      }
    } catch (e) {
      // On error, go to welcome screen
      if (mounted) {
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Icon(
              Icons.camera_alt_rounded,
              size: 100,
              color: AppColors.white,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // App Name
            Text(
              'Snapdi',
              style: AppTextStyles.headline1.copyWith(
                color: AppColors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            
            // Tagline
            Text(
              'Book Your Photographer',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 64),
            
            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
