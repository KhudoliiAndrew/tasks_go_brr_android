import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasks_go_brr/resources/colors.dart';
import 'package:tasks_go_brr/resources/dimens.dart';
import 'package:tasks_go_brr/ui/custom/animated_gesture_detector.dart';

class FAB extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const FAB({Key? key, required this.onTap, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      margin: EdgeInsets.only(
          right: Margin.middle,
          bottom: Margin.big.h + Margin.small.h),
      child: AnimatedGestureDetector(
          onTap: onTap,
          child: Container(
            height: Dimens.fab_size,
            width: Dimens.fab_size,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.all(Radiuss.circle),
            ),
            padding: EdgeInsets.all(Paddings.middle_smaller),
            child: FittedBox(
              child: Icon(
                icon,
                color: context.onPrimary,
              ),
            ),
          )),
    );  }
}
