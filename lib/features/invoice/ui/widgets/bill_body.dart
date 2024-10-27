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
                    columns: plutoController.billAdditionsDiscountsColumns,
                    rows: plutoController.billAdditionsDiscountsRows,
                    onChanged: plutoController.onAdditionsDiscountsChanged,
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      plutoController.billAdditionsDiscountsStateManager = event.stateManager;
                    },
                  ),
                ),
              ],
            ),
          ),
          Column(children: [
            const VerticalSpace(10),
            GetBuilder<InvoicePlutoController>(builder: (controller) {
              return SizedBox(
                width: Get.width,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  alignment: WrapAlignment.end,
                  children: [
                    Container(
                      color: Colors.blueGrey.shade400,
                      width: 150,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            (controller.computeWithVatTotal() - controller.computeWithoutVatTotal()).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 30, color: Colors.white),
                          ),
                          const Text(
                            "القيمة المضافة",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade600,
                      width: 150,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            controller.computeWithoutVatTotal().toStringAsFixed(2),
                            style: const TextStyle(fontSize: 30, color: Colors.white),
                          ),
                          const Text(
                            "المجموع",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.blue,
                      width: 300,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              (controller.computeWithVatTotal()).toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "النهائي",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ]),
        ],
      ),
    );
  }
}
