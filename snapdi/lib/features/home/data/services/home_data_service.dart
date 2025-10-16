import 'package:flutter/material.dart';

// Mock data and services for Home Screen
class HomeDataService {
  // Mock user data
  static String getUserGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 17) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }
  
  static String getUserName() {
    // TODO: Get from user session/storage
    return 'Per';
  }
  
  // Mock promotional data
  static List<PromotionalData> getPromotionalCards() {
    return [
      PromotionalData(
        id: '1',
        title: 'PHOTO COMPETITION',
        subtitle: 'Win amazing prizes!',
        description: 'Join our monthly photo competition and showcase your creativity.',
        buttonText: 'Join Now',
        gradientColors: const [
          Color(0xFF81C784),
          Color(0xFF4FC3F7),
        ],
      ),
      PromotionalData(
        id: '2',
        title: 'FLASH SALE',
        subtitle: '50% off all sessions!',
        description: 'Limited time offer for professional photography sessions.',
        buttonText: 'Book Now',
        gradientColors: const [
          Color(0xFFFF8A65),
          Color(0xFFFF7043),
        ],
      ),
      PromotionalData(
        id: '3',
        title: 'VIP MEMBERSHIP',
        subtitle: 'Unlock premium features',
        description: 'Get priority booking and exclusive photographer access.',
        buttonText: 'Upgrade',
        gradientColors: const [
          Color(0xFFBA68C8),
          Color(0xFF9C27B0),
        ],
      ),
    ];
  }
}

class PromotionalData {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String buttonText;
  final List<Color> gradientColors;

  const PromotionalData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonText,
    required this.gradientColors,
  });
}