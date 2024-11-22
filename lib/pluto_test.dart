import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridExamplePage extends StatefulWidget {
  @override
  _PlutoGridExamplePageState createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  PlutoGridStateManager? firstTableStateManager;
  PlutoGridStateManager? secondTableStateManager;

  // First table columns and rows
  final List<PlutoColumn> firstTableColumns = [
    PlutoColumn(title: 'المادة', field: 'item', type: PlutoColumnType.text()),
    PlutoColumn(title: 'الكمية', field: 'quantity', type: PlutoColumnType.number()),
    PlutoColumn(title: 'السعر الافرادي', field: 'unitPrice', type: PlutoColumnType.number()),
    PlutoColumn(title: 'الضريبة', field: 'tax', type: PlutoColumnType.number()),
    PlutoColumn(title: 'المجموع', field: 'total', type: PlutoColumnType.number()),
  ];

  final List<PlutoRow> firstTableRows = List.generate(4, (index) {
    return PlutoRow(cells: {
      'item': PlutoCell(value: 'Item $index'),
      'quantity': PlutoCell(value: 1),
      'unitPrice': PlutoCell(value: 95),
      'tax': PlutoCell(value: 5), // VAT will be calculated as 5% of unit price
      'total': PlutoCell(value: 100),
    });
  });

  // Second table columns and rows
  final List<PlutoColumn> secondTableColumns = [
    PlutoColumn(title: 'الحساب', field: 'account', type: PlutoColumnType.text()),
    PlutoColumn(title: 'الحسم', field: 'discount', type: PlutoColumnType.number()),
    PlutoColumn(title: 'نسبة الحسم', field: 'discountPercentage', type: PlutoColumnType.number()),
    PlutoColumn(title: 'الاضافة', field: 'addition', type: PlutoColumnType.number()),
    PlutoColumn(title: 'نسبة الاضافة', field: 'additionPercentage', type: PlutoColumnType.number()),
  ];

  final List<PlutoRow> secondTableRows = List.generate(3, (index) {
    return PlutoRow(cells: {
      'account': PlutoCell(value: 'Account $index'),
      'discount': PlutoCell(value: 0),
      'discountPercentage': index.isEven ? PlutoCell(value: index + 1 * 5) : PlutoCell(value: 0),
      'addition': PlutoCell(value: 0),
      'additionPercentage': index.isOdd ? PlutoCell(value: index * 5) : PlutoCell(value: 0),
    });
  });

  num totalFirstTable = 0; // To keep track of the total sum of the first table

  @override
  void initState() {
    super.initState();
    log('initState');
    // Initialize total from first table
    _updateFirstTableTotal();
    _applyDiscounts('initState'); // Apply initial discounts (if any)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pluto Grid Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Blue container displaying the total from the first table
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.white)),
                  Text(totalFirstTable.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PlutoGrid(
                columns: firstTableColumns,
                rows: firstTableRows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  log('onLoaded firstTable');
                  firstTableStateManager = event.stateManager;
                  // Recalculate the total when the grid is loaded
                  _updateFirstTableTotal();
                  _applyDiscounts('onLoaded firstTable'); // Reapply discounts if needed
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  if (event.column.field == 'quantity' || event.column.field == 'unitPrice') {
                    _updateFirstTableTotal();
                    _applyDiscounts('onChanged firstTable');
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PlutoGrid(
                columns: secondTableColumns,
                rows: secondTableRows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  log('onLoaded secondTable');
                  secondTableStateManager = event.stateManager;
                  _applyDiscounts('onLoaded secondTable'); // Reapply discounts if needed
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  log('field ${event.column.field}');
                  if (event.column.field == 'discountPercentage' || event.column.field == 'additionPercentage') {
                    _applyDiscounts('onChanged secondTable');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to update the 'المجموع' (Total) in the first table
  void _updateFirstTableTotal() {
    if (firstTableStateManager == null) return; // Ensure the manager is initialized

    totalFirstTable = 0; // Reset the total when recalculating

    for (final row in firstTableStateManager!.rows) {
      final quantity = row.cells['quantity']?.value ?? 0;
      final unitPrice = row.cells['unitPrice']?.value ?? 0;

      // VAT calculation (5% of the unit price)
      final vat = unitPrice * 0.05;
      row.cells['tax']?.value = vat; // Update VAT in the 'tax' field

      // Calculate total for the row
      final total = (quantity * unitPrice) + vat;
      row.cells['total']?.value = total;

      totalFirstTable += total; // Add row total to the overall total
    }

    firstTableStateManager!.notifyListeners();
  }

  // Method to apply the discounts from the second table to the total in the first table
  void _applyDiscounts(String from) {
    log('_applyDiscounts $from');
    if (secondTableStateManager == null) return; // Ensure the manager is initialized

    num totalAfterDiscounts = totalFirstTable; // Start with the sum of the first table

    for (final row in secondTableStateManager!.rows) {
      final discountPercentage = row.cells['discountPercentage']?.value ?? 0;
      final additionPercentage = row.cells['additionPercentage']?.value ?? 0;

      log('discountPercentage ${row.cells['discountPercentage']?.value} ');
      log('additionPercentage ${row.cells['additionPercentage']?.value} ');

      // Calculate discount amount
      final discountAmount = totalFirstTable * (discountPercentage / 100);
      final additionAmount = totalFirstTable * (additionPercentage / 100);

      // Apply the discount
      row.cells['discount']?.value = discountAmount;
      row.cells['addition']?.value = additionAmount;
      totalAfterDiscounts =
          totalAfterDiscounts - discountAmount + additionAmount; // Subtract the discount from the total
    }

    // Update the total value in the blue container
    setState(() {
      totalFirstTable = totalAfterDiscounts;
    });

    secondTableStateManager!.notifyListeners();
  }
}
