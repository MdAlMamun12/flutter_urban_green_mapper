// Application-wide constants and configuration values

class AppConstants {
  // App Information
  static const String appName = 'Urban Green Mapper';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Connecting Communities with Green Spaces';
  
  // API Endpoints and URLs
  static const String privacyPolicyUrl = 'https://urbangreenmapper.com/privacy';
  static const String termsOfServiceUrl = 'https://urbangreenmapper.com/terms';
  static const String supportEmail = 'support@urbangreenmapper.com';
  
  // App Settings
  static const int splashDelay = 2000; // milliseconds
  static const int autoLogoutDuration = 30; // minutes
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB in bytes
  static const int maxPhotosPerReport = 5;
  static const int debounceDuration = 500; // milliseconds for search debouncing
  
  // Pagination
  static const int itemsPerPage = 10;
  static const int eventsPerPage = 6;
  static const int reportsPerPage = 8;
  static const int plantsPerPage = 12;
  
  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 350);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  
  // Cache Durations
  static const Duration cacheTimeoutShort = Duration(minutes: 5);
  static const Duration cacheTimeoutMedium = Duration(minutes: 30);
  static const Duration cacheTimeoutLong = Duration(hours: 1);
  
  // Location Settings
  static const double defaultMapZoom = 14.0;
  static const double maxSearchRadius = 50.0; // kilometers
  static const int locationUpdateInterval = 30; // seconds
  
  // User Roles
  static const String roleCitizen = 'citizen';
  static const String roleNGO = 'ngo';
  static const String roleAdmin = 'admin';
  
  // Green Space Types
  static const String spaceTypePark = 'park';
  static const String spaceTypeGarden = 'garden';
  static const String spaceTypeForest = 'forest';
  
  // Green Space Status
  static const String spaceStatusHealthy = 'healthy';
  static const String spaceStatusDegraded = 'degraded';
  static const String spaceStatusRestored = 'restored';
  
  // Plant Health Status
  static const String plantHealthExcellent = 'excellent';
  static const String plantHealthGood = 'good';
  static const String plantHealthPoor = 'poor';
  
  // Report Status
  static const String reportStatusPending = 'pending';
  static const String reportStatusApproved = 'approved';
  static const String reportStatusRejected = 'rejected';
  
  // Event Status
  static const String eventStatusUpcoming = 'upcoming';
  static const String eventStatusOngoing = 'ongoing';
  static const String eventStatusCompleted = 'completed';
  
  // Participation Status
  static const String participationRegistered = 'registered';
  static const String participationAttended = 'attended';
  static const String participationCancelled = 'cancelled';
  
  // Sponsor Tiers
  static const String sponsorTierBronze = 'bronze';
  static const String sponsorTierSilver = 'silver';
  static const String sponsorTierGold = 'gold';
  
  // Impact Score Values
  static const int scoreReportSubmitted = 10;
  static const int scoreReportApproved = 20;
  static const int scoreEventJoined = 15;
  static const int scoreEventAttended = 30;
  static const int scorePlantAdopted = 25;
  static const int scorePlantCared = 5;
  
  // Achievement Thresholds
  static const int achievementBronze = 100;
  static const int achievementSilver = 500;
  static const int achievementGold = 1000;
  static const int achievementPlatinum = 2500;
  
  // Default Values
  static const String defaultCountry = 'Bangladesh';
  static const String defaultLanguage = 'en';
  static const String defaultCurrency = 'BDT';
  
  // Date Formats
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, HH:mm';
  static const String timeFormatDisplay = 'HH:mm';
  
  // File Extensions
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];
  
  // Validation Limits
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;
  
  // API Rate Limiting
  static const int apiRateLimit = 100; // requests per minute
  static const int uploadRateLimit = 5; // uploads per minute
  
  // Notification Channels
  static const String channelGeneral = 'general_notifications';
  static const String channelEvents = 'event_notifications';
  static const String channelReports = 'report_notifications';
  static const String channelEmergency = 'emergency_notifications';
  
  // Shared Preferences Keys
  static const String prefUserData = 'user_data';
  static const String prefAuthToken = 'auth_token';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserRole = 'user_role';
  static const String prefLanguage = 'language';
  static const String prefThemeMode = 'theme_mode';
  static const String prefNotifications = 'notifications_enabled';
  static const String prefLocationEnabled = 'location_enabled';
  static const String prefFirstLaunch = 'first_launch';
  
  // Database Constants
  static const int dbVersion = 1;
  static const String dbName = 'urban_green_mapper.db';
  
  // Error Messages
  static const String errorNoInternet = 'No internet connection';
  static const String errorServerDown = 'Server is temporarily unavailable';
  static const String errorUnauthorized = 'Please login again';
  static const String errorUnknown = 'An unexpected error occurred';
  
  // Success Messages
  static const String successReportSubmitted = 'Report submitted successfully';
  static const String successEventJoined = 'Successfully joined the event';
  static const String successPlantAdopted = 'Plant adopted successfully';
  static const String successProfileUpdated = 'Profile updated successfully';
  
  // Default Coordinates (Fallback location)
  static const double defaultLatitude = 23.8103; // Dhaka, Bangladesh
  static const double defaultLongitude = 90.4125;
  
  // Map Configuration
  static const double mapDefaultZoom = 12.0;
  static const double mapMinZoom = 10.0;
  static const double mapMaxZoom = 18.0;
  static const int mapClusterSize = 50;
  
  // Image Quality
  static const int imageQualityLow = 50;
  static const int imageQualityMedium = 75;
  static const int imageQualityHigh = 90;
  
  // Cache Sizes
  static const int imageCacheSize = 100; // number of images
  static const int mapTileCacheSize = 50; // MB
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableSocialSharing = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationTracking = true;
  static const bool enableDarkMode = true;
  
  // In-App Configuration
  static const int maxEventParticipants = 100;
  static const int maxAdoptedPlants = 10;
  static const int maxDailyReports = 5;
  
  // Testing Configuration
  static const bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;
  static const bool enableMockData = true; // Set to false in production
  
  // API Configuration
  static const String baseUrl = 'https://api.urbangreenmapper.com';
  static const int apiTimeout = 30; // seconds
  static const int uploadTimeout = 60; // seconds
  
  // Social Media Links
  static const String facebookUrl = 'https://facebook.com/urbangreenmapper';
  static const String twitterUrl = 'https://twitter.com/urbangreenmapper';
  static const String instagramUrl = 'https://instagram.com/urbangreenmapper';
  static const String linkedinUrl = 'https://linkedin.com/company/urbangreenmapper';
  
  // App Store Links
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.urban_green_mapper';
  static const String appStoreUrl = 'https://apps.apple.com/app/urban-green-mapper/id123456789';
  
  // Localization
  static const List<String> supportedLanguages = ['en', 'bn'];
  static const String defaultLocale = 'en';
  
  // Color Constants for consistent theming
  static const int primaryColorValue = 0xFF4CAF50; // Green
  static const int secondaryColorValue = 0xFF2196F3; // Blue
  static const int accentColorValue = 0xFFFF9800; // Orange
  static const int errorColorValue = 0xFFF44336; // Red
  static const int warningColorValue = 0xFFFFC107; // Amber
  static const int successColorValue = 0xFF4CAF50; // Green
  static const int infoColorValue = 0xFF2196F3; // Blue
  
  // Typography Scale
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeadline = 24.0;
  static const double fontSizeDisplay = 32.0;
  
  // Spacing Constants
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
  // Elevation Values
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // Animation Curves
  static const String curveEaseInOut = 'easeInOut';
  static const String curveFastOutSlowIn = 'fastOutSlowIn';
  static const String curveLinear = 'linear';
  static const String curveBounce = 'bounce';
}

// Extension methods for easier access
extension AppConstantsExtensions on AppConstants {
  static Duration get searchDebounceDuration => Duration(milliseconds: AppConstants.debounceDuration);
  
  static bool get isProduction => !AppConstants.isDebugMode;
  
  static List<String> get allGreenSpaceTypes => [
    AppConstants.spaceTypePark,
    AppConstants.spaceTypeGarden,
    AppConstants.spaceTypeForest,
  ];
  
  static List<String> get allUserRoles => [
    AppConstants.roleCitizen,
    AppConstants.roleNGO,
    AppConstants.roleAdmin,
  ];
  
  static List<String> get allReportStatuses => [
    AppConstants.reportStatusPending,
    AppConstants.reportStatusApproved,
    AppConstants.reportStatusRejected,
  ];
  
  static List<String> get allEventStatuses => [
    AppConstants.eventStatusUpcoming,
    AppConstants.eventStatusOngoing,
    AppConstants.eventStatusCompleted,
  ];
}

// Environment-specific configuration
class EnvironmentConfig {
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'development';
  
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.urbangreenmapper.com';
      case 'staging':
        return 'https://staging-api.urbangreenmapper.com';
      case 'development':
      default:
        return 'https://dev-api.urbangreenmapper.com';
    }
  }
}