import 'package:ba3_bs/core/widgets/pluto_with_edite.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';
import 'package:ba3_bs/features/bond/service/EnterActionShortCut.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_details/bond_details_app_bar.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_details/bond_details_buttons.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_details/bond_details_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/widgets/pluto_short_cut.dart';
import '../../controllers/bonds/bond_search_controller.dart';
import '../../controllers/pluto/bond_details_pluto_controller.dart';

class BondDetailsView extends StatelessWidget {
  const BondDetailsView({
    super.key,
    required this.fromBondById,
    required this.bondDetailsController,
    required this.bondDetailsPlutoController,
    required this.bondSearchController,
    required this.tag,
  });

  final bool fromBondById;
  final BondDetailsController bondDetailsController;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final BondSearchController bondSearchController;
  final String tag;

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BondSearchController>(

        tag: tag,
        builder: (_) {
          final BondModel currentBond = bondSearchController.getCurrentBond;

          return GetBuilder<BondDetailsController>(
              tag: tag,
              builder: (bondDetailsController) {

            return Scaffold(
              appBar: BondDetailsAppBar(bondDetailsController: bondDetailsController, bondSearchController: bondSearchController, bondTypeModel: currentBond.payTypeGuid!),
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BondDetailsHeader(bondDetailsController: bondDetailsController),
                      Expanded(child: GetBuilder<BondDetailsPlutoController>(builder: (bondController) {
                        return FocusScope(
                          autofocus: true,
                          child: PlutoWithEdite(
                            columns: bondController.mainTableColumns,
                            rows: bondController.mainTableRows,
                            onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {
                              bondController.onRowSecondaryTap(event, context);
                            },
                            onChanged: bondController.onMainTableStateManagerChanged,
                            onLoaded: bondController.onMainTableLoaded,
                            shortCut: customPlutoShortcut(const EnterAction()),
                            evenRowColor: bondController.color,
                          ),
                        );
                      })),

                      GetBuilder<BondDetailsPlutoController>(builder: (bondRecordPlutoController) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 350,
                              child: Row(
                                children: [
                                  const SizedBox(
                                      width: 100,
                                      child: Text(
                                        "المجموع",
                                      )),
                                  Container(
                                      width: 120,
                                      color: bondRecordPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red,
                                      padding: const EdgeInsets.all(5),
                                      child: Text(bondRecordPlutoController.calcDebitTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                                  const SizedBox(width: 10),
                                  Container(
                                      width: 120,
                                      color: bondRecordPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red,
                                      padding: const EdgeInsets.all(5),
                                      child: Text(bondRecordPlutoController.calcCreditTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 350,
                              child: Row(
                                children: [
                                  const SizedBox(width: 100, child: Text("الفرق")),
                                  Container(
                                      width: 250,
                                      color: bondRecordPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red,
                                      padding: const EdgeInsets.all(5),
                                      child: Text(bondRecordPlutoController.getDefBetweenCreditAndDebt().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                                ],
                              ),
                            ),
                            const Divider(),
                            BondDetailsButtons(bondDetailsController: bondDetailsController, bondDetailsPlutoController: bondDetailsPlutoController, bondModel: currentBond, fromBondById: fromBondById, bondSearchController: bondSearchController)
                          ],
                        );
                      }),


                      BondDetailsButtons(bondDetailsController: bondDetailsController, bondDetailsPlutoController: bondDetailsPlutoController, bondModel: currentBond, fromBondById: fromBondById, bondSearchController: bondSearchController)

                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
