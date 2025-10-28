import 'package:flutter/material.dart';
import 'ManualPaymentScreen.dart';

class PaymentMethodScreen extends StatelessWidget {
  final int bookingId;
  final double amount;
  final int paymentId;

  const PaymentMethodScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn phương thức thanh toán')),
      body: ListView(
        children: [
          // Manual Payment (QR) Option
          ListTile(
            leading: const Icon(Icons.qr_code_2),
            title: const Text('Chuyển khoản thủ công (QR)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManualPaymentScreen(
                    bookingId: bookingId,
                    amount: amount,
                    paymentId: paymentId,
                  ),
                ),
              );
            },
          ),
          // Add other payment methods if needed
        ],
      ),
    );
  }
}