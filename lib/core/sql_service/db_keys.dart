import 'package:flutter/material.dart';

@immutable
class DBKeys {
  const DBKeys._();

  ///DataBase Name
  static const String dbName = 'travel_near_me_db';

  ///DataBase Table Name
  static const String dbAlarmTable = 'alarm_detail';

  ///DataBase Column Name For UserTable
  static const String dbColumnId = 'id';
  static const String dbAlarmName = 'alarm_name';
  static const String dbAlarmRadius = 'alarm_radius'; 
  static const String dbPlaceDescription = 'place_description';
  static const String dbPlaceLatitude = 'place_latitude';
  static const String dbPlaceLongitude = 'place_longitude';
  static const String dbIsEntry = 'is_entry_mode';
}
