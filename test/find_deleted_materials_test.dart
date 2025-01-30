import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/features/bill/data/models/bill_details.dart';
import 'package:ba3_bs/features/bill/data/models/bill_items.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('findDeletedMaterials', () {
    test('returns empty map when no items are deleted', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems, isEmpty);
    });

    test('returns deleted items when some items are removed', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems.length, 1);
      expect(deletedItems.containsKey('item2'), isTrue);
    });

    test('returns all items when all are deleted', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems.length, 2);
      expect(deletedItems.containsKey('item1'), isTrue);
      expect(deletedItems.containsKey('item2'), isTrue);
    });

    test('returns empty map when previous bill is empty', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems, isEmpty);
    });

    test('returns all items when current bill is empty', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems.length, 2);
      expect(deletedItems.containsKey('item1'), isTrue);
      expect(deletedItems.containsKey('item2'), isTrue);
    });

    test('returns only one deleted item when previous bill has duplicates and one is removed', () {
      final previousBill = BillModel(
          billTypeModel: BillTypeModel(),
          billDetails: BillDetails(),
          status: Status.approved,
          items: BillItems(itemList: [
            BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
            BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
            BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
          ]));

      final currentBill = BillModel(
          billTypeModel: BillTypeModel(),
          billDetails: BillDetails(),
          status: Status.approved,
          items: BillItems(itemList: [
            BillItem(
                itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'), // One instance remains
            BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
          ]));

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems.length, 1);
      expect(deletedItems.containsKey('item1'), isTrue);
      expect(deletedItems['item1']!.length, 1); // Only one instance should be removed
    });
  });
}

Map<String, List<BillItem>> findDeletedMaterials({required BillModel previousBill, required BillModel currentBill}) {
  final previousGroupedItems = previousBill.items.itemList.groupBy((item) => item.itemGuid);
  final currentGroupedItems = currentBill.items.itemList.groupBy((item) => item.itemGuid);

  // Compute deleted items by filtering out those that exist in the current bill
  final deletedItems = previousGroupedItems.map((key, value) => MapEntry(key, value))
    ..removeWhere((key, _) => currentGroupedItems.containsKey(key));

  return deletedItems;
}
