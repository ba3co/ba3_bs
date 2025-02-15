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
import '../data/model/app_layout_item_model.dart';

class MainLayoutController extends GetxController {
  RxList<AppLayoutItemModel> appLayouts = [
    if (RoleItemType.viewBill.hasReadPermission)
      AppLayoutItemModel(
        name: 'الفواتير',
        layout: const BillLayout(),
        role: RoleItemType.viewBill,
        icon: AppAssets.billsIcon,
        unSelectedIcon: AppAssets.billsUnselectedIcon,
      ),
    if (RoleItemType.viewPattern.hasReadPermission)
      AppLayoutItemModel(
        name: 'الأنماط',
        layout: const PatternLayout(),
        role: RoleItemType.viewPattern,
        icon: AppAssets.patternsIcon,
        unSelectedIcon: AppAssets.patternsUnselectedIcon,
      ),
    if (RoleItemType.viewProduct.hasReadPermission)
      AppLayoutItemModel(
        name: 'المواد',
        layout: const MaterialLayout(),
        role: RoleItemType.viewProduct,
        icon: AppAssets.materialIcon,
        unSelectedIcon: AppAssets.materialUnselectedIcon,
      ),
    if (RoleItemType.viewAccount.hasReadPermission)
      AppLayoutItemModel(
        name: 'الحسابات',
        layout: const AccountLayout(),
        role: RoleItemType.viewAccount,
        icon: AppAssets.accountsIcon,
        unSelectedIcon: AppAssets.accountsUnselectedIcon,
      ),
    if (RoleItemType.viewBond.hasReadPermission)
      AppLayoutItemModel(
        name: 'السندات',
        layout: const BondLayout(),
        role: RoleItemType.viewBond,
        icon: AppAssets.bondsIcon,
        unSelectedIcon: AppAssets.bondsUnselectedIcon,
      ),
    if (RoleItemType.viewCheques.hasReadPermission)
      AppLayoutItemModel(
        name: 'الشيكات',
        layout: const ChequeLayout(),
        role: RoleItemType.viewCheques,
        icon: AppAssets.chequesIcon,
        unSelectedIcon: AppAssets.chequesUnselectedIcon,
      ),
    if (RoleItemType.viewSellers.hasReadPermission)
      AppLayoutItemModel(
        name: 'البائعون',
        layout: const SellersLayout(),
        role: RoleItemType.viewSellers,
        icon: AppAssets.accountsIcon,
        unSelectedIcon: AppAssets.accountsUnselectedIcon,
      ),
    if (RoleItemType.viewUserManagement.hasAdminPermission)
      AppLayoutItemModel(
        name: 'إدارة المستخدمين',
        layout: const UserManagementLayout(),
        role: RoleItemType.viewUserManagement,
        icon: AppAssets.usersIcon,
        unSelectedIcon: AppAssets.usersUnselectedIcon,
      ),
    AppLayoutItemModel(
      name: 'الدوام',
      layout: const UserTimeDetails(),
      role: RoleItemType.viewTime,
      icon: AppAssets.usersTimeIcon,
      unSelectedIcon: AppAssets.usersTimeUnselectedIcon,
    ),
    if (RoleItemType.administrator.hasReadPermission)
      AppLayoutItemModel(
        name: 'لوحة التحكم',
        layout: const AllAttendanceScreen(),
        role: RoleItemType.administrator,
        icon: AppAssets.billsIcon,
        unSelectedIcon: AppAssets.billsUnselectedIcon,
      ),
  ].obs;
  PageController pageController = PageController();

  int tabIndex = 0;

  set setIndex(int index) {
    tabIndex = index;
    update();
  }
}
