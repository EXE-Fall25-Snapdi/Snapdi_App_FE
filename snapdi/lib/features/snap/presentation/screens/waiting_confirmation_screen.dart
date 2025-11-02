import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WaitingConfirmationScreen extends StatelessWidget {
  final int bookingId;
  final String photographerName;

  const WaitingConfirmationScreen({
    Key? key,
    required this.bookingId,
    required this.photographerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Ẩn nút back
        title: const Text(
          'Đặt chụp thành công',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animation icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer circle animation
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Check icon
                    const Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Color(0xFF00BFA5),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Đặt chụp thành công!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BFA5),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Booking ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00BFA5).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Mã đặt chỗ: #$bookingId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Status card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Waiting icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: Colors.orange[600],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status text
                    Text(
                      'Đang chờ $photographerName xác nhận',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Photographer sẽ xem xét và phản hồi yêu cầu của bạn trong thời gian sớm nhất.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Info box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Những điều cần biết',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.history,
                      text: 'Xem trạng thái booking trong nút My Bookings ở màn hình chính',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Back to home button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate về home và clear stack
                    context.go('/home');
                  },
                  icon: const Icon(Icons.home, size: 24),
                  label: const Text(
                    'Về trang chủ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Secondary button - View bookings
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to booking history
                    context.go('/bookings');
                  },
                  icon: const Icon(Icons.history, size: 24),
                  label: const Text(
                    'Xem lịch sử đặt chụp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00BFA5),
                    side: const BorderSide(color: Color(0xFF00BFA5), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}