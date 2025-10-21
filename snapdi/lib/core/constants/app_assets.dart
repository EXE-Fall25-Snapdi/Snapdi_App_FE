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
  static const String backgroundGradient =
      '$_imagesPath/background_gradient.png';
  static const String backgroundWhite = '$_imagesPath/background_white.png';
  static const String backgroundFinding = '$_imagesPath/background_finding.png';
  static const String backgroundFound = '$_imagesPath/background_found.png';

  // Mascots
  static const String mascot = '$_imagesPath/mascot.png';
  static const String mascotWave = '$_imagesPath/mascot_wave.png';

  // Placeholders
  static const String userPlaceholder = '$_imagesPath/user_placeholder.png';
  static const String photoPlaceholder = '$_imagesPath/photo_placeholder.png';
  static const String portfolioPlaceholder =
      '$_imagesPath/portfolio_placeholder.png';

  // Promotions
  static const String promotion1 = '$_imagesPath/promotion1.png';
  static const String promotion2 = '$_imagesPath/promotion2.png';

  // Locations
  static const String locationImage1 = '$_imagesPath/location_image_1.png';
  static const String locationImage2 = '$_imagesPath/location_image_2.png';
  static const String locationImage3 = '$_imagesPath/location_image_3.png';
  static const String screenSaleBag = '$_imagesPath/screen_saleBag.png';

  // Onboarding
  // static const String onboardingImage1 = '$_imagesPath/onboarding_1.png';
  // static const String onboardingImage2 = '$_imagesPath/onboarding_2.png';
  // static const String onboardingImage3 = '$_imagesPath/onboarding_3.png';

  // Sample Photos
  // static const String samplePhotographer1 = '$_imagesPath/photographer_1.jpg';
  // static const String samplePhotographer2 = '$_imagesPath/photographer_2.jpg';
  // static const String samplePortfolio1 = '$_imagesPath/portfolio_1.jpg';
  // static const String samplePortfolio2 = '$_imagesPath/portfolio_2.jpg';

  // ==========================================================================
  // ICONS
  // ==========================================================================

  /// App Icons
  static const String _iconsPath = 'assets/icons';

  // Navigation Icons
  static const String homeIcon = '$_iconsPath/navbar_home.svg';
  static const String exploreIcon = '$_iconsPath/navbar_explore.svg';
  static const String historyIcon = '$_iconsPath/navbar_history.svg';
  static const String profileIcon = '$_iconsPath/navbar_profile.svg';
  static const String cameraIcon = '$_iconsPath/navbar_camera.svg';

  // Action Icons
  static const String allIcon = '$_iconsPath/all_icon.svg';
  static const String bookIcon = '$_iconsPath/book_icon.svg';
  static const String menuIcon = '$_iconsPath/menu_icon.svg';
  static const String notifyIcon = '$_iconsPath/notify_icon.svg';
  static const String nowIcon = '$_iconsPath/now_icon.svg';
  static const String paymentIcon = '$_iconsPath/payment_icon.svg';
  static const String vipIcon = '$_iconsPath/vip_icon.svg';
  static const String vouncherIcon = '$_iconsPath/voucher_icon.svg';
  static const String searchIcon = '$_iconsPath/search_icon.svg';
  static const String locationIcon = '$_iconsPath/location_icon.svg';
  static const String whiteLocationIcon = '$_iconsPath/white_location_icon.svg';
  static const String activeLocationIcon =
      '$_iconsPath/active_location_icon.svg';
  static const String mapIcon = '$_iconsPath/map_icon.svg';
  static const String starIcon = '$_iconsPath/star.svg';
  static const String filledStarIcon = '$_iconsPath/filled_star.svg';
  static const String halfStarIcon = '$_iconsPath/half_filled_star.svg';
  static const String camera_altIcon = '$_iconsPath/camera_icon.svg';

  // Account Type Icons
  static const String snapperAccountIcon = '$_iconsPath/snaper_acc_icon.svg';
  static const String userAccountIcon = '$_iconsPath/user_acc_icon.svg';

  // Category Icons
  // static const String weddingIcon = '$_iconsPath/wedding.png';
  // static const String portraitIcon = '$_iconsPath/portrait.png';
  // static const String eventIcon = '$_iconsPath/event.png';
  // static const String fashionIcon = '$_iconsPath/fashion.png';
  // static const String natureIcon = '$_iconsPath/nature.png';
  // static const String architectureIcon = '$_iconsPath/architecture.png';

  // ==========================================================================
  // LOGOS
  // ==========================================================================

  /// App Logos and Brand Assets
  static const String _logosPath = 'assets/logos';

  // Main Logos

  // static const String snapdiLogoWhite = '$_logosPath/snapdi_logo_white.png';
  static const String snapdiLogo = '$_logosPath/logo.svg';
  static const String snapdiLogoIcon = '$_logosPath/snapdi_icon.png';

  // Social Media Logos
  // static const String googleLogo = '$_logosPath/google_logo.png';
  // static const String facebookLogo = '$_logosPath/facebook_logo.png';
  // static const String instagramLogo = '$_logosPath/instagram_logo.png';
  // static const String twitterLogo = '$_logosPath/twitter_logo.png';
  // static const String linkedinLogo = '$_logosPath/linkedin_logo.png';

  // Payment Logos
  // static const String visaLogo = '$_logosPath/visa_logo.png';
  // static const String mastercardLogo = '$_logosPath/mastercard_logo.png';
  // static const String paypalLogo = '$_logosPath/paypal_logo.png';

  // ==========================================================================
  // ANIMATIONS
  // ==========================================================================

  // Animations and Lottie Files
  // static const String _animationsPath = 'assets/animations';

  // Loading Animations
  // static const String loadingAnimation = '$_animationsPath/loading.json';
  // static const String cameraLoadingAnimation = '$_animationsPath/camera_loading.json';

  // Success/Error Animations
  // static const String successAnimation = '$_animationsPath/success.json';
  // static const String errorAnimation = '$_animationsPath/error.json';
  // static const String emptyStateAnimation = '$_animationsPath/empty_state.json';

  // Onboarding Animations
  // static const String welcomeAnimation = '$_animationsPath/welcome.json';
  // static const String photographerAnimation = '$_animationsPath/photographer.json';
  // static const String bookingAnimation = '$_animationsPath/booking.json';

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Get all image assets
  static List<String> get allImages => [
    backgroundGradient,
    backgroundWhite,
    backgroundFinding,
    backgroundFound,
    userPlaceholder,
    photoPlaceholder,
    portfolioPlaceholder,
    mascot,
    mascotWave,
    promotion1,
    promotion2,
    locationImage1,
    locationImage2,
    locationImage3,
    screenSaleBag,
    // onboardingImage1,
    // onboardingImage2,
    // onboardingImage3,
    // samplePhotographer1,
    // samplePhotographer2,
    // samplePortfolio1,
    // samplePortfolio2,
  ];

  /// Get all icon assets
  static List<String> get allIcons => [
    homeIcon,
    exploreIcon,
    historyIcon,
    profileIcon,
    cameraIcon,
    allIcon,
    bookIcon,
    menuIcon,
    notifyIcon,
    nowIcon,
    paymentIcon,
    vipIcon,
    vouncherIcon,
    searchIcon,
    locationIcon,
    whiteLocationIcon,
    activeLocationIcon,
    mapIcon,
    starIcon,
    filledStarIcon,
    halfStarIcon,
    camera_altIcon,
    snapperAccountIcon,
    userAccountIcon,
    // weddingIcon,
    // portraitIcon,
    // eventIcon,
    // fashionIcon,
    // natureIcon,
    // architectureIcon,
  ];

  /// Get all logo assets
  static List<String> get allLogos => [
    snapdiLogo,
    // snapdiLogoWhite,
    snapdiLogoIcon,
    // googleLogo,
    // facebookLogo,
    // instagramLogo,
    // twitterLogo,
    // linkedinLogo,
    // visaLogo,
    // mastercardLogo,
    // paypalLogo,
  ];

  /// Get all animation assets
  static List<String> get allAnimations => [
    // loadingAnimation,
    // cameraLoadingAnimation,
    // successAnimation,
    // errorAnimation,
    // emptyStateAnimation,
    // welcomeAnimation,
    // photographerAnimation,
    // bookingAnimation,
  ];

  /// Get all assets
  static List<String> get allAssets => [
    ...allImages,
    ...allIcons,
    ...allLogos,
    ...allAnimations,
  ];
}
