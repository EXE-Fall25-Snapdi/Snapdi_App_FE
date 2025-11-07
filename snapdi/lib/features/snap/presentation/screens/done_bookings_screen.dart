import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/pending_booking.dart';
import '../../../profile/presentation/widgets/cloudinary_image.dart';
import '../../../chat/data/services/chat_api_service.dart';
import 'package:snapdi/core/constants/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snapdi/core/constants/app_theme.dart';

class DoneBookingsScreen extends StatefulWidget {
  const DoneBookingsScreen({super.key});

  @override
  State<DoneBookingsScreen> createState() => _DoneBookingsScreenState();
}

class _DoneBookingsScreenState extends State<DoneBookingsScreen> {
  final BookingService _bookingService = BookingService();
  final ChatApiServiceImpl _chatApiService = ChatApiServiceImpl();
  final TextEditingController _photoLinkController = TextEditingController();

  List<PendingBooking> _doneBookings = [];
  bool _isLoading = true;
  String? _photoLinkError;
  bool _isPhotoLinkInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadDoneBookings();
  }

  @override
  void dispose() {
    _photoLinkController.dispose();
    super.dispose();
  }

  Future<void> _loadDoneBookings() async {
    setState(() => _isLoading = true);

    try {
      final response = await _bookingService.getBookingsByMultipleStatuses(
        statusIds: [6], // Only done status
        page: 1,
        pageSize: 50,
      );

      if (mounted) {
        setState(() {
          if (response != null && response.data.isNotEmpty) {
            _doneBookings = response.data;
          } else {
            _doneBookings = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
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
        await _loadDoneBookings();
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
    // Reset the initialization flag when opening a new modal
    _isPhotoLinkInitialized = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => _buildBookingDetailSheet(booking),
    ).then((_) {
      // Reset flag when modal closes
      _isPhotoLinkInitialized = false;
    });
  }

  Widget _buildBookingDetailSheet(PendingBooking booking) {
    // Only set the initial text once per modal open
    if (!_isPhotoLinkInitialized) {
      _photoLinkController.text = booking.photoLink ?? '';
      _isPhotoLinkInitialized = true;
      _photoLinkError = null;
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        // Get keyboard height
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: DraggableScrollableSheet(
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
                        children: [
                          Text(
                            'Chi tiết đơn đã hoàn thành',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.grey.shade600),
                            onPressed: () => Navigator.of(context).pop(),
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
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade700.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.teal.shade700.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.doneIcon,
                                    color: Colors.teal.shade700,
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking.status.statusName,
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.only(top: 4),
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
                                    AppAssets.messageIcon,
                                    () => _openChatWithCustomer(booking),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    AppAssets.phoneIcon,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                            // Photo link section
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
                            if (booking.note != null && booking.note!.isNotEmpty) ...[
                              Text(
                                'Ghi chú',
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
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.note, color: Colors.amber.shade700, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        booking.note!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // View Booking Status Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context.push('/booking/${booking.bookingId}/status');
                                },
                                icon: Icon(Icons.timeline, size: 18),
                                label: Text('Xem trạng thái đơn'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1DB584),
                                  side: BorderSide(color: const Color(0xFF1DB584)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
          ),
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

  Widget _buildActionButton(String icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.grayField,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
          ),
        ),
      ),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Đơn cần gửi ảnh',
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
                  : _doneBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 64, color: Colors.white70),
                              const SizedBox(height: 16),
                              Text(
                                'Không có đơn cần gửi ảnh',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDoneBookings,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _doneBookings.length,
                            itemBuilder: (context, index) {
                              return _buildBookingCard(_doneBookings[index]);
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
    final bool needsPhotoLink = !hasPhotoLink;

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
                          color: Colors.teal.shade600,
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
