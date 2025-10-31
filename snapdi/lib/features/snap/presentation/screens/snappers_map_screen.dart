import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import 'finding_snappers_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/utils.dart';
// import '../../../chat/data/services/chat_api_service.dart';

/// Screen to display snappers on a map based on their location
class SnappersMapScreen extends StatefulWidget {
  final List<SnapperProfile> snappers;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusInKm;
  final Function(SnapperProfile)? onSnapperSelected; // Callback for booking

  const SnappersMapScreen({
    super.key,
    required this.snappers,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusInKm,
    this.onSnapperSelected,
  });

  @override
  State<SnappersMapScreen> createState() => _SnappersMapScreenState();
}

class _SnappersMapScreenState extends State<SnappersMapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  SnapperProfile? _selectedSnapper;
  bool _isCreatingConversation = false;
  // final ChatApiServiceImpl _chatApiService = ChatApiServiceImpl();

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createMarkers() {
    // Add user location marker (search center)
    _markers.add(
      Marker(
        point: LatLng(widget.centerLatitude, widget.centerLongitude),
        width: 50,
        height: 50,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );

    // Add snapper markers
    for (var snapper in widget.snappers) {
      if (snapper.latitude != null && snapper.longitude != null) {
        _markers.add(
          Marker(
            point: LatLng(snapper.latitude!, snapper.longitude!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSnapper = snapper;
                });
              },
              child: Icon(
                Icons.location_on,
                color: snapper.isOnline ? AppColors.primary : Colors.red,
                size: 40,
              ),
            ),
          ),
        );
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

  void _createBookingWithSnapper(SnapperProfile snapper) {
    // Pop back to finding snappers screen with the selected snapper
    Navigator.pop(context, snapper);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                widget.centerLatitude,
                widget.centerLongitude,
              ),
              initialZoom: 12,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snapdi.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                  // Title
                  Expanded(
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.snappers.length} Snapper trong ${widget.radiusInKm}km',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected snapper card at bottom
          if (_selectedSnapper != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildSnapperCard(_selectedSnapper!),
            ),

          // My location button
          Positioned(
            bottom: _selectedSnapper != null ? 180 : 20,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                _mapController.move(
                  LatLng(widget.centerLatitude, widget.centerLongitude),
                  12,
                );
              },
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapperCard(SnapperProfile snapper) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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

          // Info section
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
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      snapper.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
                    Text(
                      StringUtils.formatVND(
                        snapper.photoPrice,
                        showSymbol: true,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
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

          // Action buttons column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Snap button - Navigate back and create booking
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
                      // Return the selected snapper to finding snappers screen
                      _createBookingWithSnapper(snapper);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
              // Chat and Info buttons row
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
                      icon: _isCreatingConversation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            )
                          : SvgPicture.asset(
                              AppAssets.messageIcon,
                              width: 20,
                              height: 20,
                            ),
                      onPressed: _isCreatingConversation
                          ? null
                          : () {
                              // _openChatWithPhotographer(snapper);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bạn cần thanh toán để mở chat với Snapper',
                                  ),
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
                        // Dismiss card
                        setState(() {
                          _selectedSnapper = null;
                        });
                        // Navigate to photographer profile
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
    );
  }
}
