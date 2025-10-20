import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import 'sign_up_screen.dart';
import 'photographer_sign_up_screen.dart';

enum AccountType { user, snapper }

class AccountTypeSelectionScreen extends StatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  State<AccountTypeSelectionScreen> createState() =>
      _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState
    extends State<AccountTypeSelectionScreen> {
  AccountType? _selectedAccountType;

  void _handleAccountTypeSelection(AccountType type) {
    setState(() {
      _selectedAccountType = type;
    });
  }

  void _handleNext() {
    if (_selectedAccountType != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _selectedAccountType == AccountType.snapper
              ? PhotographerSignUpScreen(accountType: _selectedAccountType!)
              : SignUpScreen(accountType: _selectedAccountType!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an account type',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.backgroundWhite),
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              children: [
                const Spacer(flex: 2),

                const SizedBox(height: AppDimensions.marginXLarge * 2),

                // Title
                Text(
                  'Select your account type',
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.marginMedium),

                // Account type cards
                Row(
                  children: [
                    Expanded(
                      child: _AccountTypeCard(
                        type: AccountType.snapper,
                        title: 'Snapper',
                        iconAsset: AppAssets.snapperAccountIcon,
                        isSelected: _selectedAccountType == AccountType.snapper,
                        onTap: () =>
                            _handleAccountTypeSelection(AccountType.snapper),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _AccountTypeCard(
                        type: AccountType.user,
                        title: 'User',
                        iconAsset: AppAssets.userAccountIcon,
                        isSelected: _selectedAccountType == AccountType.user,
                        onTap: () =>
                            _handleAccountTypeSelection(AccountType.user),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // Next button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedAccountType != null
                        ? _handleNext
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedAccountType != null
                          ? AppColors.primary
                          : AppColors.grey,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final AccountType type;
  final String title;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.type,
    required this.title,
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSnapper = type == AccountType.snapper;
    final backgroundColor = isSnapper
        ? AppColors.primaryDarker
        : AppColors.primary;
    final textColor = isSnapper ? AppColors.primary : AppColors.black;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(3, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom asset icon
            SizedBox(
              width: 95,
              height: 95,

              child: Padding(
                padding: const EdgeInsets.all(3),
                child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
