import 'package:ba3_bs/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/get_accounts_by_enter_action.dart';
import '../../../../../core/widgets/get_products_by_enter_action.dart';
import '../../../../../core/widgets/pluto_short_cut.dart';
import '../../../../../core/widgets/pluto_with_edite.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../bill_shared/bill_grid_widget.dart';

class AddBillBody extends StatelessWidget {
  const AddBillBody({super.key, required this.billTypeModel});

  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    final addBillController = Get.find<AddBillController>();
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: GetBuilder<AddBillPlutoController>(builder: (controller) {
              return FocusScope(
                autofocus: true,
                child: PlutoWithEdite(
                  columns: controller.mainTableColumns,
                  rows: controller.mainTableRows,
                  onRowSecondaryTap: controller.onMainTableRowSecondaryTap,
                  onChanged: controller.onMainTableStateManagerChanged,
                  onLoaded: controller.onMainTableLoaded,
                  shortCut: customPlutoShortcut(GetProductByEnterAction(controller)),
                  evenRowColor: Color(billTypeModel.color!),
                ),
              );
            }),
          ),
        ),
        const VerticalSpace(5),
        GetBuilder<AddBillPlutoController>(builder: (addBillPlutoController) {
          return Expanded(
            flex: 1,
            child: BillGridWidget(
              rowColor: Colors.grey,
              columns: addBillPlutoController.additionsDiscountsColumns,
              rows: addBillPlutoController.additionsDiscountsRows,
              onChanged: addBillPlutoController.onAdditionsDiscountsChanged,
              onLoaded: addBillPlutoController.onAdditionsDiscountsLoaded,
              shortCut: customPlutoShortcut(GetAccountsByEnterAction(
                plutoController: addBillPlutoController,
                billController: addBillController,
              )),
            ),
          );
        }),
      ],
    );
  }
}
