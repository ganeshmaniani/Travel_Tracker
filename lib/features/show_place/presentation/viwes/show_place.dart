import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_near_me/features/show_place/presentation/viwes/widgets/show_address_field.dart';

import '../../../../config/common_widgets/button.dart';
import '../../../../config/dimension.dart';

class ShowPlaceScreen extends StatefulWidget {
  const ShowPlaceScreen({super.key});

  @override
  State<ShowPlaceScreen> createState() => _ShowPlaceScreenState();
}

class _ShowPlaceScreenState extends State<ShowPlaceScreen> {
  static const CameraPosition _initialPosition =
      CameraPosition(target: LatLng(11.127123, 78.656891), zoom: 12);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                        initialCameraPosition: _initialPosition,
                        mapType: MapType.hybrid,
                        zoomControlsEnabled: false)),
                Positioned(
                  bottom: 40.h,
                  left: 0.w,
                  right: 0.w,
                  child: Container(
                    height: 260.h,
                    margin: EdgeInsets.only(left: 24.w, right: 24.w),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Dimensions.kBorderRadiusAllSmall),
                    padding: Dimensions.kPaddingAllMedium,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('10 April',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('153 Km',
                                style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                        ShowAddressField(
                            isFirst: true,
                            isLast: false,
                            color: Colors.blue,
                            fromOrTo: 'From',
                            address: 'Vada Palani'),
                        ShowAddressField(
                            isFirst: false,
                            isLast: true,
                            color: Colors.orange,
                            fromOrTo: 'To',
                            address: 'Chennai'),
                        Dimensions.kSpacer,
                        Row(
                          children: [
                            Expanded(
                              child: Button(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                width: 2,
                                text: 'Close',
                                backGroundColor: Colors.white,
                                height: 40,
                                textColor: Colors.red,
                              ),
                            ),
                            Dimensions.kHorizontalSpaceSmall,
                            Expanded(
                              child: Button(
                                onTap: () {},
                                width: 2,
                                text: 'Submit',
                                backGroundColor: Colors.red,
                                height: 40,
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
