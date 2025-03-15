import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/widgets/pluto_auto_id_column.dart';

class ChequesModel implements PlutoAdaptable {
  final String? chequesTypeGuid;
  final int? chequesNumber;
  final int? chequesNum;
  final String? chequesGuid;
  final String? chequesDate;
  final String? chequesDueDate;
  final String? chequesNote;
  final double? chequesVal;
  final String? chequesAccount2Guid;
  final String? accPtr;
  final String? accPtrName;
  final String? chequesAccount2Name;
  final String? chequesPayGuid;
  final String? chequesRefundPayGuid;
  final String? chequesPayDate;
  final String? chequesRefundPayDate;

  // final ChequesCollectEntryModel? chequesCollectEntry;
  // final ChequesEntryRelationModel? chequesEntryRelation;

  final bool? isPayed;
  final bool? isRefund;

  // final String? chequesCustomerGuid;
  // final String? chequesCurGuid;

  // final double chequesCurVal;
  // final int chequesSec;
  // final int chequesPrevNum;
  // final String chequesOrgName;
  // final String chequesIntNum;
  // final String chequesIntFile;
  // final String chequesExtFile;
  // final String chequesFileDate;
  // final String chequesCost1Guid;
  // final String chequesCost2Guid;
  // final int chequesState;
  // final String chequesColDate;
  // final String chequesBankGuid;
  // final String chequesBrGuid;
  // final int chequesDir;
  // final String chequesParentGuid;

  const ChequesModel({
    this.chequesTypeGuid,
    this.chequesNumber,
    this.chequesNum,
    this.chequesGuid,
    this.chequesDate,
    this.chequesDueDate,
    this.chequesNote,
    this.chequesVal,
    this.accPtr,
    this.chequesAccount2Guid,
    this.chequesAccount2Name,
    this.accPtrName,
    this.isPayed,
    this.chequesPayGuid,
    this.chequesRefundPayGuid,
    this.isRefund,
    this.chequesPayDate,
    this.chequesRefundPayDate,
    // this.chequesCollectEntry,
    // this.chequesEntryRelation,
    // this.chequesCustomerGuid,

    // this.chequesCurGuid,
    // required this.chequesCurVal,
    // required this.chequesSec,
    // required this.chequesPrevNum,
    // required this.chequesOrgName,
    // required this.chequesIntNum,
    // required this.chequesIntFile,
    // required this.chequesExtFile,
    // required this.chequesFileDate,
    // required this.chequesCost1Guid,
    // required this.chequesCost2Guid,
    // required this.chequesState,
    // required this.chequesColDate,
    // required this.chequesBankGuid,
    // required this.chequesBrGuid,
    // required this.chequesDir,
    // required this.chequesParentGuid,
  });

  // fromJson constructor
  factory ChequesModel.fromJson(Map<String, dynamic> json) {
    return ChequesModel(
      chequesTypeGuid: json['ChequesTypeGuid'] as String?,
      chequesNumber: json['ChequesNumber'] as int?,
      chequesNum: json['ChequesNum'] as int?,
      chequesGuid: json['docId'] as String?,
      accPtrName: json['AccPtrName'] as String?,
      chequesAccount2Name: json['ChequesAccount2Name'] as String?,
      chequesDate: json['ChequesDate'] as String?,
      chequesDueDate: json['ChequesDueDate'] as String?,
      chequesNote: json['ChequesNote'] as String?,
      chequesVal: (json['ChequesVal'] as num).toDouble(),
      chequesAccount2Guid: json['ChequesAccount2Guid'] as String?,
      chequesPayGuid: json['ChequesPayGuid'] as String?,
      chequesRefundPayGuid: json['ChequesRefundPayGuid'] as String?,
      accPtr: json['AccPtr'] as String?,
      chequesPayDate: json['ChequesPayDate'] as String?,
      chequesRefundPayDate: json['ChequesRefundPayDate'] as String?,
      isPayed: json['IsPayed'] as bool?,
      isRefund: json['IsRefund'] as bool?,
      // chequesCollectEntry: json['ChequesCollectEntry'] != null ? ChequesCollectEntryModel.fromJson(json['ChequesCollectEntry']) : null,
      // chequesEntryRelation: json['chequesEntryRelation'] != null ? ChequesEntryRelationModel.fromJson(json['chequesEntryRelation']) : null,

      // chequesCustomerGuid: json['ChequesCustomerGuid'] as String,

      // chequesCurGuid: json['ChequesCurGuid'] as String,

      // chequesCurVal: (json['ChequesCurVal'] as num).toDouble(),
      // chequesSec: json['ChequesSec'] as int,
      // chequesPrevNum: json['ChequesPrevNum'] as int,
      // chequesOrgName: json['ChequesOrgName'] as String,
      // chequesIntNum: json['ChequesIntNum'] as String,
      // chequesIntFile: json['ChequesIntFile'] as String,
      // chequesExtFile: json['ChequesExtFile'] as String,
      // chequesFileDate: json['ChequesFileDate'] as String,
      // chequesCost1Guid: json['ChequesCost1Guid'] as String,
      // chequesCost2Guid: json['ChequesCost2Guid'] as String,
      // chequesState: json['ChequesState'] as int,
      // chequesColDate: json['ChequesColDate'] as String,
      // chequesBankGuid: json['ChequesBankGuid'] as String,
      // chequesBrGuid: json['ChequesBrGuid'] as String,
      // chequesDir: json['ChequesDir'] as int,
      // chequesParentGuid: json['ChequesParentGuid'] as String,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'ChequesTypeGuid': chequesTypeGuid,
      'ChequesNumber': chequesNumber,
      'ChequesNum': chequesNum,
      'docId': chequesGuid,
      'ChequesDate': chequesDate,
      'ChequesDueDate': chequesDueDate,
      'ChequesNote': chequesNote,
      'ChequesVal': chequesVal,
      'ChequesAccount2Guid': chequesAccount2Guid,
      'AccPtr': accPtr,
      'IsPayed': isPayed,
      'AccPtrName': accPtrName,
      'ChequesAccount2Name': chequesAccount2Name,
      'ChequesPayGuid': chequesPayGuid,
      'ChequesRefundPayGuid': chequesRefundPayGuid,
      'IsRefund': isRefund,
      'ChequesRefundPayDate': chequesRefundPayDate,
      'chequesPayDate': chequesPayDate,
      // 'ChequesCollectEntry': chequesCollectEntry?.toJson(),
      // 'ChequesEntryRelation': chequesEntryRelation?.toJson(),
      // 'ChequesCustomerGuid': chequesCustomerGuid,
      // 'ChequesCurGuid': chequesCurGuid,
      // 'ChequesCurVal': chequesCurVal,
      // 'ChequesSec': chequesSec,
      // 'ChequesPrevNum': chequesPrevNum,
      // 'ChequesOrgName': chequesOrgName,
      // 'ChequesIntNum': chequesIntNum,
      // 'ChequesIntFile': chequesIntFile,
      // 'ChequesExtFile': chequesExtFile,
      // 'ChequesFileDate': chequesFileDate,
      // 'ChequesCost1Guid': chequesCost1Guid,
      // 'ChequesCost2Guid': chequesCost2Guid,
      // 'ChequesState': chequesState,
      // 'ChequesColDate': chequesColDate,
      // 'ChequesBankGuid': chequesBankGuid,
      // 'ChequesBrGuid': chequesBrGuid,
      // 'ChequesDir': chequesDir,
      // 'ChequesParentGuid': chequesParentGuid,
    };
  }

  // copyWith method
  ChequesModel copyWith({
    String? chequesTypeGuid,
    int? chequesNumber,
    int? chequesNum,
    String? chequesGuid,
    String? chequesDate,
    String? chequesDueDate,
    String? chequesNote,
    double? chequesVal,
    bool? isPayed,
    String? chequesAccount2Guid,
    String? accPtr,
    String? accPtrName,
    String? chequesAccount2Name,
    String? chequesPayGuid,
    String? chequesRefundPayGuid,
    String? chequesPayDate,
    String? chequesRefundPayDate,
    bool? isRefund,
    // String? chequesCustomerGuid,
    // ChequesCollectEntryModel? chequesCollectEntry,
    // ChequesEntryRelationModel? chequesEntryRelation,
    // String? chequesCurGuid,
    // String? chequesParentGuid,
    // String? chequesBrGuid,
    // int? chequesDir,
    // String? chequesColDate,
    // String? chequesBankGuid,
    // double? chequesCurVal,
    // int? chequesSec,
    // int? chequesPrevNum,
    // String? chequesOrgName,
    // String? chequesIntNum,
    // String? chequesIntFile,
    // String? chequesExtFile,
    // String? chequesFileDate,
    // String? chequesCost1Guid,
    // int? chequesState,
    // String? chequesCost2Guid,
  }) {
    return ChequesModel(
      chequesTypeGuid: chequesTypeGuid ?? this.chequesTypeGuid,
      chequesNumber: chequesNumber ?? this.chequesNumber,
      chequesNum: chequesNum ?? this.chequesNum,
      chequesGuid: chequesGuid ?? this.chequesGuid,
      chequesDate: chequesDate ?? this.chequesDate,
      chequesDueDate: chequesDueDate ?? this.chequesDueDate,
      chequesNote: chequesNote ?? this.chequesNote,
      chequesVal: chequesVal ?? this.chequesVal,
      chequesAccount2Guid: chequesAccount2Guid ?? this.chequesAccount2Guid,
      accPtr: accPtr ?? this.accPtr,
      accPtrName: accPtrName ?? this.accPtrName,
      chequesAccount2Name: chequesAccount2Name ?? this.chequesAccount2Name,
      isPayed: isPayed ?? this.isPayed,
      chequesPayGuid: chequesPayGuid ?? this.chequesPayGuid,
      chequesRefundPayGuid: chequesRefundPayGuid ?? this.chequesRefundPayGuid,
      isRefund: isRefund ?? this.isRefund,
      chequesPayDate: chequesPayDate ?? this.chequesPayDate,
      chequesRefundPayDate: chequesRefundPayDate ?? this.chequesRefundPayDate,

      // chequesCollectEntry: chequesCollectEntry ?? this.chequesCollectEntry,
      // chequesEntryRelation: chequesEntryRelation ?? this.chequesEntryRelation,
      // chequesCustomerGuid: chequesCustomerGuid ?? this.chequesCustomerGuid,
      // chequesCurGuid: chequesCurGuid ?? this.chequesCurGuid,
      // chequesParentGuid: chequesParentGuid ?? this.chequesParentGuid,
      // chequesDir: chequesDir ?? this.chequesDir,
      // chequesBrGuid: chequesBrGuid ?? this.chequesBrGuid,
      // chequesColDate: chequesColDate ?? this.chequesColDate,
      // chequesBankGuid: chequesBankGuid ?? this.chequesBankGuid,
      // chequesCurVal: chequesCurVal ?? this.chequesCurVal,
      // chequesSec: chequesSec ?? this.chequesSec,
      // chequesPrevNum: chequesPrevNum ?? this.chequesPrevNum,
      // chequesOrgName: chequesOrgName ?? this.chequesOrgName,
      // chequesIntNum: chequesIntNum ?? this.chequesIntNum,
      // chequesIntFile: chequesIntFile ?? this.chequesIntFile,
      // chequesExtFile: chequesExtFile ?? this.chequesExtFile,
      // chequesFileDate: chequesFileDate ?? this.chequesFileDate,
      // chequesCost1Guid: chequesCost1Guid ?? this.chequesCost1Guid,
      // chequesCost2Guid: chequesCost2Guid ?? this.chequesCost2Guid,
      // chequesState: chequesState ?? this.chequesState,
    );
  }

  ChequesModel copyWithNullPayGuid() {
    return ChequesModel(
      chequesTypeGuid: chequesTypeGuid,
      chequesNumber: chequesNumber,
      chequesNum: chequesNum,
      chequesGuid: chequesGuid,
      chequesDate: chequesDate,
      chequesDueDate: chequesDueDate,
      chequesNote: chequesNote,
      chequesVal: chequesVal,
      chequesAccount2Guid: chequesAccount2Guid,
      accPtr: accPtr,
      accPtrName: accPtrName,
      chequesAccount2Name: chequesAccount2Name,
      chequesRefundPayGuid: chequesRefundPayGuid,
      isRefund: isRefund,
      chequesPayGuid: null,
      isPayed: false,
      chequesPayDate: null,
      chequesRefundPayDate: chequesRefundPayDate,
    );
  }

  ChequesModel copyWithNullRefundPayGuid() {
    return ChequesModel(
      chequesTypeGuid: chequesTypeGuid,
      chequesNumber: chequesNumber,
      chequesNum: chequesNum,
      chequesGuid: chequesGuid,
      chequesDate: chequesDate,
      chequesDueDate: chequesDueDate,
      chequesNote: chequesNote,
      chequesVal: chequesVal,
      chequesAccount2Guid: chequesAccount2Guid,
      accPtr: accPtr,
      accPtrName: accPtrName,
      chequesAccount2Name: chequesAccount2Name,
      chequesRefundPayGuid: null,
      isRefund: false,
      chequesPayGuid: chequesPayGuid,
      isPayed: isPayed,
      chequesPayDate: chequesPayDate,
      chequesRefundPayDate: null,
    );
  }

  factory ChequesModel.empty({required ChequesType chequesType, int lastChequesNumber = 0}) {
    return ChequesModel(
      chequesNumber: lastChequesNumber + 1,
      chequesTypeGuid: chequesType.typeGuide,
      chequesAccount2Guid: AppConstants.chequeToAccountId,
      accPtrName: AppConstants.chequeToAccountName,
      isPayed: false,
      chequesDate: DateTime.now().toString(),
      chequesDueDate: DateTime.now().toString(),
    );
  }

  static ChequesModel? fromChequesData({
    ChequesModel? chequesModel,
    required ChequesType chequesType,
    required String chequesTypeGuid,
    required int chequesNum,
    required String chequesDate,
    required String chequesDueDate,
    required String chequesNote,
    required double chequesVal,
    required String chequesAccount2Guid,
    required String accPtr,
    required String accPtrName,
    required String chequesAccount2Name,
    required bool isPayed,
    required bool isRefund,
    String? chequesPayGuid,
    String? chequesRefundPayGuid,
  }) {
    return chequesModel == null
        ? ChequesModel(
            chequesDate: chequesDate,
            chequesTypeGuid: chequesTypeGuid,
            chequesAccount2Guid: chequesAccount2Guid,
            chequesDueDate: chequesDueDate,
            chequesNum: chequesNum,
            chequesVal: chequesVal,
            chequesNote: chequesNote,
            accPtr: accPtr,
            accPtrName: accPtrName,
            chequesAccount2Name: chequesAccount2Name,
            isPayed: isPayed,
            isRefund: isRefund,
            chequesPayGuid: chequesPayGuid,
            chequesRefundPayGuid: chequesRefundPayGuid,
          )
        : chequesModel.copyWith(
            chequesDate: chequesDate,
            chequesTypeGuid: chequesTypeGuid,
            chequesAccount2Guid: chequesAccount2Guid,
            chequesDueDate: chequesDueDate,
            chequesNum: chequesNum,
            chequesVal: chequesVal,
            accPtr: accPtr,
            isPayed: isPayed,
            isRefund: isRefund,
            accPtrName: accPtrName,
            chequesAccount2Name: chequesAccount2Name,
            chequesNote: chequesNote,
            chequesPayGuid: chequesPayGuid,
            chequesRefundPayGuid: chequesRefundPayGuid,
          );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(title: "رقم القيد", field: AppConstants.chequesGuid, type: PlutoColumnType.text(), hide: true): chequesGuid,
      createAutoIdColumn(): '#',
      PlutoColumn(title: "الرقم التسلسلي", field: AppConstants.chequesNumber, type: PlutoColumnType.number()): chequesNumber,
      PlutoColumn(title: "رقم الشيك", field: AppConstants.chequesNum, type: PlutoColumnType.number()): chequesNumber,
      PlutoColumn(
          title: "قيمة الشيك",
          field: AppConstants.chequesVal,
          type: PlutoColumnType.currency(
            format: '#,##0.00 AED',
            locale: 'en_AE',
            symbol: 'AED',
          )): chequesVal,
      PlutoColumn(title: "الحساب", field: AppConstants.chequesAccount2Guid, type: PlutoColumnType.text()): chequesAccount2Name,
      PlutoColumn(title: "دفع الى", field: AppConstants.accPtr, type: PlutoColumnType.text()): accPtrName,
      PlutoColumn(title: "تاريخ التحرير", field: AppConstants.chequesDate, type: PlutoColumnType.date()): chequesDate.toDate,
      PlutoColumn(title: "تاريخ الاستحقاق", field: AppConstants.chequesDueDate, type: PlutoColumnType.date()): chequesDueDate.toDate,
      PlutoColumn(title: "البيان", field: AppConstants.chequesNote, type: PlutoColumnType.text()): chequesNote,
      PlutoColumn(title: "نوع الشيك", field: AppConstants.chequesTypeGuid, type: PlutoColumnType.text()):
          ChequesType.byTypeGuide(chequesTypeGuid!).value,
      PlutoColumn(
        title: "الحالة",
        field: AppConstants.isPayed,
        type: PlutoColumnType.text(),
      ): isPayed! ? ChequesStatus.paid.label : ChequesStatus.notPaid.label,
    };
  }
}