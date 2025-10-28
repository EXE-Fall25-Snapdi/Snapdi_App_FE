import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

      await _hubConnection?.start();
      debugPrint("✅ Connected to BookingHub");

      await _hubConnection?.invoke('JoinCustomerGroup', args: [userId]);
      debugPrint("📡 Joined group: customer-$userId");

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
                _booking = _booking!.copyWithStatus(
                  statusId: statusId,
                  statusName: _mapStatusName(statusId),
                );
              }
            });
          }
        } catch (e) {
          debugPrint('❌ Error parsing SignalR args: $e');
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
    switch (statusId) {
      case 2:
        return 1; // Confirmed
      case 3:
        return 2; // Paid
      case 4:
        return 3; // Completed
      case 5:
        return -1; // Cancelled
      case 1:
      default:
        return 0; // Pending
    }
  }

  String _mapStatusName(int statusId) {
    switch (statusId) {
      case 1:
        return 'Pending';
      case 2:
        return 'Confirmed';
      case 3:
        return 'Paid';
      case 4:
        return 'Completed';
      case 5:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildSteps() {
    const stepIcons = [
      'assets/icons/status_1.svg',
      'assets/icons/status_2.svg',
      'assets/icons/status_3.svg',
      'assets/icons/status_4.svg',
    ];

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
          // 4 vòng tròn status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final completed = index <= _currentStep && _currentStep >= 0;
              final color = completed ? AppColors.primary : AppColors.greyLight;

              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        stepIcons[index],
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          // 3 thanh nối giữa các bước
          Row(
            children: List.generate(3, (index) {
              final active = index < _currentStep && _currentStep > 0;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.greyLight,
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
    final status = _booking?.status;
    final statusId = status?.statusId ?? 0;
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
              status?.statusName ?? 'Đang xử lý...',
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
    final name = photographer?.name ?? 'Photographer';
    final phone = photographer?.phone ?? '';
    final avatar = photographer?.avatarUrl;

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
            child: SizedBox(
              width: 64,
              height: 64,
              child: avatar != null && avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackAvatar(),
                    )
                  : _fallbackAvatar(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headline4.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(phone, style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ..._buildRatingStars(photographer?.avgRating ?? 0),
                    const SizedBox(width: 8),
                    Text(
                      (photographer?.avgRating != null)
                          ? photographer!.avgRating!.toStringAsFixed(1)
                          : '-',
                      style: AppTextStyles.bodySmall,
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

  Widget _fallbackAvatar() {
    return Container(
      color: AppColors.primaryLight,
      child: const Icon(Icons.person, color: Colors.white),
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

  List<Widget> _buildRatingStars(double rating) {
    final stars = <Widget>[];
    double remaining = rating;
    for (int i = 0; i < 5; i++) {
      if (remaining >= 1) {
        stars.add(const Icon(Icons.star, size: 14, color: AppColors.primary));
      } else if (remaining >= 0.5) {
        stars.add(
          const Icon(Icons.star_half, size: 14, color: AppColors.primary),
        );
      } else {
        stars.add(
          const Icon(Icons.star_border, size: 14, color: AppColors.primary),
        );
      }
      remaining -= 1;
    }
    return stars;
  }

  @override
  void dispose() {
    _hubConnection?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F2),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundFound, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _booking == null
                      ? const Center(child: Text('Không tìm thấy đơn đặt lịch'))
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
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

extension on BookingData {
  BookingData copyWithStatus({
    required int statusId,
    required String statusName,
  }) {
    return BookingData(
      bookingId: bookingId,
      customer: customer,
      photographer: photographer,
      scheduleAt: scheduleAt,
      locationAddress: locationAddress,
      status: BookingStatus(statusId: statusId, statusName: statusName),
      price: price,
      note: note,
      photoTypeId: photoTypeId,
      time: time,
    );
  }
}
