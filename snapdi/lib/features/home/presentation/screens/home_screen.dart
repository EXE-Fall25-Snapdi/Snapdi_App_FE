import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/providers/user_info_provider.dart';
import '../widgets/feature_button.dart';
import '../widgets/promotional_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _userName = 'Per';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userName = await UserInfoProvider.instance.getUserName();
    if (userName != null && mounted) {
      setState(() {
        _userName = userName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient image
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundGradient, fit: BoxFit.cover),
          ),

          // Content layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 120,
              ), // Reduced space for smaller overlapping content
              child: Column(
                children: [
                  // Top bar with search and profile
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20),
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(0xFFAACBC4).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search photographers, services...',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: SvgPicture.asset(AppAssets.searchIcon),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                              ),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Notify/Menu button
                        Container(
                          width: 42,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              // TODO: Open notify/menu
                            },
                            icon: SvgPicture.asset(
                              AppAssets.menuIcon,
                              height: 16,
                              width: 16,
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          thickness: 2,
                          color: AppColors.primary,
                          indent: 4,
                          endIndent: 4,
                        ),
                        // Notify
                        Container(
                          width: 42,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              // TODO: Open notify/menu
                            },
                            icon: SvgPicture.asset(
                              AppAssets.notifyIcon,
                              height: 36,
                              width: 36,
                            ),
                          ),
                        ),
                        SizedBox(width: 20), // Right padding
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Greeting
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Row(
                      children: [
                        const SizedBox(width: 110), // Space for the mascot
                        // Greeting text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.headline2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Xin chào, '),
                                    TextSpan(
                                      text: _userName,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hôm nay, bạn đã Snap chưa?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content section - Positioned on top of header
          Positioned(
            top:
                MediaQuery.of(context).size.height *
                0.30, // Start at 30% of screen height (reduced height)
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(64),
                  topRight: Radius.circular(64),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    // Khám phá ngay section
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Khám phá ngay',
                        style: AppTextStyles.headline3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature buttons grid (single row)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FeatureButton(
                            iconPath: AppAssets.nowIcon,
                            label: 'Now',
                            backgroundColor: const Color(0xFFCAE0DB),
                            onTap: () {
                              // TODO: Navigate to instant booking
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            iconPath: AppAssets.bookIcon,
                            label: 'Book',
                            backgroundColor: const Color(0xFFCAE0DB),
                            onTap: () {
                              // TODO: Navigate to booking
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            iconPath: AppAssets.vipIcon,
                            label: 'VIP',
                            backgroundColor: const Color(0xFFCAE0DB),
                            onTap: () {
                              // TODO: Navigate to VIP services
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            iconPath: AppAssets.vouncherIcon,
                            label: 'Voucher',
                            backgroundColor: const Color(0xFFCAE0DB),
                            onTap: () {
                              // TODO: Navigate to vouchers
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            iconPath: AppAssets.paymentIcon,
                            label: 'Payment',
                            backgroundColor: const Color(0xFFCAE0DB),
                            onTap: () {
                              // TODO: Navigate to payment
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            iconPath: AppAssets.allIcon,
                            label: 'All',
                            backgroundColor: const Color(0xFFCAE0DB),
                            onTap: () {
                              // TODO: Navigate to all services
                            },
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // SNAP NOW section
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Text(
                            'SNAP NOW',
                            style: AppTextStyles.headline4.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2CC295),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.black,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Promotional carousel
                    const PromotionalCard(),
                  ],
                ),
              ),
            ),
          ),

          // Mascot character - positioned to overflow on top of main content
          Positioned(
            left: -12,
            top:
                MediaQuery.of(context).size.height * 0.30 -
                115, // Position to overlap with white section
            child: SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                AppAssets.mascot,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
