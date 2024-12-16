import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/cheques/cheques_details_controller.dart';
import '../../../controllers/cheques/cheques_search_controller.dart';

import '../../../data/models/cheques_model.dart';

class ChequesDetailsButtons extends StatelessWidget {
  const ChequesDetailsButtons({
    super.key,
    required this.chequesDetailsController,
    required this.chequesModel,
    required this.fromChequesById,
    required this.chequesSearchController,
  });

  final ChequesDetailsController chequesDetailsController;
  final ChequesSearchController chequesSearchController;
  final ChequesModel chequesModel;
  final bool fromChequesById;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 20,
        runSpacing: 20,
        children: [
          if (chequesSearchController.isNew)
            Obx(() {
              return AppButton(
                  title: 'إضافة',
                  height: 20,
                  color: chequesDetailsController.isChequesSaved.value ? Colors.green : Colors.blue.shade700,
                  onPressed: chequesDetailsController.isChequesSaved.value
                      ? () {}
                      : () async {
                          await chequesDetailsController.saveCheques(ChequesType.byTypeGuide(chequesModel.checkTypeGuid!));
                        },
                  iconData: Icons.add_chart_outlined);
            }),
          if (!chequesSearchController.isNew) ...[
            AppButton(
              title: 'السند',
              height: 20,
              onPressed: () async {},
              iconData: Icons.file_open_outlined,
            ),
            AppButton(
              title: "تعديل",
              height: 20,
              onPressed: () async {
                chequesDetailsController.updateCheques(
                  chequesType: ChequesType.byTypeGuide(chequesModel.checkTypeGuid!),
                  chequesModel: chequesModel,
                );
              },
              iconData: Icons.edit_outlined,
            ),

            AppButton(
              iconData: Icons.delete_outline,
              height: 20,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {
                chequesDetailsController.deleteCheques(chequesModel, fromChequesById: fromChequesById);
              },
            ),
          ]
        ],
      ),
    );
  }
}
