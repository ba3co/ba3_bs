import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/grid_column_item.dart';
import '../../controllers/bond_controller.dart';
import '../widgets/bond_record_data_source.dart';

class EntryBondDetailsView extends StatelessWidget {
  const EntryBondDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<BondController>(builder: (controller) {
        return Scaffold(
          appBar: AppBar(),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Expanded(child: GetBuilder<BondController>(builder: (controller) {
                  return SfDataGrid(
                    horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
                    verticalScrollPhysics: const BouncingScrollPhysics(),
                    source: BondDataGridSource(),
                    allowEditing: false,
                    selectionMode: SelectionMode.singleDeselect,
                    editingGestureType: EditingGestureType.tap,
                    navigationMode: GridNavigationMode.cell,
                    columnWidthMode: ColumnWidthMode.fill,
                    allowSwiping: false,
                    swipeMaxOffset: 200,
                    columns: <GridColumn>[
                      gridColumnItem(
                        label: 'الحساب',
                        name: AppConstants.rowBondAccount,
                        color: Colors.blue,
                      ),
                      gridColumnItem(
                        label: ' مدين',
                        name: AppConstants.rowBondDebitAmount,
                        color: Colors.blue,
                      ),
                      gridColumnItem(
                        label: ' دائن',
                        name: AppConstants.rowBondCreditAmount,
                        color: Colors.blue,
                      ),
                      gridColumnItem(
                        label: "البيان",
                        name: AppConstants.rowBondDescription,
                        color: Colors.blue,
                      ),
                    ],
                  );
                })),
              ],
            ),
          ),
        );
      }),
    );
  }
}
