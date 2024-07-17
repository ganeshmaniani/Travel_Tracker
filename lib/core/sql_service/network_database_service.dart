import 'package:sqflite/sqflite.dart';

import 'base_crud_db.dart';
import 'database_service.dart';

class NetWorkDataBaseService extends BaseCRUDDataBaseServices {
  late DataBaseServices _dataBaseServices;

  NetWorkDataBaseService() {
    _dataBaseServices = DataBaseServices();
  }

  static Database? _database;

  @override
  // TODO: implement database
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _dataBaseServices.setDataBase();
      return _database;
    }
  }

  @override
  Future insertData(String tableName, Map<String, dynamic> data) async {
    var connection = await database;
    return await connection?.insert(tableName, data);
  }

  @override
  Future getData(tableName) async {
    var connection = await database;
    return await connection?.query(tableName);
  }

  @override
  Future getDataById(tableName, itemId) async {
    var connection = await database;
    return await connection?.query(
      tableName,
      where: 'title_list_id=?',
      whereArgs: [itemId],
    );
  }

  @override
  Future updateDataById(tableName, data) async {
    var connection = await database;
    return await connection
        ?.update(tableName, data, where: 'id=?', whereArgs: [data['id']]);
  }

  @override
  Future deleteDataById(tableName, itemId) async {
    var connection = await database;
    return connection?.rawDelete('delete from $tableName where id=$itemId');
  }

  @override
  Future getUserById(tableName, itemId) async {
    var connection = await database;
    return connection?.query(tableName, where: 'id=?', whereArgs: [itemId]);
  }
}
