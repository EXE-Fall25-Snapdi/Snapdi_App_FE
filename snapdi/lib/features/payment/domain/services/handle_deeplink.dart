import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../../presentation/screens/PaymentStatusScreen.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    try {
      _appLinks = AppLinks();

      // Handle app launch từ deep link
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri.toString());
      }

      // Listen cho deep links khi app đã mở
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleDeepLink(uri.toString());
        },
        onError: (err) => print('❌ Deep link error: $err'),
      );
    } catch (e) {
      print('❌ Deep link init error: $e');
    }
  }

  void _handleDeepLink(String link) {    
    try {
      final uri = Uri.parse(link);
      
      if (uri.scheme == 'snapdi' && uri.host == 'payment' && uri.path == '/result') {
        final status = uri.queryParameters['status'];
        final code = uri.queryParameters['code'];
        final orderCode = uri.queryParameters['orderCode'];
        final error = uri.queryParameters['error'];
        
        // ✅ Determine final status: CHỈ 'paid' hoặc 'cancelled'
        String finalStatus = 'cancelled'; // Default = cancelled
        
        if (status == 'paid') {
          finalStatus = 'paid';
        } else {
          // Tất cả các trường hợp khác đều là cancelled
          finalStatus = 'cancelled';
        }
                
        _navigateToPaymentResult(finalStatus, code, orderCode, error);
      }
    } catch (e) {
      print('❌ Error parsing deep link: $e');
    }
  }

  void _navigateToPaymentResult(String finalStatus, String? code, String? orderCode, String? error) {
    // Retry logic để đảm bảo navigator context available
    void attemptNavigation() {
      final navigator = _navigatorKey?.currentState;
      if (navigator == null) {
        Future.delayed(const Duration(milliseconds: 500), attemptNavigation);
        return;
      }
      
      // ✅ Navigate tới PaymentStatusScreen với status = 'paid' hoặc 'cancelled'
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PaymentStatusScreen(
            status: finalStatus, // CHỈ 'paid' hoặc 'cancelled'
          ),
        ),
        (route) => route.isFirst, // Keep home screen in stack
      );

      // Show additional info if có error hoặc code
      _showAdditionalInfo(finalStatus, code, error);
    }

    attemptNavigation();
  }

  void _showAdditionalInfo(String status, String? code, String? error) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    String? message;
    Color? backgroundColor;

    if (status == 'paid' && code == '00') {
      message = 'Thanh toán thành công! Mã giao dịch: $code';
      backgroundColor = Colors.green;
    } else if (error != null) {
      message = 'Lỗi: $error';
      backgroundColor = Colors.red;
    } else if (code != null && code != '00') {
      message = 'Thanh toán không thành công. Mã lỗi: $code';
      backgroundColor = Colors.orange;
    }

    if (message != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_navigatorKey?.currentContext != null) {
          ScaffoldMessenger.of(_navigatorKey!.currentContext!).showSnackBar(
            SnackBar(
              content: Text(message!),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}