import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../features/users_management/controllers/user_management_controller.dart';
import '../../../features/users_management/data/models/role_model.dart';
import '../../../features/users_management/data/models/user_model.dart';
import '../enums/enums.dart';
import 'getx_controller_extensions.dart';

extension RoleItemTypeExtension on RoleItemType {
  /// Returns the [Status] based on the current [RoleItemType].
  Status get status {
    final hasPermission = this.hasPermission;

    if (kDebugMode) {
      log('RoleItemType: $this, hasPermission: $hasPermission');
    }

    return hasPermission ? Status.approved : Status.pending;
  }

  /// Returns whether the current [RoleItemType] has permission.
  bool get hasPermission => _checkPermissionStatus;

  bool get _checkPermissionStatus {
    final userManagementController = read<UserManagementController>();
    final UserModel? userModel = userManagementController.loggedInUserModel;

    // Return false if userModel or userRoleId is null
    if (userModel == null || userModel.userRoleId == null) return false;

    // Retrieve the RoleModel based on the user's role ID
    final roleModel = userManagementController.getRoleById(userModel.userRoleId!);

    // Check if roleModel is null
    if (roleModel == null) return false;

    // Get the list of RoleItems for the given RoleItemType
    final List<RoleItem>? roleItems = roleModel.roles[this];

    // Check if the list contains RoleItem.userAdmin
    return roleItems?.contains(RoleItem.userAdmin) == true;
  }
}
