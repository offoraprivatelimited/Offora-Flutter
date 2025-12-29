/// App constants
/// Define app-wide constants here
library;

/// App configuration
class AppConfig {
  static const String appName = 'Offora';
  static const String appVersion = '1.0.0';

  // API Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // Pagination
  static const int defaultPageSize = 20;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Route names as constants for better maintainability
class Routes {
  // Auth routes
  static const String authGate = '/';
  static const String roleSelection = '/role-selection';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String userLogin = '/user-login';
  static const String profileComplete = '/profile-complete';
  static const String clientLogin = '/client-login';
  static const String clientSignup = '/client-signup';
  static const String pendingApproval = '/pending-approval';
  static const String rejection = '/rejection';

  // User routes
  static const String home = '/home';
  static const String explore = '/explore';
  static const String compare = '/compare';
  static const String saved = '/saved';
  static const String profile = '/profile';
  static const String offerDetails = '/offer-details';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String advertisementDetails = '/advertisement-details';

  // Client routes
  static const String clientDashboard = '/client-dashboard';
  static const String clientAdd = '/client-add';
  static const String clientManage = '/client-manage';
  static const String clientEnquiries = '/client-enquiries';
  static const String clientProfile = '/client-profile';
  static const String newOffer = '/new-offer';
  static const String manageOffers = '/manage-offers';

  // Info pages
  static const String aboutUs = '/about-us';
  static const String contactUs = '/contact-us';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String privacyPolicy = '/privacy-policy';
}

/// Firestore collection names
class FirestoreCollections {
  static const String users = 'users';
  static const String offers = 'offers';
  static const String enquiries = 'enquiries';
  static const String notifications = 'notifications';
  static const String savedOffers = 'saved_offers';
  static const String offerScrollerTexts = 'offer_scroller_texts';
}

/// Storage paths
class StoragePaths {
  static const String userAvatars = 'user_avatars';
  static const String offerImages = 'offer_images';
  static const String businessDocuments = 'business_documents';
}
