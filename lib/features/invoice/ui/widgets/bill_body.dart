import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/widgets/app_spacer.dart';
import '../../../../core/widgets/custom_pluto_short_cut.dart';
import '../../../../core/widgets/custom_pluto_with_edite.dart';
import '../../../../core/widgets/get_product_enter_short_cut.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/invoice_pluto_controller.dart';
import 'bill_grid_widget.dart';

class BillBody extends StatelessWidget {
  const BillBody({
    super.key,
    required this.billTypeModel,
  });

  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    var plutoController = Get.find<InvoicePlutoController>();
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: GetBuilder<InvoicePlutoController>(builder: (controller) {
                      return FocusScope(
                        autofocus: true, // لتمكين التركيز تلقائيًا عند إنشاء الشاشة
                        child: CustomPlutoWithEdite(
                          evenRowColor: Color(billTypeModel.color!),
                          controller: controller,
                          shortCut: customPlutoShortcut(GetProductEnterPlutoGridAction(controller, "invRecProduct")),
                          onRowSecondaryTap: (event) {},
                          onChanged: (PlutoGridOnChangedEvent event) async {
                            String quantityNum = Utils.extractNumbersAndCalculate(
                                controller.stateManager.currentRow!.cells["invRecQuantity"]?.value?.toString() ?? '');
                            String? subTotalStr = Utils.extractNumbersAndCalculate(
                                controller.stateManager.currentRow!.cells["invRecSubTotal"]?.value);
                            String? totalStr = Utils.extractNumbersAndCalculate(
                                controller.stateManager.currentRow!.cells["invRecTotal"]?.value);
                            String? vat = Utils.extractNumbersAndCalculate(
                                controller.stateManager.currentRow!.cells["invRecVat"]?.value ?? "0");

                            double subTotal = controller.parseExpression(subTotalStr);
                            double total = controller.parseExpression(totalStr);
                            int quantity = double.parse(quantityNum).toInt();
                            if (event.column.field == "invRecSubTotal") {
                              controller.updateInvoiceValues(subTotal, quantity);
                            }
                            if (event.column.field == "invRecTotal") {
                              controller.updateInvoiceValuesByTotal(total, quantity);
                            }
                            if (event.column.field == "invRecQuantity" && quantity > 0) {
                              controller.updateInvoiceValuesByQuantity(quantity, subTotal, double.parse(vat));
                            }

                            WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then(
                              (value) {
                                controller.update();
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const VerticalSpace(),
                Expanded(
                  flex: 1,
                  child: BillGridWidget(
                    rowColor: Colors.grey,
                    columns: AppConstants.billAdditionsDiscountsColumns,
                    rows: AppConstants.billAdditionsDiscountsRows,
                    onChanged: plutoController.onAdditionsDiscountsChanged,
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      plutoController.billAdditionsDiscountsStateManager = event.stateManager;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
