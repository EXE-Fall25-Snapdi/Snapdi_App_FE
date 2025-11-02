import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/data/models/user.dart';
import '../../../chat/data/services/chat_api_service.dart';
import '../../data/models/photographer_detail_response.dart';
import '../../data/models/photo_portfolio.dart';
import '../../domain/services/profile_service.dart';
import '../widgets/cloudinary_image.dart';

class PhotographerProfileScreen extends StatefulWidget {
  final int userId;

  const PhotographerProfileScreen({super.key, required this.userId});

  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState extends State<PhotographerProfileScreen> {
  final _tokenStorage = TokenStorage.instance;
  final _profileService = ProfileServiceImpl();
  final _chatApiService = ChatApiServiceImpl();

  User? _currentUser;
  PhotographerDetailResponse? _photographerDetail;
  List<PhotoPortfolio> _portfolios = [];
  bool _isLoading = true;
  bool _isCreatingConversation = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCurrentUser();
    await _loadPhotographerData();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userInfoJson = await _tokenStorage.getUserInfo();
      if (userInfoJson != null) {
        final userMap = jsonDecode(userInfoJson);
        setState(() {
          _currentUser = User.fromJson(userMap);
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadPhotographerData() async {
    setState(() {
      _isLoading = true;
    });

    // Load photographer profile
    final profileResult = await _profileService.getPhotographerProfile(
      widget.userId,
    );
    profileResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load photographer profile'),
            ),
          );
        }
      },
      (photographerDetail) {
        setState(() {
          _photographerDetail = photographerDetail;
          _portfolios = photographerDetail.photoPortfolios ?? [];
        });
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  bool get _isOwnProfile => _currentUser?.userId == widget.userId;
  bool get _isCustomerViewingPhotographer =>
      _currentUser?.roleId == 2 && !_isOwnProfile;
  bool get _isPhotographerViewingOwnProfile =>
      _currentUser?.roleId == 3 && _isOwnProfile;

  Future<void> _handleMessageButton() async {
    if (_isCreatingConversation) return;

    setState(() {
      _isCreatingConversation = true;
    });

    final result = await _chatApiService.createOrGetConversationWithUser(
      widget.userId,
    );

    setState(() {
      _isCreatingConversation = false;
    });

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start chat: ${failure.message}')),
          );
        }
      },
      (conversationId) {
        if (mounted) {
          context.push(
            '/chat/$conversationId',
            extra: _photographerDetail?.name,
          );
        }
      },
    );
  }

  void _handleUpdatePortfolio() {
    context.push('/manage-portfolio');
  }

  void _handleSettingsMenu() {
    // Navigate to settings screen (current ProfileScreen)
    context.push('/profile/${_currentUser?.userId}');
  }

  // =================================================================
  // PHẦN BUILD ĐÃ ĐƯỢC CẬP NHẬT
  // =================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final photographer = _photographerDetail;
    if (photographer == null) {
      return const Scaffold(
        body: Center(child: Text('Photographer not found')),
      );
    }

    // Giao diện mới dùng SingleChildScrollView và Column
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header mới với logo
              _buildHeader(),

              // 2. Thông tin profile mới (thay thế _buildProfileCard)
              _buildProfileInfoSection(),

              const SizedBox(height: 24),

              // 3. Nội dung chính (Portfolio) - (đã xóa Stats)
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  // =================================================================
  // CÁC WIDGET CON ĐÃ ĐƯỢC THAY ĐỔI / THÊM MỚI
  // =================================================================

  /// (MỚI) Widget header chỉ chứa logo
  Widget _buildHeader() {
    final photographer = _photographerDetail;
    if (photographer == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(), // 1. Đặt hình dạng là hình tròn
              padding: const EdgeInsets.all(
                12,
              ), // 2. Đặt kích thước đệm (thay đổi số này để nút to/nhỏ)
              backgroundColor: const Color(0xFF00D580), // 3. Đặt màu nền
              foregroundColor: Colors.black, // 4. Đặt màu cho icon bên trong
            ),
            child: const Icon(
              Icons.arrow_back, // Icon mũi tên quay lại
              size: 24, // Kích thước icon (tùy chọn)
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                photographer.name,
                style: AppTextStyles.headline4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          if (_isOwnProfile)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _handleSettingsMenu,
            ),
        ],
      ),
    );
  }

  /// (MỚI) Thay thế cho _buildProfileCard()
  /// Bố cục ngang: Avatar | Thông tin
  Widget _buildProfileInfoSection() {
    final photographer = _photographerDetail;
    if (photographer == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- 1. Avatar ---
          Container(
            width: 120, // Kích thước avatar nhỏ hơn
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: photographer.avatarUrl != null
                  ? CloudinaryImage(
                      publicId: photographer.avatarUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.greyLight,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photographer.photographerProfile?.description != null)
                SizedBox(
                  width: 200, // Giới hạn chiều rộng để tự động xuống dòng
                  child: Text(
                    photographer.photographerProfile?.description ??
                        'Chưa có mô tả',
                    style: AppTextStyles.bodyMedium,
                    maxLines: 3, // Tối đa 3 dòng
                    overflow: TextOverflow.ellipsis, // Hiển thị ... nếu quá dài
                    softWrap: true, // Tự động xuống dòng
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Nút "Nhắn tin" (chỉ cho khách hàng)
                  if (_isCustomerViewingPhotographer)
                    ElevatedButton(
                      onPressed: _isCreatingConversation
                          ? null
                          : _handleMessageButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: AppTextStyles.bodySmall, // Chữ nhỏ hơn
                      ),
                      child: _isCreatingConversation
                          ? const SizedBox(
                              width: 32,
                              height: 6,
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 20, 19, 19),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Nhắn tin'),
                    ),
                  if (_isPhotographerViewingOwnProfile)
                    ElevatedButton(
                      onPressed: _handleUpdatePortfolio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: AppTextStyles.bodySmall, // Chữ nhỏ hơn
                      ),
                      child: const Text('Cập nhật Portfolio'),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// (ĐÃ SỬA) Chỉ còn Portfolio title và Grid
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              // Dùng CrossAxisAlignment.center để icon và gạch chân
              // luôn thẳng hàng với nhau
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Icon 3x3
                Icon(Icons.apps, size: 28, color: AppColors.primary),

                const SizedBox(height: 6),

                // 2. Đường gạch ngang
                Container(
                  height: 4,
                  width: 28,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _portfolios.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No portfolio photos yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4, // Giảm khoảng cách cho giống hình
                    mainAxisSpacing: 4, // Giảm khoảng cách cho giống hình
                    childAspectRatio: 1,
                  ),
                  itemCount: _portfolios.length,
                  itemBuilder: (context, index) {
                    final portfolio = _portfolios[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4), // Bo góc nhẹ
                      child: CloudinaryImage(
                        publicId: portfolio.photoUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}


