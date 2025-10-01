import 'package:flutter/foundation.dart';

/// Environment configuration class for managing app environment variables
/// This class provides a centralized way to access environment-specific configurations
class Environment {
  // Private constructor to prevent instantiation
  Environment._();

  /// Current environment mode
  static const String environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: kDebugMode ? 'development' : 'production',
  );

  /// API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://10.0.2.2:7000',
  );

  static const String applicationUrl = String.fromEnvironment(
    'APPLICATION_URL',
    defaultValue: 'https://10.0.2.2:7000',
  );

  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  /// Authentication Configuration
  static const String jwtSecretKey = String.fromEnvironment(
    'JWT_SECRET_KEY',
    defaultValue: '',
  );

  static const String refreshTokenExpiry = String.fromEnvironment(
    'REFRESH_TOKEN_EXPIRY',
    defaultValue: '7d',
  );

  static const String accessTokenExpiry = String.fromEnvironment(
    'ACCESS_TOKEN_EXPIRY',
    defaultValue: '1h',
  );

  /// Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  static const String firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: '',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: '',
  );

  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );

  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  );

  /// Google Services Configuration
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  /// Payment Services Configuration
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String paypalClientId = String.fromEnvironment(
    'PAYPAL_CLIENT_ID',
    defaultValue: '',
  );

  /// Social Login Configuration
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const String facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '',
  );

  static const String appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Development Configuration
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: kDebugMode,
  );

  static const String logLevel = String.fromEnvironment(
    'LOG_LEVEL',
    defaultValue: 'info',
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const bool mockApiResponses = bool.fromEnvironment(
    'MOCK_API_RESPONSES',
    defaultValue: false,
  );

  /// File Upload Configuration
  static const int maxImageSizeMB = int.fromEnvironment(
    'MAX_IMAGE_SIZE_MB',
    defaultValue: 10,
  );

  static const int maxImagesPerUpload = int.fromEnvironment(
    'MAX_IMAGES_PER_UPLOAD',
    defaultValue: 20,
  );

  static const String allowedImageFormats = String.fromEnvironment(
    'ALLOWED_IMAGE_FORMATS',
    defaultValue: 'jpg,jpeg,png,webp,heic',
  );

  /// Business Configuration
  static const String _platformCommissionRateStr = String.fromEnvironment(
    'PLATFORM_COMMISSION_RATE',
    defaultValue: '0.15',
  );
  
  static double get platformCommissionRate => double.tryParse(_platformCommissionRateStr) ?? 0.15;

  static const int minBookingAmount = int.fromEnvironment(
    'MIN_BOOKING_AMOUNT',
    defaultValue: 50,
  );

  static const int maxBookingAmount = int.fromEnvironment(
    'MAX_BOOKING_AMOUNT',
    defaultValue: 10000,
  );

  static const String defaultCountry = String.fromEnvironment(
    'DEFAULT_COUNTRY',
    defaultValue: 'US',
  );

  static const String defaultCurrency = String.fromEnvironment(
    'DEFAULT_CURRENCY',
    defaultValue: 'USD',
  );

  /// Feature Flags
  static const bool enableChatFeature = bool.fromEnvironment(
    'ENABLE_CHAT_FEATURE',
    defaultValue: true,
  );

  static const bool enableVideoCalls = bool.fromEnvironment(
    'ENABLE_VIDEO_CALLS',
    defaultValue: false,
  );

  static const bool enableLiveStreaming = bool.fromEnvironment(
    'ENABLE_LIVE_STREAMING',
    defaultValue: false,
  );

  static const bool enableAiRecommendations = bool.fromEnvironment(
    'ENABLE_AI_RECOMMENDATIONS',
    defaultValue: true,
  );

  static const bool enableGeolocation = bool.fromEnvironment(
    'ENABLE_GEOLOCATION',
    defaultValue: true,
  );

  /// Analytics Configuration
  static const String googleAnalyticsId = String.fromEnvironment(
    'GOOGLE_ANALYTICS_ID',
    defaultValue: '',
  );

  static const String mixpanelToken = String.fromEnvironment(
    'MIXPANEL_TOKEN',
    defaultValue: '',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Convenience getters
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isTesting => environment == 'testing';

  /// Get full API URL
  static String get fullApiUrl => '$apiBaseUrl/$apiVersion';

  /// Get allowed image formats as list
  static List<String> get allowedImageFormatsList =>
      allowedImageFormats.split(',').map((e) => e.trim()).toList();

  /// Validate if required environment variables are set
  static bool validateEnvironment() {
    if (isProduction) {
      // In production, ensure critical variables are set
      return apiBaseUrl.isNotEmpty &&
          firebaseProjectId.isNotEmpty &&
          stripePublishableKey.isNotEmpty;
    }
    return true; // Allow missing variables in development
  }

  /// Print environment configuration (excluding sensitive data)
  static void printConfiguration() {
    if (debugMode) {
      print('=== Environment Configuration ===');
      print('Environment: $environment');
      print('API Base URL: $apiBaseUrl');
      print('API Version: $apiVersion');
      print('Debug Mode: $debugMode');
      print('Mock API Responses: $mockApiResponses');
      print('Chat Feature: $enableChatFeature');
      print('Video Calls: $enableVideoCalls');
      print('AI Recommendations: $enableAiRecommendations');
      print('Geolocation: $enableGeolocation');
      print('===============================');
    }
  }
}