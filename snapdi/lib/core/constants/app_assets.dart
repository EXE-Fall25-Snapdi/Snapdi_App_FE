/// Central asset management class for Snapdi app
/// 
/// This class provides type-safe access to all app assets including:
/// - Images (photos, backgrounds, placeholders)
/// - Icons (UI icons, social media icons)  
/// - Logos (brand assets, partner logos)
/// - Animations (Lottie files, GIFs)
class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  // ==========================================================================
  // IMAGES
  // ==========================================================================
  
  /// App Images
  static const String _imagesPath = 'assets/images';
  
  // Backgrounds
  static const String backgroundGradient = '$_imagesPath/background_gradient.png';
  static const String backgroundPattern = '$_imagesPath/background_pattern.png';
  
  // Placeholders
  static const String userPlaceholder = '$_imagesPath/user_placeholder.png';
  static const String photoPlaceholder = '$_imagesPath/photo_placeholder.png';
  static const String portfolioPlaceholder = '$_imagesPath/portfolio_placeholder.png';
  
  // Onboarding
  static const String onboardingImage1 = '$_imagesPath/onboarding_1.png';
  static const String onboardingImage2 = '$_imagesPath/onboarding_2.png';
  static const String onboardingImage3 = '$_imagesPath/onboarding_3.png';
  
  // Sample Photos
  static const String samplePhotographer1 = '$_imagesPath/photographer_1.jpg';
  static const String samplePhotographer2 = '$_imagesPath/photographer_2.jpg';
  static const String samplePortfolio1 = '$_imagesPath/portfolio_1.jpg';
  static const String samplePortfolio2 = '$_imagesPath/portfolio_2.jpg';

  // ==========================================================================
  // ICONS
  // ==========================================================================
  
  /// App Icons
  static const String _iconsPath = 'assets/icons';
  
  // Navigation Icons
  static const String homeIcon = '$_iconsPath/home.png';
  static const String searchIcon = '$_iconsPath/search.png';
  static const String bookingIcon = '$_iconsPath/booking.png';
  static const String profileIcon = '$_iconsPath/profile.png';
  static const String cameraIcon = '$_iconsPath/camera.png';
  
  // Action Icons
  static const String heartIcon = '$_iconsPath/heart.png';
  static const String heartFilledIcon = '$_iconsPath/heart_filled.png';
  static const String starIcon = '$_iconsPath/star.png';
  static const String starFilledIcon = '$_iconsPath/star_filled.png';
  static const String shareIcon = '$_iconsPath/share.png';
  static const String chatIcon = '$_iconsPath/chat.png';
  static const String phoneIcon = '$_iconsPath/phone.png';
  static const String mailIcon = '$_iconsPath/mail.png';
  
  // Category Icons
  static const String weddingIcon = '$_iconsPath/wedding.png';
  static const String portraitIcon = '$_iconsPath/portrait.png';
  static const String eventIcon = '$_iconsPath/event.png';
  static const String fashionIcon = '$_iconsPath/fashion.png';
  static const String natureIcon = '$_iconsPath/nature.png';
  static const String architectureIcon = '$_iconsPath/architecture.png';

  // ==========================================================================
  // LOGOS
  // ==========================================================================
  
  /// App Logos and Brand Assets
  static const String _logosPath = 'assets/logos';
  
  // Main Logos
  static const String snapdiLogo = '$_logosPath/snapdi_logo.png';
  static const String snapdiLogoWhite = '$_logosPath/snapdi_logo_white.png';
  static const String snapdiLogoIcon = '$_logosPath/snapdi_icon.png';
  
  // Social Media Logos
  static const String googleLogo = '$_logosPath/google_logo.png';
  static const String facebookLogo = '$_logosPath/facebook_logo.png';
  static const String instagramLogo = '$_logosPath/instagram_logo.png';
  static const String twitterLogo = '$_logosPath/twitter_logo.png';
  static const String linkedinLogo = '$_logosPath/linkedin_logo.png';
  
  // Payment Logos
  static const String visaLogo = '$_logosPath/visa_logo.png';
  static const String mastercardLogo = '$_logosPath/mastercard_logo.png';
  static const String paypalLogo = '$_logosPath/paypal_logo.png';

  // ==========================================================================
  // ANIMATIONS
  // ==========================================================================
  
  /// Animations and Lottie Files
  static const String _animationsPath = 'assets/animations';
  
  // Loading Animations
  static const String loadingAnimation = '$_animationsPath/loading.json';
  static const String cameraLoadingAnimation = '$_animationsPath/camera_loading.json';
  
  // Success/Error Animations
  static const String successAnimation = '$_animationsPath/success.json';
  static const String errorAnimation = '$_animationsPath/error.json';
  static const String emptyStateAnimation = '$_animationsPath/empty_state.json';
  
  // Onboarding Animations
  static const String welcomeAnimation = '$_animationsPath/welcome.json';
  static const String photographerAnimation = '$_animationsPath/photographer.json';
  static const String bookingAnimation = '$_animationsPath/booking.json';

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================
  
  /// Get all image assets
  static List<String> get allImages => [
    backgroundGradient,
    backgroundPattern,
    userPlaceholder,
    photoPlaceholder,
    portfolioPlaceholder,
    onboardingImage1,
    onboardingImage2,
    onboardingImage3,
    samplePhotographer1,
    samplePhotographer2,
    samplePortfolio1,
    samplePortfolio2,
  ];
  
  /// Get all icon assets
  static List<String> get allIcons => [
    homeIcon,
    searchIcon,
    bookingIcon,
    profileIcon,
    cameraIcon,
    heartIcon,
    heartFilledIcon,
    starIcon,
    starFilledIcon,
    shareIcon,
    chatIcon,
    phoneIcon,
    mailIcon,
    weddingIcon,
    portraitIcon,
    eventIcon,
    fashionIcon,
    natureIcon,
    architectureIcon,
  ];
  
  /// Get all logo assets
  static List<String> get allLogos => [
    snapdiLogo,
    snapdiLogoWhite,
    snapdiLogoIcon,
    googleLogo,
    facebookLogo,
    instagramLogo,
    twitterLogo,
    linkedinLogo,
    visaLogo,
    mastercardLogo,
    paypalLogo,
  ];
  
  /// Get all animation assets
  static List<String> get allAnimations => [
    loadingAnimation,
    cameraLoadingAnimation,
    successAnimation,
    errorAnimation,
    emptyStateAnimation,
    welcomeAnimation,
    photographerAnimation,
    bookingAnimation,
  ];
  
  /// Get all assets
  static List<String> get allAssets => [
    ...allImages,
    ...allIcons,
    ...allLogos,
    ...allAnimations,
  ];
}