import 'dart:io';

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
  List<({String name, Widget layout, RoleItemType role})> appLayouts = [
    (name: 'الفواتير', layout: const BillLayout(), role: RoleItemType.viewBill),
    (name: 'أنماط البيع', layout: const PatternLayout(), role: RoleItemType.viewPattern),
    (name: "المواد", layout: const MaterialLayout(), role: RoleItemType.viewProduct),
    (name: 'الحسابات', layout: const AccountLayout(), role: RoleItemType.viewAccount),
    (name: 'السندات', layout: const BondLayout(), role: RoleItemType.viewBond),
    (name: 'الشيكات', layout: const ChequeLayout(), role: RoleItemType.viewCheques),
    (name: "إدارة المستخدمين", layout: const UserManagementLayout(), role: RoleItemType.viewUserManagement),
  ];
  List<({String name, Widget layout, RoleItemType role})> allData = [];
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
          backgroundColor: AppColors.backGroundColor,
          body: Row(
            children: [
              Container(
                  width: 0.15.sw,
                  color: Colors.blue,
                  child: Column(
                    children: [
                      Expanded(
                        child: TabContainer(
                          textDirection: TextDirection.rtl,
                          controller: tabController,
                          tabEdge: TabEdge.right,
                          tabsEnd: 1,
                          tabsStart: 0,
                          tabMaxLength: 60,
                          tabExtent: 0.3.sw,
                          borderRadius: BorderRadius.circular(0),
                          tabBorderRadius: BorderRadius.circular(20),
                          childPadding: const EdgeInsets.all(0.0),
                          selectedTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                          ),
                          unselectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                          ),
                          colors: List.generate(appLayouts.length, (index) => AppColors.backGroundColor),
                          tabs: List.generate(
                            appLayouts.length,
                            (index) {
                              return DrawerListTile(
                                index: index,
                                title: appLayouts[index].name,
                                press: () {
                                  tabController.animateTo(index);
                                  tabIndex = index;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                          children: List.generate(
                            appLayouts.length,
                            (index) => const SizedBox(width: 1),
                          ),
                        ),
                      )
                    ],
                  )),
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
