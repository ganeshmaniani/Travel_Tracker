import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../dimension.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    this.height = 40,
    required this.width,
    required this.backGroundColor,
    required this.text,
    required this.onTap,
    required this.textColor,
  });
  final double height;
  final double width;
  final Color backGroundColor;
  final String text;
  final VoidCallback onTap;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / width,
          height: height.h,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              color: backGroundColor,
              borderRadius: Dimensions.kBorderRadiusAllSmallest),
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: textColor)),
        ),
      ),
    );
  }
}
