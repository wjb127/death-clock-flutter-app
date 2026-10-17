# Life Timer (death-clock-flutter-app) — 작업 지침

⚠️ **공개 저장소다.** 키·토큰·비밀번호 값은 절대 커밋하지 않는다. 여기엔 위치와 명령만 적는다.
성장 검토·출시 기록: `~/Project/ss-086-mobile-app-launch-lab/memory/42-mirror-lifetimer-growth-review-2026-10-17.md`

## 식별자

| 항목 | 값 |
|---|---|
| 앱 이름 | Life Timer - 남은수명계산기 (en: Life Timer: Life Countdown) |
| 번들 ID / 패키지 | `com.deathclock.lifetimerapp` (iOS·Android 동일. pbxproj 에 `com.example.*` 가 다시 생기면 ASC 와 어긋난 것) |
| App Store | 6817656161, 개인 계정(팀 9Q26686S8R), primaryLocale ko |
| Google Play | **가월** 개발자 계정 (`7811900040565701772`) |
| AdMob | iOS 앱 `~3415260072`, Android 앱 `~9788102907` (광고 단위는 `lib/ad_helper.dart`) |
| 사이트 | https://lifetimer-app.vercel.app — 소개 `/`, 개인정보처리방침 `/privacy/`, `/app-ads.txt` (원본 `site/`) |

## 자격증명 위치 (값 출력 금지)

- **ASC API**: `~/.config/eas-submit/asc-NWM428GNG4.json` (필드 `key_id`·`issuer_id`, `.p8` 은 `~/.appstoreconnect/private_keys/`)
  - ⚠️ `SG4375G3VJ` 키는 다른 팀(리싯) 것이라 이 앱에 쓰면 `403 REQUIRED_AGREEMENTS_MISSING` 이 떠서 약관 문제로 오인한다
- **Play 업로드**: 서비스 계정 `~/.config/eas-submit/worktimer-play-sa.json` (가월 계정 공용)
- **Android 서명**: `android/key.properties`(gitignore) → `~/.config/eas-submit/life-timer-upload.jks`. 인증서 `life-timer-upload-certificate.pem` 의 SHA1 과 AAB 서명이 같아야 한다
- **Vercel**: 팀 `seungbeen-wis-projects`, 프로젝트 `life-timer-app`. `.claude/deploy-target` 이 계정을 고정한다

## 버전

`pubspec.yaml` 의 `version` 과 `android/app/build.gradle` 의 `versionCode`·`versionName` 을 **둘 다** 올린다(gradle 이 하드코딩).
iOS 빌드 번호는 ASC 에 이미 쓴 번호보다 커야 한다(1.0.7 은 8·9 사용, 1.0.8 = 10).

## 빌드·출시 명령

```bash
flutter analyze lib && flutter test

# Android → Play 프로덕션 (문구·이미지 포함. changelogs/<versionCode>.txt 가 모든 로케일에 있어야 함)
flutter build appbundle --release
fastlane supply --json_key ~/.config/eas-submit/worktimer-play-sa.json \
  --package_name com.deathclock.lifetimerapp --aab build/app/outputs/bundle/release/app-release.aab \
  --track production --release_status completed --metadata_path fastlane/metadata/android \
  --version_code <N> --skip_upload_apk true
# 문구만 고칠 땐 --skip_upload_images true --skip_upload_screenshots true (supply 는 로컬에 없는 이미지를 지운다)

# iOS → 아카이브는 남고 export 는 "No profiles" 로 실패하는 게 정상
flutter build ipa --release --export-method app-store
xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive -exportPath <out> \
  -exportOptionsPlist <method=app-store-connect, teamID=9Q26686S8R, signingStyle=automatic> \
  -allowProvisioningUpdates -authenticationKeyPath <.p8> -authenticationKeyID <key_id> -authenticationKeyIssuerID <issuer_id>
xcrun altool --upload-app -f "<out>/Life Timer.ipa" -t ios --apiKey <key_id> --apiIssuer <issuer_id>
# 이후 ASC API: 버전 생성 → 로컬라이제이션(ko·en-US·ja·de-DE) → 빌드 연결 → usesNonExemptEncryption=false → reviewSubmissions 제출

# 사이트 (site/ 에서)
vercel deploy --prod --yes && vercel alias set <배포 URL> lifetimer-app.vercel.app   # 커스텀 별칭은 자동 이동 안 함
```

## Xcode 27 함정 (이 맥은 iOS 27 SDK)

- **UIScene 필수**: `ios/Runner/Info.plist` 의 `UIApplicationSceneManifest`(FlutterSceneDelegate)와 `AppDelegate.swift` 의 `FlutterImplicitEngineDelegate` 를 지우지 말 것. 없으면 iOS 27 에서 실행 직후 종료(.ips 없음)
- **Pod 배포 타깃 15.0 미만은 빌드 에러** → `ios/Podfile` 의 `post_install` 상향 블록 유지
- **시뮬레이터 빌드**: `flutter build ios --simulator` 는 lipo 아키텍처 검사로 실패 → `cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'id=<UDID>' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build`
- 판매 중 빌드의 SDK 확인: ASC API `GET /v1/builds?filter[app]=6817656161&include=buildBundles&fields[buildBundles]=sdkBuild`

## 스토어 자산

- 문구 원본: `store/listing-text.json` (ko·en·ja·de), Play 는 `fastlane/metadata/android/<로케일>/`
- 스크린샷: `store/screenshots/{ios 1320x2868, play 1080x1920}/<lang>/{1,2,3}.png` — 캡션 생성기는 HTML + 헤드리스 Chrome(하단 테스트 광고는 잘라냄)
- 금지 문구: "공식 통계 사용", 건강·수명 예측 표현(가이드라인 1.4.1). 계산은 **100년 고정 기준**이라고만 쓴다
- iPad 스크린샷(ko)은 옛 화면 그대로 — 교체 후보

## 앱 범위 원칙

단순함이 핵심. 건강 설문 예측·공포 연출·구독·플래너 확장은 넣지 않는다. 같은 계정에 유사 death clock 앱 추가 출시 금지(4.3(b)).
