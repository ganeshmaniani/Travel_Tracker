import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/app/app.dart';

void main() {
  runApp(const ProviderScope(child: TravelNearMe()));
}
