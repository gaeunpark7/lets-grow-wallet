import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/active_character_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/character_book_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/inapp_purchase_service.dart';
import 'package:lets_grow_wallet/features/account_book/services/premium_entitlement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final premiumPurchaseControllerProvider =
    NotifierProvider<PremiumPurchaseController, PremiumPurchaseState>(
      PremiumPurchaseController.new,
    );

class PremiumPurchaseState {
  final ProductDetails? product;
  final bool isLoadingProduct;
  final bool isPurchasing;
  final String? errorMessage;

  const PremiumPurchaseState({
    this.product,
    this.isLoadingProduct = false,
    this.isPurchasing = false,
    this.errorMessage,
  });

  PremiumPurchaseState copyWith({
    ProductDetails? product,
    bool? isLoadingProduct,
    bool? isPurchasing,
    String? errorMessage,
  }) {
    return PremiumPurchaseState(
      product: product ?? this.product,
      isLoadingProduct: isLoadingProduct ?? this.isLoadingProduct,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorMessage: errorMessage,
    );
  }
}

class PremiumPurchaseController extends Notifier<PremiumPurchaseState> {
  final _iapService = InAppPurchaseService();
  final _entitlementService = PremiumEntitlementService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isDelivering = false;
  Timer? _purchaseGuardTimer;

  void _cancelPurchaseGuard() {
    _purchaseGuardTimer?.cancel();
    _purchaseGuardTimer = null;
  }

  void _startPurchaseGuard() {
    _cancelPurchaseGuard();
    _purchaseGuardTimer = Timer(const Duration(seconds: 30), () {
      if (state.isPurchasing) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: '결제 상태를 확인할 수 없습니다. 다시 시도해주세요.',
        );
      }
    });
  }

  @override
  PremiumPurchaseState build() {
    ref.watch(authUserIdProvider);

    _subscription ??= InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (e, st) {
        state = state.copyWith(isPurchasing: false, errorMessage: e.toString());
        showAppSnackBar('결제 처리 중 오류가 발생했습니다.');
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
      _cancelPurchaseGuard();
    });

    unawaited(_loadProduct());
    return const PremiumPurchaseState();
  }

  Future<void> _loadProduct() async {
    if (state.isLoadingProduct) return;

    state = state.copyWith(isLoadingProduct: true, errorMessage: null);
    try {
      final product = await _iapService.getProductDetails();
      state = state.copyWith(product: product, isLoadingProduct: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingProduct: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> buy() async {
    if (ref.read(isPremiumProvider)) {
      showAppSnackBar('이미 프리미엄이 적용되어 있습니다.');
      return;
    }

    late final ProductDetails product;
    try {
      product = state.product ?? await _iapService.getProductDetails();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      showAppSnackBar(e.toString());
      return;
    }

    state = state.copyWith(isPurchasing: true, errorMessage: null);

    try {
      final started = await _iapService.buyProduct(product);
      if (!started) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: '결제를 시작할 수 없습니다.',
        );
        showAppSnackBar('결제를 시작할 수 없습니다.');
        return;
      }
      _startPurchaseGuard();
    } catch (e) {
      state = state.copyWith(isPurchasing: false, errorMessage: e.toString());
      showAppSnackBar(e.toString());
    }
  }

  String _entitlementErrorText(Object error) {
    if (error is PostgrestException) {
      final parts = <String>[];
      if (error.message.isNotEmpty) parts.add(error.message);
      final details = error.details?.toString().trim();
      if (details != null && details.isNotEmpty) parts.add(details);
      final hint = error.hint?.toString().trim();
      if (hint != null && hint.isNotEmpty) parts.add(hint);
      return parts.isEmpty ? error.toString() : parts.join('\n');
    }
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != InAppPurchaseService.productId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(isPurchasing: true, errorMessage: null);
          break;
        case PurchaseStatus.error:
          _cancelPurchaseGuard();
          state = state.copyWith(
            isPurchasing: false,
            errorMessage: purchase.error?.message ?? '결제에 실패했습니다.',
          );
          showAppSnackBar(
            purchase.error?.message ??
                purchase.error?.toString() ??
                '결제에 실패했습니다.',
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          unawaited(_deliverAndComplete(purchase));
          break;
        case PurchaseStatus.canceled:
          _cancelPurchaseGuard();
          state = state.copyWith(isPurchasing: false);
          break;
      }
    }
  }

  Future<void> _deliverAndComplete(PurchaseDetails purchase) async {
    if (_isDelivering) return;
    _isDelivering = true;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        showAppSnackBar('로그인 상태를 확인할 수 없습니다.');
        return;
      }

      final purchasedAt = DateTime.now();

      await _entitlementService.verifyAndGrantPremium(
        userId: userId,
        purchasedAt: purchasedAt,
        productId: purchase.productID,
        serverVerificationData: purchase
            .verificationData
            .serverVerificationData, // 구글 purchaseToken
      );

      // 로컬 상태 업데이트
      ref
          .read(userProfileNotifierProvider.notifier)
          .setPremiumLocal(purchasedAt: purchasedAt);

      ref.invalidate(characterBookNotifierProvider);
      ref.invalidate(activeCharacterNotifierProvider);

      showAppSnackBar('프리미엄이 적용되었습니다. 새로운 캐릭터를 확인해보세요!');

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      _cancelPurchaseGuard();
      state = state.copyWith(isPurchasing: false, errorMessage: null);
    } catch (e) {
      _cancelPurchaseGuard();
      state = state.copyWith(isPurchasing: false, errorMessage: e.toString());
      showAppSnackBar(_entitlementErrorText(e));
    } finally {
      _isDelivering = false;
    }
  }
}
