// lib/config/config.dart

class Config {
  // API URL
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://default.api.url',
  );

  // Image paths
  static const String mainPlayBackgroundImg = String.fromEnvironment(
    'MAIN_PLAY_BACKGROUND_IMG',
    defaultValue: 'assets/app_images/default_background_image.jpg',
  );

  static const String mainPlayBackgroundImgAftermath = String.fromEnvironment(
    'MAIN_PLAY_BACKGROUND_IMG_AFTERMATH',
    defaultValue: 'assets/app_images/default_background_image.jpg',
  );

  static const String mainPlayBackgroundImgAftermathToilet =
      String.fromEnvironment(
    'MAIN_PLAY_BACKGROUND_IMG_AFTERMATH_TOILET',
    defaultValue: 'assets/app_images/default_background_image.jpg',
  );

  static const String overlayImageIdle = String.fromEnvironment(
    'OVERLAY_IMAGE_IDLE',
    defaultValue: 'assets/app_images/default_overlay_idle.png',
  );

  static const String overlayImageRevealed = String.fromEnvironment(
    'OVERLAY_IMAGE_REVEALED',
    defaultValue: 'assets/app_images/default_overlay_revealed.png',
  );

  static const String admobsBottomBanner01 = String.fromEnvironment(
    'ADMOBS_BOTTOM_BANNER01',
    defaultValue: '',
  );

  static const String admobsInterstitial01 = String.fromEnvironment(
    'ADMOBS_INTERSTITIAL01',
    defaultValue: '',
  );
}
