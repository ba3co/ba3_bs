import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/get_accounts_by_enter_action.dart';
import '../../../../../core/widgets/get_products_by_enter_action.dart';
import '../../../../../core/widgets/pluto_short_cut.dart';
import '../../../../../core/widgets/pluto_with_edite.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../../../controllers/invoice_pluto_controller.dart';
import 'bill_grid_widget.dart';

class BillBody extends StatelessWidget {
  const BillBody({
    super.key,
    required this.billTypeModel,
  });

  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: GetBuilder<InvoicePlutoController>(builder: (controller) {
                return FocusScope(
                  autofocus: true,
                  child: PlutoWithEdite(
                    evenRowColor: Color(billTypeModel.color!),
                    controller: controller,
                    shortCut: customPlutoShortcut(
                      GetProductByPlutoGridEnterAction(controller, AppConstants.invRecProduct),
                    ),
                    onRowSecondaryTap: controller.onMainTableRowSecondaryTap,
                    onChanged: controller.onMainTableStateManagerChanged,
                  ),
                );
              }),
            ),
          ),
          const VerticalSpace(),
          GetBuilder<InvoicePlutoController>(builder: (controller) {
            return Expanded(
              flex: 2,
              child: BillGridWidget(
                rowColor: Colors.grey,
                columns: controller.additionsDiscountsColumns,
                rows: controller.additionsDiscountsRows,
                shortCut: customPlutoShortcut(GetAccountsByEnterAction(controller)),
                onChanged: controller.onAdditionsDiscountsChanged,
                onLoaded: controller.onAdditionsDiscountsLoaded,
              ),
            );
          }),
        ],
      ),
    );
  }
}
