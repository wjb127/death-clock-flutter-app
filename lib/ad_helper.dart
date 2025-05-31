// 애드몹 광고 도우미 클래스
// 플랫폼별 광고 단위 ID를 제공하는 유틸리티 클래스
// ⚠️ 실제 출시 시에는 실제 AdMob ID로 변경 필요

import 'dart:io';

class AdHelper {
  // === 배너 광고 단위 ID ===
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android 테스트 배너 광고
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }

  // === 전면 광고 단위 ID ===
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android 테스트 전면 광고
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS 테스트 전면 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }

  // === 보상형 광고 단위 ID ===
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android 테스트 보상형 광고
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS 테스트 보상형 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }
} 