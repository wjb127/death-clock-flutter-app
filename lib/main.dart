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

  // === 알림 권한 확인 및 요청 ===
  Future<void> _checkAndRequestNotificationPermission() async {
    await NotificationService.requestPermissions();
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedBirthDate = DateTime(selectedYear, selectedMonth, selectedDay);
                      _calculateRemainingLife();
                      _startTimer();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인', style: TextStyle(color: Colors.red)),
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
    if (selectedBirthDate == null) return;

    final now = DateTime.now();
    final age = now.difference(selectedBirthDate!);
    final ageInYears = age.inDays / 365.25;
    
    // 100세까지 남은 시간 계산
    final remainingYears = 100 - ageInYears;
    final remainingDays = remainingYears * 365.25;
    remainingSeconds = (remainingDays * 24 * 60 * 60).round();
    
    // 인생 진행률 계산 (0-100%)
    lifePercentage = (ageInYears / 100) * 100;
    if (lifePercentage > 100) lifePercentage = 100;
    if (lifePercentage < 0) lifePercentage = 0;
  }

  // === 실시간 타이머 시작 ===
  void _startTimer() {
    _timer?.cancel(); // 기존 타이머 정리
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // === 전면광고 로드 ===
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('전면광고 로드 완료');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (err) {
          print('전면광고 로드 실패: ${err.message}');
          _isInterstitialAdReady = false;
          // 30초 후 재시도
          Timer(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  // === 전면광고 표시 ===
  void _showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('전면광고 닫힘');
          ad.dispose();
          _loadInterstitialAd(); // 다음 광고 미리 로드
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          print('전면광고 표시 실패: ${err.message}');
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
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
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // === 남은 수명 표시 (생일이 선택된 경우에만) ===
              if (selectedBirthDate != null) ...[
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
                      // 공유 시 전면광고 표시 (확률적으로)
                      if (Random().nextBool()) {
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
    _timer?.cancel(); // 타이머 정리
    _interstitialAd?.dispose(); // 전면광고 정리
    _bannerAd?.dispose(); // 배너광고 정리
    super.dispose();
  }
}
