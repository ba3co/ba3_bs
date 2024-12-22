import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';

class RoleService {
  RoleModel? createRoleModel({
    RoleModel? roleModel,
    required Map<RoleItemType, List<RoleItem>> roles,
    required String roleName,
  }) {
    final RoleModel newRoleModel;

    if (roleModel == null) {
      newRoleModel = RoleModel(roles: roles, roleName: roleName);
    } else {
      newRoleModel = roleModel.copyWith(roles: roles, roleName: roleName);
    }
    return newRoleModel;
  }

  UserModel? createUserModel({
    UserModel? userModel,
    required String userName,
    required String userPassword,
    required String userRoleId,
    required String userSellerId,
  }) {
    final UserModel newUserModel;

    if (userModel == null) {
      newUserModel = UserModel(
        userName: userName,
        userPassword: userPassword,
        userRoleId: userRoleId,
        userSellerId: userSellerId,
      );
    } else {
      newUserModel = userModel.copyWith(
        userName: userName,
        userPassword: userPassword,
        userRoleId: userRoleId,
        userSellerId: userSellerId,
      );
    }
    return newUserModel;
  }
}
