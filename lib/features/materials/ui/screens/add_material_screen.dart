import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/searchable_material_field.dart';
import 'package:ba3_bs/core/widgets/tax_dropdown.dart';
import 'package:ba3_bs/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../widgets/add_material/add_material_form.dart';

class AddMaterialScreen extends StatelessWidget {
  const AddMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(controller.selectedMaterial?.matName ?? 'مادة جديد'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 20,
            children: [
              AddMaterialForm(
                controller: controller,
              ),
              FormFieldRow(
                firstItem: TaxDropdown(taxSelectionHandler: controller.materialFromHandler),
                secondItem: SearchableMaterialField(
                  label: AppStrings().group,
                  textController: controller.materialFromHandler.parentController,
                  onSubmitted: (text) {
                    controller.openMaterialSelectionDialog(
                      query: text,
                      context: context,

                    );
                  },
                ),
              ),
              AppButton(
                title: controller.selectedMaterial?.id == null ?AppStrings().add : AppStrings().edit,
                onPressed: () {
                  controller.saveOrUpdateMaterial();
                },
                iconData: controller.selectedMaterial?.id == null ? Icons.add : Icons.edit,
                color: controller.selectedMaterial?.id == null ? null : Colors.green,
              ),
              AppButton(
                title: AppStrings().delete,
                onPressed: () {
                  controller.deleteMaterial();
                },
                iconData: Icons.delete,
                color: Colors.red,
              ),
            ],
          ),
        ),
      );
    });
  }
}
