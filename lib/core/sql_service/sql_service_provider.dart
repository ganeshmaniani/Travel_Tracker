import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_crud_db.dart';
import 'network_database_service.dart';

final sqlServiceProvider = Provider<BaseCRUDDataBaseServices>((ref) {
  return NetWorkDataBaseService();
});
