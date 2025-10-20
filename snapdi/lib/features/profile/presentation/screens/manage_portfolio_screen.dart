import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_theme.dart';
import '../../domain/services/portfolio_service.dart';
import '../../domain/services/profile_service.dart';
import '../../data/models/photo_portfolio.dart';
import '../widgets/cloudinary_image.dart';

class ManagePortfolioScreen extends StatefulWidget {
  const ManagePortfolioScreen({super.key});

  @override
  State<ManagePortfolioScreen> createState() => _ManagePortfolioScreenState();
}

class _ManagePortfolioScreenState extends State<ManagePortfolioScreen> {
  final _portfolioService = PortfolioServiceImpl();
  final _profileService = ProfileServiceImpl();
  final _imagePicker = ImagePicker();

  List<PhotoPortfolio> _portfolios = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolios();
  }

  Future<void> _loadPortfolios() async {
    setState(() => _isLoading = true);

    final result = await _profileService.getMyPortfolios();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load portfolios: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() {
          _portfolios = [];
          _isLoading = false;
        });
      },
      (portfolios) {
        setState(() {
          _portfolios = portfolios;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _pickAndUploadImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85);

      if (pickedFiles.isEmpty) return;

      setState(() => _isUploading = true);

      // Convert XFile to File
      final imageFiles = pickedFiles.map((xFile) => File(xFile.path)).toList();

      // Upload to Cloudinary
      final uploadResult = await _portfolioService.uploadImagesToCloudinary(
        imageFiles,
        'portfolio',
      );

      await uploadResult.fold(
        (failure) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        (uploadResponse) async {
          // Get uploaded publicIds instead of URLs
          final publicIds = uploadResponse.successfulUploads
              .map((upload) => upload.publicId)
              .toList();

          if (publicIds.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No images were uploaded successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }

          // Create portfolio entries with publicIds
          final createResult = await _portfolioService.createMultiplePortfolios(
            publicIds,
          );

          createResult.fold(
            (failure) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to save portfolios: ${failure.message}',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            (createResponse) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(createResponse.message),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
              _loadPortfolios();
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deletePortfolio(PhotoPortfolio portfolio) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa ảnh', style: AppTextStyles.headline4),
        content: Text(
          'Bạn có chắc chắn muốn xóa ảnh này khỏi portfolio?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Xóa',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // photoUrl now contains publicId directly
    final publicId = portfolio.photoUrl;

    // Delete from database
    final deleteResult = await _portfolioService.deletePortfolio(
      portfolio.photoPortfolioId,
    );

    await deleteResult.fold(
      (failure) async {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      (_) async {
        // Delete from Cloudinary using publicId
        await _portfolioService.deleteFromCloudinary(publicId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh đã được xóa'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        _loadPortfolios();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý Portfolio',
          style: AppTextStyles.headline3.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: _isUploading
          ? const CircularProgressIndicator()
          : FloatingActionButton.extended(
              onPressed: _pickAndUploadImages,
              backgroundColor: AppColors.primary,
              icon: const Icon(
                Icons.add_photo_alternate,
                color: AppColors.white,
              ),
              label: Text(
                'Thêm ảnh',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_portfolios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có ảnh trong portfolio',
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm ảnh để admin có thể đánh giá cấp độ của bạn',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _portfolios.length,
      itemBuilder: (context, index) {
        final portfolio = _portfolios[index];
        return _buildPortfolioItem(portfolio);
      },
    );
  }

  Widget _buildPortfolioItem(PhotoPortfolio portfolio) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CloudinaryImage(
                publicId: portfolio.photoUrl,
                width: 400,
                height: 400,
                crop: 'fill',
                quality: 80,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white, size: 20),
              onPressed: () => _deletePortfolio(portfolio),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}
