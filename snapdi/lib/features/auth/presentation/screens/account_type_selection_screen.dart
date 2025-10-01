import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import 'sign_up_screen.dart';
import 'photographer_sign_up_screen.dart';

enum AccountType { user, snapper }

class AccountTypeSelectionScreen extends StatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  State<AccountTypeSelectionScreen> createState() => _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState extends State<AccountTypeSelectionScreen> {
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
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Title
                Text(
                  'Select your account type',
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppDimensions.marginXLarge * 2),
                
                // Account type cards
                Row(
                  children: [
                    Expanded(
                      child: _AccountTypeCard(
                        type: AccountType.snapper,
                        title: 'Snapper',
                        icon: Icons.camera_alt,
                        isSelected: _selectedAccountType == AccountType.snapper,
                        onTap: () => _handleAccountTypeSelection(AccountType.snapper),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _AccountTypeCard(
                        type: AccountType.user,
                        title: 'User',
                        icon: Icons.person,
                        isSelected: _selectedAccountType == AccountType.user,
                        onTap: () => _handleAccountTypeSelection(AccountType.user),
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
                    onPressed: _selectedAccountType != null ? _handleNext : null,
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
                      style: AppTextStyles.buttonLarge,
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
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.type,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSnapper = type == AccountType.snapper;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 120,
        decoration: BoxDecoration(
          color: isSelected 
              ? (isSnapper ? AppColors.primaryDark : AppColors.primary)
              : (isSnapper ? AppColors.primaryDark : AppColors.primary),
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: AppColors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with camera overlay for snapper
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSnapper ? AppColors.primaryDark : AppColors.primary,
                    size: 24,
                  ),
                ),
                if (isSnapper)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}