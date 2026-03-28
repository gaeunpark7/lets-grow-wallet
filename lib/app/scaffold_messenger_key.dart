import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

const int _kSnackBarMaxRetries = 5;

void _showWithRetry(
  SnackBar Function() snackBarBuilder, {
  required bool hideCurrent,
  int attempt = 0,
}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) {
    if (attempt >= _kSnackBarMaxRetries) {
      debugPrint(
        'showAppSnackBar dropped: ScaffoldMessengerState is null (attempt=$attempt)',
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWithRetry(
        snackBarBuilder,
        hideCurrent: hideCurrent,
        attempt: attempt + 1,
      );
    });
    return;
  }

  if (hideCurrent) {
    messenger.hideCurrentSnackBar();
  }
  messenger.showSnackBar(snackBarBuilder());
}

void showAppSnackBar(String message, {bool hideCurrent = true}) {
  _showWithRetry(
    () => SnackBar(content: Text(message)),
    hideCurrent: hideCurrent,
  );
}

void showAppSnackBarWidget(SnackBar snackBar, {bool hideCurrent = true}) {
  _showWithRetry(() => snackBar, hideCurrent: hideCurrent);
}
