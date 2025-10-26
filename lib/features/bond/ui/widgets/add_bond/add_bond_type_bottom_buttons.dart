import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bonds/bond_type_controller.dart';

class AddBondTypeBottomButtons extends StatelessWidget {
  const AddBondTypeBottomButtons({super.key, required this.bondTypeController});

  final BondTypeController bondTypeController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Obx(() {
          return AppButton(
            isLoading: bondTypeController.addOrUpdateBondTypeRequestState.value == RequestState.loading,
            title: AppStrings.add.tr,
            onPressed: () {
              bondTypeController.addOrUpdateBondType(context);
            },
            iconData: Icons.add,
          );
        }),
      ],
    );
  }
}