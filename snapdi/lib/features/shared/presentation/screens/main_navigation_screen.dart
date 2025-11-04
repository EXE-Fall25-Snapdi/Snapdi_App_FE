import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/data/models/user.dart';

class MainNavigationScreen extends StatefulWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final _tokenStorage = TokenStorage.instance;
  String? _userId;
  int? _roleId;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userId = await _tokenStorage.getUserId();
      final userInfoJson = await _tokenStorage.getUserInfo();
      
      if (userInfoJson != null) {
        final userMap = jsonDecode(userInfoJson);
        final user = User.fromJson(userMap);
        setState(() {
          _userId = userId?.toString();
          _roleId = user.roleId;
        });
      } else {
        setState(() {
          _userId = userId?.toString();
        });
      }
    } catch (e) {
      final userId = await _tokenStorage.getUserId();
      setState(() {
        _userId = userId?.toString();
      });
    }
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    setState(() {
      if (location == '/home') {
        _currentIndex = 0;
      } else if (location == '/explore') {
        _currentIndex = 1;
      } else if (location == '/snap') {
        _currentIndex = 2;
      } else if (location == '/history') {
        _currentIndex = 3;
      } else if (location.startsWith('/profile')) {
        _currentIndex = 4;
      }
    });
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        if (_roleId == 3) {
          // If photographer, navigate to photographer welcome
          context.go('/photographer-welcome');
        } else {
          // Otherwise, navigate to home
          context.go('/home');
        }
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        if (_roleId == 3) {
          // If photographer, navigate to snap screen
          context.go('/photographer-snap');
        } else {
          // Otherwise, navigate to a placeholder snap screen
          context.go('/snap');
        }
        break;
      case 3:
        context.go('/history');
        break;
      case 4:
        if (_userId != null) {
          // If photographer (roleId == 3), navigate to photographer profile
          // Otherwise, navigate to regular profile (settings)
          if (_roleId == 3) {
            context.go('/photographer-profile/$_userId');
          } else {
            context.go('/profile/$_userId');
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content - display the child widget passed from router
          widget.child,

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
      onTap: () => _onNavItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: isCameraIcon ? 5 : (isSelected ? 10 : 5),
        ),
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
