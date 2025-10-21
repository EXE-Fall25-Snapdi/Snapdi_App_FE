import 'package:flutter/material.dart';
import 'ManualPaymentScreen.dart';

class PaymentMethodScreen extends StatelessWidget {
  final int bookingId;
  final double amount;

  const PaymentMethodScreen({
    Key? key,
    required this.bookingId,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          'Phương thức thanh toán',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header với số tiền
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${amount.toStringAsFixed(0)}đ',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BFA5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment methods
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Text(
                  'Chọn phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Ví điện tử
                _buildPaymentCategory(
                  context,
                  title: 'Ví điện tử',
                  methods: [
                    _PaymentMethod(
                      icon: Icons.account_balance_wallet,
                      name: 'MoMo',
                      description: 'Thanh toán qua ví MoMo',
                      color: Colors.pink,
                      isComingSoon: true,
                    ),
                    _PaymentMethod(
                      icon: Icons.payment,
                      name: 'ZaloPay',
                      description: 'Thanh toán qua ZaloPay',
                      color: Colors.blue,
                      isComingSoon: true,
                    ),
                    _PaymentMethod(
                      icon: Icons.account_balance_wallet_outlined,
                      name: 'VNPay',
                      description: 'Thanh toán qua VNPay',
                      color: Colors.orange,
                      isComingSoon: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Chuyển khoản
                _buildPaymentCategory(
                  context,
                  title: 'Chuyển khoản ngân hàng',
                  methods: [
                    _PaymentMethod(
                      icon: Icons.account_balance,
                      name: 'Chuyển khoản thủ công',
                      description: 'Chuyển khoản qua QR hoặc số tài khoản',
                      color: const Color(0xFF00BFA5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualPaymentScreen(
                              bookingId: bookingId,
                              amount: amount,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCategory(
    BuildContext context, {
    required String title,
    required List<_PaymentMethod> methods,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: methods.map((method) => _buildPaymentMethodTile(context, method)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(BuildContext context, _PaymentMethod method) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: method.isComingSoon
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Tính năng đang phát triển'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            : method.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: method.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method.icon,
                  color: method.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (method.isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Sắp ra mắt',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String name;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  final bool isComingSoon;

  _PaymentMethod({
    required this.icon,
    required this.name,
    required this.description,
    required this.color,
    this.onTap,
    this.isComingSoon = false,
  });

}