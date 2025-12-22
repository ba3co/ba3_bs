
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:xml/xml.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/pluto_auto_id_column.dart';

part 'material_model.g.dart'; // This will be generated automatically by the build_runner

@HiveType(typeId: 0)
class MaterialModel extends HiveObject implements PlutoAdaptable {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final int? matCode;

  @HiveField(2)
  final String? matName;

  @HiveField(3)
  final String? matBarCode;

  @HiveField(4)
  final String? matGroupGuid;

  @HiveField(5)
  final String? matUnity;

  @HiveField(6)
  final int? matPriceType;

  @HiveField(7)
  final int? matBonus;

  @HiveField(8)
  final int? matBonusOne;

  @HiveField(9)
  final String? matCurrencyGuid;

  @HiveField(10)
  final double? matCurrencyVal;

  @HiveField(11)
  final String? matPictureGuid;

  @HiveField(12)
  final int? matType;

  @HiveField(13)
  final int? matSecurity;

  @HiveField(14)
  final int? matFlag;

  @HiveField(15)
  final int? matExpireFlag;

  @HiveField(16)
  final int? matProdFlag;

  @HiveField(17)
  final int? matUnit2FactFlag;

  @HiveField(18)
  final int? matUnit3FactFlag;

  @HiveField(19)
  final int? matSNFlag;

  @HiveField(20)
  final int? matForceInSN;

  @HiveField(21)
  final int? matForceOutSN;

  @HiveField(22)
  final double? matVAT;

  @HiveField(23)
  final int? matDefUnit;

  @HiveField(24)
  final int? matBranchMask;

  @HiveField(25)
  final int? matAss;

  @HiveField(26)
  final String? matOldGUID;

  @HiveField(27)
  final String? matNewGUID;

  @HiveField(28)
  final int? matCalPriceFromDetail;

  @HiveField(29)
  final int? matForceInExpire;

  @HiveField(30)
  final int? matForceOutExpire;

  @HiveField(31)
  final DateTime? matCreateDate;

  @HiveField(32)
  final int? matIsIntegerQuantity;

  @HiveField(33)
  final int? matClassFlag;

  @HiveField(34)
  final int? matForceInClass;

  @HiveField(35)
  final int? matForceOutClass;

  @HiveField(36)
  final int? matDisableLastPrice;

  @HiveField(37)
  final double? matLastPriceCurVal;

  @HiveField(38)
  final String? matPrevQty;

  @HiveField(39)
  final DateTime? matFirstCostDate;

  @HiveField(40)
  final int? matHasSegments;

  @HiveField(41)
  final String? matParent;

  @HiveField(42)
  final int? matIsCompositionUpdated;

  @HiveField(43)
  final int? matInheritsParentSpecs;

  @HiveField(44)
  final String? matCompositionName;

  @HiveField(45)
  final String? matCompositionLatinName;

  @HiveField(46)
  final int? movedComposite;

  @HiveField(47)
  final String? wholesalePrice;

  @HiveField(48)
  final String? retailPrice;

  @HiveField(49)
  final String? endUserPrice;

  @HiveField(50)
  final String? matVatGuid;

  @HiveField(51)
  final List<MatExtraBarcodeModel>? matExtraBarcode;

  @HiveField(52)
  final int? matQuantity;

  @HiveField(53)
  final double? calcMinPrice;

  @HiveField(54)
  final Map<String, bool>? serialNumbers;
  @HiveField(55)
  final int? matLocalQuantity;
  @HiveField(56)
  final int? matFreeQuantity;
  MaterialModel({
    this.id,
    this.matLocalQuantity,
    this.matFreeQuantity,
    this.matCode,
    this.matName,
    this.matBarCode,
    this.matGroupGuid,
    this.matUnity,
    this.matPriceType,
    this.matBonus,
    this.matBonusOne,
    this.matCurrencyGuid,
    this.matCurrencyVal,
    this.matPictureGuid,
    this.matType,
    this.matSecurity,
    this.matFlag,
    this.matExpireFlag,
    this.matProdFlag,
    this.matUnit2FactFlag,
    this.matUnit3FactFlag,
    this.matSNFlag,
    this.matForceInSN,
    this.matForceOutSN,
    this.matVAT,
    this.matDefUnit,
    this.matBranchMask,
    this.matAss,
    this.matOldGUID,
    this.matNewGUID,
    this.matCalPriceFromDetail,
    this.matForceInExpire,
    this.matForceOutExpire,
    this.matCreateDate,
    this.matIsIntegerQuantity,
    this.matClassFlag,
    this.matForceInClass,
    this.matForceOutClass,
    this.matDisableLastPrice,
    this.matLastPriceCurVal,
    this.matPrevQty,
    this.matFirstCostDate,
    this.matHasSegments,
    this.matParent,
    this.matIsCompositionUpdated,
    this.matInheritsParentSpecs,
    this.matCompositionName,
    this.matCompositionLatinName,
    this.movedComposite,
    this.wholesalePrice,
    this.retailPrice,
    this.endUserPrice,
    this.matVatGuid,
    this.matExtraBarcode,
    this.matQuantity,
    this.calcMinPrice,
    this.serialNumbers,
  });

  // Factory constructor to create an instance from JSON
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['docId']?.toString(),
      matCode: json['MatCode'],
      matName: json['MatName']?.toString(),
      matBarCode: json['MatBarCode']?.toString(),
      matGroupGuid: json['MatGroupGuid']?.toString(),
      matUnity: json['MatUnity']?.toString(),
      matPriceType: json['MatPriceType'],
      matBonus: json['MatBonus'],
      matBonusOne: json['MatBonusOne'],
      matCurrencyGuid: json['MatCurrencyGuid']?.toString(),
      matCurrencyVal: json['MatCurrencyVal']?.toDouble(),
      matPictureGuid: json['MatPictureGuid']?.toString(),
      matType: json['MatType'],
      matFreeQuantity: json['matFreeQuantity'],
      matLocalQuantity: json['matLocalQuantity'],
      matSecurity: json['MatSecurity'],
      matFlag: json['MatFlag'],
      matExpireFlag: json['MatExpireFlag'],
      matProdFlag: json['MatProdFlag'],
      matUnit2FactFlag: json['MatUnit2FactFlag'],
      matUnit3FactFlag: json['MatUnit3FactFlag'],
      matSNFlag: json['MatSNFlag'],
      matForceInSN: json['MatForceInSN'],
      matForceOutSN: json['MatForceOutSN'],
      matVAT: json['MatVAT'],
      matDefUnit: json['MatDefUnit'],
      matBranchMask: json['MatBranchMask'],
      matAss: json['MatAss'],
      matOldGUID: json['MatOldGUID']?.toString(),
      matNewGUID: json['MatNewGUID']?.toString(),
      matCalPriceFromDetail: json['MatCalPriceFromDetail'],
      matForceInExpire: json['MatForceInExpire'],
      matForceOutExpire: json['MatForceOutExpire'],
      matCreateDate: DateTime.tryParse(json['MatCreateDate'] ?? '') ?? DateTime.now(),
      matIsIntegerQuantity: json['MatIsIntegerQuantity'],
      matClassFlag: json['MatClassFlag'],
      matForceInClass: json['MatForceInClass'],
      matForceOutClass: json['MatForceOutClass'],
      matDisableLastPrice: json['MatDisableLastPrice'],
      matLastPriceCurVal: double.tryParse(json['MatLastPriceCurVal'].toString()) ?? 0.0,
      matPrevQty: json['MatPrevQty']?.toString(),
      matFirstCostDate: DateTime.now().copyWith(year: 1980, day: 1, month: 1, minute: 0, hour: 0, second: 0),
      matHasSegments: json['MatHasSegments'],
      matParent: json['MatParent']?.toString(),
      matIsCompositionUpdated: json['MatIsCompositionUpdated'],
      matInheritsParentSpecs: json['MatInheritsParentSpecs'],
      matCompositionName: json['MatCompositionName']?.toString(),
      matCompositionLatinName: json['MatCompositionLatinName']?.toString(),
      movedComposite: json['MovedComposite'],
      wholesalePrice: json['Whole2']?.toString(),
      retailPrice: json['retail2']?.toString(),
      endUserPrice: json['EndUser2']?.toString(),
      matVatGuid: json['matVatGuid']?.toString(),
      matExtraBarcode: List.from(json['matExtraBarcode'] ?? []),
      matQuantity: json['MatQuantity'] ?? 0,
      calcMinPrice: json['calcMinPrice'] ?? 0.0,
      serialNumbers: (json['serialNumbers'] is Map) ? Map<String, bool>.from(json['serialNumbers'] as Map) : {},
    );
  }

  // toJson method
  Map<String, dynamic> toJson() => {
        'docId': id,
        'MatCode': matCode,
        'MatName': matName,
        'MatBarCode': matBarCode,
        'MatGroupGuid': matGroupGuid,
        'MatCreateDate': matCreateDate?.toIso8601String(),
        'MatCurrencyVal': matCurrencyVal,
        'MatPictureGuid': matPictureGuid,
        'MatLastPriceCurVal': matLastPriceCurVal,
        'MatPrevQty': matPrevQty,
        'MatCompositionLatinName': matCompositionLatinName,
        'Whole2': wholesalePrice,
        'retail2': retailPrice,
        'EndUser2': endUserPrice,
        'matVatGuid': matVatGuid,
        'matExtraBarcode': matExtraBarcode,
        'MatQuantity': matQuantity,
        'calcMinPrice': calcMinPrice,
        'matLocalQuantity': matLocalQuantity,
        'matFreeQuantity': matFreeQuantity,
        'serialNumbers': serialNumbers,
        'MatUnity': matUnity,
        'MatPriceType': matPriceType,
        'MatBonus': matBonus,
        'MatBonusOne': matBonusOne,
        'MatCurrencyGuid': matCurrencyGuid,
        'MatType': matType,
        'MatSecurity': matSecurity,
        'MatFlag': matFlag,
        'MatExpireFlag': matExpireFlag,
        'MatProdFlag': matProdFlag,
        'MatUnit2FactFlag': matUnit2FactFlag,
        'MatUnit3FactFlag': matUnit3FactFlag,
        'MatSNFlag': matSNFlag,
        'MatForceInSN': matForceInSN,
        'MatForceOutSN': matForceOutSN,
        'MatVAT': matVAT,
        'MatDefUnit': matDefUnit,
        'MatBranchMask': matBranchMask,
        'MatAss': matAss,
        'MatOldGUID': matOldGUID,
        'MatNewGUID': matNewGUID,
        'MatCalPriceFromDetail': matCalPriceFromDetail,
        'MatForceInExpire': matForceInExpire,
        'MatForceOutExpire': matForceOutExpire,
        'MatIsIntegerQuantity': matIsIntegerQuantity,
        'MatClassFlag': matClassFlag,
        'MatForceInClass': matForceInClass,
        'MatForceOutClass': matForceOutClass,
        'MatDisableLastPrice': matDisableLastPrice,
        'MovedComposite': movedComposite,
        'MatFirstCostDate': matFirstCostDate?.toIso8601String(),
        'MatHasSegments': matHasSegments,
        'MatParent': matParent,
        'MatIsCompositionUpdated': matIsCompositionUpdated,
        'MatInheritsParentSpecs': matInheritsParentSpecs,
        'MatCompositionName': matCompositionName,
      };

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(
          title: AppStrings.identificationNumber.tr,
          field: AppConstants.materialIdFiled,
          type: PlutoColumnType.text(),
          hide: true): id,
      createAutoIdColumn(): '#',
      createCheckColumn(): '',
      PlutoColumn(title: AppStrings.materialName, field: 'اسم المادة', type: PlutoColumnType.text(), width: 400):
          matName,
      PlutoColumn(
          title: AppStrings.quantity.tr,
          field: 'الكمية',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): matQuantity,
      PlutoColumn(
          title: AppStrings.mediatorPrice.tr,
          field: 'الوسطي',
          type: PlutoColumnType.currency(
            decimalDigits: 2,
            symbol: '',
          ),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): calcMinPrice,
      PlutoColumn(
          title: AppStrings.lastPayPrice.tr,
          field: 'اخر شراء',
          type: PlutoColumnType.currency(
            decimalDigits: 2,
            symbol: '',
          ),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): matLastPriceCurVal,
      PlutoColumn(
          title: AppStrings.retailPrice.tr,
          field: 'المفرق',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): retailPrice,
      PlutoColumn(
          title: AppStrings.consumer.tr,
          field: 'المستهلك',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): endUserPrice,
      PlutoColumn(
          title: AppStrings.wholesale.tr,
          field: 'الجملة',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): wholesalePrice,
      PlutoColumn(
          title: AppStrings.materialCode,
          field: 'رمز المادة',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): matCode,
      PlutoColumn(
          title: AppStrings.barcode.tr,
          field: 'الباركود',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): matBarCode,
      PlutoColumn(
          title: 'free quantity',
          field: 'free quantity',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): matFreeQuantity,
      PlutoColumn(
          title: 'local quantity',
          field: 'local quantity',
          type: PlutoColumnType.text(),
          width: 120,
          textAlign: PlutoColumnTextAlign.center): matLocalQuantity,
      PlutoColumn(title: AppStrings.group.tr, field: 'المجموعة', type: PlutoColumnType.text()):
          read<MaterialGroupController>().getMaterialGroupById(matGroupGuid!)?.groupName ?? '',
    };
  }

  // CopyWith method
  MaterialModel copyWith({
    final String? id,
    final int? matCode,
    final String? matName,
    final String? matBarCode,
    final String? matGroupGuid,
    final String? matUnity,
    final int? matPriceType,
    final int? matBonus,
    final int? matBonusOne,
    final String? matCurrencyGuid,
    final double? matCurrencyVal,
    final String? matPictureGuid,
    final int? matType,
    final int? matSecurity,
    final int? matFlag,
    final int? matExpireFlag,
    final int? matProdFlag,
    final int? matUnit2FactFlag,
    final int? matUnit3FactFlag,
    final int? matSNFlag,
    final int? matForceInSN,
    final int? matForceOutSN,
    final double? matVAT,
    final int? matDefUnit,
    final int? matBranchMask,
    final int? matAss,
    final String? matOldGUID,
    final String? matNewGUID,
    final int? matCalPriceFromDetail,
    final int? matForceInExpire,
    final int? matForceOutExpire,
    final DateTime? matCreateDate,
    final int? matIsIntegerQuantity,
    final int? matClassFlag,
    final int? matForceInClass,
    final int? matForceOutClass,
    final int? matDisableLastPrice,
    final double? matLastPriceCurVal,
    final String? matPrevQty,
    final DateTime? matFirstCostDate,
    final int? matHasSegments,
    final String? matParent,
    final int? matIsCompositionUpdated,
    final int? matInheritsParentSpecs,
    final String? matCompositionName,
    final String? matCompositionLatinName,
    final int? movedComposite,
    final String? wholesalePrice,
    final String? retailPrice,
    final String? endUserPrice,
    final String? matVatGuid,
    final int? matQuantity,
    final int? matLocalQuantity,
    final int? matFreeQuantity,
    final double? calcMinPrice,
    final Map<String, bool>? serialNumbers,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      matCode: matCode ?? this.matCode,
      matName: matName ?? this.matName,
      matBarCode: matBarCode ?? this.matBarCode,
      matGroupGuid: matGroupGuid ?? this.matGroupGuid,
      matUnity: matUnity ?? this.matUnity,
      matPriceType: matPriceType ?? this.matPriceType,
      matBonus: matBonus ?? this.matBonus,
      matBonusOne: matBonusOne ?? this.matBonusOne,
      matCurrencyGuid: matCurrencyGuid ?? this.matCurrencyGuid,
      matCurrencyVal: matCurrencyVal ?? this.matCurrencyVal,
      matPictureGuid: matPictureGuid ?? this.matPictureGuid,
      matType: matType ?? this.matType,
      matSecurity: matSecurity ?? this.matSecurity,
      matFlag: matFlag ?? this.matFlag,
      matExpireFlag: matExpireFlag ?? this.matExpireFlag,
      matProdFlag: matProdFlag ?? this.matProdFlag,
      matUnit2FactFlag: matUnit2FactFlag ?? this.matUnit2FactFlag,
      matUnit3FactFlag: matUnit3FactFlag ?? this.matUnit3FactFlag,
      matSNFlag: matSNFlag ?? this.matSNFlag,
      matForceInSN: matForceInSN ?? this.matForceInSN,
      matForceOutSN: matForceOutSN ?? this.matForceOutSN,
      matVAT: matVAT ?? this.matVAT,
      matDefUnit: matDefUnit ?? this.matDefUnit,
      matBranchMask: matBranchMask ?? this.matBranchMask,
      matAss: matAss ?? this.matAss,
      matOldGUID: matOldGUID ?? this.matOldGUID,
      matNewGUID: matNewGUID ?? this.matNewGUID,
      matCalPriceFromDetail: matCalPriceFromDetail ?? this.matCalPriceFromDetail,
      matForceInExpire: matForceInExpire ?? this.matForceInExpire,
      matForceOutExpire: matForceOutExpire ?? this.matForceOutExpire,
      matCreateDate: matCreateDate ?? this.matCreateDate,
      matIsIntegerQuantity: matIsIntegerQuantity ?? this.matIsIntegerQuantity,
      matClassFlag: matClassFlag ?? this.matClassFlag,
      matForceInClass: matForceInClass ?? this.matForceInClass,
      matForceOutClass: matForceOutClass ?? this.matForceOutClass,
      matDisableLastPrice: matDisableLastPrice ?? this.matDisableLastPrice,
      matLastPriceCurVal: matLastPriceCurVal ?? this.matLastPriceCurVal,
      matPrevQty: matPrevQty ?? this.matPrevQty,
      matFirstCostDate: matFirstCostDate ?? this.matFirstCostDate,
      matHasSegments: matHasSegments ?? this.matHasSegments,
      matParent: matParent ?? this.matParent,
      matIsCompositionUpdated: matIsCompositionUpdated ?? this.matIsCompositionUpdated,
      matInheritsParentSpecs: matInheritsParentSpecs ?? this.matInheritsParentSpecs,
      matCompositionName: matCompositionName ?? this.matCompositionName,
      matCompositionLatinName: matCompositionLatinName ?? this.matCompositionLatinName,
      movedComposite: movedComposite ?? this.movedComposite,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      retailPrice: retailPrice ?? this.retailPrice,
      endUserPrice: endUserPrice ?? this.endUserPrice,
      matVatGuid: matVatGuid ?? this.matVatGuid,
      matQuantity: matQuantity ?? this.matQuantity,
      calcMinPrice: calcMinPrice ?? this.calcMinPrice,
      serialNumbers: serialNumbers ?? this.serialNumbers,
      matLocalQuantity: matLocalQuantity ?? this.matLocalQuantity,
      matFreeQuantity: matFreeQuantity ?? this.matFreeQuantity,
    );
  }

  @override
  String toString() {
    return 'MaterialModel(id: $id, matName: $matName)';
  }

  String _f10(num? v) => (v ?? 0).toDouble().toStringAsFixed(10);
  String _f2(num? v) => (v ?? 0).toDouble().toStringAsFixed(2);

  String _dateOr1980(DateTime? d) {
    final dt = d ?? DateTime(1980, 1, 1);
    return '${dt.day}-${dt.month}-${dt.year}';
  }


  void toXml(XmlBuilder builder) {
    final unitPrice = double.tryParse(retailPrice ?? '') ?? 0.0;
    final quantity = (matQuantity ?? 0).toDouble();
    final vatRatio = (matVAT ?? 0) / 100;
    final vatValue = unitPrice * vatRatio;
    final subtotal = unitPrice * quantity;
    final profit = unitPrice - vatValue;

    builder.element('MatRec', nest: () {
      builder.element('Name', nest: matName ?? '');
      builder.element('Code', nest: matCode?.toString() ?? '');
      builder.element('Notes');

      builder.element('UnityName', nest: matUnity ?? '');
      builder.element('StoreName', nest: ''); // no store field in model

      builder.element('MatPtr', nest: id ?? '');
      builder.element('StorePtr', nest: matGroupGuid ?? '');

      builder.element('UnitPrice', nest: _f10(unitPrice));
      builder.element('CurVal', nest: _f10(matCurrencyVal));
      builder.element('Quantity', nest: _f10(quantity));

      builder.element('CurBonus', nest: _f10(matBonus));
      builder.element('CurUnit', nest: matDefUnit?.toString() ?? '');
      builder.element('CurUnitFact', nest: _f10(1));

      builder.element('DiscountRatio', nest: _f10(0));
      builder.element('ExtraRatio', nest: _f10(0));
      builder.element('BonusDiscounts', nest: _f10(0));

      builder.element('Profit', nest: _f10(profit));

      builder.element('Length', nest: _f10(0));
      builder.element('Width', nest: _f10(0));
      builder.element('Height', nest: _f10(0));
      builder.element('Count', nest: _f10(0));
      builder.element('Qty2', nest: _f10(0));
      builder.element('Qty3', nest: _f10(0));

      builder.element('Vat', nest: _f10(matVAT));

      builder.element('CostPtr', nest: matVatGuid ?? '');
      builder.element('ClassPtr');

      builder.element('ProdDate', nest: _dateOr1980(matCreateDate));
      builder.element('ExpireDate', nest: _dateOr1980(null));

      builder.element('ProdFlag', nest: (matProdFlag ?? 0).toString());
      builder.element('ExpireFlag', nest: (matExpireFlag ?? 0).toString());
      builder.element('Unit2Flag', nest: (matUnit2FactFlag ?? 0).toString());
      builder.element('Unit3Flag', nest: (matUnit3FactFlag ?? 0).toString());

      builder.element('SNFlag', nest: (matSNFlag ?? 0).toString());
      builder.element('ForceInSN', nest: (matForceInSN ?? 0).toString());
      builder.element('ForceOutSN', nest: (matForceOutSN ?? 0).toString());

      builder.element('guid', nest: matNewGUID ?? id ?? '');

      builder.element('SNReadFlag', nest: (serialNumbers?.isNotEmpty ?? false) ? '1' : '0');
      builder.element('PriceSecViol', nest: (matSecurity ?? 0).toString());
      builder.element('m_SecViol', nest: (matSecurity ?? 0).toString());
      builder.element('m_SOType', nest: (matType ?? 0).toString());
      builder.element('m_SOGuid', nest: matOldGUID ?? '');

      builder.element('BillSubTotal', nest: _f10(subtotal));
      builder.element('TotalBillDisc', nest: _f10(0));
      builder.element('TotalBillExtra', nest: _f10(0));

      builder.element('Assembled', nest: (matAss ?? 0).toString());
      builder.element('Flexible', nest: (matHasSegments ?? 0).toString());
      builder.element('Required', nest: '0');

      builder.element('mtDim');
      builder.element('mtOrigin');
      builder.element('mtPos');
      builder.element('mtCompany');
      builder.element('mtColor');
      builder.element('mtProvenance');

      builder.element('Barcode', nest: matBarCode ?? '');

      builder.element('mtQuality');
      builder.element('mtModel');

      builder.element('bPrintInBill', nest: '1'); // no field exists
      builder.element('bPrintPriceInBill', nest: '1'); // no field exists
      builder.element('bSharedFld', nest: (matFlag ?? 0).toString());

      builder.element('mtParentGuid', nest: matParent ?? '');

      builder.element('VatRatio', nest: _f10(matVAT));
      builder.element('mtVatRatio', nest: _f10(0));
      builder.element('mtType', nest: (matType ?? 0).toString());
      builder.element('ClassPrice', nest: _f10(calcMinPrice));
      builder.element('mtClassFlag', nest: (matClassFlag ?? 0).toString());
      builder.element('mtItemNumer', nest: matQuantity?.toString() ?? '0');

      builder.element('MatCardVATTaxCode', nest: matVAT?.toString() ?? '');
      builder.element('MatCardVATTaxRatio', nest: _f2(matVAT));
      builder.element('MatCardExciseTaxCode', nest: '');
      builder.element('MatCardExciseTaxRatio', nest: '0.00');
      builder.element('MatCardIsProfitMargin', nest: '0');
      builder.element('BillItemTaxCode', nest: matVAT?.toString() ?? '');

      builder.element('BillCurrencyGuid', nest: matCurrencyGuid ?? '');

      builder.element('CompositionName', nest: matCompositionName ?? '');
    });
  }




  factory MaterialModel.fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final mat = document.findAllElements('MatRec').first;

    String text(String name) =>
        mat.getElement(name)?.innerText.trim() ?? '';

    int? intVal(String name) {
      final v = text(name);
      return v.isEmpty ? null : int.tryParse(v);
    }

    double? doubleVal(String name) {
      final v = text(name);
      return v.isEmpty ? null : double.tryParse(v);
    }

    DateTime? dateVal(String name) {
      final v = text(name);
      if (v.isEmpty || v == '1-1-1980') return null;
      return DateTime.tryParse(v);
    }

    return MaterialModel(
      id: text('MatPtr').isEmpty ? null : text('MatPtr'),
      matName: text('Name'),
      matCode: intVal('Code'),
      matUnity: text('UnityName'),
      matBarCode: text('Barcode'),
      matLastPriceCurVal: doubleVal('UnitPrice'),
      matQuantity: doubleVal('Quantity')?.toInt(),
      matVAT: doubleVal('Vat'),
      matCreateDate: dateVal('ProdDate'),
      matProdFlag: intVal('ProdFlag'),
      matExpireFlag: intVal('ExpireFlag'),
      matUnit2FactFlag: intVal('Unit2Flag'),
      matUnit3FactFlag: intVal('Unit3Flag'),
      matSNFlag: intVal('SNFlag'),
      matForceInSN: intVal('ForceInSN'),
      matForceOutSN: intVal('ForceOutSN'),
      matNewGUID: text('guid').isEmpty ? null : text('guid'),
    );
  }


}

@HiveType(typeId: 1)
class MatExtraBarcodeModel extends HiveObject {
  @HiveField(0)
  final String? barcode;

  @HiveField(1)
  final String? description;

  MatExtraBarcodeModel({
    this.barcode,
    this.description,
  });

  factory MatExtraBarcodeModel.fromJson(Map<String, dynamic> json) {
    return MatExtraBarcodeModel(
      barcode: json['barcode']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class SerialNumberModel {
  final String? serialNumber;
  final String? matId; // Foreign key linking to MaterialModel.id
  final String? matName;
  final List<SerialTransactionModel> transactions; // List of buy/sell records

  SerialNumberModel({
    this.serialNumber,
    this.matId,
    this.matName,
    required this.transactions,
  });

  /// Factory constructor to create a SerialNumberModel from JSON safely.
  factory SerialNumberModel.fromJson(Map<String, dynamic> json) {

    return SerialNumberModel(
      serialNumber: json.containsKey('docId') ? json['docId'] as String? : null,
      matId: json.containsKey('matId') ? json['matId'] as String? : null,
      matName: json.containsKey('matName') ? json['matName'] as String? : null,
      transactions: json.containsKey('transactions')
          ? (json['transactions'] as List<dynamic>?)?.map((e) => SerialTransactionModel.fromJson(e)).toList() ?? []
          : [],
    );
  }

  /// Convert a SerialNumberModel to JSON without null properties.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (serialNumber != null) data['docId'] = serialNumber;
    if (matId != null) data['matId'] = matId;
    if (matName != null) data['matName'] = matName;
    if (transactions.isNotEmpty) {
      data['transactions'] = transactions.map((e) => e.toJson()).toList();
    }
    return data;
  }

  /// Creates a new instance with updated properties.
  SerialNumberModel copyWith({
    String? serialNumber,
    String? matId,
    String? matName,
    List<SerialTransactionModel>? transactions,
  }) {
    return SerialNumberModel(
      serialNumber: serialNumber ?? this.serialNumber,
      matId: matId ?? this.matId,
      matName: matName ?? this.matName,
      transactions: transactions ?? this.transactions,
    );
  }
}

class SerialTransactionModel implements PlutoAdaptable {
  final String? buyBillId;
  final int? buyBillNumber;
  final String? buyBillTypeId;
  final String? sellBillId;
  final int? sellBillNumber;
  final String? sellBillTypeId;
  final DateTime? entryDate;
  final bool? sold;
  final SerialTransactionOrigin? transactionOrigin;

  SerialTransactionModel({
    this.buyBillId,
    this.buyBillNumber,
    this.buyBillTypeId,
    this.sellBillId,
    this.sellBillNumber,
    this.sellBillTypeId,
    this.entryDate,
    this.sold,
    this.transactionOrigin,
  });

  /// Factory constructor to create a SerialTransactionModel from JSON safely.
  factory SerialTransactionModel.fromJson(Map<String, dynamic> json) {
    return SerialTransactionModel(
      buyBillId: json.containsKey('buyBillId') ? json['buyBillId'] as String? : null,
      buyBillNumber: json.containsKey('buyBillNumber') ? json['buyBillNumber'] as int? : null,
      buyBillTypeId: json.containsKey('buyBillTypeId') ? json['buyBillTypeId'] as String? : null,
      sellBillId: json.containsKey('sellBillId') ? json['sellBillId'] as String? : null,
      sellBillNumber: json.containsKey('sellBillNumber') ? json['sellBillNumber'] as int? : null,
      sellBillTypeId: json.containsKey('sellBillTypeId') ? json['sellBillTypeId'] as String? : null,
      entryDate: json.containsKey('entryDate') && json['entryDate'] != null
          ? DateTime.tryParse(json['entryDate'] as String)
          : null,
      sold: json.containsKey('sold') ? json['sold'] as bool? : null,
      transactionOrigin: json.containsKey('transactionOrigin') && json['transactionOrigin'] != null
          ? SerialTransactionOrigin.fromJson(json['transactionOrigin'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert a SerialTransactionModel to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (buyBillId != null) 'buyBillId': buyBillId,
      if (buyBillNumber != null) 'buyBillNumber': buyBillNumber,
      if (buyBillTypeId != null) 'buyBillTypeId': buyBillTypeId,
      if (sellBillId != null) 'sellBillId': sellBillId,
      if (sellBillNumber != null) 'sellBillNumber': sellBillNumber,
      if (sellBillTypeId != null) 'sellBillTypeId': sellBillTypeId,
      if (entryDate != null) 'entryDate': entryDate!.toIso8601String(),
      if (sold != null) 'sold': sold,
      if (transactionOrigin != null) 'transactionOrigin': transactionOrigin?.toJson(),
    };
  }

  /// Creates a new instance with updated properties while keeping existing ones.
  SerialTransactionModel copyWith({
    String? buyBillId,
    int? buyBillNumber,
    String? buyBillTypeId,
    String? sellBillId,
    int? sellBillNumber,
    String? sellBillTypeId,
    DateTime? entryDate,
    bool? sold,
    final SerialTransactionOrigin? transactionOrigin,
  }) {
    return SerialTransactionModel(
      buyBillId: buyBillId ?? this.buyBillId,
      buyBillNumber: buyBillNumber ?? this.buyBillNumber,
      buyBillTypeId: buyBillTypeId ?? this.buyBillTypeId,
      sellBillId: sellBillId ?? this.sellBillId,
      sellBillNumber: sellBillNumber ?? this.sellBillNumber,
      sellBillTypeId: sellBillTypeId ?? this.sellBillTypeId,
      entryDate: entryDate ?? this.entryDate,
      sold: sold ?? this.sold,
      transactionOrigin: transactionOrigin ?? this.transactionOrigin,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([_]) {
    return {
      // Visible column for the serial number.
      PlutoColumn(title: AppStrings.serialNumber.tr, field: 'serialNumber', type: PlutoColumnType.text()):
          transactionOrigin?.serialNumber ?? '',

      // Hidden column for the material ID.
      PlutoColumn(hide: true, title: 'معرف المادة', field: 'matId', type: PlutoColumnType.text()):
          transactionOrigin?.matId ?? '',

      // Hidden column for the material ID.
      PlutoColumn(title: AppStrings.materialName.tr, field: 'matName', type: PlutoColumnType.text()):
          transactionOrigin?.matName ?? '',

      // Column for the buy bill ID.
      PlutoColumn(hide: true, title: 'buyBillId', field: 'buyBillId', type: PlutoColumnType.text()): buyBillId ?? '',

      // Column for the buy bill ID.
      PlutoColumn(hide: true, title: 'buyBillTypeId', field: 'buyBillTypeId', type: PlutoColumnType.text()):
          buyBillTypeId ?? '',

      PlutoColumn(title: AppStrings.purchaseBill.tr, field: AppStrings.purchaseBill.tr, type: PlutoColumnType.text()):
          AppServiceUtils.billNameAndNumberFormat(buyBillTypeId, buyBillNumber),

      // Column for the sell bill ID.
      PlutoColumn(hide: true, title: 'sellBillId', field: 'sellBillId', type: PlutoColumnType.text()): sellBillId ?? '',

      // Column for the buy bill ID.
      PlutoColumn(hide: true, title: 'sellBillTypeId', field: 'sellBillTypeId', type: PlutoColumnType.text()):
          sellBillTypeId ?? '',

      PlutoColumn(title: AppStrings.salesBill.tr, field: AppStrings.salesBill.tr, type: PlutoColumnType.text()):
          AppServiceUtils.billNameAndNumberFormat(sellBillTypeId, sellBillNumber),

      // Column for the entry date.
      PlutoColumn(title: AppStrings.entryDate.tr, field: 'entryDate', type: PlutoColumnType.date()): entryDate,

      // Column for the sold status (displaying a simple "Yes/No").
      PlutoColumn(title: AppStrings.sold.tr, field: 'sold', type: PlutoColumnType.text()):
          sold == true ? AppStrings.yes.tr : AppStrings.no.tr,
    };
  }
}

class SerialTransactionOrigin {
  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? serialNumber;

  /// Refers to the origin entity type id of the bond entry (e.g., billTypeId for bills).
  final String? matId;

  final String? matName;

  SerialTransactionOrigin({this.serialNumber, this.matId, this.matName});

  factory SerialTransactionOrigin.fromJson(Map<String, dynamic> json) {
    return SerialTransactionOrigin(
      serialNumber: json['serialNumber'] as String?,
      matId: json['matId'] as String?,
      matName: json['matName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'matId': matId,
      'matName': matName,
    };
  }

  SerialTransactionOrigin copyWith({
    String? serialNumber,
    String? matId,
    String? matName,
  }) {
    return SerialTransactionOrigin(
      serialNumber: serialNumber ?? this.serialNumber,
      matId: matId ?? this.matId,
      matName: matName ?? this.matName,
    );
  }
}