import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ScreenUtilClampX on num {
  double get wClamp {
    final scale = ScreenUtil().scaleWidth;
    return toDouble() * (scale > 1 ? 1.0 : scale);
  }

  double wClampBetween({required double min, required double max}) {
    return wClamp.clamp(min, max).toDouble();
  }

  double get hClamp {
    final scale = ScreenUtil().scaleHeight;
    return toDouble() * (scale > 1 ? 1.0 : scale);
  }

  double hClampBetween({required double min, required double max}) {
    return hClamp.clamp(min, max).toDouble();
  }

  double get rClamp {
    final w = ScreenUtil().scaleWidth;
    final h = ScreenUtil().scaleHeight;
    final scale = w < h ? w : h;
    return toDouble() * (scale > 1 ? 1.0 : scale);
  }

  double rClampBetween({required double min, required double max}) {
    return rClamp.clamp(min, max).toDouble();
  }

  double get spClamp {
    final scale = ScreenUtil().scaleText;
    return toDouble() * (scale > 1 ? 1.0 : scale);
  }

  double spClampBetween({required double min, required double max}) {
    return spClamp.clamp(min, max).toDouble();
  }
}
