import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../features/login/controllers/nfc_cards_controller.dart';
import '../../features/login/controllers/user_management_controller.dart';
import '../../features/login/data/datasources/user_management_service.dart';
import '../../features/login/data/repositories/user_repo.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/controllers/pluto_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../base_classes/interface_data_source.dart';
import '../base_classes/interface_repository.dart';
import '../base_classes/interface_repository_impl.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize Firestore instance
    var firestore = FirebaseFirestore.instance;

    // Initialize repositories
    final userManagementRepo = UserManagementRepository(UserManagementService());

    // Instantiate PatternsDataSource and PatternsRepository
    final IDataSource patternsDataSource = PatternsDataSource(firestore);

    final IRepository<BillTypeModel> patternsRepo =
        InterfaceRepositoryImpl<BillTypeModel>(patternsDataSource, (json) => BillTypeModel.fromJson(json));

    // Lazy load controllers
    Get.lazyPut(() => UserManagementController(userManagementRepo), fenix: true);
    Get.lazyPut(() => NfcCardsController(), fenix: true);
    Get.lazyPut(() => PlutoController(), fenix: true);
    Get.lazyPut(() => PatternController(patternsRepo), fenix: true);
  }
}
