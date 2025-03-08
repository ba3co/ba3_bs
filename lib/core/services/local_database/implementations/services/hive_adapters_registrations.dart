import 'package:ba3_bs/core/helper/extensions/hive_extensions.dart';
import 'package:ba3_bs/features/dashboard/data/model/dash_account_model.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';

class HiveAdaptersRegistrations{
 static void registerAllAdapters(){
    MaterialModelAdapter().registerAdapter();
    MatExtraBarcodeModelAdapter().registerAdapter();
    DashAccountModelAdapter().registerAdapter();
  }
}