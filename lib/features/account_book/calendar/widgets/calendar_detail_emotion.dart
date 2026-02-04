import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_emotion_service.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

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
  bool _hasEmotion = false;
  bool _isSaving = false;
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
        if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _hasEmotion = true;
        _isSaving = false;
      });

      // 드롭다운/오버레이 정리 이후 스낵바 표시(디버그에서 간헐적 경고 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAppSnackBar('오늘의 감정을 등록했어요');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAppSnackBar(FriendlyErrorMessage.of(e));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isSaving) {
      return SizedBox(
        width: 30.wClamp,
        height: 30.hClamp,
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
                  _isSaving = true;
                });
                // 드롭다운 오버레이가 닫힌 뒤 저장 로직 실행
                Future.microtask(() => _saveEmotion(_emotions[value]));
              }
            },
    );
  }
}

Widget _buildIconImage(String iconName) {
  return Center(
    child: Image.asset(
      'assets/emotions/$iconName.png',
      width: 30.wClamp,
      height: 30.hClamp,
    ),
  );
}
