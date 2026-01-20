import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  //전면 광고
  static String? get InterstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return null;
  }

  //네이티브 광고
  static String? get NativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    return null;
  }

  //배너 광고
  static String? get BannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) {
      print('배너 광고 로드 완료: ${ad.adUnitId}');
    },
    onAdFailedToLoad: (ad, error) {
      print('배너 광고 로드 실패: ${ad.adUnitId}, 오류: $error');
      ad.dispose();
    },
    onAdOpened: (ad) => print('배너 광고 열림: ${ad.adUnitId}'),
    onAdClosed: (ad) => print('배너 광고 닫힘: ${ad.adUnitId}'),
    onAdImpression: (ad) => print('배너 광고 노출: ${ad.adUnitId}'),
  );
}
