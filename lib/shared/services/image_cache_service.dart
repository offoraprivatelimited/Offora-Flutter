import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Service for managing image caching across the application.
/// Handles configuration for both Android and Web platforms.
class ImageCacheService {
  static late CacheManager _bannerCacheManager;

  /// Initialize the cache manager with custom settings.
  /// Call this in main.dart during app initialization.
  static Future<void> initialize() async {
    _bannerCacheManager = CacheManager(
      Config(
        'bannerCache',
        stalePeriod: const Duration(days: 7), // Keep cache for 7 days
        maxNrOfCacheObjects: 30, // Store up to 30 banner images
      ),
    );
  }

  /// Get the banner cache manager instance
  static CacheManager getBannerCacheManager() {
    return _bannerCacheManager;
  }

  /// Clear all banner cache when needed
  static Future<void> clearBannerCache() async {
    await _bannerCacheManager.emptyCache();
  }

  /// Clear a specific banner image from cache by URL
  static Future<void> clearBannerFromCache(String imageUrl) async {
    await _bannerCacheManager.removeFile(imageUrl);
  }
}
