import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
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
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        result.fold(
          (failure) {
            // Handle login failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  failure.message,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (loginResponse) async {
            // Handle login success
            // Store authentication tokens securely using AuthService
            await _authService.storeAuthTokens(loginResponse);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome back, ${loginResponse.user.name}!',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            
            // TODO: Navigate to main app screen
          },
        );
      }
    }
  }

  void _handleSocialLogin(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$platform login - Coming soon!',
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
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
                  // Top section with logo
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo placeholder
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'LOGO',
                                style: AppTextStyles.headline3.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom section with form
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge + 20, // Extra bottom padding
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                              
                              // Password field
                              CustomInputField(
                                hintText: 'Passwords',
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
                                    // TODO: Implement forgot password
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Forgot password - Coming soon!',
                                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                                        ),
                                        backgroundColor: AppColors.secondary,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forget passwords?',
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
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Login',
                                          style: AppTextStyles.buttonLarge,
                                        ),
                                ),
                              ),
                              
                              const SizedBox(height: AppDimensions.marginLarge),
                              
                              // "Or log in with" text
                              Text(
                                'Or log in with',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: AppDimensions.marginMedium),
                              
                              // Social login buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SocialLoginButton(
                                    icon: Icons.g_mobiledata, // Google placeholder
                                    onPressed: () => _handleSocialLogin('Google'),
                                  ),
                                  const SizedBox(width: 20),
                                  _SocialLoginButton(
                                    icon: Icons.facebook, // Facebook
                                    onPressed: () => _handleSocialLogin('Facebook'),
                                  ),
                                  const SizedBox(width: 20),
                                  _SocialLoginButton(
                                    icon: Icons.code, // GitHub placeholder
                                    onPressed: () => _handleSocialLogin('GitHub'),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: AppDimensions.marginLarge),
                              
                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AccountTypeSelectionScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Sign up',
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
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.onPressed,
  });

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
        icon: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }
}