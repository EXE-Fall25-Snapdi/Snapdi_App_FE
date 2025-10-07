import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../widgets/feature_button.dart';
import '../widgets/promotional_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Header with greeting and search - Full background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment(0.0, -0.2), // Push gradient transition up so it's visible in header area
                colors: [
                  Color(0xFF015545),
                  Color(0xFF00B566),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120), // Reduced space for smaller overlapping content
                child: Column(
                  children: [
                    // Top bar with search and profile
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Search bar
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
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
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Profile/Menu button
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                                // TODO: Open profile/menu
                              },
                              icon: const Icon(
                                Icons.menu,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Profile avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),

                    // Greeting and mascot section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Row(
                        children: [
                          // Mascot character
                          // Container(
                          //   width: 80,
                          //   height: 80,
                          //   decoration: BoxDecoration(
                          //     color: Colors.white.withOpacity(0.2),
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: const Icon(
                          //     Icons.camera_alt_rounded,
                          //     size: 40,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          const SizedBox(width: 96),
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
                                    children: const [
                                      TextSpan(text: 'Xin chào, '),
                                      TextSpan(
                                        text: 'Per',
                                        style: TextStyle(
                                          color: Color(0xFFFFE57F), // Light yellow
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
          ),

          // Main content section - Positioned on top of header
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35, // Start at 35% of screen height (reduced height)
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
                    const SizedBox(height: 32),
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
                    const SizedBox(height: 20),
                    
                    // Feature buttons grid (single row)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          FeatureButton(
                            icon: Icons.camera_alt_rounded,
                            label: 'Now',
                            backgroundColor: AppColors.primary,
                            onTap: () {
                              // TODO: Navigate to instant booking
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            icon: Icons.calendar_today,
                            label: 'Book',
                            backgroundColor: const Color(0xFF4CAF50),
                            onTap: () {
                              // TODO: Navigate to booking
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            icon: Icons.card_giftcard,
                            label: 'VIP',
                            backgroundColor: const Color(0xFF9C27B0),
                            onTap: () {
                              // TODO: Navigate to VIP services
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            icon: Icons.local_offer,
                            label: 'Voucher',
                            backgroundColor: const Color(0xFFFF9800),
                            onTap: () {
                              // TODO: Navigate to vouchers
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            icon: Icons.flash_on,
                            label: 'Now',
                            backgroundColor: const Color(0xFFF44336),
                            onTap: () {
                              // TODO: Navigate to flash deals
                            },
                          ),
                          const SizedBox(width: 12),
                          FeatureButton(
                            icon: Icons.apps,
                            label: 'All',
                            backgroundColor: const Color(0xFF607D8B),
                            onTap: () {
                              // TODO: Navigate to all services
                            },
                          ),
                          const SizedBox(width: 8),
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
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Promotional cards
                    const PromotionalCard(
                      title: 'PHOTO COMPETITION',
                      subtitle: 'Win amazing prizes!',
                      imagePath: null, // Will use placeholder
                      gradientColors: [
                        Color(0xFF81C784),
                        Color(0xFF4FC3F7),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}