class RoleModel {
  final String? roleId;
  final String? roleName;
  Map<RoleItemType, List<RoleItem>> roles = {};

  RoleModel({
    this.roleId,
    this.roleName,
    required this.roles,
  });

  // Convert RoleModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
      'roles': roles.map((roleItemType, roleItems) {
        // Convert RoleItemType to its string value, and map RoleItem list to their string values
        return MapEntry(roleItemType.value, roleItems.map((roleItem) => roleItem.value).toList());
      }),
    };
  }

  // Create RoleModel object from JSON
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleId: json['roleId'],
      roleName: json['roleName'],
      roles: (json['roles'] as Map<String, dynamic>?)?.map((key, value) {
            // Convert the string key to RoleItemType and map each RoleItem string back to the enum
            return MapEntry(
              RoleItemType.byValue(key), // Convert string key back to RoleItemType
              (value as List)
                  .map((item) => RoleItem.byValue(item))
                  .toList(), // Convert string values back to RoleItem enums
            );
          }) ??
          {},
    );
  }
}

enum RoleItemType {
  viewBill('الفواتير'),
  viewBond('السندات'),
  viewAccount('الحسابات'),
  viewProduct('المواد'),
  viewStore('المستودعات'),
  viewPattern('انماط البيع'),
  viewCheques('الشيكات'),
  viewSeller('البائعون'),
  viewReport('تقارير المبيعات'),
  viewImport('استيراد المعلومات'),
  viewTarget('التارغت'),
  viewTask('التاسكات'),
  viewInventory('الجرد'),
  viewUserManagement('إدارة المستخدمين'),
  viewDue('الاستحقاق'),
  viewStatistics('التقارير'),
  viewTimer('المؤقت'),
  viewDataBase('ادارة قواعد البيانات'),
  viewCard('ادارة البطاقات'),
  viewHome('الصفحة الرئيسية');

  final String value;

  const RoleItemType(this.value);

  String get getValue => value;

  // Factory constructor to handle conversion from string to RoleItemType
  factory RoleItemType.byValue(String value) {
    return RoleItemType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('No matching RoleItemType for value: $value'),
    );
  }
}

enum RoleItem {
  userRead('userRead'),
  userWrite('userWrite'),
  userUpdate('userUpdate'),
  userDelete('userDelete'),
  userAdmin('userAdmin');

  final String value;

  const RoleItem(this.value);

  String get getValue => value;

  // Factory constructor to convert string to RoleItem
  factory RoleItem.byValue(String value) {
    return RoleItem.values.firstWhere(
      (item) => item.value == value,
      orElse: () => throw ArgumentError('No matching RoleItem for value: $value'),
    );
  }
}

class RolesConfig {
  static final adminRoles = {
    RoleItemType.viewBill: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewBond: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewAccount: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewProduct: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewStore: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewPattern: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewCheques: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewSeller: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewReport: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewImport: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewTarget: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewTask: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewInventory: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewUserManagement: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewDue: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewStatistics: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewTimer: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewDataBase: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewCard: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
    RoleItemType.viewHome: [
      RoleItem.userRead,
      RoleItem.userWrite,
      RoleItem.userUpdate,
      RoleItem.userDelete,
      RoleItem.userAdmin,
    ],
  };
}
