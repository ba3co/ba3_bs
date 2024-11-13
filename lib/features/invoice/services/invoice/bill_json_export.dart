import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/json_export/abstract/base_json_export_service.dart';
import '../../data/models/bill_model.dart';

class BillJsonExport extends BaseJsonExportService<BillModel> {
  /// Converts the list of `BillModel` to the exportable JSON structure
  @override
  Map<String, dynamic> toExportJson(List<BillModel> itemsModels) {
    return {
      "Bill": itemsModels.map((billModel) {
        return <String, dynamic>{
          "B": {
            "BillTypeGuid": _billTypeGuide(billModel.billTypeModel.billTypeLabel!),
            "BillGuid": billModel.billDetails.billGuid,
            "BillBranch": "",
            "BillPayType": billModel.billDetails.billPayType ?? 0,
            "BillCheckTypeGuid": "",
            "BillNumber": billModel.billDetails.billNumber ?? 0,
            "BillCustPtr": billModel.billDetails.billCustomerId ?? "",
            "BillCustName": billModel.billTypeModel.accounts?[BillAccounts.caches]?.accName,
            // Add the customer name if available
            "BillCurrencyGuid": "884edcde-c172-490d-a2f2-f10a0b90326a",
            "BillCurrencyVal": 1,
            "BillDate": billModel.billDetails.billDate ?? "",
            "BillStoreGuid": billModel.billTypeModel.accounts?[BillAccounts.store]?.id,
            "Note": billModel.billDetails.note ?? "",
            "BillCustAcc": "00000000-0000-0000-0000-000000000000",
            "BillMatAccGuid": "",
            "BillCostGuid": "00000000-0000-0000-0000-000000000000",
            "BillVendorSalesMan": "0,0",
            "BillFirstPay": 0,
            "BillFPayAccGuid": "00000000-0000-0000-0000-000000000000",
            "BillSecurity": 3,
            "BillTransferGuid": "00000000-0000-0000-0000-000000000000",
            "BillFld1": "",
            "BillFld2": "",
            "BillFld3": "",
            "BillFld4": "",
            "ItemsDiscAcc": "",
            "ItemsExtraAccGUID": "",
            "CostAccGUID": "",
            "StockAccGUID": "",
            "BonusAccGUID": "",
            "BonusContraAccGUID": "",
            "VATAccGUID": "",
            "DIscCard": "",
            "BillAddressGUID": "00000000-0000-0000-0000-000000000000"
          },
          "Disc": "", // Discount details if any
          "Items": {
            "I": billModel.items.itemList
                .map((item) => {
                      "MatPtr": item.itemGuid,
                      "QtyBonus": "${item.itemQuantity},0",
                      "Unit": 1, // Customize based on your data
                      "PriceDescExtra": "${item.itemTotalPrice},0,0",
                      "StorePtr": billModel.billTypeModel.accounts?[BillAccounts.store]?.id,
                      "Note": item.itemName,
                      "BonusDisc": 0,
                      "UlQty": "${item.itemQuantity},${item.itemQuantity}",
                      "CostPtr": "",
                      "ClassPtr": "",
                      "ClassPrice": 0,
                      "ExpireProdDate": "1-1-1980,1-1-1980", // Replace with actual expiration dates if available
                      "LengthWidthHeight": "0,0,0,0",
                      "Guid": item.itemGuid,
                      "VatRatio": _calcVatRatio(item.itemVatPrice, item.itemSubTotalPrice),
                      "SoGuid": "",
                      "SoType": 0
                    })
                .toList(),
          }
        };
      }).toList(),
    };
  }

  String _billTypeGuideByLabel(String label) {
    final Map<String, String> typeGuideMap = {
      BillType.purchase.label: "eb10653a-a43f-44e5-889d-41ce68c43ec4",
      BillType.sales.label: "6ed3786c-08c6-453b-afeb-a0e9075dd26d",
      BillType.purchaseReturn.label: "507f9e7d-e44e-4c4e-9761-bb3cd4fc1e0d",
      BillType.salesReturn.label: "2373523c-9f23-4ce7-a6a2-6277757fc381",
      BillType.adjustmentEntry.label: "06f0e6ea-3493-480c-9e0c-573baf049605",
      BillType.outputAdjustment.label: "563af9aa-5d7e-470b-8c3c-fee784da810a",
      BillType.firstPeriodInventory.label: "5a9e7782-cde5-41db-886a-ac89732feda7",
      BillType.transferIn.label: "f0f2a5db-53ed-4e53-9686-d6a809911327",
      BillType.transferOut.label: "1e90ef6a-f7ef-484e-9035-0ab761371545"
    };

    final typeGuide = typeGuideMap[label];

    if (typeGuide == null) {
      throw ArgumentError('No matching Type for label: $label');
    }
    return typeGuide;
  }

  String _billTypeGuide(String billLabel) => _billTypeGuideByLabel(billLabel);

  int _calcVatRatio(double? vat, double? sunTotal) {
    if (vat == null || vat == 0 || sunTotal == null || sunTotal == 0) return 0;
    return ((vat / sunTotal) * 100).round();
  }
}
