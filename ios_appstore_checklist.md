# iOS App Store 출시 체크리스트

## ✅ **완료된 작업들**

### **앱 개발**
- [x] Flutter iOS 빌드 완료 (34.8MB)
- [x] 다국어 지원 (한국어, 영어, 일본어, 독일어)
- [x] AdMob 광고 통합
- [x] 알림 기능 구현
- [x] 개인정보처리방침 작성

### **출시 준비 자료**
- [x] 앱 설명 (한국어/영어/일본어/독일어)
- [x] 출시 노트 (다국어)
- [x] 개인정보처리방침 URL: https://github.com/wjb127/life-timer-privacy
- [x] 개발자 정보: 앱돌이공장 (support@lifetimer.app)

---

## 📋 **당신이 해야 할 작업들**

### **1. Apple Developer 계정 ($99/년)**
- [ ] Apple Developer Program 가입
- [ ] 결제 완료 ($99/년)
- [ ] 개발자 계정 활성화 확인

### **2. App Store Connect 설정**
- [ ] App Store Connect 접속 (https://appstoreconnect.apple.com)
- [ ] 새 앱 생성
- [ ] 앱 정보 입력:
  - **앱 이름**: Life Timer - 남은수명계산기
  - **부제목**: 매일 동기부여받는 인생 타이머
  - **카테고리**: 라이프스타일
  - **연령 등급**: 4+

### **3. 스크린샷 촬영 (필수)**
다음 디바이스별 스크린샷 필요:
- [ ] iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max)
- [ ] iPhone 6.5" (iPhone 11 Pro Max, 12 Pro Max, 13 Pro Max)
- [ ] iPhone 5.5" (iPhone 8 Plus)
- [ ] iPad Pro 12.9" (선택사항)

**스크린샷 가이드:**
1. Xcode → iOS Simulator 실행
2. 각 화면 캡처 (메인, 설정, 알림 등)
3. 1-10장 업로드 (권장: 5장)

### **4. 앱 아이콘 확인**
- [ ] 1024x1024px PNG 파일
- [ ] 투명도 없음, 둥근 모서리 없음
- [ ] 현재 아이콘 확인 필요

### **5. Xcode에서 Archive 생성**
1. [ ] Xcode에서 프로젝트 열기
2. [ ] Product → Archive 선택
3. [ ] Archive 성공 확인
4. [ ] Distribute App → App Store Connect 선택
5. [ ] 업로드 완료

### **6. App Store Connect에서 앱 정보 입력**
- [ ] 앱 설명 복사 붙여넣기 (appstore_app_description.md 참조)
- [ ] 출시 노트 입력 (ios_release_notes.md 참조)
- [ ] 개인정보처리방침 URL 입력
- [ ] 스크린샷 업로드
- [ ] 앱 아이콘 업로드

### **7. 심사 제출**
- [ ] 모든 정보 입력 완료 확인
- [ ] "심사를 위해 제출" 버튼 클릭
- [ ] 심사 대기 (보통 1-7일)

---

## 📱 **필요한 파일 위치**

### **iOS 빌드 파일**
```
build/ios/iphoneos/Runner.app (34.8MB)
```

### **앱 설명 파일**
```
appstore_app_description.md
```

### **출시 노트**
```
ios_release_notes.md
```

### **개인정보처리방침**
```
https://github.com/wjb127/life-timer-privacy
```

---

## 🎯 **예상 일정**

1. **Apple Developer 가입**: 즉시-24시간
2. **앱 정보 입력**: 1-2시간
3. **스크린샷 촬영**: 30분-1시간
4. **Archive & 업로드**: 30분
5. **Apple 심사**: 1-7일
6. **출시**: 심사 통과 즉시

---

## 💡 **팁**

### **스크린샷 촬영 팁**
- 밝은 배경, 깔끔한 UI 강조
- 주요 기능별로 1장씩
- 텍스트가 잘 보이도록 고해상도

### **심사 통과 팁**
- 개인정보처리방침 URL 정상 작동 확인
- 앱 설명과 실제 기능 일치
- 광고가 과도하지 않게 설정

### **출시 후 할 일**
- 사용자 리뷰 모니터링
- 충돌 보고서 확인
- AdMob 수익 확인
- 업데이트 계획 수립 