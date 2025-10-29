import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../data/services/booking_service.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/providers/user_info_provider.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/network/api_service.dart';
import '../../../photographer/data/services/photographer_service.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../profile/presentation/widgets/cloudinary_image.dart';

/// Screen showing pending booking requests for photographers
class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final BookingService _bookingService = BookingService();

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
      final pendingBookingsResponse = await _photographerService
          .getPendingBookings(
            photographerId: photographerId,
            page: 1,
            pageSize: 20,
          );

      print('Pending bookings response: $pendingBookingsResponse');

      if (pendingBookingsResponse != null &&
          pendingBookingsResponse.data.isNotEmpty) {
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
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chấp nhận yêu cầu', style: AppTextStyles.headline4),
        content: Text(
          'Bạn có chắc chắn muốn chấp nhận yêu cầu chụp từ ${request.customerName}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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

    // If user cancelled, return early
    if (confirmed != true) return;

    // Set loading state
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Call API to update booking status to Accepted (status ID 2)
      final response = await _bookingService.updateBookingStatus(
        request.bookingId,
        2, // Accepted status ID
      );

      if (mounted) {
        // Reset loading state
        setState(() {
          _isLoading = false;
        });

        if (response != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã chấp nhận yêu cầu từ ${request.customerName}',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Remove the request from the list
          setState(() {
            _requests.remove(request);
          });
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể chấp nhận yêu cầu',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Reset loading state on error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString()}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(BookingRequest request) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Từ chối yêu cầu', style: AppTextStyles.headline4),
        content: Text(
          'Bạn có chắc chắn muốn từ chối yêu cầu chụp từ ${request.customerName}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Từ chối',
              style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // If user cancelled, return early
    if (confirmed != true) return;

    // Set loading state
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Call API to update booking status to Rejected (status ID 8)
      final response = await _bookingService.updateBookingStatus(
        request.bookingId,
        8, // Rejected/Cancelled status ID
      );

      if (mounted) {
        // Reset loading state
        setState(() {
          _isLoading = false;
        });

        if (response != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã từ chối yêu cầu từ ${request.customerName}',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );

          // Remove the request from the list
          setState(() {
            _requests.remove(request);
          });
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể từ chối yêu cầu',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Reset loading state on error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString()}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showUploadPhotoDialog(BookingRequest request) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final screenHeight = MediaQuery.of(context).size.height;

            return Container(
              // Thay vì cố định chiều cao cứng, dùng constraints để modal co giãn tốt hơn
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.95,
                minHeight: screenHeight * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                // Padding tổng (trên/trái/phải). Bottom sẽ được điều chỉnh bởi AnimatedPadding bên trong
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: AnimatedPadding(
                  // AnimatedPadding giúp animate khi bàn phím bật/tắt
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: SingleChildScrollView(
                    // Cho phép ẩn bàn phím khi kéo
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    // Thêm padding nhỏ phía dưới để không dính quá sát
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ConstrainedBox(
                      // Đảm bảo nội dung ít nhất chiếm 85% chiều cao modal để Spacer hoạt động tốt
                      constraints: BoxConstraints(
                        minHeight:
                            screenHeight * 0.85 -
                            48, // trừ đi padding xung quanh
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: Text(
                                "Thông tin",
                                style: AppTextStyles.headline3.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Avatar + Name + Price
                            Row(
                              children: [
                                ClipOval(
                                  child: CloudinaryImage(
                                    publicId: request.customerAvatar!,
                                    width: 60,
                                    height: 60,
                                    crop: 'fill',
                                    gravity: 'face',
                                    quality: 80,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.customerName,
                                        style: AppTextStyles.headline4.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        StringUtils.formatVND(request.price),
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Info Grid (2x2)
                            Row(
                              children: [
                                Expanded(
                                  child: _infoCard(
                                    Icons.calendar_today_outlined,
                                    _formatDate(request.scheduleAt),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoCard(
                                    Icons.access_time_outlined,
                                    _formatTime(request.scheduleAt),
                                    backgroundColor: AppColors.primary,
                                    textColor: Colors.white,
                                    iconColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoCard(
                                    Icons.camera_alt_outlined,
                                    request.photoType,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoCard(
                                    Icons.schedule_outlined,
                                    request.duration,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Location Address
                            if (request.locationAddress.isNotEmpty)
                              Column(
                                children: [
                                  _infoRowWithIcon(
                                    Icons.location_on_outlined,
                                    "Địa điểm",
                                    request.locationAddress,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),

                            // Booking Status
                            _infoRowWithIcon(
                              Icons.info_outline,
                              "Trạng thái",
                              request.status,
                              valueColor: _getStatusColor(request.status),
                            ),

                            // Note (if available)
                            if (request.note != null &&
                                request.note!.isNotEmpty)
                              Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Ghi chú",
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          request.note!,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: Colors.grey.shade800,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget for info rows with icon
  Widget _infoRowWithIcon(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'Pending':
      case 'chờ xác nhận':
        return Colors.orange;
      case 'Confirmed':
      case 'đã xác nhận':
        return Colors.green;
      case 'Completed':
      case 'hoàn thành':
        return Colors.blue;
      case 'Cancelled':
      case 'đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper widget for info cards (2x2 grid)
  Widget _infoCard(
    IconData icon,
    String text, {
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.black54,
    Color textColor = Colors.black87,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
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

  String _formatDate(String scheduleAt) {
    try {
      final dateTime = DateTime.parse(scheduleAt);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      return '$day/$month/$year';
    } catch (e) {
      return '01/01/1970';
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
    return GestureDetector(
      onTap: () => _showUploadPhotoDialog(request),
      child: Container(
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
                  child: ClipOval(
                    child: CloudinaryImage(
                      publicId: request.customerAvatar!,
                      width: 60,
                      height: 60,
                      crop: 'fill',
                      gravity: 'face',
                      quality: 80,
                    ),
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
                        StringUtils.formatVND(
                          (request.price),
                          showSymbol: false,
                        ),
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
