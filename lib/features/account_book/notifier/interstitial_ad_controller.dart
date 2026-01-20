import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';

final interstitialAdControllerProvider =
    NotifierProvider<InterstitialAdController, int>(
      InterstitialAdController.new,
    );

class InterstitialAdController extends Notifier<int> {
  InterstitialAd? _preloaded;
  bool _isLoading = false;
  bool _isShowing = false;

  @override
  int build() {
    ref.onDispose(() {
      _preloaded?.dispose();
      _preloaded = null;
    });
    return 0;
  }

  /// 거래(지출/수입) 추가 성공 시 호출.
  /// 3번째마다 전면 광고를 표시하고, 광고가 닫힐 때까지기다림.
  Future<void> onTransactionAdded() async {
    state = state + 1;

    // 3번마다 노출
    if (state % 3 == 0) {
      await _showInterstitial();
      return;
    }

    // 다음(3번째) 노출을 위해 미리 로드
    if (state % 3 == 2) {
      unawaited(_preload());
    }
  }

  Future<void> _preload() async {
    if (_preloaded != null) return;
    if (_isLoading) return;
    if (_isShowing) return;

    final unitId = AdmobService.InterstitialAdUnitId;
    if (unitId == null) return;

    _isLoading = true;
    try {
      final ad = await _loadInterstitial(unitId);
      _preloaded?.dispose();
      _preloaded = ad;
    } catch (_) {
      // ignore
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _showInterstitial() async {
    if (_isShowing) return;

    final unitId = AdmobService.InterstitialAdUnitId;
    if (unitId == null) return;

    _isShowing = true;
    try {
      final ad = _preloaded ?? await _loadInterstitial(unitId);
      _preloaded = null;
      await _showAndWait(ad);
    } catch (_) {
    } finally {
      _isShowing = false;
      unawaited(_preload());
    }
  }

  Future<InterstitialAd> _loadInterstitial(String unitId) {
    final completer = Completer<InterstitialAd>();

    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          completer.completeError(error);
        },
      ),
    );

    return completer.future;
  }

  Future<void> _showAndWait(InterstitialAd ad) {
    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
    );

    ad.show();
    return completer.future;
  }
}
