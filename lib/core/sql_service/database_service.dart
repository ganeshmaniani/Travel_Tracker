import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'db_keys.dart';

class DataBaseServices {
  Future<Database> setDataBase() async {
    final dbPath = await getDatabasesPath();
    var path = join(dbPath, DBKeys.dbName);

    var database =
        await openDatabase(path, version: 1, onCreate: _createDataBase);
    return database;
  }

  Future<void> _createDataBase(Database db, int version) async {
    String registerUserTable =
        "CREATE TABLE ${DBKeys.dbAlarmTable}(${DBKeys.dbColumnId} INTEGER PRIMARY KEY,${DBKeys.dbAlarmName} TEXT NOT NULL,${DBKeys.dbAlarmRadius} REAL  NOT NULL , ${DBKeys.dbPlaceDescription} TEXT NOT NULL,${DBKeys.dbPlaceLatitude} REAL NOT NULL,${DBKeys.dbPlaceLongitude} REAL NOT NULL,${DBKeys.dbIsEntry} INTEGER NOT NULL)";

    await db.execute(registerUserTable);
  }
}
