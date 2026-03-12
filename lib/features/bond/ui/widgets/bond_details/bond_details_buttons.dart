import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_ui_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bonds/bond_details_controller.dart';
import '../../../controllers/bonds/bond_search_controller.dart';
import '../../../controllers/pluto/bond_details_pluto_controller.dart';
import '../../../data/models/bond_type_model.dart';
import '../../../use_cases/get_bond_type_by_guide_usecase.dart';

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
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 20,
        runSpacing: 20,
        children: [
          Obx(() {
            return AppButton(
              isLoading: bondDetailsController.saveBondRequestState.value ==
                  RequestState.loading,
              title: bondDetailsController.isBondSaved.value
                  ? AppStrings.newS.tr
                  : AppStrings.add.tr,
              height: 20,
              color: bondDetailsController.isBondSaved.value
                  ? Colors.green
                  : Colors.blue.shade700,
              onPressed: () async {
                final getBondTypeByGuideUseCase =
                    Get.find<GetBondTypeByGuideUseCase>();
                final result =
                    await getBondTypeByGuideUseCase(bondModel.payTypeGuid!);

                result.fold(
                  (failure) {
                    // Handle failure gracefully
                    Get.snackbar('Error', failure.message);
                  },
                  (bondTypeModel) async {
                    if (bondDetailsController.isBondSaved.value) {
                      // When bond is already saved → append new bill
                      // bondDetailsController.appendNewBill(
                      //   bondType: bondTypeModel,
                      //   lastBondNumber: bondSearchController.bonds.last.payNumber!,
                      // );
                    } else {
                      // When bond is new → save bond

                      await bondDetailsController.saveBond(
                          bondTypeModel, context);
                    }
                  },
                );
              },
              iconData: Icons.add_chart_outlined,
            );
          }),
          if (!bondSearchController.isNew) ...[
            AppButton(
              title: AppStrings.bond.tr,
              height: 20,
              onPressed: () async {
                bondDetailsController.createEntryBond(bondModel, context);
              },
              iconData: Icons.file_open_outlined,
            ),
            Obx(() {
              return AppButton(
                isLoading: bondDetailsController.saveBondRequestState.value ==
                    RequestState.loading,
                title: AppStrings.edit.tr,
                height: 20,
                onPressed: () async {
                  // bondDetailsController.updateBond(
                  //   bondType: BondType.byTypeGuide(bondModel.payTypeGuid!),
                  //   bondModel: bondModel,
                  //   context: context
                  // );
                },
                iconData: Icons.edit_outlined,
              );
            }),
            if (!bondSearchController.isNew)
              AppButton(
                title: AppStrings.pdfEmail.tr,
                height: 20,
                onPressed: () {
                  bondDetailsController.generateAndSendBondPdf(
                      bondModel, context);
                },
                iconData: Icons.link,
              ),
            Obx(() {
              return AppButton(
                isLoading: bondDetailsController.deleteBondRequestState.value ==
                    RequestState.loading,
                iconData: Icons.delete_outline,
                height: 20,
                color: Colors.red,
                title: AppStrings.delete.tr,
                onPressed: () async {
                  if (await AppUIUtils.confirmOverlay(context, canPop: true)) {
                    if (!context.mounted) return;
                    bondDetailsController.deleteBond(bondModel, context,
                        fromBondById: fromBondById);
                  }
                },
              );
            }),
          ]
        ],
      ),
    );
  }
}
