// 애드몹 광고 도우미 클래스
// 플랫폼별 광고 단위 ID를 제공하는 유틸리티 클래스
// 🚀 실제 광고 ID 사용 중 - AdMob 계정에서 생성한 실제 ID

import 'dart:io';

class AdHelper {
  // === 배너 광고 단위 ID ===
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // 🚀 실제 출시용 (AdMob에서 생성한 실제 ID)
      // ⚠️ 아래 ID를 실제 AdMob에서 생성한 ID로 교체하세요
      return 'ca-app-pub-1234567890123456/1234567890'; // 실제 Android 배너 광고
      
      // 🧪 테스트용 (개발 시에만 사용)
      // return 'ca-app-pub-3940256099942544/6300978111'; // Android 테스트 배너 광고
    } else if (Platform.isIOS) {
      // 🚀 실제 출시용 (AdMob에서 생성한 실제 ID)
      return 'ca-app-pub-1234567890123456/1234567891'; // 실제 iOS 배너 광고
      
      // 🧪 테스트용 (개발 시에만 사용)
      // return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }

  // === 전면 광고 단위 ID ===
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // 🚀 실제 출시용 (AdMob에서 생성한 실제 ID)
      // ⚠️ 아래 ID를 실제 AdMob에서 생성한 ID로 교체하세요
      return 'ca-app-pub-1234567890123456/1234567892'; // 실제 Android 전면 광고
      
      // 🧪 테스트용 (개발 시에만 사용)
      // return 'ca-app-pub-3940256099942544/1033173712'; // Android 테스트 전면 광고
    } else if (Platform.isIOS) {
      // 🚀 실제 출시용 (AdMob에서 생성한 실제 ID)
      return 'ca-app-pub-1234567890123456/1234567893'; // 실제 iOS 전면 광고
      
      // 🧪 테스트용 (개발 시에만 사용)
      // return 'ca-app-pub-3940256099942544/4411468910'; // iOS 테스트 전면 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }

  // === 보상형 광고 단위 ID ===
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      // 🚀 실제 출시용 (AdMob에서 생성한 실제 ID)
      return 'ca-app-pub-1234567890123456/1234567894'; // 실제 Android 보상형 광고
      
      // 🧪 테스트용 (개발 시에만 사용)
      // return 'ca-app-pub-3940256099942544/5224354917'; // Android 테스트 보상형 광고
    } else if (Platform.isIOS) {
      // 🚀 실제 출시용 (AdMob에서 생성한 실제 ID)
      return 'ca-app-pub-1234567890123456/1234567895'; // 실제 iOS 보상형 광고
      
      // 🧪 테스트용 (개발 시에만 사용)
      // return 'ca-app-pub-3940256099942544/1712485313'; // iOS 테스트 보상형 광고
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }
} 