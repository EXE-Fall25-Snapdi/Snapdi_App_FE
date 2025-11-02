import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:snapdi/features/snap/data/services/booking_service.dart';
import 'package:snapdi/features/snap/data/models/pending_booking.dart';
import 'package:url_launcher/url_launcher.dart'; // Thêm dependency này vào pubspec.yaml
import '../../payment/data/models/manual_payment_request.dart';
import '../../payment/domain/services/payment_service.dart';
import '../../payment/presentation/screens/ManualPaymentScreen.dart';
import '../../profile/presentation/widgets/cloudinary_image.dart';

class BookingAcceptedScheduleScreen extends StatefulWidget {
  const BookingAcceptedScheduleScreen({super.key});

  @override
  State<BookingAcceptedScheduleScreen> createState() =>
      _BookingAcceptedScheduleScreenState();
}

class _BookingAcceptedScheduleScreenState
    extends State<BookingAcceptedScheduleScreen> {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();
  final ScrollController _scrollController = ScrollController();

  List<PendingBooking> _bookings = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isPaymentLoading = false;
  final int _pageSize = 10;
  final int _acceptedStatusId =
      2; // Adjust based on your status ID for "Confirmed"

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreBookings();
      }
    }
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    final response = await _bookingService.getBookingsByStatus(
      statusId: _acceptedStatusId,
      page: 1,
      pageSize: _pageSize,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null && response.data.isNotEmpty) {
          _bookings = response.data;
          _currentPage = 1;
          _hasMoreData = response.hasNextPage;
        } else {
          _showError('Không thể tải dữ liệu');
        }
      });
    }
  }

  Future<void> _loadMoreBookings() async {
    setState(() => _isLoading = true);

    final response = await _bookingService.getBookingsByStatus(
      statusId: _acceptedStatusId,
      page: _currentPage + 1,
      pageSize: _pageSize,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null && response.data.isNotEmpty) {
          _bookings.addAll(response.data);
          _currentPage++;
          _hasMoreData = response.hasNextPage;
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
    return WillPopScope(
      // Ngăn back gesture khi đang payment loading
      onWillPop: () async => !_isPaymentLoading,
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
                // Header với close button bị disable khi loading
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
                        // DISABLE close button khi đang payment loading
                        icon: Icon(
                          Icons.close,
                          color: _isPaymentLoading ? Colors.grey : Colors.black,
                        ),
                        onPressed: _isPaymentLoading
                            ? null
                            : () => Navigator.pop(context),
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
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking.status.statusName,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Notification for "Done" status
                        if (booking.status.statusId == 6)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chờ Link Ảnh',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Chụp ảnh đã hoàn tất. Vui lòng chờ Photographer gửi link ảnh cho bạn.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.orange.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (booking.status.statusId == 6)
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

                        // Photographer Info
                        Text(
                          'Thông tin Photographer',
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
                                  publicId:
                                      booking.photographer.avatarUrl ?? '',
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
                                      booking.photographer.name ?? 'Không tên',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${booking.photographer.avgRating?.toStringAsFixed(1) ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (booking
                                            .photographer
                                            .levelPhotographer !=
                                        null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          booking
                                              .photographer
                                              .levelPhotographer!,
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

                        // View Profile Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/photographer-profile/${booking.photographer.userId}');
                            },
                            icon: const Icon(Icons.person, size: 18),
                            label: const Text('Xem Hồ Sơ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB584),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
                                    '${_formatPrice(booking.price.toInt())} VNĐ',
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
                                    'Phí đặt cọc (20%):',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '${_formatPrice((booking.price * 0.2).toInt())} VNĐ',
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

                        // PAYMENT SECTION với loading overlay khi processing
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _isPaymentLoading
                                              ? 'Đang xử lý thanh toán...'
                                              : 'Cần thanh toán 20% để hoàn tất booking',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.orange[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isPaymentLoading
                                          ? null
                                          : () =>
                                                _confirmManualPayment(booking),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isPaymentLoading
                                            ? Colors.grey
                                            : const Color(0xFF1DB584),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: _isPaymentLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Đang xử lý...',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Text(
                                              'Xác nhận thanh toán',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Loading overlay
                            if (_isPaymentLoading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
  }

  // NEW: Confirm manual payment và hiện widget tiếp tục thanh toán
  Future<void> _confirmManualPayment(PendingBooking booking) async {
    // Ngăn không cho dismiss modal khi đang loading
    setState(() => _isPaymentLoading = true);

    try {
      // 1) Gọi confirm-manual-payment để tạo payment
      final paymentId = await _paymentService.confirmManualPayment(
        ManualPaymentRequest(bookingId: booking.bookingId, feePolicyId: 1),
      );

      if (!mounted) return;

      // 2) Đóng bottom sheet hiện tại CHỈ KHI THÀNH CÔNG
      Navigator.pop(context);

      // 3) Hiện widget tiếp tục thanh toán (không cho quay lại)
      _showContinuePaymentSheet(booking, paymentId);
    } catch (e) {
      if (!mounted) return;
      // CHỈ KHI CÓ LỖI mới cho phép tương tác lại
      setState(() => _isPaymentLoading = false);
      _showError('Không thể khởi tạo thanh toán: $e');
    }
    // Không reset _isPaymentLoading ở đây vì đã chuyển sang modal mới
  }

  // NEW: Widget tiếp tục thanh toán (giống ManualPaymentScreen)
  void _showContinuePaymentSheet(PendingBooking booking, int paymentId) {
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      // KHÔNG CHO DISMISS bằng cách tap outside
      isDismissible: false,
      // KHÔNG CHO ENABLE drag to dismiss
      enableDrag: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return WillPopScope(
            // NGĂN back gesture
            onWillPop: () async => !isProcessing,
            child: DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.6,
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
                      // Handle bar (ẩn khi processing)
                      if (!isProcessing)
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      // Header với close button disable khi processing
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isProcessing
                                  ? 'Đang xử lý thanh toán...'
                                  : 'Tiếp tục thanh toán',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isProcessing
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                              onPressed: isProcessing
                                  ? null
                                  : () => Navigator.pop(context),
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
                            children: [
                              // Amount display
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1DB584,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 48,
                                      color: const Color(0xFF1DB584),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Số tiền cần thanh toán',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_formatPrice((booking.price * 0.2).toInt())} VNĐ',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1DB584),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Payment methods (disable khi processing)
                              Opacity(
                                opacity: isProcessing ? 0.5 : 1.0,
                                child: AbsorbPointer(
                                  absorbing: isProcessing,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chọn phương thức thanh toán',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // PayOS option
                                        InkWell(
                                          onTap: () {
                                            setModalState(
                                              () => isProcessing = true,
                                            );
                                            _processPayOSPayment(booking).then((
                                              _,
                                            ) {
                                              setModalState(
                                                () => isProcessing = false,
                                              );
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.blue[200]!,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.credit_card,
                                                  color: Colors.blue[700],
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'PayOS (Khuyến nghị)',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.blue[700],
                                                        ),
                                                      ),
                                                      Text(
                                                        'Thanh toán trực tuyến qua PayOS',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.blue[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.blue[700],
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        // Manual transfer option
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(
                                              context,
                                            ); // Đóng modal này
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ManualPaymentScreen(
                                                      bookingId:
                                                          booking.bookingId,
                                                      amount: booking
                                                          .photoType
                                                          .photoPrice,
                                                      paymentId: paymentId,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.qr_code_2,
                                                  color: Colors.grey[700],
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Chuyển khoản thủ công',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      Text(
                                                        'Quét QR code hoặc chuyển khoản ngân hàng',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.grey[700],
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // // Fee Policy Agreement (disable khi processing)
                              // Opacity(
                              //   opacity: isProcessing ? 0.5 : 1.0,
                              //   child: AbsorbPointer(
                              //     absorbing: isProcessing,
                              //     child: CheckboxListTile(
                              //       value: agreeFeePolicy,
                              //       onChanged: (v) => setModalState(() => agreeFeePolicy = v ?? false),
                              //       controlAffinity: ListTileControlAffinity.leading,
                              //       contentPadding: EdgeInsets.zero,
                              //       title: const Text('Tôi đồng ý với chính sách người dùng'),
                              //       subtitle: InkWell(
                              //         onTap: () => _showFeePolicyDialog(),
                              //         child: const Text(
                              //           'Xem chi tiết chính sách',
                              //           style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              // Processing indicator
                              if (isProcessing) ...[
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(
                                      color: Color(0xFF1DB584),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      'Đang xử lý thanh toán...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1DB584),
                                      ),
                                    ),
                                  ],
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
            ),
          );
        },
      ),
    );
  }

  // NEW: Process PayOS payment (chạy trên web)
  Future<void> _processPayOSPayment(PendingBooking booking) async {
    try {
      print('🚀 Starting PayOS payment for booking: ${booking.bookingId}');

      // 1) Tạo PayOS payment URL
      final payosUrl = await _paymentService.createPayOSPayment(
        bookingId: booking.bookingId,
      );

      print('✅ PayOS URL received: $payosUrl');

      // 2) Validate URL
      if (payosUrl.isEmpty) {
        throw Exception('PayOS URL is empty');
      }

      // 3) Parse URI
      final uri = Uri.tryParse(payosUrl);
      if (uri == null) {
        throw Exception('Invalid PayOS URL format: $payosUrl');
      }

      print('🔗 Parsed URI: ${uri.toString()}');

      // 4) Thử các launch mode khác nhau
      bool launched = false;

      // Option 1: External Application (Browser)
      try {
        print('🚀 Trying LaunchMode.externalApplication...');
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ External browser launch: $launched');
      } catch (e) {
        print('❌ External browser failed: $e');
      }

      // Option 2: Platform Default
      if (!launched) {
        try {
          print('🚀 Trying LaunchMode.platformDefault...');
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
          print('✅ Platform default launch: $launched');
        } catch (e) {
          print('❌ Platform default failed: $e');
        }
      }

      // Option 3: In-App WebView
      if (!launched) {
        try {
          print('🚀 Trying LaunchMode.inAppWebView...');
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
          print('✅ In-app webview launch: $launched');
        } catch (e) {
          print('❌ In-app webview failed: $e');
        }
      }

      // Option 4: Legacy launchUrl (deprecated nhưng có thể work)
      if (!launched) {
        try {
          print('🚀 Trying legacy launch...');
          // ignore: deprecated_member_use
          launched = await launch(payosUrl);
          print('✅ Legacy launch: $launched');
        } catch (e) {
          print('❌ Legacy launch failed: $e');
        }
      }

      if (launched) {
        print('✅ PayOS URL launched successfully');

        // Đóng modal sau khi launch thành công
        if (mounted) {
          Navigator.pop(context);
          print('✅ Modal closed');
        }

        // Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.open_in_browser, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đã mở trang thanh toán PayOS. Vui lòng hoàn tất thanh toán.',
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1DB584),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        // Fallback: Copy URL to clipboard
        await _fallbackCopyToClipboard(payosUrl);
      }
    } catch (e) {
      print('❌ Error in _processPayOSPayment: $e');
      if (mounted) {
        _showError('Lỗi tạo thanh toán PayOS: $e');
      }
      rethrow;
    }
  }

  // Fallback: Copy to clipboard nếu không mở được browser
  Future<void> _fallbackCopyToClipboard(String payosUrl) async {
    try {
      await Clipboard.setData(ClipboardData(text: payosUrl));

      if (mounted) {
        Navigator.pop(context); // Đóng modal

        // Show dialog với option copy URL
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Không thể mở tự động'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Link thanh toán PayOS đã được sao chép vào clipboard.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payosUrl,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Vui lòng mở trình duyệt và dán link để thanh toán.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Thử mở lại
                  final uri = Uri.parse(payosUrl);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    print('❌ Retry launch failed: $e');
                  }
                },
                child: Text('Thử lại'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Clipboard fallback failed: $e');
      _showError('Không thể mở link thanh toán. Vui lòng thử lại sau.');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D5F47),
              const Color(0xFF1DB584),
              const Color(0xFF4CD9B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildSectionTitle(),
              const SizedBox(height: 24),
              Expanded(
                child: _bookings.isEmpty && !_isLoading
                    ? _buildEmptyState()
                    : _buildBookingList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Lịch hẹn của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đã Chấp Nhận',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photographer đã chấp nhận đơn của bạn.\nHãy thanh toán chi phí để bắt đầu snap nhé!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _bookings.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _bookings.length) {
            return _buildLoadingIndicator();
          }
          return _buildBookingCard(_bookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(PendingBooking booking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _showBookingDetails(booking),
        child: Container(
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
                  color: const Color(0xFF1DB584),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on, color: Colors.white, size: 28),
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
                    Text(
                      booking.scheduleAt.isNotEmpty
                          ? _formatDateTime(booking.scheduleAt)
                          : 'Chưa có lịch',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Payment icon badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB584),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.attach_money, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Không có đơn đặt chỗ nào',
        style: TextStyle(color: Colors.white, fontSize: 16),
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
}
