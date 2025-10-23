import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/providers/user_info_provider.dart';
import '../../data/models/booking_response.dart';
import 'booking_requests_screen.dart';

/// Photographer's Snap screen showing booking requests and upcoming sessions
class PhotographerSnapScreen extends StatefulWidget {
  const PhotographerSnapScreen({super.key});

  @override
  State<PhotographerSnapScreen> createState() => _PhotographerSnapScreenState();
}

class _PhotographerSnapScreenState extends State<PhotographerSnapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserInfoProvider _userInfoProvider = UserInfoProvider.instance;
  
  String _userName = 'Amigo';
  int _pendingRequestsCount = 1;
  List<BookingData> _upcomingBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      // For now, using mock data based on the design
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
            photographer: BookingUser(
              userId: 201,
              name: 'Photographer',
              email: 'photographer@example.com',
              phone: '0987654321',
            ),
            scheduleAt: '2025-10-23T12:00:00',
            locationAddress: 'Quận 1, TP. HCM',
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
            photographer: BookingUser(
              userId: 201,
              name: 'Photographer',
              email: 'photographer@example.com',
              phone: '0987654321',
            ),
            scheduleAt: '2025-10-23T15:00:00',
            locationAddress: 'Quận 10, TP. HCM',
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
            photographer: BookingUser(
              userId: 201,
              name: 'Photographer',
              email: 'photographer@example.com',
              phone: '0987654321',
            ),
            scheduleAt: '2025-10-24T19:00:00',
            locationAddress: 'Quận Tân Phú, TP. HCM',
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
      return '$hour:$minute';
    } catch (e) {
      return '12:00';
    }
  }

  String _getTimeLabel(String scheduleAt) {
    try {
      final dateTime = DateTime.parse(scheduleAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final bookingDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      if (bookingDate == today) {
        return 'hôm nay';
      } else if (bookingDate == today.add(const Duration(days: 1))) {
        return 'ngày mai';
      } else {
        return 'ngày ${dateTime.day}/${dateTime.month}';
      }
    } catch (e) {
      return 'hôm nay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundGradient,
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(),
                
                // Greeting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.headline2.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Hola, ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: _userName,
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              
                              // Photo Requests Card
                              _buildPhotoRequestsCard(),
                              
                              const SizedBox(height: 32),
                              
                              // Upcoming Sessions Section
                              Text(
                                'Lịch Chụp Sắp Tới',
                                style: AppTextStyles.headline3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Upcoming Bookings List
                              ..._upcomingBookings.map((booking) => 
                                _buildBookingCard(booking)
                              ).toList(),
                              
                              const SizedBox(height: 100), // Space for bottom nav
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
          // Search Bar
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Menu and Profile Icons
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                // Menu Icon
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primary),
                  onPressed: () {
                    // TODO: Open menu
                  },
                ),
                
                Container(
                  width: 1,
                  height: 25,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                
                // Profile Icon
                IconButton(
                  icon: const Icon(Icons.person, color: AppColors.primary),
                  onPressed: () {
                    context.go('/profile');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoRequestsCard() {
    return GestureDetector(
      onTap: () {
        // Navigate to photo requests screen
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
          borderRadius: BorderRadius.circular(20),
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
                    'Yêu Cầu Chụp',
                    style: AppTextStyles.headline4.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn có $_pendingRequestsCount yêu cầu chụp đang chờ....',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Calendar Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  
                  // Notification Badge
                  if (_pendingRequestsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_pendingRequestsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildBookingCard(BookingData booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 28,
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
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatTime(booking.scheduleAt)}, ${_getTimeLabel(booking.scheduleAt)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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
