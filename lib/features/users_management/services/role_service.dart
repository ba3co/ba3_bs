import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';

class RoleService {
  RoleModel? createRoleModel({
    RoleModel? roleModel,
    required Map<RoleItemType, List<RoleItem>> roles,
    required String roleName,
  }) {
    if (roles.isEmpty) {
      return null;
    }
    final RoleModel newRoleModel;

    if (roleModel == null) {
      newRoleModel = RoleModel(roles: roles, roleName: roleName);
    } else {
      newRoleModel = roleModel.copyWith(roles: roles, roleName: roleName);
    }
    return newRoleModel;
  }

  UserModel? createUserModel(
      {UserModel? userModel,
      required String userName,
      required String userPassword,
      String? userRoleId,
      String? userSellerId,
      Map<String, UserWorkingHours>? workingHour}) {
    if (userRoleId == null || userSellerId == null) {
      return null;
    }

    final UserModel newUserModel;

    if (userModel == null) {
      newUserModel = UserModel(
          userName: userName,
          userPassword: userPassword,
          userRoleId: userRoleId,
          userSellerId: userSellerId,
          userWorkingHours: workingHour);
    } else {
      newUserModel = userModel.copyWith(
          userName: userName,
          userPassword: userPassword,
          userRoleId: userRoleId,
          userSellerId: userSellerId,
          userWorkingHours: workingHour);
    }
    return newUserModel;
  }
}
