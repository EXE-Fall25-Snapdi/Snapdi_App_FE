import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/data/models/user.dart';
import '../../data/models/photographer_detail_response.dart';
import '../../data/models/photo_portfolio.dart';
import '../../domain/services/profile_service.dart';
import 'manage_portfolio_screen.dart';
import 'account_settings_screen.dart';
import '../widgets/cloudinary_image.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _tokenStorage = TokenStorage.instance;
  final _profileService = ProfileServiceImpl();
  User? _currentUser;
  PhotographerDetailResponse? _photographerDetail;
  List<PhotoPortfolio> _portfolios = [];
  bool _isLoading = true;
  bool _isPhotographer = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfoJson = await _tokenStorage.getUserInfo();
      if (userInfoJson != null) {
        final userMap = jsonDecode(userInfoJson);
        final user = User.fromJson(userMap);
        setState(() {
          _currentUser = user;
          _isPhotographer = user.roleId == 3;
        });

        // If photographer, load photographer profile and portfolios
        if (_isPhotographer) {
          await _loadPhotographerData();
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPhotographerData() async {
    if (_currentUser == null) return;

    // Load photographer profile
    final profileResult = await _profileService.getPhotographerProfile(
      _currentUser!.userId,
    );
    profileResult.fold(
      (failure) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load photographer profile')),
          );
        }
      },
      (photographerDetail) {
        setState(() {
          _photographerDetail = photographerDetail;
        });
      },
    );

    // Load portfolios
    final portfoliosResult = await _profileService.getMyPortfolios();
    portfoliosResult.fold(
      (failure) {
        // Handle error - empty list is fine
        setState(() {
          _portfolios = [];
        });
      },
      (portfolios) {
        setState(() {
          _portfolios = portfolios;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent, // Nền Scaffold trong suốt
      body: Stack(
        children: [
          // LỚP NỀN 1 (Dưới cùng): 1 ảnh gradient cho TOÀN BỘ màn hình
          // (Giả sử ảnh này là gradient XANH ở trên và XÁM NHẠT ở dưới)
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundGradient, // Dùng 1 ảnh gradient duy nhất
              fit: BoxFit.cover,
            ),
          ),

          // LỚP 2: Toàn bộ nội dung cuộn (Profile, Stats, Menu)
          SingleChildScrollView(
            child: Column(
              children: [
                // Khoảng đệm cho Status bar và nút Back
                SizedBox(height: statusBarHeight + kToolbarHeight / 2),

                // Sử dụng Stack ở đây để chồng lấn Profile Card và Stats Card
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // NỘI DUNG CHÍNH (Stats + Menu)
                    // Bắt đầu từ dưới thẻ Profile
                    Padding(
                      // Đẩy nội dung xuống 1 nửa thẻ profile
                      // (Giả sử thẻ profile cao ~100px)
                      padding: const EdgeInsets.only(top: 60.0),
                      child: _buildMainContent(), // Hàm này chứa Stats + Menu
                    ),

                    // THẺ PROFILE (Nằm trên)
                    // _buildProfileCard đã có nền trắng và shadow
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                      ),
                      child: _buildProfileCard(),
                    ),
                  ],
                ),

                const SizedBox(height: 100), // Khoảng trống cuối cùng
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        if (_portfolios.isNotEmpty) ...[
          _buildStatsSection(),
          const SizedBox(height: AppDimensions.marginLarge),
        ] else ...[
          const SizedBox(height: AppDimensions.marginLarge * 6),
        ],

        // 1. Stats
        // 2. Các thẻ Menu
        // THAY ĐỔI 5: Thêm Padding cho các thẻ menu
        Padding(
          padding: const EdgeInsets.symmetric(),
          child: Column(
            children: [
              // Bỏ container thừa
              _buildMenuCard([
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Tài khoản',
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsScreen(),
                          ),
                        )
                        .then((updated) {
                          if (updated == true) {
                            _loadUserInfo(); // Reload user info after update
                          }
                        });
                  },
                ),
                _MenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Phương thức thanh toán',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Thành viên VIP',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.discount_outlined,
                  title: 'Mã giảm giá',
                  onTap: () {},
                ),
                // if (!_isPhotographer)
                //   _MenuItem(
                //     icon: Icons.camera_alt_outlined,
                //     title: 'Trở thành SNAPPER',
                //     onTap: () {},
                //   ),
                if (_isPhotographer)
                  _MenuItem(
                    icon: Icons.photo_library_outlined,
                    title: 'Quản lý Portfolio',
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => const ManagePortfolioScreen(),
                        ),
                      );
                    },
                  ),
              ]),

              const SizedBox(height: AppDimensions.marginLarge),

              // Bỏ container thừa
              _buildMenuCard([
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.language_outlined,
                  title: 'Ngôn ngữ',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.logout_outlined,
                  title: 'Đăng xuất',
                  onTap: () => _handleLogout(),
                  isDestructive: true,
                ),
              ]),

              const SizedBox(height: AppDimensions.marginLarge),
              // Các menu khác có thể thêm vào đây
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final userName = _currentUser?.name ?? 'Guest User';
    final avatarUrl = _currentUser?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    // Get photographer info
    final photographerProfile = _photographerDetail?.photographerProfile;
    final levelPhotographer =
        photographerProfile?.levelPhotographer ??
        (_isPhotographer && _portfolios.isEmpty ? 'Disabled' : null);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(82, 0, 0, 0),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with level photographer badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: hasAvatar
                        ? SizedBox(
                            width: 60,
                            height: 60,
                            child: CloudinaryImage(
                              publicId: avatarUrl,
                              width: 60,
                              height: 60,
                              crop: 'fill',
                              gravity: 'face',
                              quality: 80,
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                  // Level photographer badge
                  if (levelPhotographer != null)
                    Positioned(
                      bottom: -5,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: levelPhotographer == ''
                              ? AppColors.error
                              : AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          levelPhotographer == ''
                              ? 'Disabled'
                              : levelPhotographer,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTextStyles.headline4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_isPhotographer &&
                        photographerProfile != null &&
                        levelPhotographer == '' &&
                        _portfolios.isNotEmpty)
                      Text(
                        'Đang trong quá trình xác nhận level',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    if (_currentUser?.email != null)
                      Text(
                        _currentUser!.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Update portfolio button for disabled photographers
          if (_isPhotographer && _portfolios.isEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const ManagePortfolioScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Cập nhật Portfolio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    // THAY ĐỔI: Bỏ đi background và shadow, chỉ giữ lại nội dung
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),

      child: Column(
        children: [
          SizedBox(height: AppDimensions.paddingLarge + 10), // Bigger top space
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('0', 'Snapped'),
              _buildVerticalDivider(),
              _buildStatItem('0', 'Rate'),
              _buildVerticalDivider(),
              _buildStatItem('0', 'Coin'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: AppColors.greyLight);
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    // THAY ĐỔI: Đây là các thẻ menu riêng lẻ, nên cần có decoration riêng
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white, // Màu nền của thẻ
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          // Thêm shadow nhẹ để thẻ nổi bật hơn nền
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        // Clip để bo góc cho cả ListView
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(
                item.icon,
                color: item.isDestructive
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
              title: Text(
                item.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: item.isDestructive
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
              onTap: item.onTap,
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 1,
              thickness: 1,
              color: AppColors.greyLight,
              indent: 16,
              endIndent: 16,
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Giữ nguyên hàm này, không thay đổi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đăng xuất', style: AppTextStyles.headline4),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
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
              'Đăng xuất',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _tokenStorage.clearAll();
      if (mounted) {
        context.go('/');
      }
    }
  }
}

// Helper class for menu items - Giữ nguyên
class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}
