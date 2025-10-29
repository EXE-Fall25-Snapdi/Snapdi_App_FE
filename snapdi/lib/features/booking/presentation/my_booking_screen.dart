import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_theme.dart';
import 'package:snapdi/features/snap/data/services/booking_service.dart';
import 'package:snapdi/features/snap/data/models/booking_list_response.dart';
import 'package:snapdi/features/snap/data/models/booking_response.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  final BookingService _bookingService = BookingService();
  BookingListResponse? _list;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 3; // show 3 items per page as requested

  @override
  void initState() {
    super.initState();
    _loadBookings(page: 1);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadBookings({required int page}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _hasMore = true;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final resp = await _bookingService.getMyBookings(
      page: page,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (resp == null) {
      // on error, stop loading indicators
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    setState(() {
      if (page == 1) {
        _list = resp;
      } else {
        // append items to existing list
        final existing = _list?.items ?? [];
        final combined = List<BookingData>.from(existing)..addAll(resp.items);
        _list = BookingListResponse(
          items: combined,
          currentPage: resp.currentPage,
          pageSize: resp.pageSize,
          totalItems: resp.totalItems,
          totalPages: resp.totalPages,
          hasPreviousPage: resp.hasPreviousPage,
          hasNextPage: resp.hasNextPage,
        );
      }

      _isLoading = false;
      _isLoadingMore = false;
      _currentPage = resp.currentPage;
      _hasMore = resp.hasNextPage || (_currentPage < resp.totalPages);
    });

    //  Tự động load trang kế tiếp nếu danh sách quá ngắn (chưa thể cuộn)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent <= 0 &&
            _hasMore) {
          debugPrint(' Danh sách quá ngắn, tự load trang ${_currentPage + 1}');
          _loadBookings(page: _currentPage + 1);
        }
      } catch (e) {
        debugPrint(' Lỗi khi auto-load trang tiếp theo: $e');
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final threshold = 200.0; // pixels from bottom to trigger load
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= threshold) {
      // load next page
      final nextPage = _currentPage + 1;
      if (_hasMore) {
        _loadBookings(page: nextPage);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCard(BookingData data) {
    final date = DateTime.tryParse(data.scheduleAt);
    final timeText = date != null
        ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}, ${date.day}/${date.month}/${date.year}'
        : data.scheduleAt;

    return GestureDetector(
      onTap: () => context.go('/booking/${data.bookingId}/status'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.locationAddress,
                    style: AppTextStyles.headline4.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(timeText, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                data.status.statusName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundGradient, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Lịch hẹn của bạn',
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: Colors.white54),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_list == null || _list!.items.isEmpty)
                      ? Center(
                          child: Text(
                            'Không có lịch hẹn',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: _list!.items.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _list!.items.length) {
                              return _buildCard(_list!.items[index]);
                            }

                            // loading indicator at the end
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Center(
                                child: _isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : const SizedBox.shrink(),
                              ),
                            );
                          },
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
