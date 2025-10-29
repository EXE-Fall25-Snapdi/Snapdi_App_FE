import 'package:flutter/material.dart';
import '../../../payment/presentation/screens/ManualPaymentScreen.dart';
import 'finding_snappers_screen.dart';
// NEW: import payment service
import '../../../payment/domain/services/payment_service.dart';
// NEW: import request model
import '../../../payment/data/models/manual_payment_request.dart';

class BookingConfirmScreen extends StatelessWidget {
  final SnapperProfile snapper;
  final String? location;
  final DateTime? date;
  final TimeOfDay? scheduleAt;
  final int bookingId;
  final double amount;
  final int? photoTypeId;
  final int? time;

  const BookingConfirmScreen({
    Key? key,
    required this.snapper,
    this.location,
    this.date,
    this.scheduleAt,
    required this.bookingId,
    required this.amount,
    this.photoTypeId,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double totalAmount = amount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác nhận đặt chụp',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header thông tin booking
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Booking #$bookingId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Đang chờ xác nhận',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thông tin chi tiết
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin booking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Snapper info
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Photographer',
                    value: snapper.name,
                  ),
                  const Divider(height: 24),
                  
                  // Location
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Địa điểm',
                    value: location ?? 'Chưa xác định',
                  ),
                  const Divider(height: 24),
                  
                  // Date
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày xác nhận đặt',
                    value: date != null 
                        ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
                        : 'Chưa xác định',
                  ),
                  const Divider(height: 24),
                  
                  // Time
                  _buildInfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Giờ xác nhận đặt',
                    value: scheduleAt?.format(context) ?? 'Chưa xác định',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thông tin thanh toán
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Phí đặt cọc (20%)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${(totalAmount*0.2).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VND',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền cần thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VND',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BFA5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lưu ý
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bạn chỉ cần thanh toán 20% để đặt cọc. Số tiền còn lại sẽ được thanh toán sau khi hoàn thành buổi chụp.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Nút xác nhận
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await _handleConfirmBooking(context, totalAmount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Xác nhận và thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF00BFA5)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirmBooking(BuildContext context, double totalAmount) async {
    // 1) Hiện dialog thông báo như cũ
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: const Color(0xFF00BFA5), size: 28),
            const SizedBox(width: 12),
            const Text('Thành công'),
          ],
        ),
        content: Text(
          'Đã đặt chụp với ${snapper.name} thành công!\n\n'
          'Mã đặt chỗ: #$bookingId\n'
          'Trạng thái: Đang chờ xác nhận\n'
          'Địa chỉ: ${location ?? 'Chưa xác định'}\n'
          'Giá: ${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VND',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00BFA5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Tiếp tục thanh toán'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      // 2) Gọi confirmManualPayment
      final paymentService = PaymentService();
      int paymentId = 0;
      
      // Hiện loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
        ),
      );

      try {
        paymentId = await paymentService.confirmManualPayment(
          ManualPaymentRequest(
            bookingId: bookingId,
            feePolicyId: 1,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không khởi tạo được thanh toán: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } finally {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // đóng loading
        }
      }

      // 3) Điều hướng sang trang thanh toán
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManualPaymentScreen(
            bookingId: bookingId,
            amount: totalAmount,
            paymentId: paymentId,
          ),
        ),
      );
    }
  }
}