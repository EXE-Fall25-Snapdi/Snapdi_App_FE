import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/constants/app_theme.dart';
import '../../domain/services/auth_service.dart';
import 'portfolio_upload_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String password;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  final AuthService _authService = AuthServiceImpl();

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get _isCodeComplete {
    return _verificationCode.length == 6 && _verificationCode.isNotEmpty;
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_isCodeComplete && !_isLoading) {
      _verifyCode();
    }

    setState(() {});
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  Future<void> _verifyCode() async {
    if (!_isCodeComplete || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify email code
      final verifyResult = await _authService.verifyEmailCode(
        email: widget.email,
        code: _verificationCode,
      );

      await verifyResult.fold(
        (failure) async {
          if (mounted) {
            _showErrorSnackBar(failure.message);
            _clearCode();
          }
        },
        (response) async {
          // Email verified successfully, now auto-login
          if (mounted) {
            _showSuccessSnackBar('Xác thực email thành công!');
          }

          // Auto-login
          final loginResult = await _authService.login(
            emailOrPhone: widget.email,
            password: widget.password,
          );

          await loginResult.fold(
            (failure) async {
              if (mounted) {
                _showErrorSnackBar(
                  'Xác thực thành công nhưng đăng nhập thất bại. Vui lòng đăng nhập thủ công.',
                );
                // Navigate back to login screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            (loginResponse) async {
              // Store auth tokens
              await _authService.storeAuthTokens(loginResponse);

              if (mounted) {
                // Navigate based on user role
                final userRole = loginResponse.user.roleId;

                if (userRole == 2) {
                  // Customer role - navigate to home
                  context.go('/home');
                } else if (userRole == 3) {
                  // Photographer role - navigate to portfolio upload
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          PortfolioUploadScreen(email: widget.email),
                    ),
                  );
                } else {
                  // Unknown role - default to home
                  context.go('/home');
                }
              }
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Xác thực thất bại. Vui lòng thử lại.");
        _clearCode();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      final result = await _authService.resendVerificationCode(
        email: widget.email,
      );

      result.fold(
        (failure) {
          if (mounted) {
            _showErrorSnackBar(failure.message);
          }
        },
        (response) {
          if (mounted) {
            _showSuccessSnackBar(
              "Mã xác thực đã được gửi! Vui lòng kiểm tra email.",
            );
            _startResendCooldown();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Không thể gửi lại mã. Vui lòng thử lại.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E8B7B), Color(0xFF1E5F56)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: AppColors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Xác thực Email',
                      style: AppTextStyles.headline4.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          size: 50,
                          color: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Kiểm tra Email của bạn',
                        style: AppTextStyles.headline3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Chúng tôi đã gửi mã xác thực gồm 6 chữ số đến',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.email,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Code input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 60,
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(1),
                              ],
                              style: AppTextStyles.headline4.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) =>
                                  _onCodeChanged(value, index),
                              onTap: () {
                                _controllers[index].clear();
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      if (_isLoading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Đang xác thực...',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        )
                      else if (_isCodeComplete)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Xác thực mã',
                              style: AppTextStyles.buttonLarge.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 48),

                      // Resend code section
                      Column(
                        children: [
                          Text(
                            'Không nhận được mã?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_resendCooldown > 0)
                            Text(
                              'Gửi lại sau ${_resendCooldown}s',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white.withOpacity(0.6),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _isResending ? null : _resendCode,
                              child: _isResending
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.white,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Đang gửi...',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Gửi lại mã',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
