import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:get/get.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';

class DashboardLayoutController extends GetxController {
  int get onlineUsersLength => read<UserManagementController>()
      .allUsers
      .where(
        (user) => user.userWorkStatus == UserWorkStatus.online,
      )
      .length;
  int get allUsersLength => read<UserManagementController>().allUsers.length;
}