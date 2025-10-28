import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/error/failures.dart';
import '../../domain/services/auth_service.dart';
import '../../data/models/photographer_sign_up_request.dart';
import '../../data/models/photographer_photo_type.dart';
import '../../data/models/photographer_stage1_data.dart';
import '../../data/models/photographer_stage2_data.dart';
import 'verify_code_screen.dart';

class PhotographerSignUpStage3Screen extends StatefulWidget {
  final PhotographerStage1Data stage1Data;
  final PhotographerStage2Data stage2Data;

  const PhotographerSignUpStage3Screen({
    super.key,
    required this.stage1Data,
    required this.stage2Data,
  });

  @override
  State<PhotographerSignUpStage3Screen> createState() =>
      _PhotographerSignUpStage3ScreenState();
}

class _PhotographerSignUpStage3ScreenState
    extends State<PhotographerSignUpStage3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _equipmentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authService = AuthServiceImpl();

  final List<String> _yearsOfExperienceOptions = [
    'Dưới 1 năm',
    '1-3 năm',
    '3-5 năm',
    'Trên 5 năm',
  ];
  String? _selectedYearsOfExperience;

  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _equipmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateEquipment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng mô tả thiết bị của bạn';
    }
    if (value.length < 10) {
      return 'Vui lòng cung cấp thêm chi tiết';
    }
    return null;
  }

  String? _validateYearsOfExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn số năm kinh nghiệm';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản và chính sách'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Create the complete registration request without avatar
        final photographerSignUpRequest = PhotographerSignUpRequest(
          // Stage 1 data
          name: widget.stage1Data.name,
          email: widget.stage1Data.email,
          phone: widget.stage1Data.phone,
          password: widget.stage1Data.password,
          locationAddress: widget.stage1Data.locationAddress.isNotEmpty
              ? widget.stage1Data.locationAddress
              : null,
          locationCity: widget.stage1Data.locationCity,
          avatarUrl: null,
          // Stage 2 data
          workLocation: widget.stage2Data.workLocation,
          photographerPhotoTypes: widget.stage2Data.photoTypes
              .map(
                (pt) => PhotographerPhotoType(
                  photoTypeId: pt.photoTypeId,
                  photoPrice: pt.photoPrice,
                  time: pt.time,
                ),
              )
              .toList(),
          photographerStyleIds: widget.stage2Data.styleIds,
          // Stage 3 data
          yearsOfExperience: _selectedYearsOfExperience!,
          equipmentDescription: _equipmentController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          isAvailable: false,
        );

        final result = await _authService.registerPhotographer(
          photographerSignUpRequest: photographerSignUpRequest,
        );

        setState(() => _isLoading = false);

        if (mounted) {
          result.fold(
            (failure) {
              String errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.';
              if (failure is ValidationFailure ||
                  failure is AuthenticationFailure ||
                  failure is NetworkFailure ||
                  failure is ServerFailure) {
                errorMessage = failure.message;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            (response) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tạo tài khoản thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );

              // Navigate to verify code screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => VerifyCodeScreen(
                    email: widget.stage1Data.email,
                    password: widget.stage1Data.password,
                  ),
                ),
              );
            },
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xảy ra lỗi: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
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
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Kinh nghiệm & Hồ sơ',
                            style: AppTextStyles.headline3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bước 3 / 3',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.marginXLarge),

                          // Years of Experience
                          DropdownButtonFormField<String>(
                            value: _selectedYearsOfExperience,
                            decoration: InputDecoration(
                              hintText: 'Số năm kinh nghiệm',
                              prefixIcon: Icon(
                                Icons.work_outline,
                                color: AppColors.primary,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFB8D4D1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _yearsOfExperienceOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYearsOfExperience = value;
                              });
                            },
                            validator: _validateYearsOfExperience,
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),

                          // Equipment Description
                          TextFormField(
                            controller: _equipmentController,
                            validator: _validateEquipment,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Mô tả thiết bị của bạn\n(Máy ảnh, ống kính, đèn chiếu sáng, v.v.)',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 60),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFB8D4D1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Giới thiệu về bản thân và phong cách của bạn (Tùy chọn)',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 60),
                                child: Icon(
                                  Icons.description_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFB8D4D1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginLarge),

                          // Terms and Conditions
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
                                          const TextSpan(
                                            text: 'Tôi đồng ý với ',
                                          ),
                                          TextSpan(
                                            text: 'điều khoản dịch vụ',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          const TextSpan(text: ' và '),
                                          TextSpan(
                                            text: 'chính sách bảo mật',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              decoration:
                                                  TextDecoration.underline,
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

                          // Submit Button
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Tạo tài khoản',
                                      style: AppTextStyles.buttonLarge,
                                    ),
                            ),
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
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
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
                        ],
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
