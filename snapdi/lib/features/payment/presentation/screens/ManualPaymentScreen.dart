import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/manual_payment_request.dart';
import '../../domain/services/payment_service.dart';
import 'PaymentStatusScreen.dart';

class ManualPaymentScreen extends StatefulWidget {
  final int bookingId;
  final double amount;
  final int paymentId;

  const ManualPaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.paymentId,
  });

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final TextEditingController transactionCodeController =
      TextEditingController();
  bool isLoading = false;

  // NEW: must agree fee policy
  bool _agreeFeePolicy = false;

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            print("Đang gọi context.go('/home')...");
            Navigator.of(context).popUntil((route) => route.isFirst);
            print("Đã gọi xong.");
          },
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
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(widget.amount * 0.2).toStringAsFixed(0)}đ',
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

            // QR Code Section (ảnh tĩnh)
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      'assets/images/QR_Image.png', // Đặt ảnh QR của bạn
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sử dụng app ngân hàng để quét mã QR',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    onCopy: () =>
                        _copyToClipboard(accountNumber, 'số tài khoản'),
                  ),
                  const Divider(height: 24),
                  _buildBankInfoRow(
                    'Chủ tài khoản',
                    accountName,
                    Icons.person_outline,
                    onCopy: () =>
                        _copyToClipboard(accountName, 'tên chủ tài khoản'),
                  ),
                  // const Divider(height: 24),
                  // _buildBankInfoRow(
                  //   'Nội dung',
                  //   'Booking_${widget.bookingId}',
                  //   Icons.description_outlined,
                  //   onCopy: () => _copyToClipboard('Booking_${widget.bookingId}', 'nội dung chuyển khoản'),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Form nhập + đồng ý Fee Policy
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  // TextField(
                  //   controller: transactionCodeController,
                  //   decoration: InputDecoration(
                  //     labelText: 'Mã giao dịch (tuỳ chọn)',
                  //     hintText: 'Nhập mã giao dịch từ ngân hàng (nếu có)',
                  //     prefixIcon: const Icon(Icons.receipt_long),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: BorderSide(color: Colors.grey[300]!),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 12),

                  // NEW: Agree Fee Policy
                  CheckboxListTile(
                    value: _agreeFeePolicy,
                    onChanged: (v) =>
                        setState(() => _agreeFeePolicy = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tôi đồng ý với chính sách người dùng'),
                    subtitle: InkWell(
                      onTap: _showFeePolicyDialog,
                      child: const Text(
                        'Xem chi tiết chính sách',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
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
                  onPressed: (isLoading || !_agreeFeePolicy)
                      ? null
                      : _submitPayment,
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
            // Nút huỷ thanh toán
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _cancelPayment,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.red,
                          ),
                        )
                      : const Text(
                          'Huỷ thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
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

  void _showFeePolicyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fee Policy'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Đăng ký & sử dụng tài khoản:\n'
            '- Người dùng phải cung cấp thông tin chính xác và không mạo danh.\n'
            '- Ứng dụng có quyền khóa tài khoản nếu phát hiện hành vi gian lận.\n\n'
            '2. Đặt lịch & thanh toán:\n'
            '- Khách hàng thanh toán trước 20% giá trị booking để xác nhận.\n'
            '- Khoản phí này không hoàn lại nếu huỷ do phía khách hàng.\n'
            '- Nhiếp ảnh gia có thể hoàn trả nếu không thể thực hiện buổi chụp.\n\n'
            '3. Quyền riêng tư:\n'
            '- Thông tin cá nhân được bảo mật và chỉ sử dụng cho mục đích đặt lịch.\n'
            '- Ứng dụng không chia sẻ dữ liệu cho bên thứ ba nếu không có sự đồng ý.\n\n'
            '4. Hành vi bị cấm:\n'
            '- Đăng tải nội dung vi phạm pháp luật, xúc phạm hoặc lừa đảo.\n'
            '- Sử dụng ảnh của người khác mà không được phép.\n\n'
            '5. Giải quyết tranh chấp:\n'
            '- Mọi tranh chấp phát sinh sẽ được giải quyết thông qua thương lượng.\n'
            '- Nếu không đạt thỏa thuận, vụ việc sẽ được xử lý theo quy định pháp luật Việt Nam.\n\n'
            'Bằng việc sử dụng ứng dụng, bạn đồng ý với các điều khoản nêu trên.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onCopy,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    if (!_agreeFeePolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Bạn cần đồng ý với Fee Policy để tiếp tục.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // FIX: feePolicyId luôn = 1, không còn widget.feePolicyId
    final request = ManualPaymentRequest(
      bookingId: widget.bookingId,
      feePolicyId: 1,
      // Nếu model có field transactionReference/amount, có thể truyền thêm:
      // transactionReference: transactionCodeController.text,
      // amount: widget.amount,
    );

    try {
      final success = await _paymentService.confirmPaid(
        request,
        widget.paymentId,
      );
      String status = '';
      if (success == true) {
        status = 'paid';
      }
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PaymentStatusScreen(status: status)),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _cancelPayment() async {
    setState(() => isLoading = true);
    final cancelRequest = ManualPaymentRequest(
      bookingId: widget.bookingId,
      feePolicyId: 1,
      // Nếu model có field transactionReference/amount, có thể truyền thêm:
      // transactionReference: transactionCodeController.text,
      // amount: widget.amount,
    );
    try {
      final success = await _paymentService.CancelManualPayment(
        cancelRequest,
        widget.paymentId,
      );
      String status = '';
      if (success == true) {
        status = 'cancelled';
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PaymentStatusScreen(status: status)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
