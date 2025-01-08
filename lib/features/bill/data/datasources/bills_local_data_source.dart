// BillsDataSource Implementation
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/filterable_datasource.dart';
import 'package:ba3_bs/core/services/local_database/implementations/repos/local_datasource_repo.dart';
import 'package:ba3_bs/core/services/local_database/implementations/services/hive_database_service.dart';
import 'package:ba3_bs/core/services/local_database/interfaces/local_datasource_base.dart';

import '../../../../core/models/date_filter.dart';
import '../../../../core/models/query_filter.dart';
import '../../../../core/services/firebase/implementations/services/firebase_sequential_number_database.dart';
import '../models/bill_model.dart';

class BillsLocalDataSource extends LocalDatasourceBase {
  BillsLocalDataSource( super.database);



}
