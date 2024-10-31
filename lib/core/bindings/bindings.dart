import 'package:ba3_bs/core/classes/repositories/firebase_repo_concrete.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/data/repositories/accounts_repository.dart';
import 'package:ba3_bs/features/bond/controllers/bond_controller.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../features/login/controllers/nfc_cards_controller.dart';
import '../../features/login/controllers/user_management_controller.dart';
import '../../features/login/data/datasources/user_management_service.dart';
import '../../features/login/data/repositories/user_repo.dart';
import '../../features/materials/data/repositories/materials_repository.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../classes/repositories/firebase_repo_base.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize Firestore instance
    var firestore = FirebaseFirestore.instance;

    // Initialize repositories
    final userManagementRepo = UserManagementRepository(UserManagementService());

    // Instantiate PatternsDataSource and PatternsRepository
    final FirebaseRepositoryBase<BillTypeModel> patternsRepo =
        FirebaseRepositoryConcrete(PatternsDataSource(firestore));

    // Lazy load controllers
    Get.lazyPut(() => UserManagementController(userManagementRepo), fenix: true);
    Get.lazyPut(() => NfcCardsController(), fenix: true);
    Get.lazyPut(() => PlutoController(), fenix: true);
    Get.lazyPut(() => PatternController(patternsRepo), fenix: true);
    Get.lazyPut(() => BondController(), fenix: true);
    Get.lazyPut(() => InvoiceController(patternsRepo), fenix: true);
    Get.lazyPut(() => MaterialController(MaterialRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
  }
}
