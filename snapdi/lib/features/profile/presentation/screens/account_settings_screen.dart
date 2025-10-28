import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_theme.dart';
import '../../domain/services/user_service.dart';
import '../../domain/services/cloudinary_service.dart';
import '../../domain/services/profile_service.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/update_user_request.dart';
import '../widgets/cloudinary_image.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _userService = UserServiceImpl();
  final _cloudinaryService = CloudinaryServiceImpl();
  final _profileService = ProfileServiceImpl();
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workLocationController = TextEditingController();

  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  File? _selectedImage;
  bool _isPhotographer = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _workLocationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    final result = await _userService.getCurrentUserProfile();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load profile: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isLoading = false);
      },
      (profile) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.name;
          _phoneController.text = profile.phone;
          _addressController.text = profile.locationAddress ?? '';
          _cityController.text = profile.locationCity ?? '';
          _isPhotographer = profile.roleId == 3; // 3 is PHOTOGRAPHER role

          // Load photographer fields if available
          if (profile.photographerProfile != null) {
            _descriptionController.text =
                profile.photographerProfile!.description ?? '';
            _workLocationController.text =
                profile.photographerProfile!.workLocation ?? '';
          }

          _isLoading = false;
        });
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_selectedImage == null) return null;

    // If user already has an avatar publicId, delete the old one first
    // if (_userProfile?.avatarUrl != null &&
    //     _userProfile!.avatarUrl!.isNotEmpty) {
    //   await _cloudinaryService.deleteImage(_userProfile!.avatarUrl!);
    // }

    final uploadResult = await _cloudinaryService.uploadSingleImage(
      _selectedImage!,
      publicId: 'avatar',
      uploadType: 'avatar',
      overwrite: true,
    );

    return uploadResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload avatar: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return null;
      },
      (uploadResponse) {
        // Return publicId instead of URL
        return uploadResponse.publicId;
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userProfile == null) return;

    setState(() => _isSaving = true);

    // Upload avatar if a new image was selected
    String? avatarPublicId =
        _userProfile!.avatarUrl; // avatarUrl now stores publicId
    if (_selectedImage != null) {
      final uploadedPublicId = await _uploadAvatar();
      if (uploadedPublicId != null) {
        avatarPublicId = uploadedPublicId;
      } else {
        setState(() => _isSaving = false);
        return;
      }
    }

    // Update user profile
    final request = UpdateUserRequest(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      locationAddress: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      locationCity: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      avatarUrl: avatarPublicId, // Store publicId instead of URL
    );

    final result = await _userService.updateUser(_userProfile!.userId, request);

    if (!mounted) return;

    bool userUpdateSuccess = false;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isSaving = false);
      },
      (updatedProfile) {
        userUpdateSuccess = true;
        setState(() {
          _userProfile = updatedProfile;
          _selectedImage = null;
        });
      },
    );

    // If user update failed, don't continue
    if (!userUpdateSuccess) return;

    // If photographer, also update photographer profile
    if (_isPhotographer) {
      final photographerResult = await _profileService
          .updatePhotographerProfile(
            _userProfile!.userId,
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            _workLocationController.text.trim().isEmpty
                ? null
                : _workLocationController.text.trim(),
          );

      if (!mounted) return;

      photographerResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User updated but failed to update photographer profile: ${failure.message}',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
          setState(() => _isSaving = false);
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() => _isSaving = false);
          Navigator.pop(context, true); // Return true to indicate success
        },
      );
    } else {
      // Not a photographer, just show success for user update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() => _isSaving = false);
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tài khoản',
          style: AppTextStyles.headline3.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          if (!_isLoading && !_isSaving)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Lưu',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar section
                    const SizedBox(height: 20),
                    _buildAvatarSection(),
                    const SizedBox(height: 32),

                    // Account info
                    _buildInfoCard(),
                    const SizedBox(height: 16),

                    // Form fields
                    _buildFormFields(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    final avatarPublicId = _userProfile?.avatarUrl; // avatarUrl stores publicId
    final hasAvatar = avatarPublicId != null && avatarPublicId.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            // Show selected image if user picked one
            if (_selectedImage != null)
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.greyLight,
                backgroundImage: FileImage(_selectedImage!),
              )
            // Show CloudinaryImage if user has avatar publicId
            else if (hasAvatar)
              ClipOval(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CloudinaryImage(
                    publicId: avatarPublicId,
                    width: 200,
                    height: 200,
                    crop: 'fill',
                    gravity: 'face',
                    quality: 80,
                    placeholder: const CircularProgressIndicator(),
                    errorWidget: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            // Show default icon if no avatar
            else
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.greyLight,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.textSecondary,
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 20,
                  ),
                  onPressed: _pickImage,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Nhấn vào camera để thay đổi ảnh đại diện',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.email, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _userProfile?.email ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.badge, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vai trò',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _userProfile?.roleName ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin cá nhân',
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),

        // Name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Họ và tên *',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Số điện thoại *',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Address
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Địa chỉ',
            prefixIcon: const Icon(Icons.home_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // City
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'Thành phố',
            prefixIcon: const Icon(Icons.location_city_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // Photographer-specific fields
        if (_isPhotographer) ...[
          const SizedBox(height: 24),
          Text(
            'Thông tin Photographer',
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Mô tả',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Giới thiệu ngắn gọn về bản thân',
            ),
            maxLines: 2,
            maxLength: 50,
          ),
          const SizedBox(height: 16),

          // Work Location
          TextFormField(
            controller: _workLocationController,
            decoration: InputDecoration(
              labelText: 'Địa điểm làm việc',
              prefixIcon: const Icon(Icons.work_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Ví dụ: TP. Hồ Chí Minh, Hà Nội',
            ),
            maxLength: 255,
          ),
        ],
      ],
    );
  }
}
