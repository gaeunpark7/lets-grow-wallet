import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidSystemBars extends StatefulWidget {
  final Widget child;

  final Color statusBarColor;
  final Brightness statusBarIconBrightness;

  final Color navigationBarColor;
  final Brightness navigationBarIconBrightness;

  const AndroidSystemBars({
    super.key,
    required this.child,
    required this.statusBarColor,
    required this.statusBarIconBrightness,
    required this.navigationBarColor,
    required this.navigationBarIconBrightness,
  });

  const AndroidSystemBars.light({
    super.key,
    required this.child,
    this.statusBarColor = Colors.white,
    this.navigationBarColor = Colors.white,
  }) : statusBarIconBrightness = Brightness.dark,
       navigationBarIconBrightness = Brightness.dark;

  const AndroidSystemBars.dark({
    super.key,
    required this.child,
    this.statusBarColor = Colors.black,
    this.navigationBarColor = Colors.black,
  }) : statusBarIconBrightness = Brightness.light,
       navigationBarIconBrightness = Brightness.light;

  @override
  State<AndroidSystemBars> createState() => _AndroidSystemBarsState();
}

class _AndroidSystemBarsState extends State<AndroidSystemBars> {
  SystemUiOverlayStyle get _style => SystemUiOverlayStyle(
    statusBarColor: widget.statusBarColor,
    statusBarIconBrightness: widget.statusBarIconBrightness,
    systemNavigationBarColor: widget.navigationBarColor,
    systemNavigationBarIconBrightness: widget.navigationBarIconBrightness,
  );

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _apply();
  }

  @override
  void didUpdateWidget(covariant AndroidSystemBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusBarColor != widget.statusBarColor ||
        oldWidget.statusBarIconBrightness != widget.statusBarIconBrightness ||
        oldWidget.navigationBarColor != widget.navigationBarColor ||
        oldWidget.navigationBarIconBrightness !=
            widget.navigationBarIconBrightness) {
      _apply();
    }
  }

  void _apply() {
    if (!_isAndroid) return;
    SystemChrome.setSystemUIOverlayStyle(_style);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _style,
      child: widget.child,
    );
  }
}
