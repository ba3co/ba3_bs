import 'dart:io';

import 'package:ba3_bs/core/constants/app_assets.dart';
import 'package:ba3_bs/core/styling/app_themes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tab_container/tab_container.dart';

import '../../../../core/styling/app_colors.dart';
import '../../../accounts/ui/screens/account_layout.dart';
import '../../../bill/ui/screens/bill_layout.dart';
import '../../../bond/ui/screens/bond_layout.dart';
import '../../../cheques/ui/screens/cheque_layout.dart';
import '../../../materials/ui/screens/materials_layout.dart';
import '../../../patterns/ui/screens/pattern_layout.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../../users_management/data/models/role_model.dart';
import '../../../users_management/ui/screens/user_management_layout.dart';
import '../../controllers/window_close_controller.dart';
import '../widgets/drawer_list_tile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
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
  late PageController pageController;
  late TabController tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      Get.put(WindowCloseController());
    } else {}
    allData = appLayouts.where((element) => checkMainPermission(element.role)).toList();
    tabController = TabController(length: appLayouts.length, vsync: this, initialIndex: tabIndex);
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: Row(
            children: [
              Column(
                spacing: 20,
                children: [
                  SizedBox(
                    height: 75,
                    width: 0.2.sw,
                    child: Image.asset(AppAssets.logo),
                  ),
                  Expanded(
                      child: Column(
                    spacing: 15,
                    children: [
                      ...List.generate(
                        appLayouts.length,
                        (index) {
                          return DrawerListTile(
                            index: index,
                            tabIndex: tabIndex,
                            title: appLayouts[index].name,
                            icon: appLayouts[index].icon,
                            unSelectedIcon: appLayouts[index].unSelectedIcon,
                            onTap: () {
                              tabController.animateTo(index);
                              tabIndex = index;
                              setState(() {});
                            },
                          );
                        },
                      )
                    ],
                  ))
                ],
              ),
              Expanded(
                child: Column(children: [
                  Expanded(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: appLayouts[tabIndex].layout,
                  ))
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
