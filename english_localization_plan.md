# 🌍 Death Clock 앱 영어 다국어 지원 추가 계획

## 📋 **현재 상태**
- ✅ `flutter_localizations` 패키지 설정 완료
- ✅ 한국어(`ko_KR`), 영어(`en_US`) 로케일 지원 설정됨
- ✅ 기본 Material Design 다국어 지원 활성화

## 🎯 **추가 작업 필요 사항**

### 1️⃣ **ARB 파일 생성**
```
lib/l10n/
├── app_ko.arb (한국어 번역)
├── app_en.arb (영어 번역)
└── l10n.yaml (설정 파일)
```

### 2️⃣ **번역할 텍스트 목록**

#### 앱 제목 및 기본 UI
- "⏰ Death Clock" → "⏰ Death Clock" (동일)
- "수명 계산기" → "Life Timer"
- "설정" → "Settings"

#### 메인 화면
- "생일을 선택하세요" → "Select your birthday"
- "남은 수명" → "Remaining Life"
- "인생 진행률" → "Life Progress"
- "년" → "years"
- "일" → "days"
- "시간" → "hours"
- "분" → "minutes"
- "초" → "seconds"

#### 동기부여 명언
- "시간은 생명이다. 낭비하지 마라." → "Time is life. Don't waste it."
- "매 순간이 소중하다. 지금 이 순간을 살아라." → "Every moment is precious. Live this moment."
- "시간을 아끼는 자가 인생을 얻는다." → "Those who save time gain life."
- "오늘 할 수 있는 일을 내일로 미루지 마라." → "Don't put off until tomorrow what you can do today."
- "시간은 돌아오지 않는다. 현재에 집중하라." → "Time doesn't come back. Focus on the present."

#### 설정 화면
- "매일 알림" → "Daily Notifications"
- "매일 아침 8시에 알림이 설정되었습니다! 🔔" → "Daily notification set for 8 AM! 🔔"
- "알림이 해제되었습니다." → "Notifications disabled."

#### 알림 메시지
- "⏰ 남은 수명을 확인하고 정신차리세요!" → "⏰ Check your remaining life and wake up!"
- "💀 시간은 기다려주지 않습니다. 지금 확인하세요!" → "💀 Time doesn't wait. Check now!"
- "⚡ 매 순간이 소중합니다. 남은 시간을 체크하세요!" → "⚡ Every moment is precious. Check your remaining time!"

#### 공유 메시지
- "⏰ Death Clock 수명 체크 결과" → "⏰ Death Clock Life Check Result"
- "생일" → "Birthday"
- "남은 수명" → "Remaining Life"
- "인생 진행률" → "Life Progress"
- "당신의 남은 시간은? Death Clock 앱으로 확인해보세요!" → "What's your remaining time? Check with Death Clock app!"

### 3️⃣ **구현 단계**

1. **ARB 파일 생성**
   - `lib/l10n/app_ko.arb` (한국어)
   - `lib/l10n/app_en.arb` (영어)

2. **pubspec.yaml 설정 추가**
   ```yaml
   flutter:
     generate: true
   ```

3. **l10n.yaml 설정 파일 생성**

4. **코드에서 하드코딩된 텍스트를 번역 키로 변경**

5. **언어 감지 및 자동 전환 로직 추가**

### 4️⃣ **플레이스토어 다국어 출시**

#### 한국어 버전 (우선 출시)
- 앱명: "Death Clock - 남은수명계산기"
- 설명: 한국어 메타데이터 사용
- 타겟: 한국 사용자

#### 영어 버전 (추가 출시)
- 앱명: "Death Clock - Life Timer"
- 설명: 영어 메타데이터 작성
- 타겟: 전 세계 사용자

### 5️⃣ **장점**
- ✅ 하나의 앱으로 전 세계 사용자 대상
- ✅ 사용자 기기 언어에 따라 자동 전환
- ✅ 앱 관리 및 업데이트 용이
- ✅ 다운로드 수 통합으로 랭킹 상승 효과
- ✅ 구글 정책 위반 위험 없음

### 6️⃣ **예상 작업 시간**
- ARB 파일 생성: 1시간
- 코드 수정: 2-3시간
- 테스트 및 빌드: 1시간
- **총 예상 시간: 4-5시간**

## 🚀 **결론**
별도 영어 앱을 만들기보다는 현재 앱에 영어 지원을 추가하는 것이 최적의 방법입니다. 이렇게 하면 하나의 앱으로 전 세계 사용자를 대상으로 할 수 있고, 관리도 훨씬 쉬워집니다. 