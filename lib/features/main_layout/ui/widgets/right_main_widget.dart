import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../controllers/main_layout_controller.dart';
import 'drawer_list_tile.dart';
import 'main_header.dart';

class RightMainWidget extends StatelessWidget {
  const RightMainWidget({super.key, required this.mainController});

  final MainLayoutController mainController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        spacing: 10,
        children: [
          SizedBox(
            height: 0.15.sh,
            width: 0.14.sw,
            child: Image.asset(AppAssets.logo),
          ),
          Obx(() {
            return SizedBox(
              height: 0.700.sh,
              width: 0.15.sw,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: mainController.appLayouts.length,
                separatorBuilder: (context, index) => const VerticalSpace(),
                itemBuilder: (context, index) {
                  return DrawerListTile(
                    index: index,
                    tabIndex: mainController.tabIndex,
                    title: mainController.appLayouts[index].name,
                    icon: mainController.appLayouts[index].icon,
                    unSelectedIcon: mainController.appLayouts[index].unSelectedIcon,
                    onTap: () {
                      mainController.setIndex = index;
                    },
                  );
                }
                ,
              ),
            );
          }),
          const MainHeader(),
        ],
      ),
    );
  }
}
