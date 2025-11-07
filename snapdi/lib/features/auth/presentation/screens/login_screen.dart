import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_input_field.dart';
import 'account_type_selection_screen.dart';
import '../../domain/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthServiceImpl();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _authService.login(
        emailOrPhone: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failure.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (loginResponse) async {
          // Check if user email is verified
          if (!loginResponse.user.isVerify) {
            // Send verification code
            final sendCodeResult = await _authService.sendVerificationCode(
              email: loginResponse.user.email,
            );

            sendCodeResult.fold(
              (failure) {
                // Show error if failed to send code
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Không thể gửi mã xác thực: ${failure.message}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              (verificationResponse) {
                // Navigate to verify screen with both email and password
                if (mounted) {
                  context.push(
                    '/verify-code',
                    extra: {
                      'email': loginResponse.user.email,
                      'password': _passwordController.text,
                    },
                  );
                }
              },
            );
            return;
          }

          // If verified, proceed with login
          await _authService.storeAuthTokens(loginResponse);

          if (mounted) {
            if (loginResponse.user.roleId == 3) {
              // Photographer
              context.go('/photographer-welcome');
            } else {
              context.go('/home');
            }
          }
        },
      );
    }
  }

  void _handleSocialLogin(String platform) {
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
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundGradient, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 200 + MediaQuery.of(context).padding.top,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            // color: AppColors.primaryDarker,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            AppAssets.snapdiLogoWithText,
                            height: 150,
                            width: 150,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge + 20,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: AppDimensions.marginMedium,
                              ),

                              // Email field
                              CustomInputField(
                                hintText: 'Email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: _validateEmail,
                              ),

                              const SizedBox(
                                height: AppDimensions.marginMedium,
                              ),

                              // Password field
                              CustomInputField(
                                hintText: 'Mật khẩu',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                controller: _passwordController,
                                validator: _validatePassword,
                              ),

                              const SizedBox(height: AppDimensions.marginSmall),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.push('/forgot-password');
                                  },
                                  child: Text(
                                    'Quên mật khẩu?',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppDimensions.marginLarge),

                              // Login button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
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
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          'Đăng nhập',
                                          style: AppTextStyles.buttonLarge,
                                        ),
                                ),
                              ),

                              const SizedBox(height: AppDimensions.marginLarge),

                              // "Or log in with" text
                              Text(
                                'Hoặc đăng nhập với',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(
                                height: AppDimensions.marginMedium,
                              ),

                              // Social login buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SocialLoginButton(
                                    icon: Icons.g_mobiledata,
                                    onPressed: () =>
                                        _handleSocialLogin('Google'),
                                  ),
                                  const SizedBox(width: 20),
                                  _SocialLoginButton(
                                    icon: Icons.facebook,
                                    onPressed: () =>
                                        _handleSocialLogin('Facebook'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.marginLarge),

                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Chưa có tài khoản? ',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AccountTypeSelectionScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Đăng ký',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialLoginButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textSecondary, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}
