import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/utils/app_colors.dart';

class AppTextStyles {
  static TextStyle appBarTitle = TextStyle(
    color: AppColors.purpleColor,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle todoTitle = TextStyle(
    color: AppColors.purpleColor,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle todoSubtitle = TextStyle(
    color: AppColors.greyColor,
    fontSize: 14.sp,
  );

  static TextStyle emptyMessage = TextStyle(
    fontSize: 16.sp,
    color: Colors.grey,
  );

  static TextStyle dialogTitle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );
}
