class RoleModel {
  String? roleId, roleName;
  Map<String, List<String>> roles = {};

  RoleModel({this.roleId, this.roleName,required this.roles});

  // Convert RoleModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
      'roles': roles,
    };
  }

  // Create RoleModel object from JSON
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleId: json['roleId'],
      roleName: json['roleName'],
      roles: json['roles']==null ?{}:(json['roles'] as Map<String, dynamic>).map((key, value) {
        return MapEntry(key, List<String>.from(value));
      }),
    );
  }
}