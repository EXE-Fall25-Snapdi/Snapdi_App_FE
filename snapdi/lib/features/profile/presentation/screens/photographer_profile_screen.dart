import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
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
  State<PhotographerProfileScreen> createState() => _PhotographerProfileScreenState();
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
            const SnackBar(content: Text('Failed to load photographer profile')),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundGradient,
              fit: BoxFit.cover,
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: statusBarHeight + 16),

                // Back button and settings menu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      if (_isOwnProfile)
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: _handleSettingsMenu,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Profile card with overlapping content
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Main content (stats + portfolio)
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: _buildMainContent(),
                    ),

                    // Profile card (floating on top)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildProfileCard(),
                    ),
                  ],
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final photographer = _photographerDetail;
    if (photographer == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: ClipOval(
              child: photographer.avatarUrl != null
                  ? CloudinaryImage(
                      publicId: photographer.avatarUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.greyLight,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            photographer.name,
            style: AppTextStyles.headline3.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Level and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  photographer.photographerProfile?.levelPhotographer ?? 'Photographer',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    (photographer.photographerProfile?.avgRating ?? 0.0)
                        .toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (photographer.photographerProfile?.description != null) ...[
            const SizedBox(height: 12),
            Text(
              photographer.photographerProfile!.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // Action button
          if (_isCustomerViewingPhotographer)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingConversation ? null : _handleMessageButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreatingConversation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.message, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Message',
                            style: AppTextStyles.buttonLarge,
                          ),
                        ],
                      ),
              ),
            )
          else if (_isPhotographerViewingOwnProfile)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleUpdatePortfolio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Update Portfolio',
                      style: AppTextStyles.buttonLarge,
                    ),
                  ],
                ),
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
          const SizedBox(height: 24),
        ] else ...[
          const SizedBox(height: 80),
        ],

        // Portfolio section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portfolio',
                style: AppTextStyles.headline4.copyWith(
                  fontWeight: FontWeight.bold,
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
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _portfolios.length,
                      itemBuilder: (context, index) {
                        final portfolio = _portfolios[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '${_portfolios.length}',
              'Photos',
              Icons.photo_library,
            ),
            _buildDivider(),
            _buildStatItem(
              _photographerDetail?.photographerProfile?.yearsOfExperience ?? '0',
              'Experience',
              Icons.work,
            ),
            _buildDivider(),
            _buildStatItem(
              '0',
              'Followers',
              Icons.people,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headline4.copyWith(
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.greyLight,
    );
  }
}

