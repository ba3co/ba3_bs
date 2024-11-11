import 'package:ba3_bs/core/utils/utils.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:get/get.dart';

class AccountModel implements PlutoAdaptable {
  String? id;
  String? accName;
  String? accLatinName;
  String? accCode;
  DateTime? accCDate;
  DateTime? accCheckDate;
  String? accParentGuid;
  String? accFinalGuid;
  int? accAccNSons;
  double? accInitDebit;
  double? accInitCredit;
  double? maxDebit;
  int? accWarn;
  String? note;
  int? accCurVal;
  String? accCurGuid;
  int? accSecurity;
  int? accDebitOrCredit;
  int? accType;
  int? accState;
  int? accIsChangableRatio;
  String? accBranchGuid;
  int? accNumber;
  int? accBranchMask;

  AccountModel({
    this.id,
    this.accName,
    this.accLatinName,
    this.accCode,
    this.accCDate,
    this.accCheckDate,
    this.accParentGuid,
    this.accFinalGuid,
    this.accAccNSons,
    this.accInitDebit,
    this.accInitCredit,
    this.maxDebit,
    this.accWarn,
    this.note,
    this.accCurVal,
    this.accCurGuid,
    this.accSecurity,
    this.accDebitOrCredit,
    this.accType,
    this.accState,
    this.accIsChangableRatio,
    this.accBranchGuid,
    this.accNumber,
    this.accBranchMask,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['AccPtr'].toString(),
      accName: json['AccName'].toString(),
      accLatinName: json['AccLatinName'].toString(),
      accCode: json['AccCode'].toString(),
      accCDate: DateTime.tryParse(json['AccCDate']),
      accCheckDate: DateTime.tryParse(json['AccCheckDate']),
      accParentGuid: json['AccParentGuid'],
      accFinalGuid: json['AccFinalGuid'],
      accAccNSons: json['AccAccNSons'],
      accInitDebit: (json['AccInitDebit'] as num?)?.toDouble(),
      accInitCredit: (json['AccInitCredit'] as num?)?.toDouble(),
      maxDebit: (json['MaxDebit'] as num?)?.toDouble(),
      accWarn: json['AccWarn'],
      note: json['Note'].toString(),
      accCurVal: json['AccCurVal'],
      accCurGuid: json['AccCurGuid'],
      accSecurity: json['AccSecurity'],
      accDebitOrCredit: json['AccDebitOrCredit'],
      accType: json['AccType'],
      accState: json['AccState'],
      accIsChangableRatio: json['AccIsChangableRatio'],
      accBranchGuid: json['AccBranchGuid'],
      accNumber: json['AccNumber'],
      accBranchMask: json['AccBranchMask'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccPtr': id,
      'AccName': accName,
      'AccLatinName': accLatinName,
      'AccCode': accCode,
      'AccCDate': accCDate?.toIso8601String(),
      'AccCheckDate': accCheckDate?.toIso8601String(),
      'AccParentGuid': accParentGuid,
      'AccFinalGuid': accFinalGuid,
      'AccAccNSons': accAccNSons,
      'AccInitDebit': accInitDebit,
      'AccInitCredit': accInitCredit,
      'MaxDebit': maxDebit,
      'AccWarn': accWarn,
      'Note': note,
      'AccCurVal': accCurVal,
      'AccCurGuid': accCurGuid,
      'AccSecurity': accSecurity,
      'AccDebitOrCredit': accDebitOrCredit,
      'AccType': accType,
      'AccState': accState,
      'AccIsChangableRatio': accIsChangableRatio,
      'AccBranchGuid': accBranchGuid,
      'AccNumber': accNumber,
      'AccBranchMask': accBranchMask,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> json) => AccountModel(
        id: json['AccPtr'].toString(),
        accName: json['AccName'].toString(),
      );

  Map<String, dynamic> toMap() => {
        'AccPtr': id,
        'AccName': accName,
      };

  AccountModel copyWith({
    String? id,
    String? accName,
    String? accLatinName,
    String? accCode,
    DateTime? accCDate,
    DateTime? accCheckDate,
    String? accParentGuid,
    String? accFinalGuid,
    int? accAccNSons,
    double? accInitDebit,
    double? accInitCredit,
    double? maxDebit,
    int? accWarn,
    String? note,
    int? accCurVal,
    String? accCurGuid,
    int? accSecurity,
    int? accDebitOrCredit,
    int? accType,
    int? accState,
    int? accIsChangableRatio,
    String? accBranchGuid,
    int? accNumber,
    int? accBranchMask,
  }) {
    return AccountModel(
      id: id ?? this.id,
      accName: accName ?? this.accName,
      accLatinName: accLatinName ?? this.accLatinName,
      accCode: accCode ?? this.accCode,
      accCDate: accCDate ?? this.accCDate,
      accCheckDate: accCheckDate ?? this.accCheckDate,
      accParentGuid: accParentGuid ?? this.accParentGuid,
      accFinalGuid: accFinalGuid ?? this.accFinalGuid,
      accAccNSons: accAccNSons ?? this.accAccNSons,
      accInitDebit: accInitDebit ?? this.accInitDebit,
      accInitCredit: accInitCredit ?? this.accInitCredit,
      maxDebit: maxDebit ?? this.maxDebit,
      accWarn: accWarn ?? this.accWarn,
      note: note ?? this.note,
      accCurVal: accCurVal ?? this.accCurVal,
      accCurGuid: accCurGuid ?? this.accCurGuid,
      accSecurity: accSecurity ?? this.accSecurity,
      accDebitOrCredit: accDebitOrCredit ?? this.accDebitOrCredit,
      accType: accType ?? this.accType,
      accState: accState ?? this.accState,
      accIsChangableRatio: accIsChangableRatio ?? this.accIsChangableRatio,
      accBranchGuid: accBranchGuid ?? this.accBranchGuid,
      accNumber: accNumber ?? this.accNumber,
      accBranchMask: accBranchMask ?? this.accBranchMask,
    );
  }

  @override
  Map<String, dynamic> toPlutoGridFormat() => {
        'الرقم التعريفي': id,
        'رقم الحساب': accNumber,
        'رمز الحساب': accCode,
        'اسم الحساب': accName,
        'الاسم الاتيني': accLatinName,
        'نوع الحساب': Utils.getAccountType(accType),
        'Debit Or Credit': Utils.getAccountAccDebitOrCredit(accDebitOrCredit),
        'حساب الاب': Get.find<AccountsController>().getAccountNameById(accParentGuid),
        'الاولاد': Get.find<AccountsController>().getAccountChildren(id).join(' , '),
      };
}
