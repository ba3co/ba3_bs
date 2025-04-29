import 'package:ba3_bs/core/helper/extensions/hive_extensions.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';
import 'package:ba3_bs/features/bond/data/models/pay_item_model.dart';
import 'package:ba3_bs/features/dashboard/data/model/dash_account_model.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';

import '../../../../../features/accounts/data/models/account_model.dart';
import '../../../../../features/bill/data/models/bill_details.dart';
import '../../../../../features/bill/data/models/bill_items.dart';
import '../../../../../features/bill/data/models/bill_model.dart';
import '../../../../../features/bill/data/models/discount_addition_account_model.dart';
import '../../../../../features/patterns/data/models/bill_type_model.dart';
import '../../../../helper/enums/enums.dart';

class HiveAdaptersRegistrations {
  static void registerAllAdapters() {
    MaterialModelAdapter().registerAdapter();
    MatExtraBarcodeModelAdapter().registerAdapter();
    DashAccountModelAdapter().registerAdapter();
    BillModelAdapter().registerAdapter();
    BillTypeModelAdapter().registerAdapter();
    BillItemsAdapter().registerAdapter();
    BillItemAdapter().registerAdapter();
    BillDetailsAdapter().registerAdapter();
    BillPatternTypeAdapter().registerAdapter();
    AccountModelAdapter().registerAdapter();
    DiscountAdditionAccountModelAdapter().registerAdapter();
    BillAccountsAdapter().registerAdapter();
    StatusAdapter().registerAdapter();
    BondTypeAdapter().registerAdapter();
    BondModelAdapter().registerAdapter();
    PayItemAdapter().registerAdapter();
    PayItemsAdapter().registerAdapter();




    /// last typeId = 15
  }
}