import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/widgets/pluto_grid_with_app_bar_.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllCheques extends StatelessWidget {
  const AllCheques({super.key, required this.onlyDues});

  final bool onlyDues;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllChequesController>(builder: (logic) {
      return Scaffold(
        body: PlutoGridWithAppBar(
          onLoaded: (p0) {},
          onSelected: (event) {
            final chequesId =
                event.row?.cells[AppConstants.chequesGuid]?.value as String?;
            if (chequesId == null) return;
            final matches =
                logic.chequesList.where((c) => c.chequesGuid == chequesId);
            if (matches.isEmpty) return;
            final model = matches.first;
            final typeGuid = model.chequesTypeGuid;
            if (typeGuid == null) return;
            logic.openChequesDetailsById(
              chequesId,
              context,
              ChequesType.byTypeGuide(typeGuid),
            );
          },
          isLoading: logic.isLoading,
          title:
              !onlyDues ? AppStrings.allCheques.tr : AppStrings.chequesDues.tr,
          tableSourceModels: logic.chequesList.where(
            (element) {
              if (!onlyDues) {
                return true;
              } else {
                return element.isPayed == false;
              }
            },
          ).toList(),
        ),
      );
    });
  }
}
