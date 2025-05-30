import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const DeathClockApp());
}

class DeathClockApp extends StatelessWidget {
  const DeathClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Death Clock - 수명 계산기',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      home: const DeathClockHomePage(),
    );
  }
}

class DeathClockHomePage extends StatefulWidget {
  const DeathClockHomePage({super.key});

  @override
  State<DeathClockHomePage> createState() => _DeathClockHomePageState();
}

class _DeathClockHomePageState extends State<DeathClockHomePage> {
  DateTime? selectedBirthDate;
  int remainingSeconds = 0;
  double lifePercentage = 0.0;
  int currentQuoteIndex = 0;
  Timer? _timer;
  
  // 날짜 선택을 위한 변수들
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;
  
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
    final now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;
    selectedDay = now.day;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDateChanged() {
    setState(() {
      selectedBirthDate = DateTime(selectedYear, selectedMonth, selectedDay);
      _calculateRemainingLife();
      _startTimer();
    });
  }

  void _calculateRemainingLife() {
    if (selectedBirthDate == null) return;

    final now = DateTime.now();
    final age = now.difference(selectedBirthDate!);
    final ageInYears = age.inDays / 365.25;
    
    // 80년 수명 기준
    const lifeExpectancy = 80.0;
    final remainingYears = lifeExpectancy - ageInYears;
    
    if (remainingYears > 0) {
      remainingSeconds = (remainingYears * 365.25 * 24 * 60 * 60).round();
      lifePercentage = (ageInYears / lifeExpectancy) * 100;
    } else {
      remainingSeconds = 0;
      lifePercentage = 100.0;
    }

    // 명언 인덱스 랜덤 변경
    currentQuoteIndex = Random().nextInt(motivationalQuotes.length);
  }

  void _startTimer() {
    _timer?.cancel(); // 기존 타이머가 있다면 취소
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

  String _formatTime(int seconds) {
    if (seconds <= 0) return "0초";
    
    final years = seconds ~/ (365.25 * 24 * 60 * 60);
    final days = (seconds % (365.25 * 24 * 60 * 60)) ~/ (24 * 60 * 60);
    final hours = (seconds % (24 * 60 * 60)) ~/ (60 * 60);
    final minutes = (seconds % (60 * 60)) ~/ 60;
    final remainingSecs = seconds % 60;

    return "${years}년 ${days}일 ${hours}시간 ${minutes}분 ${remainingSecs}초";
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
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
      ),
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
                        const Text(
                          '남은 수명',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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
