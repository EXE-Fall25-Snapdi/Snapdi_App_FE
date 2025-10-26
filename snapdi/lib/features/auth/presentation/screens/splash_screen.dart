import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:snapdi/core/constants/app_assets.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppAssets
                  .backgroundWhite, // or use your preferred background asset
              fit: BoxFit.cover,
            ),
          ),

          // Content overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                SvgPicture.asset(
                  AppAssets.snapdiLogoWithText,
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                // Tagline
                Text(
                  'Đặt Nhiếp Ảnh Gia Của Bạn',
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
        ],
      ),
    );
  }
}
