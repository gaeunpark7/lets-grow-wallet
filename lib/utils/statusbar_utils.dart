import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class StatusbarUtils extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Color? statusBarColor;
  final Color? statusNavigationBarColor;
  const StatusbarUtils({
    super.key,
    this.backgroundColor = MainColors.mainLight,
    this.statusBarColor = MainColors.mainLight,
    this.statusNavigationBarColor = MainColors.mainLight,
  });

  @override
  Size get preferredSize => const Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        // 상태바 배경색 (안드로이드)
        statusBarColor: statusBarColor,
        statusBarIconBrightness: Brightness.light, // 안드로이드 아이콘 색상
        systemNavigationBarColor: statusNavigationBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}

Future<T?> showDialogWithDimmedSystemBars<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? dimColor,
  Brightness iconBrightness = Brightness.light,
  Color barrierColor = Colors.black54,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
}) {
  final effectiveDimColor = dimColor ?? MainColors.mainDark.withOpacity(0.6);
  final overlayStyle = SystemUiOverlayStyle(
    statusBarColor: effectiveDimColor,
    statusBarIconBrightness: iconBrightness,
    systemNavigationBarColor: effectiveDimColor,
    systemNavigationBarIconBrightness: iconBrightness,
  );

  return showDialog<T>(
    context: context,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    builder: (dialogContext) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: builder(dialogContext),
      );
    },
  );
}
