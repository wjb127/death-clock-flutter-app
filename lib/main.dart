// Death Clock 앱 - 남은 수명 계산기
// 생일을 입력하면 100세 기준으로 남은 수명을 초 단위로 계산하여 표시
// 매일 알림, 공유 기능, 동기부여 명언 제공

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'dart:async';
import 'notification_service.dart';
import 'ad_helper.dart';

// 앱 진입점 - 알림 서비스 및 애드몹 초기화 후 앱 실행
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 푸시 알림 서비스 초기화
  await NotificationService.initialize();
  
  // 애드몹 SDK 초기화
  await MobileAds.instance.initialize();
  
  runApp(const DeathClockApp());
}

// 메인 앱 클래스 - Material Design 테마 및 다국어 설정
class DeathClockApp extends StatelessWidget {
  const DeathClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Death Clock - 수명 계산기',
      theme: ThemeData(
        primarySwatch: Colors.red, // 빨간색 테마
        fontFamily: 'Roboto',
      ),
      // 한국어 지원을 위한 로케일 설정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
      ],
      home: const DeathClockHomePage(),
    );
  }
}

// 홈페이지 위젯 - 메인 화면 구성
class DeathClockHomePage extends StatefulWidget {
  const DeathClockHomePage({super.key});

  @override
  State<DeathClockHomePage> createState() => _DeathClockHomePageState();
}

// 홈페이지 상태 관리 클래스
class _DeathClockHomePageState extends State<DeathClockHomePage> {
  // === 상태 변수들 ===
  DateTime? selectedBirthDate; // 선택된 생일
  int remainingSeconds = 0; // 남은 수명 (초 단위)
  double lifePercentage = 0.0; // 인생 진행률 (%)
  int currentQuoteIndex = 0; // 현재 표시 중인 명언 인덱스
  Timer? _timer; // 실시간 카운트다운을 위한 타이머
  bool notificationsEnabled = false; // 알림 설정 상태
  
  // 애드몹 전면광고 관련 변수
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  
  // 애드몹 배너광고 관련 변수
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  
  // 날짜 선택을 위한 변수들 (룰렛 피커용)
  late int selectedYear; // 선택된 년도
  late int selectedMonth; // 선택된 월
  late int selectedDay; // 선택된 일
  
  // 동기부여 명언 목록 (5개)
  final List<String> motivationalQuotes = [
    "시간은 생명이다. 낭비하지 마라.",
    "매 순간이 소중하다. 지금 이 순간을 살아라.",
    "시간을 아끼는 자가 인생을 얻는다.",
    "오늘 할 수 있는 일을 내일로 미루지 마라.",
    "시간은 돌아오지 않는다. 현재에 집중하라."
  ];

  @override
  void initState() {
    super.initState();
    // 현재 날짜로 초기값 설정
    final now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;
    selectedDay = now.day;
    _loadNotificationSettings(); // 저장된 알림 설정 불러오기
    _checkAndRequestNotificationPermission(); // 앱 시작 시 알림 권한 확인
    _loadInterstitialAd(); // 전면광고 로드
    _loadBannerAd(); // 배너광고 로드
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  // === 앱 시작 시 알림 권한 요청 ===
  Future<void> _checkAndRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAskedBefore = prefs.getBool('notification_permission_asked') ?? false;
    
    // 이전에 물어본 적이 없다면 권한 요청
    if (!hasAskedBefore) {
      // 잠시 후에 다이얼로그 표시 (UI가 완전히 로드된 후)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotificationPermissionDialog();
      });
    }
  }

  // === 알림 권한 요청 다이얼로그 ===
  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 뒤로가기로 닫을 수 없음
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.red[400], size: 28),
              const SizedBox(width: 10),
              const Text(
                '알림 설정',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '매일 아침 8시에 수명 확인 알림을 받으시겠습니까?',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[900]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 알림의 효과:',
                      style: TextStyle(color: Colors.red[300], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '• 매일 남은 시간을 인식하게 됩니다\n• 시간 관리 의식이 향상됩니다\n• 목표 달성 동기부여를 받습니다',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // 거부 선택
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('notification_permission_asked', true);
                await prefs.setBool('notifications_enabled', false);
                
                setState(() {
                  notificationsEnabled = false;
                });
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('알림을 거부했습니다. 설정에서 언제든 변경할 수 있습니다.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text(
                '나중에',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // 허용 선택
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('notification_permission_asked', true);
                
                // 알림 권한 요청 및 스케줄링
                await NotificationService.requestPermissions();
                await NotificationService.scheduleDailyNotification();
                await prefs.setBool('notifications_enabled', true);
                
                setState(() {
                  notificationsEnabled = true;
                });
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 매일 아침 8시에 알림이 설정되었습니다!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('알림 받기'),
            ),
          ],
        );
      },
    );
  }

  // === 설정 다이얼로그 표시 메서드 ===
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // 다이얼로그 내부 상태 관리를 위한 StatefulBuilder
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900], // 다크 테마
              title: const Text(
                '설정',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '매일 알림',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Switch(
                        value: notificationsEnabled,
                        onChanged: (value) async {
                          // 먼저 다이얼로그 상태 업데이트 (즉시 UI 반영)
                          setDialogState(() {
                            notificationsEnabled = value;
                          });
                          
                          // 그 다음 실제 알림 설정 처리
                          final prefs = await SharedPreferences.getInstance();
                          
                          if (value) {
                            // 알림 켜기
                            await NotificationService.requestPermissions();
                            await NotificationService.scheduleDailyNotification();
                            await prefs.setBool('notifications_enabled', true);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('매일 아침 8시에 알림이 설정되었습니다! 🔔'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            // 알림 끄기
                            await NotificationService.cancelAllNotifications();
                            await prefs.setBool('notifications_enabled', false);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('알림이 해제되었습니다'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                          
                          // 마지막에 메인 위젯 상태 업데이트
                          setState(() {
                            notificationsEnabled = value;
                          });
                        },
                        activeColor: Colors.red[400], // 스위치 활성화 색상
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '매일 아침 8시에 수명 확인 알림을 받습니다',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  // 개발용 권한 초기화 기능 (필요시 주석 해제)
                  /*
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('notification_permission_asked');
                        await prefs.remove('notifications_enabled');
                        
                        setState(() {
                          notificationsEnabled = false;
                        });
                        
                        Navigator.of(context).pop();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('권한 요청이 초기화되었습니다. 앱을 재시작하면 다시 물어봅니다.'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('권한 요청 초기화 (개발용)'),
                    ),
                  ),
                  */
                  // 알림 테스트 기능 (개발용 - 필요시 주석 해제)
                  /*
                  const SizedBox(height: 20),
                  // 테스트 알림 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await NotificationService.requestPermissions();
                        await NotificationService.sendTestNotification();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔔 테스트 알림을 보냈습니다! 알림창을 확인해보세요.'),
                              backgroundColor: Colors.blue,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active, color: Colors.white),
                      label: const Text(
                        '알림 테스트',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  */
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '닫기',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // === 리소스 정리 메서드 ===
  @override
  void dispose() {
    _timer?.cancel(); // 타이머 정리
    _interstitialAd?.dispose(); // 전면광고 정리
    _bannerAd?.dispose(); // 배너광고 정리
    super.dispose();
  }

  // === 날짜 변경 처리 메서드 ===
  void _onDateChanged() {
    setState(() {
      selectedBirthDate = DateTime(selectedYear, selectedMonth, selectedDay);
      _calculateRemainingLife(); // 수명 재계산
      _startTimer(); // 타이머 재시작
    });
  }

  // === 남은 수명 계산 메서드 ===
  void _calculateRemainingLife() {
    if (selectedBirthDate == null) return;

    final now = DateTime.now();
    final age = now.difference(selectedBirthDate!); // 현재 나이 계산
    final ageInYears = age.inDays / 365.25; // 년 단위로 변환 (윤년 고려)
    
    // 100년 수명 기준으로 계산
    const lifeExpectancy = 100.0;
    final remainingYears = lifeExpectancy - ageInYears;
    
    if (remainingYears > 0) {
      // 남은 년수를 초 단위로 변환
      remainingSeconds = (remainingYears * 365.25 * 24 * 60 * 60).round();
      lifePercentage = (ageInYears / lifeExpectancy) * 100; // 진행률 계산
    } else {
      // 100세 초과한 경우
      remainingSeconds = 0;
      lifePercentage = 100.0;
    }

    // 명언 인덱스 랜덤 변경
    currentQuoteIndex = Random().nextInt(motivationalQuotes.length);
  }

  // === 실시간 카운트다운 타이머 시작 ===
  void _startTimer() {
    _timer?.cancel(); // 기존 타이머가 있다면 취소
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--; // 매초마다 1초씩 감소
        });
      } else {
        timer.cancel(); // 0에 도달하면 타이머 중지
      }
    });
  }

  // === 시간 포맷팅 메서드 (초 → 년/일/시/분/초) ===
  String _formatTime(int seconds) {
    if (seconds <= 0) return "0초";
    
    final years = seconds ~/ (365.25 * 24 * 60 * 60); // 년 계산
    final days = (seconds % (365.25 * 24 * 60 * 60)) ~/ (24 * 60 * 60); // 일 계산
    final hours = (seconds % (24 * 60 * 60)) ~/ (60 * 60); // 시간 계산
    final minutes = (seconds % (60 * 60)) ~/ 60; // 분 계산
    final remainingSecs = seconds % 60; // 초 계산

    return "${years}년 ${days}일 ${hours}시간 ${minutes}분 ${remainingSecs}초";
  }

  // === 해당 월의 최대 일수 계산 (윤년 고려) ===
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // === SNS 공유 기능 ===
  void _shareLifeStats() {
    if (selectedBirthDate == null) return;
    
    // 공유할 텍스트 생성
    final shareText = '''
⏰ Death Clock 수명 체크 결과

📅 생일: ${selectedBirthDate!.year}.${selectedBirthDate!.month.toString().padLeft(2, '0')}.${selectedBirthDate!.day.toString().padLeft(2, '0')}
⏳ 남은 수명: ${_formatTime(remainingSeconds)}
📊 인생 진행률: ${lifePercentage.toStringAsFixed(1)}%
💭 "${motivationalQuotes[currentQuoteIndex]}"

당신의 남은 시간은? Death Clock 앱으로 확인해보세요!
''';
    
    // 바로 공유 실행
    Share.share(shareText);
  }

  // === 전면광고 로드 메서드 ===
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('전면광고 로드 완료');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          // 앱 시작 직후 1번만 표시 (3초 후)
          Timer(const Duration(seconds: 3), () {
            _showInterstitialAd();
          });
          
          // 광고 이벤트 리스너 설정
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                print('전면광고 표시됨'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('전면광고 닫힘');
              ad.dispose();
              _isInterstitialAdReady = false;
              // 앱 시작 후에는 더 이상 로드하지 않음
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('전면광고 표시 실패: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('전면광고 로드 실패: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // === 전면광고 표시 메서드 ===
  void _showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    }
  }

  // === 배너광고 로드 메서드 ===
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('배너광고 로드 완료');
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('배너광고 로드 실패: ${err.message}');
          ad.dispose();
          _isBannerAdReady = false;
          // 30초 후 재시도
          Timer(const Duration(seconds: 30), () {
            _loadBannerAd();
          });
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '⏰ Death Clock',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      // 배너광고를 화면 하단에 표시
      bottomNavigationBar: _isBannerAdReady && _bannerAd != null
          ? Container(
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.access_time,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                
                // 생일 선택 섹션
                const Text(
                  '생일을 선택하세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '* 수명은 100살로 가정하여 계산됩니다',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 날짜 선택 피커들
                Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      // 년도 선택
                      Expanded(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '년',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 32,
                                scrollController: FixedExtentScrollController(
                                  initialItem: DateTime.now().year - 1924,
                                ),
                                onSelectedItemChanged: (index) {
                                  selectedYear = 1924 + index;
                                  // 선택된 월의 일수를 초과하지 않도록 조정
                                  final maxDay = _getDaysInMonth(selectedYear, selectedMonth);
                                  if (selectedDay > maxDay) {
                                    selectedDay = maxDay;
                                  }
                                  _onDateChanged();
                                },
                                children: List.generate(101, (index) {
                                  return Center(
                                    child: Text(
                                      '${1924 + index}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 월 선택
                      Expanded(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '월',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 32,
                                scrollController: FixedExtentScrollController(
                                  initialItem: DateTime.now().month - 1,
                                ),
                                onSelectedItemChanged: (index) {
                                  selectedMonth = index + 1;
                                  // 선택된 월의 일수를 초과하지 않도록 조정
                                  final maxDay = _getDaysInMonth(selectedYear, selectedMonth);
                                  if (selectedDay > maxDay) {
                                    selectedDay = maxDay;
                                  }
                                  _onDateChanged();
                                },
                                children: List.generate(12, (index) {
                                  return Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 일 선택
                      Expanded(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '일',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 32,
                                scrollController: FixedExtentScrollController(
                                  initialItem: DateTime.now().day - 1,
                                ),
                                onSelectedItemChanged: (index) {
                                  selectedDay = index + 1;
                                  _onDateChanged();
                                },
                                children: List.generate(_getDaysInMonth(selectedYear, selectedMonth), (index) {
                                  return Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                if (selectedBirthDate != null) ...[
                  // 남은 수명 표시
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[800]?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '남은 수명',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.white),
                              onPressed: _shareLifeStats,
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _formatTime(remainingSeconds),
                          style: TextStyle(
                            color: Colors.red[300],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${remainingSeconds.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}초',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 수명 퍼센트 표시
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[800]?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '인생 진행률',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: lifePercentage / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            lifePercentage > 75 ? Colors.red : 
                            lifePercentage > 50 ? Colors.orange : Colors.green
                          ),
                          minHeight: 10,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${lifePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 동기부여 명언
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[800]?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: Colors.blue,
                          size: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          motivationalQuotes[currentQuoteIndex],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentQuoteIndex = Random().nextInt(motivationalQuotes.length);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('다른 명언 보기'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
