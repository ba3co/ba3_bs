import 'package:flutter/cupertino.dart';

import '../../../users_management/data/models/role_model.dart';

  class   AppLayoutItemModel {
  final String name;
  final Widget layout;
  final RoleItemType role;
  final String icon;
  final String unSelectedIcon;

  AppLayoutItemModel({
    required this.name,
    required this.layout,
    required this.role,
    required this.icon,
    required this.unSelectedIcon,
  });
}