import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart';

import '../../../features/bond/data/models/bond_model.dart';
import '../../../features/cheques/data/models/cheques_model.dart';
import '../../../features/materials/data/models/materials/material_model.dart';
import '../../helper/enums/enums.dart';


class StaticSections{
void buildStaticSections(
    {required XmlBuilder builder, required List<MaterialModel> materials, required Map<BondType, List<BondModel>> bonds, required List<ChequesModel> chequesList}) {
  _buildExportVersion(builder);
  _buildExpSetting(builder, bonds, chequesList);
  _buildExportType(builder);
  _buildBillsTypes(builder);
  _buildChequesDescription(builder);
  _buildPayTypesDescription(builder,bonds);
  _buildCurrencySection(builder);
  _buildGccTaxOptions(builder);
  _buildMaterialTaxes(builder, materials);
}

void _buildExportVersion(XmlBuilder builder) {
  builder.element('ExportVersion', nest: () {
    builder.element('V', nest: '3.1');
    builder.element('Id', nest: '64a6a2dd-d2e8-43f0-ab6c-f4692312d711');
  });
}

void _buildExpSetting(XmlBuilder builder, Map<BondType, List<BondModel>> bonds, List<ChequesModel> chequesList) {
  builder.element('ExpSetting', nest: () {
    builder
      ..element('Counter', nest: '9')
      ..element('StdCount', nest: '0')
      ..element('OtherCnt', nest: '7')
      ..element('PayCnt', nest: '4');

    builder.element('Pays', nest: () {
      final pays = [
        ['ea69ba80-662d-4fa4-90ee-4d2e1988a8ea', '${bonds[BondType.openingEntry]!.lastOrNull?.payNumber ?? '0'},1'],
        ['3dbab874-6002-413b-9a6b-9a216f338097', '${bonds[BondType.receiptVoucher]!.lastOrNull?.payNumber ?? '0'},1'],
        ['5085dc23-1444-4e9a-9d8f-1794da9e7f96', '${bonds[BondType.paymentVoucher]!.lastOrNull?.payNumber ?? '0'},1'],
        ['2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de', '${bonds[BondType.journalVoucher]!.lastOrNull?.payNumber ?? '0'},1'],
      ];
      for (var pay in pays) {
        builder.element('Pay', nest: () {
          builder.element('Range', nest: '${pay[0]} ${pay[1]}');
        });
      }
    });

    builder.element('ChkCnt', nest: '3');
    builder.element('Notes', nest: () {
      final notes = [
        ['fc3fe7b6-dbb4-4007-b8a4-fc3533dccd18', '${chequesList.lastOrNull?.chequesNumber ?? '0'},1'],
        ['c27c5972-2b40-47df-8e3e-6ee29c4d5838', '1,1'],
      ];
      for (var note in notes) {
        builder.element('Note', nest: () {
          builder.element('Range', nest: '${note[0]} ${note[1]}');
        });
      }
    });

    final defaultFields = {
      'Ignore': '0',
      'CrdtAsCash': '0',
      'ExportType': '1',
      'ExportMat': '0',
      'ExportAllMats': '0',
      'MatFrom': null,
      'MatTo': null,
      'ExportStore': '0',
      'ExportAllStores': '0',
      'StoreFrom': null,
      'StoreTo': null,
      'ExportGroup': '0',
      'ExportAllGroup': '0',
      'GroupFrom': null,
      'GroupTo': null,
      'ExportAcc': '0',
      'ExportAllAcc': '0',
      'AccpFrom': null,
      'AccTo': null,
      'ExportCost': '0',
      'ExportAllCosts': '0',
      'CostFrom': null,
      'CostTo': null,
      'StoreGuid': '00000000-0000-0000-0000-000000000000',
      'ExpEntry': '1',
      'ExpBll': '1',
      'ExpPay': '1',
      'ExpChk': '1',
      'ExpMBonus': '0',
      'ExpMatAcc': '0',
      'ExpCashBill': '0',
      'IsExpBillDate': '0',
      'ExpStartBillDate': '1-1-2022',
      'ExpBillDate': '10-11-2022',
      'FilterStoreGuid': '00000000-0000-0000-0000-000000000000',
      'EntryFrom': '0',
      'EntryTo': '10000',
    };

    defaultFields.forEach((key, value) {
      builder.element(key, nest: value);
    });
  });
}

void _buildExportType(XmlBuilder builder) {
  builder.element('ExportType', nest: () {
    builder.element('T', nest: '1');
  });
}

void _buildBillsTypes(XmlBuilder builder) {
  final types = [
    ['eb10653a-a43f-44e5-889d-41ce68c43ec4', 'مشتريات', 'Purchase', '1', '1', '234'],
    ['507f9e7d-e44e-4c4e-9761-bb3cd4fc1e0d', 'مرتجع مشتريات', 'Purchase Return', '1', '1', '10'],
    ['6ed3786c-08c6-453b-afeb-a0e9075dd26d', 'مبيعات', 'Sales', '1', '1', '2458'],
    ['2373523c-9f23-4ce7-a6a2-6277757fc381', 'مرتجع مبيعات', 'Sales Return', '1', '1', '11'],
    ['06f0e6ea-3493-480b-9e0c-573baf049605', 'تسوية ادخال', 'تسوية ادخال', '1', '1', '7'],
    ['563af9aa-5d7e-470b-8c3c-fee784da810a', 'تسوية اخراج', 'تسوية اخراج', '1', '1', '1'],
    ['35c75331-1917-451e-84de-d26861134cd4', 'تسوية النقص', 'تسوية النقص', '1', '1', '3'],
    ['494fa945-3fe5-4fc3-86d6-7a9999b6c9e8', 'تسوية الزيادة', 'تسوية الزيادة', '1', '1', '4'],
    ['5a9e7782-cde5-41db-886a-ac89732feda7', 'بضاعة أول المدة', 'First Period Inventory', '2', '1', '17'],
  ];

  builder.element('BillsTypes', nest: () {
    for (var t in types) {
      builder.element('D', nest: () {
        builder.element('Type', nest: t[0]);
        builder.element('Name', nest: t[1]);
        builder.element('LatinName', nest: t[2]);
        builder.element('iType', nest: t[3]);
        builder.element('From', nest: t[4]);
        builder.element('To', nest: t[5]);
      });
    }
  });
}

void _buildChequesDescription(XmlBuilder builder) {
  final cheques = [
    ['fc3fe7b6-dbb4-4007-b8a4-fc3533dccd18', 'شيكات مدفوعة', 'شيكات مدفوعة', '1', '99'],
    ['c27c5972-2b40-47df-8e3e-6ee29c4d5838', 'شيكات تأمين', 'شيكات تأمين', '1', '1'],
  ];

  builder.element('ChkDesc', nest: () {
    for (var c in cheques) {
      builder.element('K', nest: () {
        builder.element('Type', nest: c[0]);
        builder.element('Name', nest: c[1]);
        builder.element('LatinName', nest: c[2]);
        builder.element('DefPayAccGuid', nest: '00000000-0000-0000-0000-000000000000');
        builder.element('DefRecAccGuid', nest: '00000000-0000-0000-0000-000000000000');
        builder.element('From', nest: c[3]);
        builder.element('To', nest: c[4]);
      });
    }
  });
}

void _buildPayTypesDescription(XmlBuilder builder,Map<BondType, List<BondModel>> bonds) {
  final pays = [

    ['ea69ba80-662d-4fa4-90ee-4d2e1988a8ea', 'القيد الافتتاحي', 'Opening Entry', '1', '${bonds[BondType.openingEntry]!.lastOrNull?.payNumber ?? '0'}', '0'],
    ['3dbab874-6002-413b-9a6b-9a216f338097', 'سند قبض', 'Receipt Voucher', '1', '${bonds[BondType.receiptVoucher]!.lastOrNull?.payNumber ?? '0'}', '2'],
    ['5085dc23-1444-4e9a-9d8f-1794da9e7f96', 'سند دفع', 'Payment Voucher', '1', '${bonds[BondType.paymentVoucher]!.lastOrNull?.payNumber ?? '0'}', '1'],
    ['2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de', 'سند يومية', 'Journal Voucher', '1', '${bonds[BondType.journalVoucher]!.lastOrNull?.payNumber ?? '0'}', '1'],
  ];

  builder.element('PayDesc', nest: () {
    for (var p in pays) {
      builder.element('Y', nest: () {
        builder.element('Type', nest: p[0]);
        builder.element('Name', nest: p[1]);
        builder.element('LatinName', nest: p[2]);
        builder.element('From', nest: p[3]);
        builder.element('To', nest: p[4]);
        builder.element('TaxType', nest: p[5]);
      });
    }
  });
}

void _buildCurrencySection(XmlBuilder builder) {
  builder.element('Currency', nest: () {
    builder.element('CurrencyCount', nest: '1');
    builder.element('cr', nest: () {
      builder.element('CurGuid', nest: '884EDCDE-C172-490D-A2F2-F10A0B90326A');
      builder.element('CurCode', nest: 'د.هـ.');
      builder.element('CurName', nest: 'درهم إماراتي');
      builder.element('CurVal', nest: '1');
      builder.element('CurPartName', nest: 'فلس');
      builder.element('CurPartPrecision', nest: '100');
      builder.element('CurSecurity', nest: '0');
      builder.element('CurDate', nest: '1-1-1980');
      builder.element('CurLatinName', nest: 'UAE Dirham');
      builder.element('CurLatinPartName', nest: 'Fils');
      builder.element('CurNumber', nest: '4.94065645841246544176568792868e-324');
      builder.element('CurBranchMask', nest: '0');
    });
  });
}

void _buildGccTaxOptions(XmlBuilder builder) {
  builder.element('GCCTaxSystemOption', nest: () {
    builder.element('GCCTaxSystemOptionFlag', nest: '1');
  });

  builder.element('GCCTaxSystemCountry', nest: () {
    builder.element('xmlGCCTaxSystemCountryNumber', nest: '0');
  });
}

void _buildMaterialTaxes(XmlBuilder builder, List<MaterialModel> materials) {
  builder.element('GCCMaterialTaxes', nest: () {
    for (var mat in materials) {
      final isTaxable = mat.matVatGuid == 'xtc33mNeCZYR98i96pd8';
      final generatedId = XmlHelpers.uuid.v4();

      builder.element('GCCMaterialTax', nest: () {
        builder.element('GCCMaterialTaxGUID', nest: generatedId);
        builder.element('GCCMaterialTaxType', nest: '1.00');
        builder.element('GCCMaterialTaxCode', nest: isTaxable ? '1.00' : '4.00');
        builder.element('GCCMaterialTaxRatio', nest: isTaxable ? '5.00' : '0.0');
        builder.element('GCCMaterialTaxMatGUID', nest: mat.id);
        builder.element('GCCMaterialTaxProfitMargin', nest: 'F');
      });
    }
  });
}
}