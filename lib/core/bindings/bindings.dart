import 'package:get/get.dart';

import '../../features/login/controllers/login_controller.dart';
import '../../features/login/controllers/nfc_cards_controller.dart';
import '../../features/login/controllers/user_management_controller.dart';
import '../../features/login/data/datasources/user_management_service.dart';
import '../../features/login/data/repositories/user_repo.dart';

class GetBinding extends Bindings {
  @override
  void dependencies() {
    final userManagementRepo = UserManagementRepository(UserManagementService());

    Get.lazyPut(() => UserManagementController(userManagementRepo), fenix: true);
    Get.lazyPut(() => NfcCardsController(), fenix: true);
  }
}
