import 'package:ba3_bs/core/helper/enums/enums.dart';

import 'check_collect_entry_model.dart';
import 'check_entry_relation_model.dart';

class ChequesModel {
  final String? checkTypeGuid;
  final int? checkNumber;
  final int? checkNum;
  final String? checkGuid;

  final String? accPtr;
  final String? checkDate;
  final String? checkDueDate;

  final String? checkNote;
  final double? checkVal;

  //TODO
  final String? checkCurGuid;

  final String? checkAccount2Guid;
  final String? checkCustomerGuid;
  final CheckCollectEntryModel? checkCollectEntry;
  final CheckEntryRelationModel? checkEntryRelation;

  // final double checkCurVal;
  // final int checkSec;
  // final int checkPrevNum;
  // final String checkOrgName;
  // final String checkIntNum;
  // final String checkIntFile;
  // final String checkExtFile;
  // final String checkFileDate;
  // final String checkCost1Guid;
  // final String checkCost2Guid;
  // final int checkState;
  // final String checkColDate;
  // final String checkBankGuid;
  // final String checkBrGuid;
  // final int checkDir;
  // final String checkParentGuid;

  const ChequesModel({
     this.checkTypeGuid,
     this.checkNumber,
     this.checkNum,
     this.checkGuid,
     this.accPtr,
     this.checkDate,
     this.checkDueDate,
     this.checkNote,
     this.checkVal,
     this.checkCurGuid,
     this.checkAccount2Guid,
     this.checkCustomerGuid,
     this.checkCollectEntry,
     this.checkEntryRelation,
    // required this.checkCurVal,
    // required this.checkSec,
    // required this.checkPrevNum,
    // required this.checkOrgName,
    // required this.checkIntNum,
    // required this.checkIntFile,
    // required this.checkExtFile,
    // required this.checkFileDate,
    // required this.checkCost1Guid,
    // required this.checkCost2Guid,
    // required this.checkState,
    // required this.checkColDate,
    // required this.checkBankGuid,
    // required this.checkBrGuid,
    // required this.checkDir,
    // required this.checkParentGuid,
  });

  // fromJson constructor
  factory ChequesModel.fromJson(Map<String, dynamic> json) {
    return ChequesModel(
      checkTypeGuid: json['CheckTypeGuid'] as String,
      checkNumber: json['CheckNumber'] as int,
      checkNum: json['CheckNum'] as int,
      checkGuid: json['CheckGuid'] as String,
      accPtr: json['AccPtr'] as String,
      checkDate: json['CheckDate'] as String,
      checkDueDate: json['CheckDueDate'] as String,
      checkNote: json['CheckNote'] as String,
      checkVal: (json['CheckVal'] as num).toDouble(),
      checkCurGuid: json['CheckCurGuid'] as String,
      checkAccount2Guid: json['CheckAccount2Guid'] as String,
      checkCustomerGuid: json['CheckCustomerGuid'] as String,
      checkCollectEntry: CheckCollectEntryModel.fromJson(json['CheckCollectEntry']),
      checkEntryRelation: CheckEntryRelationModel.fromJson(json['CheckEntryRelation']),
      // checkCurVal: (json['CheckCurVal'] as num).toDouble(),
      // checkSec: json['CheckSec'] as int,
      // checkPrevNum: json['CheckPrevNum'] as int,
      // checkOrgName: json['CheckOrgName'] as String,
      // checkIntNum: json['CheckIntNum'] as String,
      // checkIntFile: json['CheckIntFile'] as String,
      // checkExtFile: json['CheckExtFile'] as String,
      // checkFileDate: json['CheckFileDate'] as String,
      // checkCost1Guid: json['CheckCost1Guid'] as String,
      // checkCost2Guid: json['CheckCost2Guid'] as String,
      // checkState: json['CheckState'] as int,
      // checkColDate: json['CheckColDate'] as String,
      // checkBankGuid: json['CheckBankGuid'] as String,
      // checkBrGuid: json['CheckBrGuid'] as String,
      // checkDir: json['CheckDir'] as int,
      // checkParentGuid: json['CheckParentGuid'] as String,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'CheckTypeGuid': checkTypeGuid,
      'CheckNumber': checkNumber,
      'CheckNum': checkNum,
      'CheckGuid': checkGuid,
      'AccPtr': accPtr,
      'CheckDate': checkDate,
      'CheckDueDate': checkDueDate,
      'CheckNote': checkNote,
      'CheckVal': checkVal,
      'CheckCurGuid': checkCurGuid,
      'CheckAccount2Guid': checkAccount2Guid,
      'CheckCustomerGuid': checkCustomerGuid,
      'CheckCollectEntry': checkCollectEntry?.toJson(),
      'CheckEntryRelation': checkEntryRelation?.toJson(),
      // 'CheckCurVal': checkCurVal,
      // 'CheckSec': checkSec,
      // 'CheckPrevNum': checkPrevNum,
      // 'CheckOrgName': checkOrgName,
      // 'CheckIntNum': checkIntNum,
      // 'CheckIntFile': checkIntFile,
      // 'CheckExtFile': checkExtFile,
      // 'CheckFileDate': checkFileDate,
      // 'CheckCost1Guid': checkCost1Guid,
      // 'CheckCost2Guid': checkCost2Guid,
      // 'CheckState': checkState,
      // 'CheckColDate': checkColDate,
      // 'CheckBankGuid': checkBankGuid,
      // 'CheckBrGuid': checkBrGuid,
      // 'CheckDir': checkDir,
      // 'CheckParentGuid': checkParentGuid,
    };
  }

  // copyWith method
  ChequesModel copyWith({
    String? checkTypeGuid,
    int? checkNumber,
    int? checkNum,
    String? checkGuid,
    String? accPtr,
    String? checkDate,
    String? checkDueDate,
    String? checkNote,
    double? checkVal,
    String? checkCurGuid,
    String? checkAccount2Guid,
    String? checkCustomerGuid,
    CheckCollectEntryModel? checkCollectEntry,
    CheckEntryRelationModel? checkEntryRelation,
    // String? checkParentGuid,
    // String? checkBrGuid,
    // int? checkDir,
    // String? checkColDate,
    // String? checkBankGuid,
    // double? checkCurVal,
    // int? checkSec,
    // int? checkPrevNum,
    // String? checkOrgName,
    // String? checkIntNum,
    // String? checkIntFile,
    // String? checkExtFile,
    // String? checkFileDate,
    // String? checkCost1Guid,
    // int? checkState,
    // String? checkCost2Guid,
  }) {
    return ChequesModel(
      checkTypeGuid: checkTypeGuid ?? this.checkTypeGuid,
      checkNumber: checkNumber ?? this.checkNumber,
      checkNum: checkNum ?? this.checkNum,
      checkGuid: checkGuid ?? this.checkGuid,
      accPtr: accPtr ?? this.accPtr,
      checkDate: checkDate ?? this.checkDate,
      checkDueDate: checkDueDate ?? this.checkDueDate,
      checkNote: checkNote ?? this.checkNote,
      checkVal: checkVal ?? this.checkVal,
      checkCurGuid: checkCurGuid ?? this.checkCurGuid,
      checkAccount2Guid: checkAccount2Guid ?? this.checkAccount2Guid,
      checkCustomerGuid: checkCustomerGuid ?? this.checkCustomerGuid,
      checkCollectEntry: checkCollectEntry ?? this.checkCollectEntry,
      checkEntryRelation: checkEntryRelation ?? this.checkEntryRelation,
      // checkParentGuid: checkParentGuid ?? this.checkParentGuid,
      // checkDir: checkDir ?? this.checkDir,
      // checkBrGuid: checkBrGuid ?? this.checkBrGuid,
      // checkColDate: checkColDate ?? this.checkColDate,
      // checkBankGuid: checkBankGuid ?? this.checkBankGuid,
      // checkCurVal: checkCurVal ?? this.checkCurVal,
      // checkSec: checkSec ?? this.checkSec,
      // checkPrevNum: checkPrevNum ?? this.checkPrevNum,
      // checkOrgName: checkOrgName ?? this.checkOrgName,
      // checkIntNum: checkIntNum ?? this.checkIntNum,
      // checkIntFile: checkIntFile ?? this.checkIntFile,
      // checkExtFile: checkExtFile ?? this.checkExtFile,
      // checkFileDate: checkFileDate ?? this.checkFileDate,
      // checkCost1Guid: checkCost1Guid ?? this.checkCost1Guid,
      // checkCost2Guid: checkCost2Guid ?? this.checkCost2Guid,
      // checkState: checkState ?? this.checkState,
    );
  }

 factory ChequesModel.empty({required ChequesType chequesType, int lastChequesNumber = 0}) {
    return  ChequesModel(checkNumber:lastChequesNumber,checkTypeGuid: chequesType.typeGuide );
  }

  static ChequesModel? fromChequesData({ChequesModel? chequesModel, required ChequesType chequesType, String? note, required String payAccountGuid, required String payDate}) {
    return null;
  }
}
