import 'package:fitness_management_app/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeekdayIndicator extends StatelessWidget {
  final String day;
  final bool isPresent;
  final Color color;

  const WeekdayIndicator(
    this.day,
    this.isPresent,
    this.color, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: isPresent ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isPresent ? color : AppTheme.border,
              width: 2,
            ),
          ),
          child: Center(
            child: isPresent
                ? Icon(Icons.check_rounded, color: Colors.white, size: 18.w)
                : Text(
                    day,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          day,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: isPresent ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}