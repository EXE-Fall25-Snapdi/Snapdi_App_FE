import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
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
  bool _isLoading = true;
  String? _levelPhotographer;

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

    // Load availability status on init
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final userId = await _userInfoProvider.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final availability = await _photographerService.getAvailability(
        photographerId: userId,
      );
      if (availability != null) {
        setState(() {
          _isOnline = availability.isAvailable;
          _levelPhotographer = availability.levelPhotographer;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // Check if it's a refresh token expiration error
      if (e.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        if (mounted) {
          // Clear stored tokens
          await TokenStorage.instance.clearTokens();
          // Redirect to login
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      } else if (e.toString().contains('TOKEN_EXPIRED') ||
          e.toString().contains('401')) {
        if (mounted) {
          // Clear stored tokens
          await TokenStorage.instance.clearTokens();
          // Redirect to login
          if (mounted) {
            context.go('/login');
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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

                // Toggle Online/Offline button - Pill style toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5A54),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Đang tải...',
                                  style: AppTextStyles.buttonLarge.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : _levelPhotographer == null
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hồ sơ chưa xác nhận',
                                    style: AppTextStyles.buttonLarge.copyWith(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: _isUpdatingStatus ? null : _toggleStatus,
                              borderRadius: BorderRadius.circular(50),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left content with arrow
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Row(
                                        children: [
                                          if (_isUpdatingStatus)
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _isOnline
                                                ? 'Go Offline'
                                                : 'Go Online',
                                            style: AppTextStyles.buttonLarge
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Right circle indicator
                                  Container(
                                    margin: const EdgeInsets.all(4),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _isOnline
                                          ? Colors.green
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _isOnline
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: _isOnline
                                            ? Colors.white
                                            : const Color(0xFF2D5A54),
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
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
