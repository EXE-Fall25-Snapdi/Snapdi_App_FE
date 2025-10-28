import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_input_field.dart';
import 'account_type_selection_screen.dart';
import '../../domain/services/auth_service.dart';
import '../../data/models/sign_up_request.dart';
import '../../../../core/error/failures.dart';
import 'verify_code_screen.dart';

class SignUpScreen extends StatefulWidget {
  final AccountType accountType;

  const SignUpScreen({super.key, required this.accountType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;
  final AuthService _authService = AuthServiceImpl();

  int get _roleId {
    return widget.accountType == AccountType.user ? 2 : 3;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Vui lòng nhập email hợp lệ';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      String phoneDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (phoneDigits.length < 10) {
        return 'Số điện thoại phải có ít nhất 10 chữ số';
      }
      if (phoneDigits.length > 15) {
        return 'Số điện thoại không được vượt quá 15 chữ số';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  void _handleSignUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng đồng ý với điều khoản và chính sách',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final signUpRequest = SignUpRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        password: _passwordController.text,
        roleId: _roleId,
        locationAddress: null,
        locationCity: null,
        avatarUrl: null,
      );

      final result = await _authService.register(signUpRequest: signUpRequest);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        result.fold(
          (failure) {
            String errorMessage;
            if (failure is ValidationFailure) {
              errorMessage = failure.message;
            } else if (failure is AuthenticationFailure) {
              errorMessage = failure.message;
            } else if (failure is NetworkFailure) {
              errorMessage = failure.message;
            } else if (failure is ServerFailure) {
              errorMessage = failure.message;
            } else {
              errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  errorMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (signUpResponse) async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tạo tài khoản thành công! Vui lòng kiểm tra email để lấy mã xác thực.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.success,
              ),
            );

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VerifyCodeScreen(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                ),
              ),
            );
          },
        );
      }
    }
  }

  void _handleSocialSignUp(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$platform - Sắp ra mắt!',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
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
            colors: [Color(0xFFE8F5F3), Color(0xFFF0F9F7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.marginLarge),

                    // Title
                    Text(
                      'Tạo tài khoản của bạn',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.marginXLarge),

                    // Name field
                    CustomInputField(
                      hintText: 'Họ tên',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                      validator: _validateName,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Email field
                    CustomInputField(
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Phone field (optional)
                    CustomInputField(
                      hintText: 'Số điện thoại (Tùy chọn)',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: _validatePhone,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Password field
                    CustomInputField(
                      hintText: 'Mật khẩu',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: _validatePassword,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Confirm Password field
                    CustomInputField(
                      hintText: 'Xác nhận mật khẩu',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: _validateConfirmPassword,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Terms and conditions checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Tôi đồng ý với '),
                                    TextSpan(
                                      text: 'điều khoản dịch vụ',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' và '),
                                    TextSpan(
                                      text: 'chính sách bảo mật',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginLarge),

                    // Sign up button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text('Đăng ký', style: AppTextStyles.buttonLarge),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.marginLarge),

                    // "Or sign up with" text
                    Text(
                      'Hoặc đăng ký với',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Social sign up buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialSignUpButton(
                          icon: Icons.g_mobiledata,
                          onPressed: () => _handleSocialSignUp('Google'),
                        ),
                        const SizedBox(width: 20),
                        _SocialSignUpButton(
                          icon: Icons.facebook,
                          onPressed: () => _handleSocialSignUp('Facebook'),
                        ),
                        const SizedBox(width: 20),
                        _SocialSignUpButton(
                          icon: Icons.code,
                          onPressed: () => _handleSocialSignUp('GitHub'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginLarge),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Đăng nhập',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialSignUpButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialSignUpButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textSecondary, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}