import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/dimension.dart';
import '../../../data/model/auto_complete_prediction_model.dart';

class AddressFieldContainer extends StatelessWidget {
  final VoidCallback onTap;
  final Predictions predictions;

  const AddressFieldContainer(
      {super.key, required this.onTap, required this.predictions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16).w,
        child: Container(
          // padding: const EdgeInsets.all(16.0).w,
          decoration: BoxDecoration(
              borderRadius: Dimensions.kBorderRadiusAllSmall,
              border: Border.all(color: Colors.grey)),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, size: Dimensions.iconSizeSmall),
              Dimensions.kHorizontalSpaceMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(predictions.structuredFormatting!.mainText ?? ''),
                    Text(predictions.description ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
