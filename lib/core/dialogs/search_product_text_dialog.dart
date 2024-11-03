import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/invoice/ui/widgets/custom_Text_field.dart';
import '../widgets/new_pluto.dart';

Future<MaterialModel?> searchProductTextDialog(String productText) async {
  TextEditingController productTextController = TextEditingController()..text = productText;

  List<MaterialModel> searchedMaterials;

  searchedMaterials = Get.find<MaterialController>().searchOfProductByText(productTextController.text);

  MaterialModel? selectedMaterial;

  if (searchedMaterials.length == 1) {
    return searchedMaterials.first;
  } else if (searchedMaterials.isEmpty) {
    return null;
  } else {
    await showDialog<String>(
        context: Get.context!,
        builder: (BuildContext context) => Dialog(
              child: GetBuilder<MaterialController>(builder: (materialController) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: Get.height / 1.5,
                          child: ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(15),
                            child: CustomPlutoGridWithAppBar(
                              title: 'اختيار مادة',
                              tableSourceModels: searchedMaterials,
                              onLoaded: (p0) {},
                              onSelected: (selected) {
                                selectedMaterial =
                                    materialController.getMaterialFromId(selected.row?.cells['الرقم التعريفي']!.value);
                                Get.back();
                              },
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextFieldWithIcon(
                            controller: productTextController,
                            onSubmitted: (_) async {
                              searchedMaterials = materialController.searchOfProductByText(productTextController.text);
                              materialController.update();
                            },
                            onIconPressed: () {}),
                      ),
                      const VerticalSpace(),
                    ],
                  ),
                );
              }),
            ));

    return selectedMaterial;
  }
}
