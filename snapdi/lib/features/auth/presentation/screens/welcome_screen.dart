import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              SvgPicture.asset(AppAssets.snapdiLogo, height: 100, width: 100),

              const SizedBox(height: AppDimensions.marginXLarge),

              // Welcome Text
              Text(
                'Chào mừng đến với Snapdi',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Description
              Text(
                'Tìm và đặt chụp ảnh chuyên nghiệp cho những khoảnh khắc đặc biệt của bạn. Từ đám cưới đến chân dung, chúng tôi kết nối bạn với các nhiếp ảnh gia tài năng trong khu vực của bạn.',
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
                    context.push('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                  ),
                  child: Text('Bắt đầu', style: AppTextStyles.buttonLarge),
                ),
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Photographer Register Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/photographer-signup');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    'Đăng ký là Nhiếp ảnh gia',
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
