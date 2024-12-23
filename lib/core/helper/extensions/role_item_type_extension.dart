import 'dart:developer';

import 'package:get/get.dart';

import '../../../features/users_management/controllers/user_management_controller.dart';
import '../../../features/users_management/data/models/role_model.dart';
import '../enums/enums.dart';

extension RoleItemTypeExtension on RoleItemType {
  /// Returns the [BillStatus] based on the current [RoleItemType].
  Status get status {
    final hasPermission = Get.find<UserManagementController>().hasPermission(this);

    // Log the role type and permission for debugging purposes
    log('RoleItemType: $this, hasPermission: $hasPermission');

    // Map permission to the appropriate BillStatus
    return hasPermission ? Status.approved : Status.pending;
  }
}
