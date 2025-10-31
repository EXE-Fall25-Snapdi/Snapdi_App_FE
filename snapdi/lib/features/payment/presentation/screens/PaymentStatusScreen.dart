import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String status; // 'paid', 'cancelled'

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

                      // Additional info box cho trường hợp thanh toán thành công
                      if (widget.status.toLowerCase() == 'paid')
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: const Color(0xFF00BFA5), size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Photographer sẽ liên hệ với bạn sớm nhất có thể để xác nhận lịch chụp',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF00BFA5),
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

            // Action buttons - CHỈ NÚT VỀ TRANG CHỦ
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
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
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (widget.status.toLowerCase()) {
      case 'paid':
        return _StatusConfig(
          icon: Icons.check_circle_outline,
          title: 'Thanh toán thành công!',
          description: 'Booking của bạn đã được xác nhận.\nChúc bạn có trải nghiệm tuyệt vời!',
          color: const Color(0xFF00BFA5),
        );
      case 'cancelled':
      default:
        return _StatusConfig(
          icon: Icons.cancel_outlined,
          title: 'Thanh toán đã bị hủy',
          description: 'Giao dịch của bạn đã được hủy.\nBạn có thể thử lại hoặc chọn phương thức thanh toán khác.',
          color: Colors.red,
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
