import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/providers/user_info_provider.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/pending_booking.dart';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import 'booking_requests_screen.dart';

/// Photographer's Snap screen showing booking requests and upcoming sessions
class PhotographerSnapScreen extends StatefulWidget {
  const PhotographerSnapScreen({super.key});

  @override
  State<PhotographerSnapScreen> createState() => _PhotographerSnapScreenState();
}

class _PhotographerSnapScreenState extends State<PhotographerSnapScreen> {
  final UserInfoProvider _userInfoProvider = UserInfoProvider.instance;
  late final BookingService _bookingService;
  final TextEditingController _photoLinkController = TextEditingController();

  String _userName = 'Amigo';
  int _pendingRequestsCount = 0;
  List<PendingBooking> _upcomingBookings = [];
  bool _isLoading = true;
  String? _photoLinkError;

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService();
    _loadData();
  }

  @override
  void dispose() {
    _photoLinkController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Get user name
      final userName = await _userInfoProvider.getUserName();
      if (userName != null && mounted) {
        setState(() => _userName = userName.split(' ').first);
      }

      // Fetch bookings with multiple statuses
      final bookingsResponse = await _bookingService
          .getBookingsByMultipleStatuses(
            statusIds: [1, 2, 3, 4, 5, 6],
            page: 1,
            pageSize: 20,
          );

      if (!mounted) return;

      if (bookingsResponse != null && bookingsResponse.data.isNotEmpty) {
        setState(() {
          // Count pending requests (status ID 1) for notification
          _pendingRequestsCount = bookingsResponse.data
              .where((booking) => booking.status.statusId == 1)
              .length;

          // Filter out status 1 bookings from display list
          _upcomingBookings = bookingsResponse.data
              .where((booking) => booking.status.statusId != 1)
              .toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _upcomingBookings = [];
          _pendingRequestsCount = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePhotoLink(
    int bookingId,
    StateSetter setModalState,
  ) async {
    final link = _photoLinkController.text.trim();

    // Validate empty
    if (link.isEmpty) {
      setModalState(() {
        _photoLinkError = 'Vui lòng nhập link ảnh';
      });
      return;
    }

    // Validate URL format
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasAbsolutePath || !uri.hasScheme) {
      setModalState(() {
        _photoLinkError = 'Link không hợp lệ. Vui lòng nhập URL đầy đủ';
      });
      return;
    }

    // Clear error
    setModalState(() {
      _photoLinkError = null;
    });

    // Close the detail modal using root navigator
    Navigator.of(context, rootNavigator: true).pop();

    // Small delay to ensure modal is closed
    await Future.delayed(Duration(milliseconds: 300));

    // Check if still mounted before proceeding
    if (!mounted) return;

    // Show loading
    setState(() => _isLoading = true);

    try {
      final response = await _bookingService.updatePhotoLink(bookingId, link);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật link ảnh thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        // Reload data to update the list
        _photoLinkController.clear();
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Không thể cập nhật link ảnh'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBookingDetails(PendingBooking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => _buildBookingDetailSheet(booking),
    );
  }

  Widget _buildBookingDetailSheet(PendingBooking booking) {
    final bool isDone = booking.status.statusId == 6;
    _photoLinkController.text = booking.photoLink ?? '';
    _photoLinkError = null; // Reset error when opening

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chi tiết đặt chỗ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusBadgeColor(
                                booking.status.statusId,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusBadgeColor(
                                  booking.status.statusId,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(booking.status.statusId),
                                  color: _getStatusBadgeColor(
                                    booking.status.statusId,
                                  ),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.status.statusName,
                                  style: TextStyle(
                                    color: _getStatusBadgeColor(
                                      booking.status.statusId,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Booking ID
                          _buildDetailRow(
                            icon: Icons.confirmation_number,
                            label: 'Mã đặt chỗ',
                            value: '#${booking.bookingId}',
                          ),
                          const SizedBox(height: 16),

                          // Location
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'Địa điểm',
                            value: booking.locationAddress.isNotEmpty
                                ? booking.locationAddress
                                : 'Không có địa chỉ',
                          ),
                          const SizedBox(height: 16),

                          // Schedule
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: 'Thời gian',
                            value: booking.scheduleAt.isNotEmpty
                                ? _formatFullDateTime(booking.scheduleAt)
                                : 'Chưa có lịch',
                          ),
                          const SizedBox(height: 16),

                          // Customer Info
                          Text(
                            'Thông tin khách hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: CloudinaryImage(
                                    publicId: booking.user.avatarUrl ?? '',
                                    width: 60,
                                    height: 60,
                                    crop: 'fill',
                                    gravity: 'face',
                                    quality: 80,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.user.name ?? 'Không tên',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (booking.user.email != null &&
                                          booking.user.email!.isNotEmpty)
                                        Text(
                                          booking.user.email!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      if (booking.user.phone != null &&
                                          booking.user.phone!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            booking.user.phone!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Photo Type Details
                          Text(
                            'Chi tiết gói chụp',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DB584).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF1DB584).withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tên gói:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      booking.photoType.photoTypeName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Giá gói:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '${_formatPrice(booking.photoType.photoPrice.toInt())} VNĐ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1DB584),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Thời gian:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '${booking.photoType.time} giờ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Photo Link Input (only show if status is Done - ID 6)
                          if (isDone) ...[
                            Text(
                              'Link ảnh',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.teal.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.photo_library,
                                        color: Colors.teal.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          booking.photoLink != null &&
                                                  booking.photoLink!.isNotEmpty
                                              ? 'Cập nhật link album'
                                              : 'Thêm link album cho khách hàng',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.teal.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _photoLinkController,
                                    onChanged: (value) {
                                      // Clear error when user types
                                      if (_photoLinkError != null) {
                                        setModalState(() {
                                          _photoLinkError = null;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText:
                                          'Nhập link Google Drive, Dropbox...',
                                      filled: true,
                                      fillColor: Colors.white,
                                      errorText: _photoLinkError,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: _photoLinkError != null
                                              ? Colors.red
                                              : Colors.teal.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: _photoLinkError != null
                                              ? Colors.red
                                              : Colors.teal.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: _photoLinkError != null
                                              ? Colors.red
                                              : Colors.teal.shade700,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.link,
                                        color: _photoLinkError != null
                                            ? Colors.red
                                            : Colors.teal.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _updatePhotoLink(
                                        booking.bookingId,
                                        setModalState,
                                      ),
                                      icon: Icon(Icons.upload, size: 18),
                                      label: Text('Lưu link'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Note
                          if (booking.note != null &&
                              booking.note!.isNotEmpty) ...[
                            Text(
                              'Ghi chú',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                booking.note!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // View Booking Status Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Close the modal
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                // Navigate to booking status screen
                                context.push(
                                  '/booking/${booking.bookingId}/status',
                                );
                              },
                              icon: Icon(Icons.track_changes, size: 20),
                              label: Text('Xem trạng thái đơn hàng'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1DB584),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB584).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1DB584), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(String scheduleAt) {
    try {
      final dateTime = DateTime.parse(scheduleAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));
      final bookingDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      if (bookingDate == today) {
        return '$hour:$minute, hôm nay';
      } else if (bookingDate == tomorrow) {
        return '$hour:$minute, ngày mai';
      } else {
        return '$hour:$minute, ${dateTime.day}/${dateTime.month}';
      }
    } catch (e) {
      return '12:00, hôm nay';
    }
  }

  String _formatFullDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}, ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 2: // Accepted
        return Colors.green;
      case 3: // Paid
        return Colors.orange;
      case 4: // Going
        return Colors.blue;
      case 5: // Processing
        return Colors.purple;
      case 6: // Done
        return Colors.teal;
      case 7: // Completed
        return Colors.purple.shade600;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBadgeColor(int statusId) {
    switch (statusId) {
      case 2: // Accepted
        return Colors.green.shade700;
      case 3: // Paid
        return Colors.orange.shade700;
      case 4: // Going
        return Colors.blue.shade700;
      case 5: // Processing
        return Colors.purple.shade700;
      case 6: // Done
        return Colors.teal.shade700;
      case 7: // Completed
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(int statusId) {
    switch (statusId) {
      case 2: // Accepted
        return Icons.check_circle_outline;
      case 3: // Paid
        return Icons.payment;
      case 4: // Going
        return Icons.directions_car;
      case 5: // Processing
        return Icons.camera_alt;
      case 6: // Done
        return Icons.check_circle;
      case 7: // Completed
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
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
                // Header Section
                _buildHeader(),

                // Greeting section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.headline2.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Hola, ',
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
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                if (_upcomingBookings.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Text(
                                        'Không có lịch chụp nào',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                      ),
                                    ),
                                  )
                                else
                                  ..._upcomingBookings
                                      .map(
                                        (booking) => _buildBookingCard(booking),
                                      )
                                      .toList(),

                                const SizedBox(height: 100),
                              ],
                            ),
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
              onPressed: () => context.go('/photographer-welcome'),
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
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingRequestsScreen(),
          ),
        );

        // Reload data when returning from booking requests screen
        if (result == true || result == null) {
          _loadData();
        }
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
                    _pendingRequestsCount > 0
                        ? 'Bạn có $_pendingRequestsCount yêu cầu chụp đang chờ....'
                        : 'Không có yêu cầu chụp nào',
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

  Widget _buildBookingCard(PendingBooking booking) {
    final bool isDone = booking.status.statusId == 6;
    final bool needsPhotoLink =
        isDone && (booking.photoLink == null || booking.photoLink!.isEmpty);

    return GestureDetector(
      onTap: () => _showBookingDetails(booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4EBE6),
          borderRadius: BorderRadius.circular(30),
          border: needsPhotoLink
              ? Border.all(color: Colors.teal.shade400, width: 2)
              : null,
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
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AppAssets.whiteLocationIcon,
                      width: 42,
                      height: 42,
                    ),
                  ),
                  if (needsPhotoLink)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade700,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.upload,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatTime(booking.scheduleAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status.statusId),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          booking.status.statusName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (needsPhotoLink) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.upload_file,
                          size: 14,
                          color: Colors.teal.shade700,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
