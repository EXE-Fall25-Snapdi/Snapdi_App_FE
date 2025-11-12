import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'dart:async';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import '../../data/services/snapper_service.dart';
import '../../data/models/find_snappers_request.dart';
import 'booking_confirm_screen.dart';
import 'snappers_map_screen.dart';
import '../../../../core/utils/utils.dart';

class FindingSnappersScreen extends StatefulWidget {
  final String? location;
  final DateTime? date;
  final TimeOfDay? time;
  final String? city;
  final List<int>? styleIds;
  final List<int>? photoTypeIds;
  final int? minBudget;
  final int? maxBudget;
  final int? customerId;
  final String? locationAddress;
  final String? note;

  const FindingSnappersScreen({
    super.key,
    this.location,
    this.date,
    this.time,
    this.city,
    this.styleIds,
    this.photoTypeIds,
    this.minBudget,
    this.maxBudget,
    this.customerId,
    this.locationAddress,
    this.note,
  });

  @override
  State<FindingSnappersScreen> createState() => _FindingSnappersScreenState();
}

class _FindingSnappersScreenState extends State<FindingSnappersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isSearching = true;
  final List<SnapperProfile> _foundSnappers = [];
  final SnapperService _snapperService = SnapperService();
  bool _isCreatingBooking = false;
  // bool _isCreatingConversation = false;

  // Store search center and radius for map display
  double? _searchCenterLatitude;
  double? _searchCenterLongitude;
  double _radiusInKm = 30.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Find snappers using the API
    _findSnappers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _findSnappers() async {
    setState(() {
      _isSearching = true;
      _foundSnappers.clear();
    });

    try {
      // Get user's current location
      double? userLatitude;
      double? userLongitude;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          userLatitude = position.latitude;
          userLongitude = position.longitude;
        }
      } catch (e) {
        print('FindingSnappersScreen: Could not get location - $e');
      }

      final request = FindSnappersRequest(
        workLocation:'',
        photoTypeIds: widget.photoTypeIds ?? [],
        styleIds: widget.styleIds ?? [],
        isAvailable: true,
        minPrice: widget.minBudget,
        maxPrice: widget.maxBudget,
        page: 1,
        pageSize: 50,
        sortBy: 'rating',
        sortDirection: 'desc',
        latitude: userLatitude,
        longitude: userLongitude,
        radiusInKm: 30,
      );

      final response = await _snapperService.findSnappers(request);

      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _isSearching = false;

            // Use user's current location as search center
            if (userLatitude != null && userLongitude != null) {
              _searchCenterLatitude = userLatitude;
              _searchCenterLongitude = userLongitude;
            } else if (response.data!.searchCenter != null) {
              _searchCenterLatitude = response.data!.searchCenter!.latitude;
              _searchCenterLongitude = response.data!.searchCenter!.longitude;
            }

            if (response.data!.radiusInKm != null) {
              _radiusInKm = response.data!.radiusInKm!;
            }

            // Get the searched photo type ID (first one if multiple)
            final searchedPhotoTypeId = widget.photoTypeIds?.isNotEmpty == true
                ? widget.photoTypeIds!.first
                : null;

            _foundSnappers.addAll(
              response.data!.snappers.map((snapper) {
                // Find the matching photo type price, time, and name
                double photoPrice = 0;
                int photoTime = 0;
                String? photoTypeName;

                if (searchedPhotoTypeId != null) {
                  // Find the photo type that matches the search criteria
                  final matchingPhotoType = snapper.photoTypes.firstWhere(
                    (pt) => pt.photoTypeId == searchedPhotoTypeId,
                    orElse: () => snapper.photoTypes.first,
                  );
                  photoPrice = matchingPhotoType.photoPrice;
                  photoTime = matchingPhotoType.time;
                  photoTypeName =
                      matchingPhotoType.photoTypeName; // Extract name
                } else {
                  // If no specific type searched, use the first available type
                  photoPrice = snapper.photoTypes.first.photoPrice;
                  photoTime = snapper.photoTypes.first.time;
                  photoTypeName = snapper.photoTypes.first.photoTypeName;
                }

                return SnapperProfile(
                  userId: snapper.userId,
                  name: snapper.name,
                  subtitle: snapper.levelPhotographer,
                  rating: snapper.avgRating,
                  reviewCount: 0,
                  isOnline: snapper.isAvailable,
                  avatarUrl: snapper.avatarUrl,
                  photoPrice: photoPrice,
                  photoTime: photoTime,
                  photoTypeId: searchedPhotoTypeId,
                  photoTypeName: photoTypeName, // Store name
                  latitude: snapper.currentLocation?.latitude,
                  longitude: snapper.currentLocation?.longitude,
                );
              }),
            );

            // Calculate search center from snappers if needed
            if (_searchCenterLatitude == null ||
                _searchCenterLongitude == null) {
              final snappersWithLocation = _foundSnappers
                  .where((s) => s.latitude != null && s.longitude != null)
                  .toList();

              if (snappersWithLocation.isNotEmpty) {
                double sumLat = 0;
                double sumLng = 0;
                for (var snapper in snappersWithLocation) {
                  sumLat += snapper.latitude!;
                  sumLng += snapper.longitude!;
                }
                _searchCenterLatitude = sumLat / snappersWithLocation.length;
                _searchCenterLongitude = sumLng / snappersWithLocation.length;
              }
            }
          });
        } else {
          setState(() {
            _isSearching = false;
          });
          if (mounted) {
            _showErrorDialog('Không tìm thấy Snapper nào phù hợp');
          }
        }
        _animationController.stop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        _animationController.stop();
        _showErrorDialog('Lỗi khi tìm kiếm Snapper: $e');
      }
    }
  }

  // Future<void> _openChatWithPhotographer(SnapperProfile snapper) async {
  //   if (_isCreatingConversation) return;

  //   setState(() {
  //     _isCreatingConversation = true;
  //   });

  //   final result = await _chatApiService.createOrGetConversationWithUser(
  //     snapper.userId,
  //   );

  //   setState(() {
  //     _isCreatingConversation = false;
  //   });

  //   result.fold(
  //     (failure) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Không thể mở chat: ${failure.message}')),
  //         );
  //       }
  //     },
  //     (conversationId) {
  //       if (mounted) {
  //         context.push('/chat/$conversationId', extra: snapper.name);
  //       }
  //     },
  //   );
  // }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToBookingConfirm(SnapperProfile snapper) async {
    if (widget.customerId == null ||
        widget.date == null ||
        widget.time == null) {
      _showErrorDialog('Thiếu thông tin đặt chỗ');
      return;
    }

    setState(() {
      _isCreatingBooking = true;
    });

    try {
      // Navigate to BookingConfirmScreen without creating booking yet
      // Booking will be created after user confirms
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmScreen(
            snapper: snapper,
            location: widget.location,
            date: widget.date,
            scheduleAt: widget.time,
            customerId: widget.customerId!,
            locationAddress: widget.locationAddress ?? widget.location ?? '',
            note: widget.note ?? '',
            photoTypeId: snapper.photoTypeId,
            time: snapper.photoTime,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });
      }
    }
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
                      const Spacer(),
                      // Menu and Add buttons
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            _animationController.repeat();
                            _findSnappers();
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
                              color: Colors.black.withOpacity(0.3),
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
                      // Search area - Navigate to map
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (_foundSnappers.isNotEmpty &&
                                _searchCenterLatitude != null &&
                                _searchCenterLongitude != null) {

                              // Navigate and wait for result
                              final selectedSnapper =
                                  await Navigator.push<SnapperProfile>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SnappersMapScreen(
                                        snappers: _foundSnappers,
                                        centerLatitude: _searchCenterLatitude!,
                                        centerLongitude:
                                            _searchCenterLongitude!,
                                        radiusInKm: _radiusInKm,
                                      ),
                                    ),
                                  );

                              // If a snapper was selected from the map, navigate to confirm
                              if (selectedSnapper != null && mounted) {
                                _navigateToBookingConfirm(selectedSnapper);
                              }
                            } else if (_foundSnappers.isEmpty) {
                              _showErrorDialog(
                                'Không có Snapper nào để hiển thị trên bản đồ',
                              );
                            } else {
                              _showErrorDialog(
                                'Không có dữ liệu vị trí để hiển thị bản đồ',
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
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
                                    'Xem các Snappers tìm được trên map',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Icon(
                                    Icons.map_outlined,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main content area
                _isSearching
                    ? Expanded(child: _buildSearchingView())
                    : Expanded(child: _buildResultsView()),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              itemCount: _foundSnappers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildSnapperCard(_foundSnappers[index]);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSnapperCard(SnapperProfile snapper) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar section (unchanged)
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

            // Info section with photo type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    snapper.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                // Level and Photo Type
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        snapper.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (snapper.photoTypeName != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          snapper.photoTypeName!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Price and Time row
                Row(
                  children: [
                    // Price
                    Flexible(
                      child: Text(
                        StringUtils.formatVND(
                          snapper.photoPrice,
                          showSymbol: true,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Separator
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDarker,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${snapper.photoTime}h',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Action buttons (unchanged)
          Column(
            children: [
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
                    onTap: _isCreatingBooking
                        ? null
                        : () {
                            _navigateToBookingConfirm(snapper);
                          },
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isCreatingBooking)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        else
                          SvgPicture.asset(
                            AppAssets.cameraIcon,
                            width: 18,
                            height: 18,
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
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.grayField,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        AppAssets.messageIcon,
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {
                        // _openChatWithPhotographer(snapper);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bạn cần thanh toán để mở chat với Snapper'),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.grayField,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        AppAssets.profileActionIcon,
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {
                        context.push('/photographer-profile/${snapper.userId}');
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
      ),
    );
  }
}

class SnapperProfile {
  final int userId;
  final String name;
  final String subtitle;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final String? avatarUrl;
  final double photoPrice;
  final int photoTime;
  final int? photoTypeId;
  final String? photoTypeName; // Add this
  final double? latitude;
  final double? longitude;

  SnapperProfile({
    required this.userId,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.isOnline,
    this.avatarUrl,
    required this.photoPrice,
    required this.photoTime,
    this.photoTypeId,
    this.photoTypeName, // Add this
    this.latitude,
    this.longitude,
  });
}
