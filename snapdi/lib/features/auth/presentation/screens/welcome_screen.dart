import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo Section
              Image.asset(AppAssets.snapdiLogoIcon),
              
              const SizedBox(height: AppDimensions.marginXLarge),
              
              // Welcome Text
              Text(
                'Welcome to Snapdi',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.marginMedium),
              
              // Description
              Text(
                'Find and book professional photographers for your special moments. From weddings to portraits, we connect you with talented photographers in your area.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: AppTextStyles.buttonLarge,
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.marginMedium),
              
              // Photographer Register Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to photographer registration
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Photographer Registration - Coming soon!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Register as Photographer',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}