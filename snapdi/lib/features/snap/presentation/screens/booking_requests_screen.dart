import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/providers/user_info_provider.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/network/api_service.dart';
import '../../../photographer/data/services/photographer_service.dart';
import '../../../auth/domain/services/auth_service.dart';

/// Screen showing pending booking requests for photographers
class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final UserInfoProvider _userInfoProvider = UserInfoProvider.instance;
  late final PhotographerService _photographerService;
  late final AuthService _authService;

  List<BookingRequest> _requests = [];
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
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      // Get photographer ID
      final photographerId = await _userInfoProvider.getUserId();
      
      if (photographerId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch pending bookings from API
      final pendingBookingsResponse = await _photographerService.getPendingBookings(
        photographerId: photographerId,
        page: 1,
        pageSize: 20,
      );
       
       print('Pending bookings response: $pendingBookingsResponse');

      if (pendingBookingsResponse != null && pendingBookingsResponse.data.isNotEmpty) {
        // Convert pending bookings to BookingRequest for display
        final requests = pendingBookingsResponse.data.map((booking) {
          return BookingRequest(
            bookingId: booking.bookingId,
            customerName: booking.user.name ?? 'Customer',
            customerAvatar: booking.user.avatarUrl,
            scheduleAt: booking.scheduleAt,
            locationAddress: booking.locationAddress,
            price: booking.price,
            status: booking.status.statusName,
            duration: '${booking.duration}h',
            photoType: booking.photoType.photoTypeName,
            note: booking.note,
          );
        }).toList();

        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      } else {
        setState(() {
          _requests = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading booking requests: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(BookingRequest request) async {
    // TODO: Call API to accept the booking request
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chấp nhận yêu cầu', style: AppTextStyles.headline4),
        content: Text(
          'Bạn có chắc chắn muốn chấp nhận yêu cầu chụp từ ${request.customerName}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã chấp nhận yêu cầu từ ${request.customerName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                _requests.remove(request);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarker,
            ),
            child: Text(
              'Chấp nhận',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectRequest(BookingRequest request) async {
    // TODO: Call API to reject the booking request
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Từ chối yêu cầu', style: AppTextStyles.headline4),
        content: Text(
          'Bạn có chắc chắn muốn từ chối yêu cầu chụp từ ${request.customerName}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã từ chối yêu cầu từ ${request.customerName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              setState(() {
                _requests.remove(request);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Từ chối',
              style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String scheduleAt) {
    try {
      final dateTime = DateTime.parse(scheduleAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} AM,ZN ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return scheduleAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundGradient, fit: BoxFit.cover),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Bell Icon Title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.notifySnapIcon,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ),

                // Requests List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _requests.isEmpty
                      ? Center(
                          child: Text(
                            'Không có yêu cầu chụp nào',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            return _buildRequestCard(_requests[index]);
                          },
                        ),
                ),

                const SizedBox(height: 100),
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
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Center(
              child: Text(
                'Yêu cầu chụp',
                style: AppTextStyles.headline3.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

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
              onPressed: () {
                // TODO: Open menu
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BookingRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Customer Info and Price
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  shape: BoxShape.circle,
                ),
                child: request.customerAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          request.customerAvatar!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
              ),

              const SizedBox(width: 12),

              // Name and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.customerName,
                      style: AppTextStyles.headline4.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(request.scheduleAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Price badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.walletIcon,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      StringUtils.formatVND((request.price), showSymbol: false),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status and Duration Badges
          Row(
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.photoType,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Duration Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.duration,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // Reject Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _rejectRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Từ Chối',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Accept Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarker,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Chấp Nhận',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Model class for booking request
class BookingRequest {
  final int bookingId;
  final String customerName;
  final String? customerAvatar;
  final String scheduleAt;
  final String locationAddress;
  final double price;
  final String status;
  final String duration;
  final String photoType;
  final String? note;

  BookingRequest({
    required this.bookingId,
    required this.customerName,
    this.customerAvatar,
    required this.scheduleAt,
    required this.locationAddress,
    required this.price,
    required this.status,
    required this.duration,
    required this.photoType,
    this.note,
  });
}
