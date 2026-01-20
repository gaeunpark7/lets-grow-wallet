import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/calendar_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_emotion_service.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CalendarDetailEmotion extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const CalendarDetailEmotion({super.key, required this.selectedDate});

  @override
  ConsumerState<CalendarDetailEmotion> createState() =>
      _CalendarDetailEmotionState();
}

class _CalendarDetailEmotionState extends ConsumerState<CalendarDetailEmotion> {
  final _emotionService = UserEmotionService();
  String _selectedEmotion = 'basic';
  bool _isLoading = true;
  bool _hasEmotion = false; // 감정 등록 여부 확인
  final List<String> _emotions = ['happy', 'good', 'basic', 'angry', 'sad'];

  @override
  void initState() {
    super.initState();
    _loadEmotion();
  }

  Future<void> _loadEmotion() async {
    try {
      final emotion = await _emotionService.getEmotion(
        date: widget.selectedDate,
      );

      if (emotion != null && mounted) {
        setState(() {
          _selectedEmotion = emotion;
          _hasEmotion = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasEmotion = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasEmotion = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveEmotion(String emotion) async {
    try {
      await _emotionService.saveEmotion(
        iconName: emotion,
        date: widget.selectedDate,
      );
      if (mounted) {
        showAppSnackBar('오늘의 감정을 등록했어요');
        // 캘린더 데이터 새로고침
        ref.read(calendarStatNotifierProvider.notifier).refreshDailyStats();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: MainColors.point,
        ),
      );
    }

    return DropdownButton<int>(
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(50),
      isDense: true,
      value: _emotions.indexOf(_selectedEmotion),
      underline: SizedBox(),
      icon: SizedBox(),
      selectedItemBuilder: (context) =>
          _emotions.map((emotion) => _buildIconImage(emotion)).toList(),
      items: _emotions
          .asMap()
          .entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.key,
              child: _buildIconImage(entry.value),
            ),
          )
          .toList(),
      onChanged: _hasEmotion
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  _selectedEmotion = _emotions[value];
                });
                _saveEmotion(_emotions[value]);
              }
            },
    );
  }
}

Widget _buildIconImage(String iconName) {
  return Center(
    child: Image.asset('assets/emotions/$iconName.png', width: 30, height: 30),
  );
}
