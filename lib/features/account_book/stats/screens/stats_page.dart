import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/stats_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_expense_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_income_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/montly_header.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdmobService.BannerAdUnitId!,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: AdmobService.bannerAdListener,
    )..load();
  }

  @override
  Widget build(BuildContext context) {
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
                _buildSelectButton(context, 0, "수입"),
                const SizedBox(width: 12),
                _buildSelectButton(context, 1, "지출"),
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
              children: [StatsIncomeView(), StatsExpenseView()],
            ),
          ),
          //광고 배너
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
        minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 45),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      onPressed: () {
        setState(() => _tabController.index = index);
      },
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
