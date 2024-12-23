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
import '../../users_management/ui/screens/user_management_layout.dart';

class MainController extends GetxController {
  List<({String name, Widget layout, RoleItemType role, String icon, String unSelectedIcon})> appLayouts = [
    (name: 'الفواتير', layout: const BillLayout(), role: RoleItemType.viewBill, icon: AppAssets.billsIcon, unSelectedIcon: AppAssets.billsUnselectedIcon),
    (name: 'أنماط البيع', layout: const PatternLayout(), role: RoleItemType.viewPattern, icon: AppAssets.patternsIcon, unSelectedIcon: AppAssets.patternsUnselectedIcon),
    (name: 'المواد', layout: const MaterialLayout(), role: RoleItemType.viewProduct, icon: AppAssets.materialIcon, unSelectedIcon: AppAssets.materialUnselectedIcon),
    (name: 'الحسابات', layout: const AccountLayout(), role: RoleItemType.viewAccount, icon: AppAssets.accountsIcon, unSelectedIcon: AppAssets.accountsUnselectedIcon),
    (name: 'السندات', layout: const BondLayout(), role: RoleItemType.viewBond, icon: AppAssets.bondsIcon, unSelectedIcon: AppAssets.bondsUnselectedIcon),
    (name: 'الشيكات', layout: const ChequeLayout(), role: RoleItemType.viewCheques, icon: AppAssets.chequesIcon, unSelectedIcon: AppAssets.chequesUnselectedIcon),
    (name: 'إدارة المستخدمين', layout: const UserManagementLayout(), role: RoleItemType.viewUserManagement, icon: AppAssets.usersIcon, unSelectedIcon: AppAssets.usersUnselectedIcon),
  ];
  List<({String name, Widget layout, RoleItemType role, String icon, String unSelectedIcon})> allData = [];
   PageController pageController= PageController();
  int tabIndex = 0;



  set setIndex(int index){
    tabIndex=index;
    update();

  }

}