import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'dart:async';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import 'booking_confirm_screen.dart';

class FindingSnappersScreen extends StatefulWidget {
  final String? location;
  final DateTime? date;
  final TimeOfDay? time;

  const FindingSnappersScreen({super.key, this.location, this.date, this.time});

  @override
  State<FindingSnappersScreen> createState() => _FindingSnappersScreenState();
}

class _FindingSnappersScreenState extends State<FindingSnappersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isSearching = true;
  final List<SnapperProfile> _foundSnappers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Simulate finding snappers after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _foundSnappers.addAll(_getMockSnappers());
        });
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<SnapperProfile> _getMockSnappers() {
    return [
      SnapperProfile(
        name: 'Nguyễn Tuấn Kiệt',
        subtitle: 'Snapper Chuyên Nghiệp',
        rating: 5.0,
        reviewCount: 25,
        isOnline: true,
        avatarUrl: null,
      ),
      SnapperProfile(
        name: 'Lưu Hoàng Phú',
        subtitle: 'Snapper Nghiệp Dư',
        rating: 5.0,
        reviewCount: 20,
        isOnline: true,
        avatarUrl: null,
      ),
      SnapperProfile(
        name: 'Phạm Hoàng Duy',
        subtitle: 'Snapper Trung Cấp',
        rating: 5.0,
        reviewCount: 10,
        isOnline: true,
        avatarUrl: null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image - changes based on search state
          Positioned.fill(
            child: Image.asset(
              _isSearching
                  ? AppAssets.backgroundFinding
                  : AppAssets.backgroundFound,
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const Spacer(),
                      // Menu and Add buttons
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSearching = true;
                              _foundSnappers.clear();
                            });
                            _animationController.repeat();
                            Timer(const Duration(seconds: 3), () {
                              if (mounted) {
                                setState(() {
                                  _isSearching = false;
                                  _foundSnappers.addAll(_getMockSnappers());
                                });
                                _animationController.stop();
                              }
                            });
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            // TODO: Add filter options
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bars
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Location search
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.locationIcon,
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.location ?? 'Vị trí hiện tại',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search area
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.searchIcon,
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Tìm Snaper trong khu vực',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                AppAssets.cameraIcon,
                                width: 16,
                                height: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main content area
                Expanded(
                  child: _isSearching
                      ? _buildSearchingView()
                      : _buildResultsView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingView() {
    return Container(
      child: Column(
        children: [
          // Spacer to center mascot
          const Spacer(flex: 1),
          // Static mascot (no rotation)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Image.asset(
                AppAssets.mascotWave,
                width: 180,
                height: 180,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          // Spacer to push text to bottom
          const Spacer(flex: 2),
          // Text at the bottom with padding - no bottom space
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 32.0,
              bottom: 10.0 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.headline3.copyWith(
                    color: Colors.black87,
                  ),
                  children: const [
                    TextSpan(text: 'Đang tìm '),
                    TextSpan(
                      text: 'Snapper',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(text: '....'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Results count
          RichText(
            text: TextSpan(
              style: AppTextStyles.headline3.copyWith(color: Colors.black87),
              children: [
                const TextSpan(text: 'Đã tìm được '),
                TextSpan(
                  text: '${_foundSnappers.length} Snapper',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Snappers list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _foundSnappers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildSnapperCard(_foundSnappers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapperCard(SnapperProfile snapper) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              ClipOval(
                child: snapper.avatarUrl != null
                    ? CloudinaryImage(
                        publicId: snapper.avatarUrl!,
                        width: 60,
                        height: 60,
                        crop: 'fill',
                        gravity: 'face',
                        quality: 80,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
              if (snapper.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapper.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  snapper.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                // Rating
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < snapper.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.primary,
                        size: 16,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '(${snapper.reviewCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Column(
            children: [
              // Snap button
              Container(
                width: 70,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryDarker,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Navigate to booking confirm screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingConfirmScreen(
                            snapper: snapper,
                            location: widget.location,
                            date: widget.date,
                            time: widget.time,
                            // Truyền các thông tin booking khác
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.cameraIcon,
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Snap',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Action icons
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8D4CF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        // TODO: Open chat
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8D4CF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        // TODO: Show snapper info
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SnapperProfile {
  final String name;
  final String subtitle;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final String? avatarUrl;

  SnapperProfile({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.isOnline,
    this.avatarUrl,
  });
}
