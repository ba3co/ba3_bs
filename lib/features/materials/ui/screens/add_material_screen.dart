import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/core/widgets/searchable_material_field.dart';
import 'package:ba3_bs/core/widgets/tax_dropdown.dart';
import 'package:ba3_bs/features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import 'package:ba3_bs/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_constants.dart';

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
              Form(
                  key: controller.materialFromHandler.formKey,
                  child: Column(
                    spacing: 20,
                    children: [
                      OrganizedWidget(
                          titleWidget: Center(child: Text("معلومات المادة")),
                          bodyWidget: Column(
                            spacing: 8,
                            children: [
                              FormFieldRow(
                                firstItem: TextAndExpandedChildField(
                                    label: "اسم المادة",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                                secondItem: TextAndExpandedChildField(
                                    label: "الاسم اللاتيني",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                              ),
                              FormFieldRow(
                                firstItem: TextAndExpandedChildField(
                                    label: "رمز المادة",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                                secondItem: TextAndExpandedChildField(
                                    label: "رمز الباركود",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                              ),
                            ],
                          )),
                      OrganizedWidget(
                          titleWidget: Center(child: Text("الاسعار")),
                          bodyWidget: Column(
                            spacing: 8,
                            children: [
                              FormFieldRow(
                                firstItem: TextAndExpandedChildField(
                                    label: "التكلفة",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                                secondItem: TextAndExpandedChildField(
                                    label: "المفرق",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                              ),
                              FormFieldRow(
                                firstItem: TextAndExpandedChildField(
                                    label: "الجملة",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                                secondItem: TextAndExpandedChildField(
                                    label: " المستهلك",
                                    child: CustomTextFieldWithoutIcon(
                                        filedColor: AppColors.backGroundColor,
                                        textEditingController: controller.materialFromHandler.nameController)),
                              ),
                            ],
                          ))
                    ],
                  )),
              FormFieldRow(
                firstItem: TaxDropdown(taxSelectionHandler: controller.materialFromHandler),
                secondItem: SearchableMaterialField(
                  label: "المجموعة",
                  height: AppConstants.constHeightTextField,
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: .15.sh),
                  child: AppButton(
                    title: controller.selectedMaterial?.id == null ? 'إضافة' : 'تعديل',
                    onPressed: () {
                      controller.saveOrUpdateMaterial();
                    },
                    iconData: controller.selectedMaterial?.id == null ? Icons.add : Icons.edit,
                    color: controller.selectedMaterial?.id == null ? null : Colors.green,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
