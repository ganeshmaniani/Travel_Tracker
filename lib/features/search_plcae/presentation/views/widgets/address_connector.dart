import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:travel_near_me/config/dimension.dart';

class AddressCardContainer extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPass;
  final Widget child;
  final Color color;

  const AddressCardContainer({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPass,
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(color: Colors.grey, thickness: 1),
      indicatorStyle: IndicatorStyle(
        drawGap: false,
        indicator: Padding(
          padding: Dimensions.kPaddingAllSmaller,
          child: Container(
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 2.5,
                      spreadRadius: 2.5)
                ]),
          ),
        ),
      ),
      endChild: Padding(
        padding: Dimensions.kPaddingAllSmaller,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: Dimensions.kPaddingAllSmall,
          decoration: BoxDecoration(
            borderRadius: Dimensions.kBorderRadiusAllSmaller,
          ),
          child: child,
        ),
      ),
    );
  }
}
