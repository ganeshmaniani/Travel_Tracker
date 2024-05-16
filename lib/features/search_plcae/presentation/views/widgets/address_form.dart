import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/dimension.dart';
import 'address_connector.dart';

class AddressFormField extends StatelessWidget {
  const AddressFormField({
    super.key,
    required this.color,
    required this.locationIcon,
    required this.isFirst,
    required this.isLast,
    required this.place,
    required this.onTap,
  });

  final Color color;
  final String locationIcon;
  final bool isFirst;
  final bool isLast;
  final String place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(children: [
          AddressCardContainer(
              isFirst: isFirst,
              isLast: isLast,
              isPass: false,
              color: color,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  searchTextFormField(
                      onPressed: onTap,
                      place: place,
                      locationIcon: Icons.search)
                ],
              )),
        ]),
      )
    ]);
  }
}

Widget searchTextFormField(
    {required VoidCallback onPressed,
    required String place,
    required IconData locationIcon}) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 58.h,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Dimensions.kHorizontalSpaceSmall,
          Icon(locationIcon),
          Dimensions.kHorizontalSpaceSmall,
          Expanded(
            child: Opacity(
              opacity: place == 'Alarm location?' ? 0.95 : 1,
              child: Text(place,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: place == 'Alarm location?'
                        ? const Color(0xFF1B293D)
                        : Colors.black,
                  )),
            ),
          ),
        ],
      ),
    ),
  );
}
