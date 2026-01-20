import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppSnackBar(String message, {bool hideCurrent = true}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;

  if (hideCurrent) {
    messenger.hideCurrentSnackBar();
  }
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

void showAppSnackBarWidget(SnackBar snackBar, {bool hideCurrent = true}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;

  if (hideCurrent) {
    messenger.hideCurrentSnackBar();
  }
  messenger.showSnackBar(snackBar);
}
