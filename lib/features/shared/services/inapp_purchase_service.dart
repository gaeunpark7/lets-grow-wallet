import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  static const String productId = 'premium_package_final';

  // 1. 구글 서버에서 상품 정보 가져오기
  Future<ProductDetails> getProductDetails() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception(
        '스토어 결제를 사용할 수 없습니다. (isAvailable=false)\n'
        '에뮬레이터/디바이스에 Play Store가 없거나, Google 계정 로그인이 안 됐거나, '
        '웹/데스크톱에서 실행 중일 수 있어요.',
      );
    }

    const Set<String> kIds = {productId};
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(kIds);

    if (response.error != null) {
      debugPrint('IAP queryProductDetails error: ${response.error}');
      throw Exception('상품 조회 오류: ${response.error}');
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP notFoundIDs: ${response.notFoundIDs}');
      throw Exception(
        '상품 ID를 찾지 못했습니다: ${response.notFoundIDs.join(', ')}\n'
        'Play Console에 등록된 상품 ID와 코드의 productId가 정확히 일치하는지 확인해주세요.',
      );
    }

    if (response.productDetails.isNotEmpty) {
      return response.productDetails.first;
    }

    throw Exception('상품 정보를 가져오지 못했습니다.');
  }

  // 결제 시작
  Future<bool> buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }
}
