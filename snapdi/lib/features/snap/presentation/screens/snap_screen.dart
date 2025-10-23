import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'choose_location_screen_with_map.dart';
import 'booking_detail_screen.dart';

class SnapScreen extends StatefulWidget {
  const SnapScreen({super.key});

  @override
  State<SnapScreen> createState() => _SnapScreenState();
}

class _SnapScreenState extends State<SnapScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Back button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            context.go('/home');
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      Text(
                        'Snap ngay',
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Map icon
                      GestureDetector(
                        onTap: () {
                          // Navigate to location screen with map
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChooseLocationScreenWithMap(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFAACBC4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.mapIcon,
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Bản đồ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Promo banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    padding: const EdgeInsets.only(left: 18),

                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đi du lịch mùa lễ? Cần ảnh đẹp để Snapper lo!',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDarker,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Đặt liền tay, giảm 20%',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.primary,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Promo icons
                        Column(
                          children: [
                            Image.asset(
                              AppAssets.screenSaleBag,
                              width: 184,
                              height: 184,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Main content area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        50,
                        20,
                        20,
                      ), // Top padding for floating search bar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location list
                          _buildLocationItem(
                            'Dinh Độc Lập',
                            '135 Nam Kỳ Khởi Nghĩa, phường Bến Thành, Quận 1, Thành phố Hồ Chí Minh',
                          ),
                          const Divider(height: 16),
                          _buildLocationItem(
                            'Công viên Tao Đàn',
                            'Quận 1, Thành phố Hồ Chí Minh, Việt Nam',
                          ),
                          const Divider(height: 16),
                          _buildLocationItem(
                            'KATINAT Cống viên Thủ Thiêm',
                            'QPG6+F2H, rr 2, Thủ Thiêm, Thủ Đức, Hồ Chí Minh',
                          ),

                          const SizedBox(height: 24),

                          // Hot destinations section
                          Row(
                            children: [
                              Text(
                                'Địa điểm hot - to - snap',
                                style: AppTextStyles.headline4.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
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

                          const SizedBox(height: 16),

                          // Hot destinations cards
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildDestinationCard(
                                  AppAssets.locationImage1,
                                  'Đà Nẵng',
                                ),
                                const SizedBox(width: 16),
                                _buildDestinationCard(
                                  AppAssets.locationImage2,
                                  'Đà Lạt',
                                ),
                                const SizedBox(width: 16),
                                _buildDestinationCard(
                                  AppAssets.locationImage3,
                                  'Hội An',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // User preferences section
                          Text(
                            'Đa dạng lựa chọn của bạn',
                            style: AppTextStyles.headline4.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Preference cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildPreferenceCard(
                                  'Ảnh nổi bật trong tuần',
                                  AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPreferenceCard(
                                  'Đặt trước cho snapper',
                                  const Color(0xFFB8D4CF),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Third preference card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5F2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Thuê đồ chụp hình ở đâu?',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SvgPicture.asset(
                                    AppAssets.cameraIcon,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ), // End of inner Column children
                    ), // End of SingleChildScrollView
                  ), // End of Container
                ), // End of Expanded
              ], // End of main Column children
            ), // End of Column
          ), // End of SafeArea
          // Floating search bar
          Positioned(
            left: 16,
            right: 16,
            top: 280, // Adjust based on promo banner height
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Location icon
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: SvgPicture.asset(
                      AppAssets.whiteLocationIcon,
                      width: 28,
                      height: 28,
                    ),
                  ),
                  // Search field
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to choose location screen with map
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChooseLocationScreenWithMap(),
                          ),
                        );
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Bạn muốn snap ở đâu?',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Snap button
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarker,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate to booking detail screen
                          // Pass null for selectedLocation to use user's location
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingDetailScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.cameraIcon,
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Snap',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ], // End of Stack children
      ),
    );
  }

  Widget _buildLocationItem(String title, String address) {
    return InkWell(
      onTap: () {
        // Navigate directly to booking detail screen with location pre-filled
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(
              selectedLocation: '$title, $address',
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SvgPicture.asset(
              AppAssets.locationIcon,
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(String imagePath, String name) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Text(
          name,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(String text, Color color) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.black,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
