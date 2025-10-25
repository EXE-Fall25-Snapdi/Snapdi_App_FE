import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'dart:async';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import '../../data/services/snapper_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/find_snappers_request.dart';
import '../../data/models/booking_request.dart';
import 'booking_confirm_screen.dart';
import 'snappers_map_screen.dart';

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
  final BookingService _bookingService = BookingService();
  bool _isCreatingBooking = false;
  
  // Store search center and radius for map display
  double? _searchCenterLatitude;
  double? _searchCenterLongitude;
  double _radiusInKm = 100.0;

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
        // Check location permission
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
        // Continue without location - API might use workLocation instead
      }

      final request = FindSnappersRequest(
        workLocation: widget.city ?? '',
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
        radiusInKm: 100,
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
              print('Using user location as search center: $_searchCenterLatitude, $_searchCenterLongitude');
            } else if (response.data!.searchCenter != null) {
              // Fallback to API search center if available
              _searchCenterLatitude = response.data!.searchCenter!.latitude;
              _searchCenterLongitude = response.data!.searchCenter!.longitude;
              print('Using API search center: $_searchCenterLatitude, $_searchCenterLongitude');
            }
            
            if (response.data!.radiusInKm != null) {
              _radiusInKm = response.data!.radiusInKm!;
            }
            
            _foundSnappers.addAll(
              response.data!.snappers.map((snapper) => SnapperProfile(
                    userId: snapper.userId,
                    name: snapper.name,
                    subtitle: snapper.levelPhotographer,
                    rating: snapper.avgRating,
                    reviewCount: 0, // Not in API
                    isOnline: snapper.isAvailable,
                    avatarUrl: snapper.avatarUrl,
                    photoPrice: snapper.photoPrice,
                    latitude: snapper.currentLocation?.latitude,
                    longitude: snapper.currentLocation?.longitude,
                  )),
            );
            
            // If still no search center, calculate from snappers' locations
            if (_searchCenterLatitude == null || _searchCenterLongitude == null) {
              final snappersWithLocation = _foundSnappers.where(
                (s) => s.latitude != null && s.longitude != null
              ).toList();
              
              if (snappersWithLocation.isNotEmpty) {
                double sumLat = 0;
                double sumLng = 0;
                for (var snapper in snappersWithLocation) {
                  sumLat += snapper.latitude!;
                  sumLng += snapper.longitude!;
                }
                _searchCenterLatitude = sumLat / snappersWithLocation.length;
                _searchCenterLongitude = sumLng / snappersWithLocation.length;
                print('Calculated center from snappers: $_searchCenterLatitude, $_searchCenterLongitude');
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

  Future<void> _createBooking(SnapperProfile snapper) async {
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
      // Combine date and time into ISO 8601 format
      final scheduleDateTime = DateTime(
        widget.date!.year,
        widget.date!.month,
        widget.date!.day,
        widget.time!.hour,
        widget.time!.minute,
      );

      final bookingRequest = BookingRequest(
        customerId: widget.customerId!,
        photographerId: snapper.userId,
        scheduleAt: scheduleDateTime.toIso8601String(),
        locationAddress: widget.locationAddress ?? widget.location ?? '',
        price: snapper.photoPrice.toInt(),
        note: null, // Can be extended to accept user notes in the future
      );

      final response = await _bookingService.createBooking(bookingRequest);

      if (!mounted) return;

      if (response.success && response.data != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thành công'),
            content: Text(
              'Đã đặt chụp với ${response.data!.photographer.name} thành công!\n\n'
              'Mã đặt chỗ: #${response.data!.bookingId}\n'
              'Trạng thái: ${response.data!.status.statusName}\n'
              'Địa chỉ: ${response.data!.locationAddress}\n'
              'Giá: ${response.data!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND',
            ),
                actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // After closing the dialog, navigate to BookingConfirmScreen with real values
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmScreen(
                          snapper: snapper,
                          location: widget.location,
                          date: widget.date,
                          time: widget.time,
                          bookingId: response.data!.bookingId,
                          amount: response.data!.price.toDouble(),
                        ),
                      ),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
          ),
        );
      } else {
        _showErrorDialog(response.message ?? 'Không thể tạo đặt chỗ');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Lỗi: ${e.toString()}');
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
                          onTap: () {
                            print('Map button tapped!');
                            print('Found snappers: ${_foundSnappers.length}');
                            print('Search center: $_searchCenterLatitude, $_searchCenterLongitude');
                            print('Is searching: $_isSearching');
                            
                            // Only navigate if we have search results and location data
                            if (_foundSnappers.isNotEmpty && 
                                _searchCenterLatitude != null && 
                                _searchCenterLongitude != null) {
                              print('Navigating to map...');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SnappersMapScreen(
                                    snappers: _foundSnappers,
                                    centerLatitude: _searchCenterLatitude!,
                                    centerLongitude: _searchCenterLongitude!,
                                    radiusInKm: _radiusInKm,
                                  ),
                                ),
                              );
                            } else if (_foundSnappers.isEmpty) {
                              print('No snappers found - showing error');
                              _showErrorDialog('Không có Snapper nào để hiển thị trên bản đồ');
                            } else if (_searchCenterLatitude == null || _searchCenterLongitude == null) {
                              print('No location data - showing error');
                              _showErrorDialog('Không có dữ liệu vị trí để hiển thị bản đồ');
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
                    : const Spacer(),

                // Results view positioned at bottom
                if (!_isSearching) _buildResultsView(),
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
        mainAxisSize: MainAxisSize.min,
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            itemCount: _foundSnappers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildSnapperCard(_foundSnappers[index]);
            },
          ),
          const SizedBox(height: 50),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  snapper.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
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
                    onTap: _isCreatingBooking ? null : () {
                      _createBooking(snapper);
                      // Start booking creation; navigation to BookingConfirmScreen
                      // will happen from the booking success dialog handler.
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
  final int userId;
  final String name;
  final String subtitle;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final String? avatarUrl;
  final double photoPrice;
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
    this.latitude,
    this.longitude,
  });
}
