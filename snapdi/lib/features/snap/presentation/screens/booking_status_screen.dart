import 'package:flutter/material.dart';

import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/booking_response.dart';

class BookingStatusScreen extends StatefulWidget {
  final int? bookingId;

  const BookingStatusScreen({super.key, this.bookingId});

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

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _connectSignalR();
    await _loadBooking();
  }

  Future<void> _connectSignalR() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final bookingId = widget.bookingId;
      if (bookingId == null) return;

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            '${Environment.apiBaseUrl}/hubs/booking',
            HttpConnectionOptions(
              accessTokenFactory: () async => token ?? '',
              transport: HttpTransportType.webSockets,
            ),
          )
          .build();

      await _hubConnection!.start();
      debugPrint("✅ Connected to BookingHub");

      // 👉 Join đúng nhóm như backend
      await _hubConnection!.invoke('JoinBookingRoom', args: [bookingId]);
      debugPrint("📡 Joined room: Booking_$bookingId");

      // 👉 Lắng đúng event backend gửi
      _hubConnection?.on('BookingUpdated', (args) {
        if (args == null || args.isEmpty) return;
        try {
          final data = args.first;
          debugPrint("📩 Received BookingUpdated: $data");

          // Parse booking object (tùy backend gửi object gì)
          if (data is Map) {
            final newStatusId = data['status']['statusId'] ?? 0;

            setState(() {
              _currentStep = _mapStatusToStep(newStatusId);
              _booking = BookingData.fromJson(Map<String, dynamic>.from(data));
            });
          }
        } catch (e) {
          debugPrint('❌ Error parsing BookingUpdated: $e');
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
    // We only care about statuses 3..7 (inclusive) and map them to steps 0..4.
    // Backend table (expected):
    // 1 - Pending
    // 2 - Confirmed
    // 3 - Paid
    // 4 - Going
    // 5 - Processing
    // 6 - Done
    // 7 - Completed
    // 8 - Cancelled
    switch (statusId) {
      case 3:
        return 0; // Paid -> first step
      case 4:
        return 1; // Going -> second step
      case 5:
        return 2; // Processing -> third step
      case 6:
        return 3; // Done -> fourth step
      case 7:
        return 4; // Completed -> fifth step
      case 8:
        return -1; // Cancelled -> no steps
      default:
        // For statuses outside 3..7, show 0 or -1 depending on semantics
        return 0;
    }
  }

  String _mapStatusName(int statusId) {
    // Return status display name based on backend id (align with provided table)
    switch (statusId) {
      case 1:
        return 'Pending';
      case 2:
        return 'Confirmed';
      case 3:
        return 'Paid';
      case 4:
        return 'Going';
      case 5:
        return 'Processing';
      case 6:
        return 'Done';
      case 7:
        return 'Completed';
      case 8:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _mapPhotoTypeName(int id) {
    switch (id) {
      case 1:
        return 'Sự kiện';
      case 2:
        return 'Kiến trúc';
      case 3:
        return 'Photobooth';
      case 4:
        return 'Thiên nhiên';
      case 5:
        return 'Chân dung';
      default:
        return 'Không xác định';
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
            children: List.generate(5, (index) {
              final completed = index <= _currentStep;
              final icons = [
                Icons.attach_money,
                Icons.directions_car,
                Icons.settings,
                Icons.book,
                Icons.done_all,
              ];
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: completed
                          ? AppColors.primary
                          : AppColors.greyLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Icon(icons[index], color: Colors.black, size: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (index) {
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
    final isCancelled = statusId == 8;
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
                const SizedBox(height: 8),
                // Photo type and time
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_camera,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _mapPhotoTypeName(_booking?.photoTypeId ?? 0),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_booking?.time ?? '-'} giờ',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
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
    return Container(
      color: const Color(0xFFE8F5F2),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundFound, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Trạng thái đơn hàng',
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _booking == null
                      ? const Center(child: Text('Không tìm thấy đơn đặt lịch'))
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 120, top: 8),
                          children: [
                            _buildSteps(),
                            _buildStatusMessage(),
                            const SizedBox(height: 12),
                            _buildSnapperCard(),
                            const SizedBox(height: 12),
                          ],
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
