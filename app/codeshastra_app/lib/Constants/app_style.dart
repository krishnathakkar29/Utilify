import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppStyle {
  static TextStyle exampleText = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    color: AppColors.lightText,
    fontWeight: FontWeight.w500,
  );
  static TextStyle appbartext = const TextStyle(
    color: AppColors.red,
    fontSize: 25,
    fontFamily: "popR",
    fontWeight: FontWeight.w600,
  );
  static TextStyle notificationtitletext = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: "popR",
  );
  static TextStyle notificationsubtitletext = TextStyle(
    fontSize: 13,
    color: AppColors.grey400,
    fontWeight: FontWeight.w600,
    fontFamily: "popR",
  );
  static TextStyle contactustext = const TextStyle(
    fontFamily: "popR",
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );
}
