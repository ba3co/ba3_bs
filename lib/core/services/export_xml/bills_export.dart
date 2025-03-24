import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/bill/data/models/bill_model.dart';
import '../../helper/enums/enums.dart';

class BillsExport {
  /// Generates the Bill section of the export XML
  List<xml.XmlElement> exportBills(List<BillModel> bills) {
    return bills.map((bill) {
      return xml.XmlElement(xml.XmlName('Bill'), [], [
        _buildBillElement(bill), // <B>
        xml.XmlElement(xml.XmlName('Disc'), [], []),
        xml.XmlElement(xml.XmlName('Items'), [], _buildItems(bill)),
      ]);
    }).toList();
  }

/*  xml.XmlElement exportBills(List<BillModel> bills) {


    return xml.XmlElement(
      xml.XmlName('Bill'),
      [],
      bills.map((bill) => _buildBillElement(bill)).toList(),
    );
  }*/

   xml.XmlElement _buildBillElement(BillModel bill) {
    return xml.XmlElement(
      xml.XmlName('B'),
      [],
      [
        XmlHelpers.element('BillTypeGuid', bill.billTypeModel.billTypeId),
        XmlHelpers.element('BillGuid', bill.billDetails.billGuid),
        XmlHelpers.element('BillBranch', null),
        XmlHelpers.element('BillPayType', bill.billDetails.billPayType?.toString() ?? '0'),
        XmlHelpers.element('BillCheckTypeGuid', null),
        XmlHelpers.element('BillNumber', bill.billDetails.billNumber?.toString() ?? '0'),
        XmlHelpers.element('BillCustPtr', bill.billDetails.billCustomerId),
        XmlHelpers.element('BillCustName', bill.billTypeModel.accounts?[BillAccounts.caches]?.accName),
        XmlHelpers.element('BillCurrencyGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
        XmlHelpers.element('BillCurrencyVal', '1'),
        XmlHelpers.element('BillDate', bill.billDetails.billDate?.toIso8601String()),
        XmlHelpers.element('BillStoreGuid', bill.billTypeModel.accounts?[BillAccounts.store]?.id),
        XmlHelpers.element('Note', bill.billDetails.billNote),
        XmlHelpers.element('BillCustAcc', '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('BillMatAccGuid', null),
        XmlHelpers.element('BillCostGuid', '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('BillVendorSalesMan', '0,0'),
        XmlHelpers.element('BillFirstPay', bill.billDetails.billFirstPay?.toString() ?? '0'),
        XmlHelpers.element('BillFPayAccGuid', '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('BillSecurity', '3'),
        XmlHelpers.element('BillTransferGuid', '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('BillFld1', null),
        XmlHelpers.element('BillFld2', null),
        XmlHelpers.element('BillFld3', null),
        XmlHelpers.element('BillFld4', null),
        XmlHelpers.element('ItemsDiscAcc', null),
        XmlHelpers.element('ItemsExtraAccGUID', null),
        XmlHelpers.element('CostAccGUID', null),
        XmlHelpers.element('StockAccGUID', null),
        XmlHelpers.element('BonusAccGUID', null),
        XmlHelpers.element('BonusContraAccGUID', null),
        XmlHelpers.element('VATAccGUID', null),
        XmlHelpers.element('DIscCard', null),
        XmlHelpers.element('BillAddressGUID', '00000000-0000-0000-0000-000000000000'),
      ],
    );
  }

    List<xml.XmlElement> _buildItems(BillModel bill) {
    return bill.items.itemList.map((item) {
      // final vatRatio = _calcVatRatio(item.itemVatPrice, item.itemSubTotalPrice);
      return xml.XmlElement(xml.XmlName('I'), [], [
        XmlHelpers.element('MatPtr', item.itemGuid),
        XmlHelpers.element('QtyBonus', '${item.itemQuantity},${item.itemGiftsNumber ?? 0}'),
        XmlHelpers.element('Unit', '1'),
        XmlHelpers.element('PriceDescExtra', '${item.itemTotalPrice},0,0'),
        XmlHelpers.element('StorePtr', bill.billTypeModel.accounts?[BillAccounts.store]?.id),
        XmlHelpers.element('Note', item.itemName),
        XmlHelpers.element('BonusDisc', '0'),
        XmlHelpers.element('UlQty', '${item.itemQuantity},${item.itemQuantity}'),
        XmlHelpers.element('CostPtr', null),
        XmlHelpers.element('ClassPtr', null),
        XmlHelpers.element('ClassPrice', '0'),
        XmlHelpers.element('ExpireProdDate', '1-1-1980,1-1-1980'),
        XmlHelpers.element('LengthWidthHeight', '0,0,0,0'),
        XmlHelpers.element('Guid', item.itemGuid),
        XmlHelpers.element('VatRatio', '0'),
        XmlHelpers.element('SoGuid', null),
        XmlHelpers.element('SoType', '0'),
      ]);
    }).toList();
  }
  xml.XmlElement exportBillGuids(List<BillModel> bills) {
    return xml.XmlElement(
      xml.XmlName('BillGuids'),
      [],
      bills
          .where((b) => b.billDetails.billGuid != null)
          .map((b) => xml.XmlElement(xml.XmlName('BillGuid'), [], [
        xml.XmlText(b.billDetails.billGuid!),
      ]))
          .toList(),
    );
  }

}