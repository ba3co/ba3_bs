import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../controllers/bonds/bond_type_controller.dart';
import '../widgets/add_bond/add_bond_type_bottom_buttons.dart';
import '../widgets/add_bond/add_bond_type_form.dart';
import '../widgets/add_bond/colors_picker.dart';


class AddBondTypeScreen extends StatelessWidget {
  const AddBondTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppStrings.addBondType.tr),
              ),
              body: GetBuilder<BondTypeController>(
                builder: (bondTypeController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView(
                      children: [
                        const VerticalSpace(20),
                        AddBondTypeForm(controller: bondTypeController),
                        const VerticalSpace(40),
                        ColorsPicker(bondTypeController: bondTypeController),
                        const VerticalSpace(40),
                        AddBondTypeBottomButtons(bondTypeController: bondTypeController),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
