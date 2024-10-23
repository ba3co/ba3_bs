import 'package:get/get.dart';

import '../../features/login/controllers/nfc_cards_controller.dart';
import '../../features/login/controllers/user_management_controller.dart';
import '../../features/login/data/datasources/user_management_service.dart';
import '../../features/login/data/repositories/user_repo.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/controllers/pluto_controller.dart';

class GetBinding extends Bindings {
  @override
  void dependencies() {
    final userManagementRepo = UserManagementRepository(UserManagementService());

    Get.lazyPut(() => UserManagementController(userManagementRepo), fenix: true);
    Get.lazyPut(() => NfcCardsController(), fenix: true);
    Get.lazyPut(() => PatternController(), fenix: true);
    Get.lazyPut(() => PlutoController(), fenix: true);
  }
}
