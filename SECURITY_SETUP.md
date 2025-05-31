# 🔒 보안 설정 가이드

## ⚠️ 실제 출시 전 필수 작업

### **1. AdMob 실제 ID로 변경**

`lib/ad_helper.dart` 파일에서 테스트 ID를 실제 ID로 변경:

```dart
// 현재 (테스트용)
return 'ca-app-pub-3940256099942544/6300978111';

// 실제 출시용으로 변경
return 'YOUR_REAL_ADMOB_ID_HERE';
```

### **2. AndroidManifest.xml 업데이트**

`android/app/src/main/AndroidManifest.xml`:
```xml
<!-- 현재 (테스트용) -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>

<!-- 실제 출시용으로 변경 -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_REAL_ADMOB_APP_ID"/>
```

### **3. iOS Info.plist 업데이트**

`ios/Runner/Info.plist`:
```xml
<!-- 현재 (테스트용) -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>

<!-- 실제 출시용으로 변경 -->
<key>GADApplicationIdentifier</key>
<string>YOUR_REAL_ADMOB_APP_ID</string>
```

### **4. 개인정보처리방침 이메일 업데이트**

다음 파일들에서 이메일 주소를 실제 주소로 변경:
- `privacy_policy_en.md`
- `playstore_app_description.md`

```
support@lifetimer.app → 실제_이메일@도메인.com
```

## 🔐 **보안 체크리스트**

### **출시 전 확인사항**
- [ ] AdMob 실제 ID로 변경
- [ ] 개인 이메일 주소 업데이트
- [ ] 테스트 키/인증서 제거
- [ ] 디버그 모드 비활성화
- [ ] 로그 출력 제거
- [ ] API 키 환경변수 처리

### **GitHub 보안**
- [ ] `.gitignore`에 민감한 파일 추가
- [ ] 실제 키/ID는 로컬에만 보관
- [ ] 환경변수 또는 별도 설정 파일 사용

## 💡 **권장사항**

### **환경별 설정 분리**
```dart
// config/app_config.dart
class AppConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  
  static String get admobAppId {
    return isProduction 
        ? 'REAL_ADMOB_ID' 
        : 'ca-app-pub-3940256099942544~3347511713';
  }
}
```

### **빌드 시 환경 지정**
```bash
# 개발용
flutter build apk

# 출시용
flutter build apk --dart-define=PRODUCTION=true
```

## 🚨 **주의사항**

1. **실제 AdMob ID는 절대 GitHub에 올리지 마세요**
2. **개인 이메일 주소는 스팸 위험이 있습니다**
3. **API 키나 인증서는 별도 관리하세요**
4. **출시 전 반드시 실제 ID로 변경하세요**

---

**이 파일은 GitHub에 올라가므로 실제 키/ID는 포함하지 마세요!** 