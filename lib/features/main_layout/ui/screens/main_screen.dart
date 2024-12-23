import 'dart:io';

import 'package:ba3_bs/core/constants/app_assets.dart';
import 'package:ba3_bs/core/styling/app_themes.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/main_layout/controllers/main_controller.dart';
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
import '../widgets/main_header.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      Get.put(WindowCloseController());
    }
    return SafeArea(
      child: GetBuilder<MainController>(builder: (mainController) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.whiteColor,
            body: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      SizedBox(
                        height: 0.15.sh,
                        width: 0.15.sw,
                        child: Image.asset(AppAssets.logo),
                      ),
                      SizedBox(
                        height: 0.725.sh,
                        width: 0.15.sw,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount:mainController. appLayouts.length,
                          separatorBuilder: (context, index) => const VerticalSpace(),
                          itemBuilder: (context, index) =>
                              DrawerListTile(
                                index: index,
                                tabIndex: mainController.tabIndex,
                                title:mainController. appLayouts[index].name,
                                icon:mainController. appLayouts[index].icon,
                                unSelectedIcon:mainController. appLayouts[index].unSelectedIcon,
                                onTap: () {
                                  mainController. tabIndex = index;
                                  setState(() {});
                                },
                              ),
                        ),
                      ),
                      const MainHeader(),
                    ],
                  ),
                ),
                Expanded(child:mainController. appLayouts[mainController.tabIndex].layout),
              ],
            ),
          ),
        );
      }),
    );
  }
}

