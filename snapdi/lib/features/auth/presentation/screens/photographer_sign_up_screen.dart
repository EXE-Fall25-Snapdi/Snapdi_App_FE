import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_input_field.dart';
import 'account_type_selection_screen.dart';

class PhotographerSignUpScreen extends StatefulWidget {
  final AccountType accountType;

  const PhotographerSignUpScreen({
    super.key,
    required this.accountType,
  });

  @override
  State<PhotographerSignUpScreen> createState() => _PhotographerSignUpScreenState();
}

class _PhotographerSignUpScreenState extends State<PhotographerSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _equipmentController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    // Basic phone validation - adjust regex as needed for your region
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your city';
    }
    if (value.length < 2) {
      return 'City must be at least 2 characters';
    }
    return null;
  }

  String? _validateEquipment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please describe your equipment';
    }
    if (value.length < 10) {
      return 'Please provide more details about your equipment';
    }
    return null;
  }

  void _handleSignUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to terms and conditions',
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

      // Simulate sign up process
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // TODO: Implement actual photographer sign up logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Photographer account created successfully!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate back to login or main app
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _handleSocialSignUp(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$platform sign up - Coming soon!',
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
              Color(0xFFE8F5F3), // Light mint/teal at top
              Color(0xFFF0F9F7), // Very light teal at bottom
            ],
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
                      'Create photographer account',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppDimensions.marginXLarge),
                    
                    // Name field
                    CustomInputField(
                      hintText: 'Name',
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
                    
                    // Phone field
                    CustomInputField(
                      hintText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: _validatePhone,
                    ),
                    
                    const SizedBox(height: AppDimensions.marginMedium),
                    
                    // City field
                    CustomInputField(
                      hintText: 'City',
                      prefixIcon: Icons.location_city_outlined,
                      keyboardType: TextInputType.text,
                      controller: _cityController,
                      validator: _validateCity,
                    ),
                    
                    const SizedBox(height: AppDimensions.marginMedium),
                    
                    // Password field
                    CustomInputField(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: _validatePassword,
                    ),
                    
                    const SizedBox(height: AppDimensions.marginMedium),
                    
                    // Confirm Password field
                    CustomInputField(
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: _validateConfirmPassword,
                    ),
                    
                    const SizedBox(height: AppDimensions.marginMedium),
                    
                    // Equipment field (multiline)
                    TextFormField(
                      controller: _equipmentController,
                      validator: _validateEquipment,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Describe your photography equipment\n(Camera, lenses, lighting, etc.)',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFB8D4D1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: AppColors.primary, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: AppColors.error, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: AppColors.error, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
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
                                    const TextSpan(text: 'I agree with '),
                                    TextSpan(
                                      text: 'terms conditions',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'privacy policy',
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
                            : Text(
                                'Create Photographer Account',
                                style: AppTextStyles.buttonLarge,
                              ),
                      ),
                    ),
                    
                    // const SizedBox(height: AppDimensions.marginLarge),
                    
                    // // "Or sign up with" text
                    // Text(
                    //   'Or sign up with',
                    //   style: AppTextStyles.bodyMedium.copyWith(
                    //     color: AppColors.textSecondary,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    
                    // const SizedBox(height: AppDimensions.marginMedium),
                    
                    // // Social sign up buttons
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     _SocialSignUpButton(
                    //       icon: Icons.g_mobiledata, // Google placeholder
                    //       onPressed: () => _handleSocialSignUp('Google'),
                    //     ),
                    //     const SizedBox(width: 20),
                    //     _SocialSignUpButton(
                    //       icon: Icons.facebook, // Facebook
                    //       onPressed: () => _handleSocialSignUp('Facebook'),
                    //     ),
                    //     const SizedBox(width: 20),
                    //     _SocialSignUpButton(
                    //       icon: Icons.code, // GitHub placeholder
                    //       onPressed: () => _handleSocialSignUp('GitHub'),
                    //     ),
                    //   ],
                    // ),
                    
                    const SizedBox(height: AppDimensions.marginLarge),
                    
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Pop back to login screen (skip account type selection)
                            // Navigation stack: Welcome → Login → AccountType → PhotographerSignUp
                            // We need to pop 2 screens to get back to Login
                            Navigator.of(context).pop(); // Pop PhotographerSignUp
                            Navigator.of(context).pop(); // Pop AccountType, back to Login
                          },
                          child: Text(
                            'Login',
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

// class _SocialSignUpButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onPressed;

//   const _SocialSignUpButton({
//     required this.icon,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: IconButton(
//         icon: Icon(
//           icon,
//           color: AppColors.textSecondary,
//           size: 24,
//         ),
//         onPressed: onPressed,
//       ),
//     );
//   }
// }