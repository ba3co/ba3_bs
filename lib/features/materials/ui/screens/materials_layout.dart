import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_menu_item.dart';

class MaterialLayout extends StatelessWidget {
  const MaterialLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text("المواد"),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppButton(
                      title: 'تحميل المواد',
                      onPressed: () => read<MaterialController>().fetchAllMaterialFromLocal(),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  AppMenuItem(
                      text: "معاينة المواد",
                      onTap: () {
                        read<MaterialController>()
                          ..fetchMaterials()
                          ..navigateToAllMaterialScreen();
                      }),
                ],
              ),
            ),
            LoadingDialog(
              isLoading: read<MaterialController>().saveAllMaterialsRequestState.value == RequestState.loading,
              message: 'المواد',
              fontSize: 14.sp,
            )
          ],
        );
      }),
    );
  }
}
