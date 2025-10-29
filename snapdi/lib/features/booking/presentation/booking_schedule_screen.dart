import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import 'booking_pending_schedule_screen.dart';
import "booking_accepted_schedule_screen.dart";
import 'booking_cancelled_schedule_screen.dart';
import 'booking_track_snaper_screen.dart';

class BookingScheduleScreen extends StatefulWidget {
  const BookingScheduleScreen({super.key});

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1DB584), const Color(0xFF0A8B5C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lịch hẹn của bạn',
                      style: AppTextStyles.headline3.copyWith(
                        color: Colors.white,
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

              const SizedBox(height: 24),

              // Booking Cards Grid
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // First Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildBookingCard(
                                title: 'Chờ Chấp Nhận',
                                icon: Icons.apps_outlined,
                                filter: 'pending',
                                backgroundColor: Colors.white,
                                iconColor: const Color(0xFF1DB584),
                                onTap: () {
                                  // Navigate to booking list with 'pending' filter
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BookingPendingScheduleScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBookingCard(
                                title: 'Đã Chấp nhận',
                                icon: Icons.bookmark_outline,
                                filter: 'approved',
                                backgroundColor: Colors.white,
                                iconColor: const Color(0xFF1DB584),
                                onTap: () {
                                  // Navigate to booking list with 'confirmed' filter
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BookingAcceptedScheduleScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Second Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildBookingCard(
                                title: 'Theo dõi Snapper',
                                icon: Icons.camera_alt_outlined,
                                filter: 'follow',
                                backgroundColor: Colors.white,
                                iconColor: const Color(0xFF1DB584),
                                onTap: () {
                                  // Navigate to booking list with 'tracking' filter
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BookingTrackSnapperScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBookingCard(
                                title: 'Bị Từ Chối',
                                icon: Icons.close_rounded,
                                filter: 'rejected',
                                backgroundColor: Colors.white,
                                iconColor: const Color(0xFF1DB584),
                                onTap: () {
                                  // Navigate to booking list with 'cancelled' filter
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BookingCancelledScheduleScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required String title,
    required IconData icon,
    required String filter,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
