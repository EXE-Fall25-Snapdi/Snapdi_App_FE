import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/pending_booking.dart';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import '../../../chat/data/services/chat_api_service.dart';

class CompletedBookingsScreen extends StatefulWidget {
  const CompletedBookingsScreen({super.key});

  @override
  State<CompletedBookingsScreen> createState() =>
      _CompletedBookingsScreenState();
}

class _CompletedBookingsScreenState extends State<CompletedBookingsScreen> {
  final BookingService _bookingService = BookingService();
  final ChatApiServiceImpl _chatApiService = ChatApiServiceImpl();
  final TextEditingController _photoLinkController = TextEditingController();

  List<PendingBooking> _completedBookings = [];
  bool _isLoading = true;
  String? _photoLinkError;

  @override
  void initState() {
    super.initState();
    _loadCompletedBookings();
  }

  @override
  void dispose() {
    _photoLinkController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedBookings() async {
    setState(() => _isLoading = true);

    try {
      final response = await _bookingService.getBookingsByMultipleStatuses(
        statusIds: [7], // Only completed status
        page: 1,
        pageSize: 50,
      );

      if (mounted) {
        setState(() {
          if (response != null && response.data.isNotEmpty) {
            _completedBookings = response.data;
          } else {
            _completedBookings = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading completed bookings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Open chat with the customer
  Future<void> _openChatWithCustomer(PendingBooking booking) async {
    final result = await _chatApiService.createOrGetConversationWithUser(
      booking.user.userId,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở chat: ${failure.message}')),
          );
        }
      },
      (conversationId) {
        if (mounted) {
          context.push('/chat/$conversationId', extra: booking.user.name);
        }
      },
    );
  }

  /// Call the customer
  Future<void> _callCustomer(String? phone) async {
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có số điện thoại')),
        );
      }
      return;
    }

    try {
      await launchUrl(Uri.parse('tel:$phone'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gọi: ${e.toString()}')),
        );
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

    // Close the detail modal
    Navigator.of(context, rootNavigator: true).pop();

    // Small delay
    await Future.delayed(Duration(milliseconds: 300));

    if (!mounted) return;

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
        _photoLinkController.clear();
        await _loadCompletedBookings();
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
    _photoLinkController.text = booking.photoLink ?? '';
    _photoLinkError = null;

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
                          // Status Badge - Completed
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.purple.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.status.statusName,
                                  style: TextStyle(
                                    color: Colors.purple.shade700,
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
                          const SizedBox(height: 16),

                          // Action Buttons - Chat and Call
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  Icons.send,
                                  () => _openChatWithCustomer(booking),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  Icons.call,
                                  () => _callCustomer(booking.user.phone),
                                ),
                              ),
                            ],
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

                          // Photo Link Edit Section
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
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      color: Colors.purple.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        booking.photoLink != null &&
                                                booking.photoLink!.isNotEmpty
                                            ? 'Chỉnh sửa link album'
                                            : 'Thêm link album',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _photoLinkController,
                                  onChanged: (value) {
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
                                            : Colors.purple.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: _photoLinkError != null
                                            ? Colors.red
                                            : Colors.purple.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: _photoLinkError != null
                                            ? Colors.red
                                            : Colors.purple.shade700,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.red),
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
                                          : Colors.purple.shade700,
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
                                    icon: Icon(Icons.save, size: 18),
                                    label: Text('Lưu link'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

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
                          ],
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

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFB8D4CF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(icon: Icon(icon, size: 18), onPressed: onPressed),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1DB584),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Đơn hoàn thành',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _completedBookings.isEmpty
                  ? Center(
                      child: Text(
                        'Không có đơn hoàn thành nào',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCompletedBookings,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _completedBookings.length,
                        itemBuilder: (context, index) {
                          return _buildBookingCard(_completedBookings[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(PendingBooking booking) {
    final bool hasPhotoLink =
        booking.photoLink != null && booking.photoLink!.isNotEmpty;

    return GestureDetector(
      onTap: () => _showBookingDetails(booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.locationAddress.isNotEmpty
                        ? booking.locationAddress
                        : 'Không có địa chỉ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        booking.scheduleAt.isNotEmpty
                            ? _formatDateTime(booking.scheduleAt)
                            : 'Chưa có lịch',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (!hasPhotoLink) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber,
                                size: 12,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Chưa có link',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final bookingDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (bookingDate == today) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}, hôm nay';
      } else {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}, ${dateTime.day}/${dateTime.month}';
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}