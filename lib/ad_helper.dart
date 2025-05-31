// 애드몹 광고 도우미 클래스
// 플랫폼별 광고 단위 ID를 제공하는 유틸리티 클래스

import 'dart:io';

class AdHelper {
  // === 배너 광고 단위 ID ===
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2803803669720807/2571646800'; // Android 실제 배너 광고
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2803803669720807/2571646800'; // iOS 실제 배너 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }

  // === 전면 광고 단위 ID ===
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2803803669720807/2571646800'; // Android 실제 전면 광고
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2803803669720807/2571646800'; // iOS 실제 전면 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }

  // === 보상형 광고 단위 ID ===
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2803803669720807/2571646800'; // Android 실제 보상형 광고
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2803803669720807/2571646800'; // iOS 실제 보상형 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }
} 