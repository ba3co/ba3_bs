import 'dart:developer';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/dialogs/e_invoice_dialog_content.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bonds/bond_details_controller.dart';
import '../../../controllers/bonds/bond_search_controller.dart';
import '../../../controllers/pluto/bond_details_pluto_controller.dart';
import '../../../data/models/bond_model.dart';

class BondDetailsButtons extends StatelessWidget {
  const BondDetailsButtons({
    super.key,
    required this.bondDetailsController,
    required this.bondDetailsPlutoController,
    required this.bondModel,
    required this.fromBondById,
    required this.bondSearchController,
  });

  final BondDetailsController bondDetailsController;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final BondSearchController bondSearchController;
  final BondModel bondModel;
  final bool fromBondById;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          if (bondSearchController.isNew)
            Obx(() {
              return AppButton(
                  title: 'إضافة',
                  height: 20,
                  color: bondDetailsController.isBondSaved.value ? Colors.green : Colors.blue.shade700,
                  onPressed: bondDetailsController.isBondSaved.value
                      ? () {}
                      : () async {
                          bondDetailsController.saveBond(bondModel.payTypeGuid);
                        },
                  iconData: Icons.add_chart_outlined);
            }),
          AppButton(
            title: 'السند',
            height: 20,
            onPressed: () async {
              bondDetailsController.createBond(bondModel.payTypeGuid);
            },
            iconData: Icons.file_open_outlined,
          ),
          if (!bondSearchController.isNew)
            AppButton(
              title: "تعديل",
              height: 20,
              onPressed: () async {
                bondDetailsController.updateBond(
                  bondModel: bondModel,
                  bondTypeModel: bondModel.payTypeGuid,
                );
              },
              iconData: Icons.edit_outlined,
            ),

          if (!bondSearchController.isNew)
            AppButton(
              title: 'Pdf-Email',
              height: 20,
              onPressed: () {
                bondDetailsController.generateAndSendBondPdf(
                  recipientEmail: AppStrings.recipientEmail,
                  bondModel: bondModel,
                  fileName: AppStrings.bond,
                  logoSrc: AppAssets.ba3Logo,
                  fontSrc: AppAssets.notoSansArabicRegular,
                );
              },
              iconData: Icons.link,
            ),
          if (!bondSearchController.isNew)
            AppButton(
              iconData: Icons.delete_outline,
              height: 20,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {
                bondDetailsController.deleteBond(bondModel, fromBondById: fromBondById);
              },
            ),
        ],
      ),
    );
  }
}
