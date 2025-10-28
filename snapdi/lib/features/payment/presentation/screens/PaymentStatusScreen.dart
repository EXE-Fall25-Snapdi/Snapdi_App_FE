import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaymentStatusScreen extends StatefulWidget {
  final String status; // 'pending', 'approved', 'rejected'

  const PaymentStatusScreen({super.key, required this.status});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: statusConfig.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            statusConfig.icon,
                            size: 64,
                            color: statusConfig.color,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          statusConfig.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: statusConfig.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          statusConfig.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Additional info box
                      if (widget.status == 'pending')
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.orange[700], size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Thời gian xử lý: 5-10 phút\nBạn sẽ nhận được thông báo khi thanh toán được xác nhận',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.orange,
                                      height: 1.4,
                                    ),
                                  ),
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

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (widget.status == 'pending') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Navigate to booking detail
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: statusConfig.color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Xem chi tiết booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: statusConfig.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusConfig.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Về trang chủ',
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
          ],
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (widget.status.toLowerCase()) {
      case 'approved':
        return _StatusConfig(
          icon: Icons.check_circle_outline,
          title: 'Thanh toán thành công!',
          description: 'Booking của bạn đã được xác nhận.\nChúc bạn có trải nghiệm tuyệt vời!',
          color: const Color(0xFF00BFA5),
        );
      case 'rejected':
        return _StatusConfig(
          icon: Icons.error_outline,
          title: 'Thanh toán thất bại',
          description: 'Giao dịch của bạn không được xác nhận.\nVui lòng thử lại hoặc liên hệ hỗ trợ.',
          color: Colors.red,
        );
      default:
        return _StatusConfig(
          icon: Icons.pending_outlined,
          title: 'Đang chờ xác nhận',
          description: 'Chúng tôi đang xác minh thông tin thanh toán của bạn.\nVui lòng đợi trong giây lát.',
          color: Colors.orange,
        );
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _StatusConfig({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

}
