import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/providers/user_info_provider.dart';
import '../../../photographer/data/services/photographer_service.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/network/api_service.dart';

class PhotographerWelcomeScreen extends StatefulWidget {
  const PhotographerWelcomeScreen({super.key});

  @override
  State<PhotographerWelcomeScreen> createState() =>
      _PhotographerWelcomeScreenState();
}

class _PhotographerWelcomeScreenState extends State<PhotographerWelcomeScreen> {
  final UserInfoProvider _userInfoProvider = UserInfoProvider.instance;
  late final PhotographerService _photographerService;
  late final AuthService _authService;

  bool _isOnline = false;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    // Initialize services
    final apiService = ApiService();
    final tokenStorage = TokenStorage.instance;
    _authService = AuthServiceImpl(
      apiService: apiService,
      tokenStorage: tokenStorage,
    );
    _photographerService = PhotographerService(authService: _authService);
  }

  Future<void> _toggleStatus() async {
    setState(() => _isUpdatingStatus = true);

    try {
      // Get current location
      Position? position;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        }
      } catch (e) {
        // Continue without location if permission denied
        print('Location error: $e');
      }

      // Get photographer ID
      final userId = await _userInfoProvider.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Toggle status
      final newStatus = !_isOnline;

      // Update status
      final success = await _photographerService.updateStatus(
        photographerId: userId,
        isAvailable: newStatus,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (!mounted) return;

      if (success) {
        setState(() => _isOnline = newStatus);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? 'Bạn đang online - sẵn sàng nhận việc'
                  : 'Bạn đã offline - không nhận việc mới',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: newStatus ? Colors.green : AppColors.textSecondary,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showError('Không thể cập nhật trạng thái. Vui lòng thử lại.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map background image
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundFinding, fit: BoxFit.cover),
          ),

          // Optional: Overlay tint to adjust brightness
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF4DB8A8).withOpacity(0.3),
                    const Color(0xFF4DB8A8).withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Welcome message card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chào mừng\ntrở lại',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mascot image
                      Image.asset(
                        AppAssets.mascotSnap,
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),

                // Toggle Online/Offline button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isUpdatingStatus ? null : _toggleStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isOnline
                            ? Colors.green
                            : Colors.white,
                        foregroundColor: _isOnline
                            ? Colors.white
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: _isUpdatingStatus
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isOnline
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Đang cập nhật...',
                                  style: AppTextStyles.buttonLarge.copyWith(
                                    color: _isOnline
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isOnline
                                      ? Icons.check_circle
                                      : Icons.double_arrow_rounded,
                                  color: _isOnline
                                      ? Colors.white
                                      : AppColors.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _isOnline
                                      ? 'Online - Đang sẵn sàng'
                                      : 'Go Online',
                                  style: AppTextStyles.buttonLarge.copyWith(
                                    color: _isOnline
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
