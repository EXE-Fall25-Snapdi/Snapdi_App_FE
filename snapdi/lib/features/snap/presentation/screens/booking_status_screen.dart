import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:signalr_core/signalr_core.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/booking_response.dart';

class BookingStatusScreen extends StatefulWidget {
  final int bookingId;
  final String initialStatus; // 'Paid' or 'Cancelled'

  const BookingStatusScreen({
    super.key,
    required this.bookingId,
    required this.initialStatus,
  });

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  final BookingService _bookingService = BookingService();
  final TokenStorage _tokenStorage = TokenStorage.instance;
  HubConnection? _hubConnection;

  bool _isLoading = true;
  BookingData? _booking;
  int _currentStep = 0;
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _initPage();
  }

  Future<void> _initPage() async {
    await _connectSignalR();
    await _loadBooking();
  }

  Future<void> _connectSignalR() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final userId = await _tokenStorage.getUserId();

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            '${Environment.apiBaseUrl}/hubs/booking',
            HttpConnectionOptions(
              accessTokenFactory: () async => token ?? '',
              transport: HttpTransportType.webSockets,
            ),
          )
          .build();

      if (_hubConnection != null) {
        await _hubConnection!.start();
        debugPrint("✅ Connected to BookingHub");
      }
      debugPrint("✅ Connected to BookingHub");

      // Join the user's group (e.g. "customer-5")
      if (_hubConnection != null) {
        await _hubConnection!.invoke('JoinCustomerGroup', args: [userId]);
        debugPrint("📡 Joined group: customer-$userId");
      }

      // Listen for booking status updates
      _hubConnection?.on('bookingStatusUpdated', (args) {
        if (args == null || args.isEmpty) return;
        try {
          final data = args.first as Map<String, dynamic>;
          final bookingId = data['bookingId'];
          final statusId = data['statusId'];

          if (bookingId == widget.bookingId) {
            setState(() {
              _currentStep = _mapStatusToStep(statusId);
              if (_booking != null) {
                _booking = BookingData(
                  bookingId: _booking!.bookingId,
                  customer: _booking!.customer,
                  photographer: _booking!.photographer,
                  scheduleAt: _booking!.scheduleAt,
                  locationAddress: _booking!.locationAddress,
                  status: BookingStatus(
                    statusId: statusId,
                    statusName: _mapStatusName(statusId),
                  ),
                  price: _booking!.price,
                  note: _booking!.note,
                );
              }
            });
          }
        } catch (e) {
          debugPrint('Error parsing SignalR args: $e');
        }
      });
    } catch (e) {
      debugPrint("❌ SignalR connection error: $e");
    }
  }

  Future<void> _loadBooking() async {
    if (widget.bookingId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await _bookingService.getBookingById(widget.bookingId!);
    if (response.success && response.data != null) {
      setState(() {
        _booking = response.data;
        _currentStep = _mapStatusToStep(_booking!.status.statusId);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  int _mapStatusToStep(int statusId) {
    // Map backend status IDs to the step index in the UI.
    // Status mapping (from backend):
    // 1 - Pending
    // 2 - Processing
    // 3 - Confirmed
    // 4 - Completed
    // 5 - Cancelled
    switch (statusId) {
      case 2:
        return 1; // Processing -> step 1
      case 3:
        return 2; // Confirmed -> step 2
      case 4:
        return 3; // Completed -> step 3
      case 5:
        return -1; // Cancelled -> no steps completed
      case 1:
      default:
        return 0; // Pending -> step 0
    }
  }

  String _mapStatusName(int statusId) {
    // Return status display name based on backend id (align with provided table)
    switch (statusId) {
      case 1:
        return 'Pending';
      case 2:
        return 'Processing';
      case 3:
        return 'Confirmed';
      case 4:
        return 'Completed';
      case 5:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildSteps() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final completed = index <= _currentStep;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: index == 2 ? 56 : 44,
                    height: index == 2 ? 56 : 44,
                    decoration: BoxDecoration(
                      color: completed
                          ? AppColors.primary
                          : AppColors.greyLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        index == 0
                            ? Icons.book
                            : (index == 1
                                  ? Icons.check
                                  : (index == 2
                                        ? Icons.camera_alt
                                        : Icons.done_all)),
                        color: Colors.black,
                        size: index == 2 ? 28 : 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              final leftCompleted = index <= (_currentStep - 1);
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: leftCompleted
                        ? AppColors.primary
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    final statusText =
        _booking?.status.statusName ?? 'Khách hàng đang chuẩn bị...';
    final statusId = _booking?.status.statusId ?? 0;
    final isCancelled = statusId == 5;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFFEBEE) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.info_outline,
            color: isCancelled ? Colors.red : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isCancelled ? Colors.red.shade700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapperCard() {
    final photographer = _booking?.photographer;
    final name = photographer?.name ?? 'Snapper';
    final phone = photographer?.phone ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              AppAssets.userPlaceholder,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // If the asset is missing, fall back to a simple colored circle with icon
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            // 👈 bọc phần thông tin trong Expanded để co giãn
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headline4.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis, // 👈 tránh text quá dài
                ),
                const SizedBox(height: 6),
                Text(phone, style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) =>
                          Icon(Icons.star, size: 14, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text('5.0', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _buildActionButton(Icons.send, () {
                // TODO: open chat
              }),
              const SizedBox(height: 8),
              _buildActionButton(Icons.call, () async {
                if (phone.isNotEmpty) {
                  await launchUrl(Uri.parse('tel:$phone'));
                }
              }),
            ],
          ),
        ],
      ),
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

  @override
  void dispose() {
    _hubConnection?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _status == 'Paid';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trạng thái đặt chỗ'),
        backgroundColor: isPaid ? Colors.green : Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPaid ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: isPaid ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isPaid ? 'Thanh toán thành công' : 'Đơn đặt chỗ đã hủy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking ID: ${widget.bookingId}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
