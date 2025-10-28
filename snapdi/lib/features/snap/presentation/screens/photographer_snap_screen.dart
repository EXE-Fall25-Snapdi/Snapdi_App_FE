import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/providers/user_info_provider.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/booking_response.dart';
import '../../../photographer/data/services/photographer_service.dart';
import '../../../auth/domain/services/auth_service.dart';
import 'booking_requests_screen.dart';

/// Photographer's Snap screen showing booking requests and upcoming sessions
class PhotographerSnapScreen extends StatefulWidget {
  const PhotographerSnapScreen({super.key});

  @override
  State<PhotographerSnapScreen> createState() => _PhotographerSnapScreenState();
}

class _PhotographerSnapScreenState extends State<PhotographerSnapScreen> {
  final UserInfoProvider _userInfoProvider = UserInfoProvider.instance;
  late final PhotographerService _photographerService;
  late final AuthService _authService;

  String _userName = 'Amigo';
  int _pendingRequestsCount = 1;
  List<BookingData> _upcomingBookings = [];
  bool _isLoading = true;

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get user name
      final userName = await _userInfoProvider.getUserName();
      if (userName != null) {
        setState(() => _userName = userName.split(' ').first);
      }

      // TODO: Load photographer's bookings from API
      setState(() {
        _upcomingBookings = [
          BookingData(
            bookingId: 1,
            customer: BookingUser(
              userId: 101,
              name: 'Nguyễn Văn A',
              email: 'customer1@example.com',
              phone: '0901234567',
            ),
            photographer: BookingPhotographer(
              userId: 201,
              name: 'Photographer',
              email: 'photographer@example.com',
              phone: '0987654321',
            ),
            scheduleAt: '2025-10-28T14:30:00',
            locationAddress: 'Quận 1, TP.HCM',
            status: BookingStatus(statusId: 1, statusName: 'Confirmed'),
            price: 500000,
            note: 'Wedding photography',
          ),
          BookingData(
            bookingId: 2,
            customer: BookingUser(
              userId: 102,
              name: 'Trần Thị B',
              email: 'customer2@example.com',
              phone: '0902345678',
            ),
            photographer: BookingPhotographer(
              userId: 201,
              name: 'Photographer',
              email: 'photographer@example.com',
              phone: '0987654321',
            ),
            scheduleAt: '2025-10-28T17:30:00',
            locationAddress: 'Quận 10, TP.HCM',
            status: BookingStatus(statusId: 1, statusName: 'Confirmed'),
            price: 300000,
            note: 'Portrait session',
          ),
          BookingData(
            bookingId: 3,
            customer: BookingUser(
              userId: 103,
              name: 'Lê Văn C',
              email: 'customer3@example.com',
              phone: '0903456789',
            ),
            photographer: BookingPhotographer(
              userId: 201,
              name: 'Photographer',
              email: 'photographer@example.com',
              phone: '0987654321',
            ),
            scheduleAt: '2025-10-28T20:30:00',
            locationAddress: 'Quận Phú Nhuận, TP.HCM',
            status: BookingStatus(statusId: 1, statusName: 'Confirmed'),
            price: 450000,
            note: 'Event photography',
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(String scheduleAt) {
    try {
      final dateTime = DateTime.parse(scheduleAt);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute, ngày mai';
    } catch (e) {
      return '12:00, hôm nay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              AppAssets
                  .backgroundGradient, // or use backgroundFinding/backgroundFound
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(),

                // Update the Greeting section - Center it
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Center(
                    // Changed from Align to Center
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Changed to center
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.headline2.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Hola,',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              TextSpan(
                                text: _userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start your day with beauty!!!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // Photo Requests Card
                              _buildPhotoRequestsCard(),

                              const SizedBox(height: 24),

                              // Upcoming Sessions Section
                              Text(
                                'Lịch chụp sắp tới',
                                style: AppTextStyles.headline4.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Upcoming Bookings List
                              ..._upcomingBookings
                                  .map((booking) => _buildBookingCard(booking))
                                  .toList(),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
            ),
          ),

          const Spacer(),

          // Menu Icon
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary, size: 24),
              onPressed: () async {
                final id = await _userInfoProvider.getUserId();
                if (id != null) {
                  context.go('/profile/$id');
                }
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoRequestsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingRequestsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yêu cầu chụp',
                    style: AppTextStyles.headline4.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn có một yêu cầu chụp đang chờ....',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Bell Icon with notification
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AppAssets.notifySnapIcon,
                      width: 28,
                      height: 28,
                    ),
                  ),

                  // Red dot indicator
                  if (_pendingRequestsCount > 0)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update _buildBookingCard - Remove colorFilter
  Widget _buildBookingCard(BookingData booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EBE6),
        borderRadius: BorderRadius.circular(30),
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
          // Location Icon
          Container(
            width: 50,
            height: 50,
            
            child: Center(
              child: SvgPicture.asset(
                AppAssets.whiteLocationIcon,
                width: 42,
                height: 42,
                // Removed colorFilter
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Booking Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.locationAddress,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(booking.scheduleAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
