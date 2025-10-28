import 'package:flutter/material.dart';
import '../../../payment/presentation/screens/payment_method_screen.dart';
import 'finding_snappers_screen.dart';

class BookingConfirmScreen extends StatelessWidget {
  final SnapperProfile snapper;
  final String? location;
  final DateTime? date;
  final TimeOfDay? time;
  final int bookingId;
  final double amount;

  const BookingConfirmScreen({
    Key? key,
    required this.snapper,
    this.location,
    this.date,
    this.time,
    required this.bookingId,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  // Use values passed from the booking response
  final double totalAmount = amount;
  // bookingId is provided via constructor

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt chụp')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin Snapper
            Text('Snapper: ${snapper.name}'),
            Text('Địa điểm: $location'),
            Text('Ngày: ${date?.day}/${date?.month}/${date?.year}'),
            Text('Giờ: ${time?.format(context)}'),
            
            const SizedBox(height: 24),
            
            // Tổng tiền
            Text(
              'Tổng tiền: ${totalAmount.toStringAsFixed(0)} VND',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Nút xác nhận
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to payment method selection
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentMethodScreen(
                        bookingId: bookingId,
                        amount: totalAmount,
                      ),
                    ),
                  );
                },
                child: const Text('Xác nhận và thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}