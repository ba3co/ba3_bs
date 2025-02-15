import 'package:ba3_bs/features/main_layout/controllers/main_layout_controller.dart';
import 'package:ba3_bs/features/main_layout/ui/widgets/right_main_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../../../../core/services/translation/translation_controller.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../changes/controller/changes_controller.dart';
import '../../../changes/data/model/changes_model.dart';
import '../../controllers/window_close_controller.dart';
import '../widgets/left_main_widget.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    put(WindowCloseController());
    put(MainLayoutController());
    put(ChangesController(read<ListenDataSourceRepository<ChangesModel>>()), permanent: true);

    return GetBuilder<MainLayoutController>(builder: (mainController) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: Row(
            children: Get.find<TranslationController>().currentLocaleIsRtl
                ? [RightMainWidget(mainController: mainController), LeftMainWidget(mainController: mainController)]
                : [LeftMainWidget(mainController: mainController), RightMainWidget(mainController: mainController)],
          ),
        ),
      );
    });
  }
}
