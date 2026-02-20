import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/stats_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_expense_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_income_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/month_header.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BannerAd? _bannerAd;
  ProviderSubscription<bool>? _premiumSubscription;

  @override
  void initState() {
    super.initState();

    _premiumSubscription = ref.listenManual<bool>(isPremiumProvider, (
      prev,
      next,
    ) {
      if (!mounted) return;

      if (next) {
        setState(() {
          _bannerAd?.dispose();
          _bannerAd = null;
        });
        return;
      }

      if (_bannerAd == null) {
        setState(_createBannerAd);
      }
    });

    if (!ref.read(isPremiumProvider)) {
      _createBannerAd();
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _premiumSubscription?.close();
    _tabController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _createBannerAd() {
    final adUnitId = AdmobService.BannerAdUnitId;
    if (adUnitId == null) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: AdmobService.bannerAdListener,
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: MonthHeader(onKindChanged: (_) {}, current: StatsKind.income),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.hClamp),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.hClamp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSelectButton(context, 0, "지출"),
                const SizedBox(width: 12),
                _buildSelectButton(context, 1, "수입"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [StatsExpenseView(), StatsIncomeView()],
            ),
          ),
          //광고 배너
          if (!isPremium)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: MainColors.point, width: 1),
                  ),
                ),
                child: SizedBox(
                  height: 56.hClamp,
                  width: _bannerAd?.size.width.toDouble() ?? 0,
                  child: _bannerAd != null
                      ? AdWidget(ad: _bannerAd!)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _buildSelectButton(BuildContext context, int index, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tabController.index == index
            ? MainColors.mainLight
            : MainColors.main,
        foregroundColor: _tabController.index == index
            ? Colors.white
            : MainColors.mainDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 45.hClamp),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      onPressed: () {
        setState(() => _tabController.index = index);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.spClamp,
          fontFamily: 'ScoreMedium',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
