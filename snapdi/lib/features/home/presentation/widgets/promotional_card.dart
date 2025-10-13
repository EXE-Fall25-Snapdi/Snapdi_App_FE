import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_assets.dart';

class PromotionalCard extends StatefulWidget {
  const PromotionalCard({super.key});

  @override
  State<PromotionalCard> createState() => _PromotionalCardState();
}

class _PromotionalCardState extends State<PromotionalCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<String> _promotionImages = [
    AppAssets.promotion1,
    AppAssets.promotion2,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _promotionImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    _promotionImages[index],
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promotionImages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? AppColors.primaryDark
                    : AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}