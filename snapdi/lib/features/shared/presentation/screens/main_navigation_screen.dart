import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../snap/presentation/screens/snap_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Pages for bottom navigation
  final List<Widget> _pages = [
    const HomeScreen(),
    const PlaceholderScreen(title: 'Explore', icon: Icons.explore),
    const SnapScreen(),
    const PlaceholderScreen(title: 'History', icon: Icons.history),
    const PlaceholderScreen(title: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          _pages[_currentIndex],
          
          // Custom Floating Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 16,
            child: SizedBox(
              height: 90,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDarker,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Navigation Items
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildNavItem(0, AppAssets.homeIcon, 'Home'),
                          _buildNavItem(1, AppAssets.exploreIcon, 'Explore'),
                          _buildNavItem(2, AppAssets.cameraIcon, ''),
                          _buildNavItem(3, AppAssets.historyIcon, 'History'),
                          _buildNavItem(4, AppAssets.profileIcon, 'Profile'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = _currentIndex == index;
    final isCameraIcon = index == 2;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(bottom: isCameraIcon ? 5 : (isSelected ? 10 : 5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: isCameraIcon ? 56 : (isSelected ? 48 : 36),
              height: isCameraIcon ? 56 : (isSelected ? 48 : 36),
            ),
            if (label.isNotEmpty) ...[
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.iconText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Placeholder screens for other navigation items
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.primary,
            ),
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