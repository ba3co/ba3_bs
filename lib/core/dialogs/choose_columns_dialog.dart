import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_strings.dart';
import '../styling/app_colors.dart';
import '../widgets/custom_checklist.dart';
class MaterialAttributesDialog extends StatefulWidget {
 final BillDetailsPlutoController billDetailsPlutoController;
 const MaterialAttributesDialog({super.key, required this.billDetailsPlutoController});

  @override
  State<MaterialAttributesDialog> createState() => _MaterialAttributesDialogState();
}

class _MaterialAttributesDialogState extends State<MaterialAttributesDialog> {
  List<String> _selectedAttributes = [];

  final List<String> materialAttributes = [
    // AppStrings.quantity.tr,

    AppStrings.materialCode.tr,
    AppStrings.materialName.tr,
    AppStrings.barcode.tr,
    AppStrings.quantity.tr,
    AppStrings.consumer.tr,
    AppStrings.individual.tr,
    AppStrings.tax.tr,
    AppStrings.total.tr,

    AppStrings.retailPrice.tr,
    AppStrings.wholesale.tr,



    AppStrings.gifts.tr,
    AppStrings.invRecSubTotalWithVat.tr,
    AppStrings.productSerialNumbers.tr,
    AppStrings.productSoldSerialNumber.tr,

    AppStrings.identificationNumber.tr,
    AppStrings.mediatorPrice.tr,
    AppStrings.lastPayPrice.tr,
  ];

  void _onSelect(String attribute) {
    _selectedAttributes.add(attribute);
  }

  void _onDeselect(String attribute) {
    _selectedAttributes.remove(attribute);
  }

  @override
  void initState() {
_selectedAttributes=[
  AppStrings.materialCode.tr,
  AppStrings.materialName.tr,
  AppStrings.quantity.tr,
  AppStrings.individual.tr,
  AppStrings.total.tr,
  AppStrings.barcode.tr,
  AppStrings.retailPrice.tr,
  AppStrings.consumer.tr,
  AppStrings.wholesale.tr,
];
super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(AppStrings.viewOptions.tr,style: AppTextStyles.headLineStyle1,),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomChecklist<String>(
                items: materialAttributes,
                displayText: (item) => item, // attribute name
                onItemSelected: _onSelect,
                onItemDeselected: _onDeselect,
                initiallySelected: [
                  AppStrings.materialCode.tr,
                  AppStrings.materialName.tr,
                  AppStrings.quantity.tr,
                  AppStrings.individual.tr,
                  AppStrings.total.tr,
                  AppStrings.barcode.tr,
                  AppStrings.retailPrice.tr,
                  AppStrings.consumer.tr,
                  AppStrings.wholesale.tr,
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  AppButton(title: AppStrings.confirm.tr, onPressed: () {
                    widget.billDetailsPlutoController.exportBillItemsToExcel(ExportFilterOption.all,columnsToExport: _selectedAttributes);
                  },color: AppColors.greenColor,iconData: Icons.check,),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
