import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/app_theme/text_theme.dart';
import '../features/search_plcae/presentation/views/search_place.dart';

class TravelNearMe extends StatefulWidget {
  const TravelNearMe({super.key});

  @override
  State<TravelNearMe> createState() => _TravelNearMeState();
}

class _TravelNearMeState extends State<TravelNearMe> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
                useMaterial3: true, textTheme: AppTextTheme.textTheme),
            debugShowCheckedModeBanner: false,
            home: const SearchPlaceScreen(),
          );
        });
  }
}
