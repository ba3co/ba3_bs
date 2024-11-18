import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/get_accounts_by_enter_action.dart';
import '../../../../../core/widgets/get_products_by_enter_action.dart';
import '../../../../../core/widgets/pluto_short_cut.dart';
import '../../../../../core/widgets/pluto_with_edite.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../bill_shared/bill_grid_widget.dart';

class BillDetailsBody extends StatelessWidget {
  const BillDetailsBody({super.key, required this.billTypeModel});

  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    final billDetailsController = Get.find<BillDetailsController>();
    return Expanded(
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: GetBuilder<BillDetailsPlutoController>(builder: (controller) {
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
          const VerticalSpace(),
          GetBuilder<BillDetailsPlutoController>(builder: (billDetailsPlutoController) {
            return Expanded(
              flex: 2,
              child: BillGridWidget(
                rowColor: Colors.grey,
                columns: billDetailsPlutoController.additionsDiscountsColumns,
                rows: billDetailsPlutoController.additionsDiscountsRows,
                onChanged: billDetailsPlutoController.onAdditionsDiscountsChanged,
                onLoaded: billDetailsPlutoController.onAdditionsDiscountsLoaded,
                shortCut: customPlutoShortcut(GetAccountsByEnterAction(
                  plutoController: billDetailsPlutoController,
                  billController: billDetailsController,
                )),
              ),
            );
          }),
        ],
      ),
    );
  }
}
