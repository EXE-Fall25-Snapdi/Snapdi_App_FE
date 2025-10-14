import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'booking_detail_screen.dart';

class ChooseLocationScreen extends StatefulWidget {
  const ChooseLocationScreen({super.key});

  @override
  State<ChooseLocationScreen> createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Dùng gần đây';

  final List<LocationItem> _locations = [
    LocationItem(
      name: 'Dinh Độc Lập',
      address:
          '135 Nam Kỳ Khởi Nghĩa, phường Bến Thành, Quận 1, Thành phố Hồ Chí Minh, Việt Nam',
      distance: '6.5km',
    ),
    LocationItem(
      name: 'Công viên Tao Đàn',
      address: 'Quận 1, Thành phố Hồ Chí Minh, Việt Nam',
      distance: '1km',
    ),
    LocationItem(
      name: 'KATINAT Cống viên Thủ Thiêm',
      address: 'QPG6+F2H, rr 2, Thủ Thiêm, Thủ Đức, Hồ Chí Minh',
      distance: '3km',
    ),
    LocationItem(
      name: 'Sân vận động Thống Nhất',
      address: '113B Đào Duy Từ, Phường 6, Quận 10, Thành phố Hồ Chí Minh',
      distance: '0.7km',
    ),
    LocationItem(
      name: 'Highlands Coffee Saigon Post Office',
      address: 'Số 2 Công Xã Paris, P. Bến Nghé, Quận 1, Thành phố Hồ Chí Minh',
      distance: '10km',
    ),
    LocationItem(
      name: 'Bưu Điện Sài Gòn',
      address:
          'Số 2 Công Xã Paris, P. Bến Nghé,, Quận 1, Thành phố Hồ Chí Minh',
      distance: '9.8km',
    ),
    LocationItem(
      name: 'Bưu Điện Sài Gòn',
      address:
          'Số 2 Công Xã Paris, P. Bến Nghé,, Quận 1, Thành phố Hồ Chí Minh',
      distance: '10.7km',
    ),
    LocationItem(
      name: 'Chợ Bến Thành',
      address: 'Lê Lợi, Phường Bến Thành, Quận 1, Thành phố Hồ Chí Minh',
      distance: '8.2km',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.backgroundWhite),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header section with gradient background
              Container(
                child: Column(
                  children: [
                    // Top bar with back button and current location
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
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Current location
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                border: Border.all(
                                  color: Colors.cyan.shade100,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.whiteLocationIcon,
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Vị trí hiện tại',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // City button
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                AppAssets.starIcon,
                                width: 16,
                                height: 16,
                              ),
                              onPressed: () {
                                // TODO: Open menu
                              },
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.grayField,
                          borderRadius: BorderRadius.circular(24),
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
                            // Location icon
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: SvgPicture.asset(
                                AppAssets.whiteLocationIcon,
                                color: AppColors.primaryDark,
                                width: 24,
                                height: 24,
                              ),
                            ),
                            // Search field
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Tìm địa điểm chụp ảnh đẹp',
                                  hintStyle: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            // Search button
                            Container(
                              margin: const EdgeInsets.all(4),

                              child: IconButton(
                                icon: SvgPicture.asset(
                                  AppAssets.camera_altIcon,
                                  width: 20,
                                  height: 20,
                                ),
                                onPressed: () {
                                  // TODO: Handle search
                                },
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    _buildFilterChip('Dùng gần đây'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Đề xuất'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Đã lưu'),
                  ],
                ),
              ),

              // Location list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _locations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return _buildLocationItem(location);
                  },
                ),
              ), // Bottom button
              GestureDetector(
                onTap: () {
                  // Navigate to booking detail with map selection
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingDetailScreen(
                        selectedLocation: 'Vị trí từ bản đồ',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 20,
                    bottom: 5 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFAACBC4),
                    
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.mapIcon,
                        width: 24,
                        height: 24,
                        
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Chọn trên Snapmaps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey.shade700,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationItem(LocationItem location) {
    return InkWell(
      onTap: () {
        // Navigate to booking detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookingDetailScreen(selectedLocation: location.name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location icon with distance
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SvgPicture.asset(
                    AppAssets.locationIcon,
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location.distance,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Location details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // More options button
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () {
                // TODO: Show more options
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationItem {
  final String name;
  final String address;
  final String distance;

  LocationItem({
    required this.name,
    required this.address,
    required this.distance,
  });
}
