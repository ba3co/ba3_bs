import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/features/sellers/ui/screens/sellers_layout.dart';
import 'package:ba3_bs/features/user_time/ui/screens/all_attendance_screen.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../accounts/ui/screens/account_layout.dart';
import '../../bill/ui/screens/bill_layout.dart';
import '../../bond/ui/screens/bond_layout.dart';
import '../../cheques/ui/screens/cheque_layout.dart';
import '../../materials/ui/screens/materials_layout.dart';
import '../../patterns/ui/screens/pattern_layout.dart';
import '../../user_time/ui/screens/user_time_details.dart';
import '../../users_management/ui/screens/user_management_layout.dart';

class MainLayoutController extends GetxController {
  RxList<({String name, Widget layout, RoleItemType role, String icon, String unSelectedIcon})> appLayouts = [
    if (RoleItemType.viewBill.hasReadPermission)
      (
        name: AppStrings().bills,
        layout: const BillLayout(),
        role: RoleItemType.viewBill,
        icon: AppAssets.billsIcon,
        unSelectedIcon: AppAssets.billsUnselectedIcon
      ),
    if (RoleItemType.viewPattern.hasReadPermission)
      (
        name: '${AppStrings().patterns} ${AppStrings().al + AppStrings().sell}',
        layout: const PatternLayout(),
        role: RoleItemType.viewPattern,
        icon: AppAssets.patternsIcon,
        unSelectedIcon: AppAssets.patternsUnselectedIcon
      ),
    if (RoleItemType.viewProduct.hasReadPermission)
      (
        name: AppStrings().materials,
        layout: const MaterialLayout(),
        role: RoleItemType.viewProduct,
        icon: AppAssets.materialIcon,
        unSelectedIcon: AppAssets.materialUnselectedIcon
      ),
    if (RoleItemType.viewAccount.hasReadPermission)
      (
        name: AppStrings().accounts,
        layout: const AccountLayout(),
        role: RoleItemType.viewAccount,
        icon: AppAssets.accountsIcon,
        unSelectedIcon: AppAssets.accountsUnselectedIcon
      ),
    if (RoleItemType.viewBond.hasReadPermission)
      (
        name: AppStrings().bonds,
        layout: const BondLayout(),
        role: RoleItemType.viewBond,
        icon: AppAssets.bondsIcon,
        unSelectedIcon: AppAssets.bondsUnselectedIcon
      ),
    if (RoleItemType.viewCheques.hasReadPermission)
      (
        name: AppStrings().cheques,
        layout: const ChequeLayout(),
        role: RoleItemType.viewCheques,
        icon: AppAssets.chequesIcon,
        unSelectedIcon: AppAssets.chequesUnselectedIcon
      ),
    if (RoleItemType.viewSellers.hasReadPermission)
      (
        name: AppStrings().sellers,
        layout: const SellersLayout(),
        role: RoleItemType.viewSellers,
        icon: AppAssets.accountsIcon,
        unSelectedIcon: AppAssets.accountsUnselectedIcon
      ),
    if (RoleItemType.viewUserManagement.hasAdminPermission)
      (
        name: '${AppStrings().administration} ${AppStrings().users}',
        layout: const UserManagementLayout(),
        role: RoleItemType.viewUserManagement,
        icon: AppAssets.usersIcon,
        unSelectedIcon: AppAssets.usersUnselectedIcon
      ),
    (
      name: AppStrings().work,
      layout: const UserTimeDetails(),
      role: RoleItemType.viewTime,
      icon: AppAssets.usersTimeIcon,
      unSelectedIcon: AppAssets.usersTimeUnselectedIcon
    ),
    if (RoleItemType.administrator.hasReadPermission)
      (
        name: '${AppStrings().panel} ${AppStrings().control}',
        layout: const AllAttendanceScreen(),
        role: RoleItemType.administrator,
        icon: AppAssets.billsIcon,
        unSelectedIcon: AppAssets.billsUnselectedIcon
      ),
  ].obs;

  PageController pageController = PageController();

  int tabIndex = 0;

  set setIndex(int index) {
    tabIndex = index;
    update();
  }
}
