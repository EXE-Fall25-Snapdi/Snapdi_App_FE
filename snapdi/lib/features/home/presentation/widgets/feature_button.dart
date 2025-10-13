import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';

class FeatureButton extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const FeatureButton({
    super.key,
    this.icon,
    this.iconPath,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  }) : assert(icon != null || iconPath != null, 'Either icon or iconPath must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: iconPath != null
                  ? SvgPicture.asset(
                      iconPath!,
                      width: 30,
                      height: 30,
                    )
                  : Icon(
                      icon!,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}