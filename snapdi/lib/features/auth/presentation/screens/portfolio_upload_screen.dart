import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../profile/domain/services/cloudinary_service.dart';
import '../../../profile/domain/services/portfolio_service.dart';
import '../../../auth/domain/services/auth_service.dart';

class PortfolioUploadScreen extends StatefulWidget {
  final String email;

  const PortfolioUploadScreen({super.key, required this.email});

  @override
  State<PortfolioUploadScreen> createState() => _PortfolioUploadScreenState();
}

class _PortfolioUploadScreenState extends State<PortfolioUploadScreen> {
  final _cloudinaryService = CloudinaryServiceImpl();
  final _portfolioService = PortfolioServiceImpl();
  final _imagePicker = ImagePicker();

  File? _avatarImage;
  List<File> _portfolioImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickAvatarImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  Future<void> _pickPortfolioImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _portfolioImages.addAll(images.map((xfile) => File(xfile.path)));
        if (_portfolioImages.length > 10) {
          _portfolioImages = _portfolioImages.take(10).toList();
        }
      });
    }
  }

  void _removePortfolioImage(int index) {
    setState(() {
      _portfolioImages.removeAt(index);
    });
  }

  Future<void> _uploadAllMedia() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Get current user ID from token storage
      final authService = AuthServiceImpl();
      final session = await authService.getCurrentSession();

      if (session == null || session.userId == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      int totalItems = (_avatarImage != null ? 1 : 0) + _portfolioImages.length;
      int uploadedCount = 0;

      // Upload avatar if selected
      if (_avatarImage != null) {
        final avatarResult = await _cloudinaryService.uploadSingleImage(
          _avatarImage!,
          publicId: 'avatar',
          uploadType: 'avatar',
        );

        await avatarResult.fold(
          (failure) {
            throw Exception('Không thể tải ảnh đại diện: ${failure.message}');
          },
          (uploadResponse) async {
            // Update photographer profile with avatar URL using the new API
            final updateResult = await authService.updateAvatar(
              userId: session.userId!,
              avatarUrl: uploadResponse.publicId,
            );

            updateResult.fold(
              (failure) {
                throw Exception(
                  'Không thể cập nhật ảnh đại diện: ${failure.message}',
                );
              },
              (success) {
                uploadedCount++;
                setState(() {
                  _uploadProgress = uploadedCount / totalItems;
                });
              },
            );
          },
        );
      }

      // Upload portfolio images
      if (_portfolioImages.isNotEmpty) {
        List<String> portfolioUrls = [];

        for (var image in _portfolioImages) {
          final uploadResult = await _cloudinaryService.uploadSingleImage(
            image,
            uploadType: 'portfolio',
          );

          uploadResult.fold(
            (failure) {
              throw Exception('Không thể tải ảnh: ${failure.message}');
            },
            (uploadResponse) {
              portfolioUrls.add(uploadResponse.publicId);
              uploadedCount++;
              setState(() {
                _uploadProgress = uploadedCount / totalItems;
              });
            },
          );
        }

        if (portfolioUrls.isNotEmpty) {
          final createPortfolioResult = await _portfolioService
              .createMultiplePortfolios(portfolioUrls);

          createPortfolioResult.fold(
            (failure) {
              throw Exception('Không thể lưu portfolio: ${failure.message}');
            },
            (portfolioResponse) {
              // Success
            },
          );
        }
      }

      setState(() => _isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tải ảnh thành công!'),
            backgroundColor: AppColors.success,
          ),
        );

        _navigateToHome();
      }
    } catch (e) {
      setState(() => _isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tải lên thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _skipAllUploads() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bỏ qua tải ảnh?'),
        content: Text(
          'Bạn có thể thêm ảnh đại diện và portfolio sau trong cài đặt hồ sơ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHome();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Bỏ qua'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    // Navigate to home and clear all previous routes
    context.go('/home');
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
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hoàn thiện hồ sơ',
                        style: AppTextStyles.headline3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Thêm ảnh đại diện và portfolio để tạo ấn tượng đầu tiên tốt với khách hàng!',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.marginXLarge),

                        // Avatar Upload Section
                        Text(
                          'Ảnh đại diện',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        Center(
                          child: GestureDetector(
                            onTap: _isUploading ? null : _pickAvatarImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8D4D1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: _avatarImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _avatarImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.marginXLarge),

                        // Portfolio Section
                        Text(
                          'Portfolio (Tối đa 10 ảnh)',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),

                        OutlinedButton.icon(
                          onPressed:
                              _portfolioImages.length < 10 && !_isUploading
                              ? _pickPortfolioImages
                              : null,
                          icon: Icon(Icons.add_photo_alternate),
                          label: Text(
                            _portfolioImages.isEmpty
                                ? 'Thêm ảnh Portfolio'
                                : 'Thêm ảnh (${_portfolioImages.length}/10)',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.all(20),
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.marginLarge),

                        if (_portfolioImages.isNotEmpty) ...[
                          Text(
                            'Ảnh đã chọn (${_portfolioImages.length})',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _portfolioImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _portfolioImages[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  if (!_isUploading)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _removePortfolioImage(index),
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.error,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],

                        if (_isUploading) ...[
                          const SizedBox(height: AppDimensions.marginXLarge),
                          Column(
                            children: [
                              Text(
                                'Đang tải ảnh của bạn...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: _uploadProgress,
                                backgroundColor: AppColors.textSecondary
                                    .withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(_uploadProgress * 100).toInt()}% hoàn thành',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: AppDimensions.marginXLarge),

                        if (!_isUploading) ...[
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  (_avatarImage != null ||
                                      _portfolioImages.isNotEmpty)
                                  ? _uploadAllMedia
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Tải lên & Tiếp tục',
                                style: AppTextStyles.buttonLarge,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.marginMedium),

                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _skipAllUploads,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Bỏ qua bây giờ',
                                style: AppTextStyles.buttonLarge.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: AppDimensions.marginLarge),

                        Center(
                          child: Text(
                            'Bạn có thể thêm hoặc cập nhật ảnh\nbất cứ lúc nào từ hồ sơ của bạn',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
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
