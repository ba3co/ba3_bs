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
          onSelected: (p0) {},
          isLoading: logic.isLoading,

          title: !onlyDues ? "جميع الشيكات" : "الشيكات المستحقة",
          tableSourceModels: logic.chequesList.where(
            (element) {
              if (!onlyDues) {
                return true;
              } else {
                return element.isPayed ==false;
              }
            },
          ).toList(),
        ),
      );
    });
  }
}
