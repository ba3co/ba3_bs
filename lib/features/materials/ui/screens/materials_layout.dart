import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_menu_item.dart';

class MaterialLayout extends StatelessWidget {
  const MaterialLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("المواد"),
        ),
        body: Column(
          children: [
            AppMenuItem(
                text: "معاينة المواد",
                onTap: () {
                  Get.find<MaterialController>()
                    ..fetchMaterials()
                    ..navigateToAllMaterialScreen();
                }),
          ],
        ),
      ),
    );
  }
}
