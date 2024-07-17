import 'package:travel_near_me/core/sql_service/db_keys.dart';

class PlaceListModel {
  int? id;
  String? alarmName;
  double? alarmRadius;
  String? placeDescription;
  double? placeLatitude;
  double? placeLongitude;
  bool? isEntryMode;

  PlaceListModel({
    this.id,
    this.alarmName,
    this.alarmRadius,
    this.placeDescription,
    this.placeLatitude,
    this.placeLongitude,
    this.isEntryMode,
  });

  // Create an instance from JSON
  PlaceListModel.fromJson(Map<String, dynamic> json) {
    id = json[DBKeys.dbColumnId];
    alarmName = json[DBKeys.dbAlarmName];
    alarmRadius = (json[DBKeys.dbAlarmRadius] as num?)?.toDouble();
    placeDescription = json[DBKeys.dbPlaceDescription];
    placeLatitude = (json[DBKeys.dbPlaceLatitude] as num?)?.toDouble();
    placeLongitude = (json[DBKeys.dbPlaceLongitude] as num?)?.toDouble();
    isEntryMode = json[DBKeys.dbIsEntry] == 1;
  }

  // Convert the instance to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DBKeys.dbColumnId] = id;
    data[DBKeys.dbAlarmName] = alarmName;
    data[DBKeys.dbAlarmRadius] = alarmRadius;
    data[DBKeys.dbPlaceDescription] = placeDescription;
    data[DBKeys.dbPlaceLatitude] = placeLatitude;
    data[DBKeys.dbPlaceLongitude] = placeLongitude;
    data[DBKeys.dbIsEntry] = isEntryMode == true ? 1 : 0;
    return data;
  }
}
