import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_emotion_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CalendarDetailEmotion extends StatefulWidget {
  final DateTime selectedDate;

  const CalendarDetailEmotion({super.key, required this.selectedDate});

  @override
  State<CalendarDetailEmotion> createState() => _CalendarDetailEmotionState();
}

class _CalendarDetailEmotionState extends State<CalendarDetailEmotion> {
  final _emotionService = UserEmotionService();
  int _selectedValue = 0;
  bool _isLoading = true;

  final Map<int, String> _emotionMap = {0: 'happy', 1: 'basic', 2: 'sad'};

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
          _selectedValue = _emotionMap.entries
              .firstWhere(
                (entry) => entry.value == emotion,
                orElse: () => MapEntry(0, 'sentiment_satisfied'),
              )
              .key;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveEmotion(int value) async {
    try {
      await _emotionService.saveEmotion(
        iconName: _emotionMap[value]!,
        date: widget.selectedDate,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오늘의 감정을 등록했어요')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
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
      isDense: true,
      value: _selectedValue,
      underline: SizedBox(),
      icon: SizedBox(), // 화살표 숨김
      selectedItemBuilder: (context) => [
        _buildIcon(Icons.sentiment_satisfied_outlined),
        _buildIcon(Icons.sentiment_neutral_outlined),
        _buildIcon(Icons.sentiment_dissatisfied_outlined),
      ],
      items: [
        DropdownMenuItem(
          value: 0,
          child: _buildIcon(Icons.sentiment_satisfied_outlined),
        ),
        DropdownMenuItem(
          value: 1,
          child: _buildIcon(Icons.sentiment_neutral_outlined),
        ),
        DropdownMenuItem(
          value: 2,
          child: _buildIcon(Icons.sentiment_dissatisfied_outlined),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedValue = value;
          });
          _saveEmotion(value);
        }
      },
    );
  }
}

Widget _buildIcon(IconData iconData) {
  return Center(child: Icon(iconData, size: 30, color: MainColors.point));
}
