import 'package:flutter/foundation.dart';

class AdHelper {
  // Verified against Life Timer in the owner's AdMob account, 2026-09-30.
  static const androidAppId = 'ca-app-pub-2803803669720807~9788102907';
  static const androidBannerId = 'ca-app-pub-2803803669720807/1200245993';
  static const androidInterstitialId = 'ca-app-pub-2803803669720807/2571646800';
  // iOS needs its own AdMob app; never reuse the Android app ID.
  static const iosBannerId = String.fromEnvironment('ADMOB_IOS_BANNER_ID');
  static const iosInterstitialId =
      String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID');

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  static bool get adsEnabled =>
      isSupported &&
      (!kReleaseMode ||
          defaultTargetPlatform == TargetPlatform.android ||
          (iosBannerId.isNotEmpty && iosInterstitialId.isNotEmpty));

  static String get bannerAdUnitId {
    if (!kReleaseMode) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3940256099942544/6300978111';
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? iosBannerId
        : androidBannerId;
  }

  static String get interstitialAdUnitId {
    if (!kReleaseMode) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? iosInterstitialId
        : androidInterstitialId;
  }
}
