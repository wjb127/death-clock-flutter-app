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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 앱 진입점 - 알림 서비스 및 애드몹 초기화 후 앱 실행
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 기본 앱 실행 (초기화 실패해도 앱은 실행)
    runApp(const DeathClockApp());
    
    // 백그라운드에서 서비스 초기화 (앱 실행 후)
    _initializeServices();
  } catch (e) {
    print('앱 초기화 중 오류 발생: $e');
    // 최소한의 앱이라도 실행
    runApp(const DeathClockApp());
  }
}

// 서비스들을 백그라운드에서 초기화
void _initializeServices() async {
  try {
    // 푸시 알림 서비스 초기화 (안전하게)
    try {
      await NotificationService.initialize();
      print('알림 서비스 초기화 완료');
    } catch (e) {
      print('알림 서비스 초기화 실패: $e');
    }
    
    // 애드몹 SDK 초기화 (안전하게)
    try {
      await MobileAds.instance.initialize();
      print('AdMob 초기화 완료');
    } catch (e) {
      print('AdMob 초기화 실패: $e');
    }
  } catch (e) {
    print('서비스 초기화 중 전체 오류: $e');
  }
}

// 메인 앱 클래스 - Material Design 테마 및 다국어 설정
class DeathClockApp extends StatelessWidget {
  const DeathClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Death Clock - Life Timer',
      theme: ThemeData(
        primarySwatch: Colors.red, // 빨간색 테마
        fontFamily: 'Roboto',
      ),
      // 다국어 지원을 위한 로케일 설정
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
        Locale('ja', 'JP'), // 일본어
        Locale('de', 'DE'), // 독일어
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
  bool showLifeStats = false; // 남은 수명 통계 표시 여부
  
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

  // 다국어 지원 명언 목록을 반환하는 함수
  List<String> getMotivationalQuotes(AppLocalizations l10n) {
    return [
      l10n.quote1,
      l10n.quote2,
      l10n.quote3,
      l10n.quote4,
      l10n.quote5,
    ];
  }

  @override
  void initState() {
    super.initState();
    try {
      // 현재 날짜로 초기값 설정
      final now = DateTime.now();
      selectedYear = now.year;
      selectedMonth = now.month;
      selectedDay = now.day;
      
      // 기본 설정 로드 (생일 포함)
      _loadNotificationSettings();
      _loadSavedBirthDate(); // 저장된 생일 로드 추가
      
      // 권한 요청은 지연 실행
      Future.delayed(const Duration(seconds: 1), () {
        _checkAndRequestNotificationPermission();
      });
      
      // 광고 로드는 더 지연 실행 (앱이 안정화된 후)
      Future.delayed(const Duration(seconds: 3), () {
        _loadInterstitialAd();
        _loadBannerAd();
      });
    } catch (e) {
      print('초기화 중 오류 발생: $e');
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
        });
      }
    } catch (e) {
      print('알림 설정 로드 실패: $e');
      // 기본값으로 설정
      if (mounted) {
        setState(() {
          notificationsEnabled = false;
        });
      }
    }
  }

  // === 저장된 생일 로드 ===
  Future<void> _loadSavedBirthDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBirthDateString = prefs.getString('birth_date');
      
      if (savedBirthDateString != null && mounted) {
        final savedBirthDate = DateTime.parse(savedBirthDateString);
        setState(() {
          selectedBirthDate = savedBirthDate;
          selectedYear = savedBirthDate.year;
          selectedMonth = savedBirthDate.month;
          selectedDay = savedBirthDate.day;
          showLifeStats = true; // 저장된 생일이 있으면 바로 통계 표시
          _calculateRemainingLife();
        });
        print('저장된 생일 로드됨: $savedBirthDate');
      }
    } catch (e) {
      print('생일 로드 실패: $e');
    }
  }

  // === 생일 저장 ===
  Future<void> _saveBirthDate(DateTime birthDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('birth_date', birthDate.toIso8601String());
      print('생일 저장됨: $birthDate');
    } catch (e) {
      print('생일 저장 실패: $e');
    }
  }

  // === 알림 권한 확인 및 요청 ===
  Future<void> _checkAndRequestNotificationPermission() async {
    try {
      await NotificationService.requestPermissions();
    } catch (e) {
      print('알림 권한 요청 실패: $e');
    }
  }

  // === 생일 선택 다이얼로그 표시 ===
  void _showBirthDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                l10n.selectBirthday,
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                height: 200,
                child: Row(
                  children: [
                    // 년도 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setDialogState(() {
                            selectedYear = 1900 + index;
                          });
                        },
                        children: List.generate(125, (index) {
                          final year = 1900 + index;
                          return Center(
                            child: Text(
                              '$year',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          );
                        }),
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedYear - 1900,
                        ),
                      ),
                    ),
                    // 월 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setDialogState(() {
                            selectedMonth = index + 1;
                            // 선택된 월에 따라 일 조정
                            final maxDays = _getDaysInMonth(selectedYear, selectedMonth);
                            if (selectedDay > maxDays) {
                              selectedDay = maxDays;
                            }
                          });
                        },
                        children: List.generate(12, (index) {
                          final month = index + 1;
                          return Center(
                            child: Text(
                              '$month',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          );
                        }),
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth - 1,
                        ),
                      ),
                    ),
                    // 일 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setDialogState(() {
                            selectedDay = index + 1;
                          });
                        },
                        children: List.generate(_getDaysInMonth(selectedYear, selectedMonth), (index) {
                          final day = index + 1;
                          return Center(
                            child: Text(
                              '$day',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          );
                        }),
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedDay - 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newBirthDate = DateTime(selectedYear, selectedMonth, selectedDay);
                    
                    // 생일 저장
                    await _saveBirthDate(newBirthDate);
                    
                    setState(() {
                      selectedBirthDate = newBirthDate;
                      showLifeStats = false; // 새로운 생일 선택 시 통계 숨김
                      _calculateRemainingLife();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // === 설정 다이얼로그 표시 ===
  void _showSettingsDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // 다이얼로그 내부 상태 관리를 위한 StatefulBuilder
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900], // 다크 테마
              title: Text(
                l10n.settings,
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 알림 설정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.dailyNotifications,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
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
                                SnackBar(
                                  content: Text(l10n.notificationEnabled),
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
                                SnackBar(
                                  content: Text(l10n.notificationDisabled),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                          
                          // 메인 화면 상태도 업데이트
                          setState(() {
                            this.notificationsEnabled = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 광고 상태 표시
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 광고 상태',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              _isBannerAdReady ? Icons.check_circle : Icons.error,
                              color: _isBannerAdReady ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '배너광고: ${_isBannerAdReady ? "준비됨" : "로딩중"}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              _isInterstitialAdReady ? Icons.check_circle : Icons.error,
                              color: _isInterstitialAdReady ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '전면광고: ${_isInterstitialAdReady ? "준비됨" : "로딩중"}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '광고가 로딩되지 않으면 네트워크 연결을 확인하세요',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // === 남은 수명 계산 ===
  void _calculateRemainingLife() {
    try {
      if (selectedBirthDate == null) return;
      
      final now = DateTime.now();
      final age = now.difference(selectedBirthDate!).inDays / 365.25;
      final lifeExpectancy = 100.0; // 100세 기준
      
      if (age >= lifeExpectancy) {
        setState(() {
          remainingSeconds = 0;
          lifePercentage = 100.0;
        });
        return;
      }
      
      final remainingYears = lifeExpectancy - age;
      final remainingDays = remainingYears * 365.25;
      
      setState(() {
        remainingSeconds = (remainingDays * 24 * 60 * 60).round();
        lifePercentage = (age / lifeExpectancy) * 100;
      });
    } catch (e) {
      print('수명 계산 중 오류 발생: $e');
    }
  }

  // === 실시간 카운트다운 타이머 시작 ===
  void _startTimer() {
    try {
      _timer?.cancel(); // 기존 타이머 정리
      
      if (!showLifeStats || selectedBirthDate == null) return;
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        try {
          if (remainingSeconds > 0) {
            setState(() {
              remainingSeconds--;
            });
          } else {
            timer.cancel();
          }
        } catch (e) {
          print('타이머 업데이트 중 오류: $e');
          timer.cancel();
        }
      });
    } catch (e) {
      print('타이머 시작 중 오류 발생: $e');
    }
  }

  // === 전면광고 로드 ===
  void _loadInterstitialAd() {
    try {
      if (!mounted) return;
      
      print('🔄 전면광고 로드 시작...');
      print('🎯 전면광고 ID: ${AdHelper.interstitialAdUnitId}');
      
      InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print('✅ 전면광고 로드 완료!');
            if (mounted) {
              _interstitialAd = ad;
              _isInterstitialAdReady = true;
              _interstitialAd!.setImmersiveMode(true);
            }
          },
          onAdFailedToLoad: (err) {
            print('❌ 전면광고 로드 실패: ${err.message}');
            print('🔍 오류 코드: ${err.code}');
            print('🔍 오류 도메인: ${err.domain}');
            if (mounted) {
              _isInterstitialAdReady = false;
              // 30초 후 재시도
              Timer(const Duration(seconds: 30), () {
                if (mounted) {
                  print('🔄 전면광고 재시도...');
                  _loadInterstitialAd();
                }
              });
            }
          },
        ),
      );
    } catch (e) {
      print('💥 전면광고 로드 중 예외 발생: $e');
    }
  }

  // === 전면광고 표시 ===
  void _showInterstitialAd() {
    print('🎬 전면광고 표시 시도...');
    print('📊 광고 준비 상태: $_isInterstitialAdReady');
    print('📊 광고 객체 존재: ${_interstitialAd != null}');
    
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('✅ 전면광고 닫힘');
          ad.dispose();
          _loadInterstitialAd(); // 다음 광고 미리 로드
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          print('❌ 전면광고 표시 실패: ${err.message}');
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdShowedFullScreenContent: (ad) {
          print('✅ 전면광고 표시 성공!');
        },
      );
      
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
    } else {
      print('⚠️ 전면광고를 표시할 수 없음 (준비되지 않음)');
    }
  }

  // === 시간 포맷팅 (년, 일, 시간, 분, 초로 변환) ===
  String _formatTime(int seconds, AppLocalizations l10n) {
    if (seconds <= 0) return "0${l10n.seconds}";
    
    final years = seconds ~/ (365.25 * 24 * 60 * 60); // 년 계산
    final days = (seconds % (365.25 * 24 * 60 * 60)) ~/ (24 * 60 * 60); // 일 계산
    final hours = (seconds % (24 * 60 * 60)) ~/ (60 * 60); // 시간 계산
    final minutes = (seconds % (60 * 60)) ~/ 60; // 분 계산
    final remainingSecs = seconds % 60; // 초 계산

    return "${years}${l10n.years} ${days}${l10n.days} ${hours}${l10n.hours} ${minutes}${l10n.minutes} ${remainingSecs}${l10n.seconds}";
  }

  // === 해당 월의 최대 일수 계산 (윤년 고려) ===
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // === SNS 공유 기능 ===
  void _shareLifeStats() {
    if (selectedBirthDate == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    final motivationalQuotes = getMotivationalQuotes(l10n);
    
    // 공유할 텍스트 직접 구성
    final birthday = '${selectedBirthDate!.year}.${selectedBirthDate!.month.toString().padLeft(2, '0')}.${selectedBirthDate!.day.toString().padLeft(2, '0')}';
    final remainingTime = _formatTime(remainingSeconds, l10n);
    final progress = lifePercentage.toStringAsFixed(1);
    final quote = motivationalQuotes[currentQuoteIndex];
    
    final shareText = '''${l10n.appTitle} Life Check Result

📅 ${l10n.birthday}: $birthday
⏳ ${l10n.remainingLife}: $remainingTime
📊 ${l10n.lifeProgress}: $progress%
💭 "$quote"

What's your remaining time? Check with Death Clock app!''';
    
    // 바로 공유 실행
    Share.share(shareText);
  }

  // === 배너광고 로드 ===
  void _loadBannerAd() {
    try {
      if (!mounted) return;
      
      print('🔄 배너광고 로드 시작...');
      print('🎯 배너광고 ID: ${AdHelper.bannerAdUnitId}');
      
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ 배너광고 로드 완료!');
            if (mounted) {
              setState(() {
                _isBannerAdReady = true;
              });
            }
          },
          onAdFailedToLoad: (ad, err) {
            print('❌ 배너광고 로드 실패: ${err.message}');
            print('🔍 오류 코드: ${err.code}');
            print('🔍 오류 도메인: ${err.domain}');
            ad.dispose();
            if (mounted) {
              _isBannerAdReady = false;
              // 30초 후 재시도
              Timer(const Duration(seconds: 30), () {
                if (mounted) {
                  print('🔄 배너광고 재시도...');
                  _loadBannerAd();
                }
              });
            }
          },
          onAdOpened: (ad) {
            print('📱 배너광고 클릭됨');
          },
          onAdClosed: (ad) {
            print('📱 배너광고 닫힘');
          },
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      print('💥 배너광고 로드 중 예외 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final motivationalQuotes = getMotivationalQuotes(l10n);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // === 생일 선택 버튼 ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[900]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red[300]!, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cake,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedBirthDate == null
                          ? l10n.selectBirthday
                          : '${selectedBirthDate!.year}.${selectedBirthDate!.month.toString().padLeft(2, '0')}.${selectedBirthDate!.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _showBirthDatePicker,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(selectedBirthDate == null ? l10n.selectBirthday : '변경'),
                    ),
                    
                    // === 남은 수명 보기 버튼 (생일 선택 후에만 표시) ===
                    if (selectedBirthDate != null && !showLifeStats) ...[
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showLifeStats = true;
                            _calculateRemainingLife();
                            _startTimer();
                          });
                        },
                        icon: const Icon(Icons.visibility, color: Colors.white),
                        label: const Text(
                          '남은 수명 보기',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // === 남은 수명 표시 (showLifeStats가 true일 때만) ===
              if (selectedBirthDate != null && showLifeStats) ...[
                // 남은 수명 카운터
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[900]!, Colors.red[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.remainingLife,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _formatTime(remainingSeconds, l10n),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // 인생 진행률 바
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.lifeProgress,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              Text(
                                '${lifePercentage.toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: lifePercentage / 100,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              lifePercentage < 50 ? Colors.green : 
                              lifePercentage < 80 ? Colors.orange : Colors.red,
                            ),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 공유 버튼
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _shareLifeStats();
                      // 공유 시 전면광고 표시 (광고가 준비된 경우에만)
                      if (_isInterstitialAdReady && _interstitialAd != null && Random().nextBool()) {
                        _showInterstitialAd();
                      }
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: Text(
                      l10n.shareLifeStats,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 동기부여 명언 섹션
                if (motivationalQuotes.isNotEmpty)
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
                          style: const TextStyle(
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
                          child: Text(l10n.viewOtherQuote),
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
    );
  }

  @override
  void dispose() {
    try {
      _timer?.cancel(); // 타이머 정리
      _interstitialAd?.dispose(); // 전면광고 정리
      _bannerAd?.dispose(); // 배너광고 정리
    } catch (e) {
      print('리소스 정리 중 오류: $e');
    }
    super.dispose();
  }
}
