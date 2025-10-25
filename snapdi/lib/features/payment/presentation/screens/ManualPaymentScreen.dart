import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_theme.dart';
import '../../data/models/manual_payment_request.dart';
import '../../domain/services/payment_service.dart';
import 'upload_proof_screen.dart';
import 'PaymentStatusScreen.dart';

class ManualPaymentScreen extends StatefulWidget {
  final int bookingId;
  final double amount;

  const ManualPaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final TextEditingController transactionCodeController = TextEditingController();
  bool isLoading = false;
  String? uploadedImagePath;
  final PaymentService _paymentService = PaymentService();

  // Thông tin ngân hàng
  final String bankName = 'ACB';
  final String accountNumber = '40163177';
  final String accountName = 'NGUYEN DUC THANG';

  @override
  void dispose() {
    transactionCodeController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData = '970436-$bankName-$accountNumber-$accountName-Booking_${widget.bookingId}-Amount:${widget.amount.toStringAsFixed(0)}';

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
          'Thanh toán',
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
            // Header với số tiền
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: Color(0xFF00BFA5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Số tiền cần thanh toán',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.amount.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // QR Code Section
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
                children: [
                  const Text(
                    'Quét mã QR để chuyển khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Image.asset(
                      'assets/images/QR_Image.png', // Đường dẫn đến ảnh QR của bạn
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sử dụng app ngân hàng để quét mã QR',
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thông tin ngân hàng
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
                    'Thông tin chuyển khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBankInfoRow(
                    'Ngân hàng',
                    bankName,
                    Icons.account_balance,
                  ),
                  const Divider(height: 24),
                  _buildBankInfoRow(
                    'Số tài khoản',
                    accountNumber,
                    Icons.credit_card,
                    onCopy: () => _copyToClipboard(accountNumber, 'số tài khoản'),
                  ),
                  const Divider(height: 24),
                  _buildBankInfoRow(
                    'Chủ tài khoản',
                    accountName,
                    Icons.person_outline,
                    onCopy: () => _copyToClipboard(accountName, 'tên chủ tài khoản'),
                  ),
                  const Divider(height: 24),
                  _buildBankInfoRow(
                    'Nội dung',
                    'Booking_${widget.bookingId}',
                    Icons.description_outlined,
                    onCopy: () => _copyToClipboard('Booking_${widget.bookingId}', 'nội dung chuyển khoản'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Form nhập thông tin
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
                    'Xác nhận thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: transactionCodeController,
                    decoration: InputDecoration(
                      labelText: 'Mã giao dịch',
                      hintText: 'Nhập mã giao dịch từ ngân hàng',
                      prefixIcon: const Icon(Icons.receipt_long),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: uploadedImagePath != null
                            ? const Color(0xFF00BFA5)
                            : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final result = await Navigator.push<String?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UploadProofScreen(),
                            ),
                          );
                          if (result != null) {
                            setState(() => uploadedImagePath = result);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                  color: uploadedImagePath != null
                    ? const Color(0xFF00BFA5).withOpacity(0.1)
                    : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                  uploadedImagePath != null
                    ? Icons.check_circle
                    : Icons.cloud_upload_outlined,
                  color: uploadedImagePath != null
                    ? const Color(0xFF00BFA5)
                    : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                          Text(
                                            uploadedImagePath != null
                                                ? 'Đã chọn hóa đơn'
                                                : 'Tải lên hóa đơn chuyển khoản',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: uploadedImagePath != null
                                                  ? const Color(0xFF00BFA5)
                                                  : Colors.black,
                                            ),
                                          ),
                                          if (uploadedImagePath != null)
                                            Text(
                                              uploadedImagePath!.split('/').last,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nút xác nhận
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Xác nhận thanh toán',
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

  Widget _buildBankInfoRow(String label, String value, IconData icon, {VoidCallback? onCopy}) {
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 20),
            color: const Color(0xFF00BFA5),
            tooltip: 'Sao chép',
          ),
      ],
    );
  }

  Future<void> _submitPayment() async {
  if (uploadedImagePath == null || transactionCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Vui lòng nhập mã giao dịch và tải lên hóa đơn!'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final request = ManualPaymentRequest(
      bookingId: widget.bookingId,
      amount: widget.amount,
      transactionReference: transactionCodeController.text,
      proofImageUrl: uploadedImagePath!,
    );

    try {
      final status = await _paymentService.confirmManualPayment(request);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentStatusScreen(status: status),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Lỗi: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
