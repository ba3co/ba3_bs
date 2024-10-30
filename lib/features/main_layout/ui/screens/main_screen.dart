import 'package:flutter/material.dart';
import 'package:tab_container/tab_container.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../invoice/ui/screens/invoice_layout.dart';
import '../../../login/controllers/user_management_controller.dart';
import '../../../materials/ui/screens/materials_layout.dart';
import '../../../patterns/ui/screens/pattern_layout.dart';
import '../widgets/drawer_list_tile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<({String name, Widget layout, String role})> appLayouts = [
    (name: 'الفواتير', layout: const InvoiceLayout(), role: AppConstants.roleViewInvoice),
    (name: 'أنماط البيع', layout: const PatternLayout(), role: AppConstants.roleViewPattern),
    (name: "المواد", layout: const MaterialLayout(), role: AppConstants.roleViewMaterial),
  ];
  List<({String name, Widget layout, String role})> allData = [];
  late PageController pageController;
  late TabController tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    allData = appLayouts.where((element) => checkMainPermission(element.role)).toList();
    tabController = TabController(length: appLayouts.length, vsync: this, initialIndex: tabIndex);
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: Row(
          children: [
            Container(
                width: 250,
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
                        tabExtent: 250,
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
                  borderRadius: BorderRadius.circular(20),
                  child: appLayouts[tabIndex].layout,
                ))
              ]),
            )
          ],
        ),
      ),
    );
  }
}
