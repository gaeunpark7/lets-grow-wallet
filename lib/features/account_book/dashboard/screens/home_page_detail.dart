import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/delete_dialog.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/transaction_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class HomePageDetail extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const HomePageDetail({super.key, required this.transaction});

  @override
  ConsumerState<HomePageDetail> createState() => _HomePageDetailState();
}

class _HomePageDetailState extends ConsumerState<HomePageDetail> {
  late GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }

  Future<void> deleteTransaction() async {
    try {
      await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(widget.transaction.id);
    } catch (e) {
      debugPrint('deleteTransaction failed: $e');
      if (mounted) {
        showAppSnackBar('삭제 실패하였습니다. 다시 시도해주세요.');
      }
      return;
    }

    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).maybePop();
    showAppSnackBar('삭제 되었습니다.');
  }

  //수정 페이지 이동
  Future<void> goToEditPage() async {
    final location = widget.transaction.type == 'expense'
        ? '${Routes.home}/${Routes.editExpense}'
        : '${Routes.home}/${Routes.editIncome}';

    Navigator.of(context).pop();
    _router.push(location, extra: widget.transaction);
  }

  //삭제 다이얼로그
  void showDeleteDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          onTap: () {
            Navigator.pop(context);
            deleteTransaction();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${tx.title.isNotEmpty ? tx.title : tx.categoryName}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: MainColors.mainDark,
                  ),
                ),
                SizedBox(
                  width: 15,
                  height: 20, // 아이콘 높이
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    constraints: const BoxConstraints(), //팝업 메뉴 최소 크기 제한 x
                    icon: Icon(Icons.more_vert, color: MainColors.mainLight),
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 'edit') {
                        goToEditPage();
                      } else if (value == 'delete') {
                        showDeleteDialog();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        height: 32,
                        child: Text(
                          '수정',
                          style: TextStyle(color: MainColors.mainDark),
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        height: 32,
                        child: Text(
                          '삭제',
                          style: TextStyle(color: MainColors.mainDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: MainColors.mainLight, thickness: 1, height: 5),
            SizedBox(height: 12),
            _buildList("카테고리", "${tx.categoryName}"),
            _buildList("유형", tx.type == "income" ? "수입" : "지출"),
            _buildList(
              "금액",
              (() {
                final formatter = NumberFormat('#,##0');
                final formatted = formatter.format(widget.transaction.amount);
                return widget.transaction.type == "income"
                    ? "+$formatted"
                    : "-$formatted";
              })(),
            ),
            _buildList("날짜", DateFormat('yyyy.MM.dd').format(tx.date)),
            SizedBox(height: 7),
            _buildMemo(context, tx),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: MainColors.mainLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "닫기",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildList(String title, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: MainColors.mainDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(value, style: TextStyle(color: MainColors.mainDark)),
          ],
        ),
        Divider(
          color: MainColors.mainLight,
          thickness: 1, // 두께를 명시적으로 설정
          height: 5, // 높이를 명시적으로 설정
        ),
        SizedBox(height: 5),
      ],
    );
  }

  _buildMemo(BuildContext context, TransactionModel tx) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: MainColors.mainLight),
      ),
      child: Text(
        tx.memo.isNotEmpty ? tx.memo : "작성한 메모가 없습니다.",
        style: TextStyle(color: MainColors.mainDark),
      ),
    );
  }
}
