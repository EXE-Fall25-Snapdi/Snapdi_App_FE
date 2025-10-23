import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import 'finding_snappers_screen.dart';

/// Screen to display snappers on a map based on their location
class SnappersMapScreen extends StatefulWidget {
  final List<SnapperProfile> snappers;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusInKm;

  const SnappersMapScreen({
    super.key,
    required this.snappers,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusInKm,
  });

  @override
  State<SnappersMapScreen> createState() => _SnappersMapScreenState();
}

class _SnappersMapScreenState extends State<SnappersMapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  SnapperProfile? _selectedSnapper;

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
      // Only add markers for snappers with valid location data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.centerLatitude, widget.centerLongitude),
              initialZoom: 12,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snapdi.app',
              ),
              MarkerLayer(
                markers: _markers,
              ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, -2),
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
                Text(
                  snapper.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${snapper.photoPrice.toStringAsFixed(0)} VND',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
          // Close button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedSnapper = null;
              });
            },
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
