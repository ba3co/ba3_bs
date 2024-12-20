import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/bond/controllers/entry_bond/entry_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/grid_column_item.dart';
import '../../data/models/entry_bond_model.dart';
import '../widgets/entry_bond_details/bond_record_data_source.dart';

class EntryBondDetailsScreen extends StatelessWidget {
  const EntryBondDetailsScreen({super.key, required this.entryBondModel});

  final EntryBondModel entryBondModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
              child: SfDataGrid(
            horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
            verticalScrollPhysics: const BouncingScrollPhysics(),
            source: BondDataGridSource(entryBondModel: entryBondModel),
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
          )),
          AppButton(
              title: "عرض الاصل",
              onPressed: () {
                Get.find<EntryBondController>().openOriginForEntryBond(entryBondModel,context);
              },
              iconData: Icons.keyboard_return)
        ],
      ),
    );
  }
}
