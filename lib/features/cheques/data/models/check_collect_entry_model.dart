import '../../../bond/data/models/pay_item_model.dart';

class CheckCollectEntryModel {
  final CheckEntry checkEntryModel;
  final int entryCount;

  const CheckCollectEntryModel({
    required this.checkEntryModel,
    required this.entryCount,
  });

  factory CheckCollectEntryModel.fromJson(Map<String, dynamic> json) {
    return CheckCollectEntryModel(
      checkEntryModel: CheckEntry.fromJson(json['checkEntry']),
      entryCount: json['EntryCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkEntry': checkEntryModel.toJson(),
      'EntryCount': entryCount,
    };
  }

  CheckCollectEntryModel copyWith({
    CheckEntry? checkEntry,
    int? entryCount,
  }) {
    return CheckCollectEntryModel(
      checkEntryModel: checkEntry ?? this.checkEntryModel,
      entryCount: entryCount ?? this.entryCount,
    );
  }
}


class CheckEntry {
  // final int cEntryType;
  final String cEntryTypeGuid;
  final String cEntryGuid;
  final String cEntryDate;
  final String cEntryPostDate;
  final String cEntryDebit;
  final String cEntryCredit;
  final String cEntryNote;
  // final String cEntryCurrencyGuid;
  // final double cEntryCurrencyVal;
  // final int cEntryIsPosted;
  // final int cEntryState;
  // final int cEntrySecurity;
  // final String cEntryBranch;
  final int cEntryNumber;
  final PayItems payItems;

  const CheckEntry({
    // required this.cEntryType,
    required this.cEntryTypeGuid,
    required this.cEntryGuid,
    required this.cEntryDate,
    required this.cEntryPostDate,
    required this.cEntryDebit,
    required this.cEntryCredit,
    required this.cEntryNote,
    // required this.cEntryCurrencyGuid,
    // required this.cEntryCurrencyVal,
    // required this.cEntryIsPosted,
    // required this.cEntryState,
    // required this.cEntrySecurity,
    // required this.cEntryBranch,
    required this.cEntryNumber,
    required this.payItems,
  });

  factory CheckEntry.fromJson(Map<String, dynamic> json) {
    return CheckEntry(
      // cEntryType: json['CEntryType'] as int,
      cEntryTypeGuid: json['CEntryTypeGuid'] as String,
      cEntryGuid: json['CEntryGuid'] as String,
      cEntryDate: json['CEntryDate'] as String,
      cEntryPostDate: json['CEntryPostDate'] as String,
      cEntryDebit: json['CEntryDebit'] as String,
      cEntryCredit: json['CEntryCredit'] as String,
      cEntryNote: json['CEntryNote'] as String,
      // cEntryCurrencyGuid: json['CEntryCurrencyGuid'] as String,
      // cEntryCurrencyVal: (json['CEntryCurrencyVal'] as num).toDouble(),
      // cEntryIsPosted: json['CEntryIsPosted'] as int,
      // cEntryState: json['CEntryState'] as int,
      // cEntrySecurity: json['CEntrySecurity'] as int,
      // cEntryBranch: json['CEntryBranch'] as String,
      cEntryNumber: json['CEntryNumber'] as int,
      payItems: PayItems.fromJson(json['PayItems']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'CEntryType': cEntryType,
      'CEntryTypeGuid': cEntryTypeGuid,
      'CEntryGuid': cEntryGuid,
      'CEntryDate': cEntryDate,
      'CEntryPostDate': cEntryPostDate,
      'CEntryDebit': cEntryDebit,
      'CEntryCredit': cEntryCredit,
      'CEntryNote': cEntryNote,
      // 'CEntryCurrencyGuid': cEntryCurrencyGuid,
      // 'CEntryCurrencyVal': cEntryCurrencyVal,
      // 'CEntryIsPosted': cEntryIsPosted,
      // 'CEntryState': cEntryState,
      // 'CEntrySecurity': cEntrySecurity,
      // 'CEntryBranch': cEntryBranch,
      'CEntryNumber': cEntryNumber,
      'PayItems': payItems.toJson(),
    };
  }

  CheckEntry copyWith({
    // int? cEntryType,
    String? cEntryTypeGuid,
    String? cEntryGuid,
    String? cEntryDate,
    String? cEntryPostDate,
    String? cEntryDebit,
    String? cEntryCredit,
    String? cEntryNote,
    // String? cEntryCurrencyGuid,
    // double? cEntryCurrencyVal,
    // int? cEntryIsPosted,
    // int? cEntryState,
    // int? cEntrySecurity,
    // String? cEntryBranch,
    int? cEntryNumber,
    PayItems? payItems,
  }) {
    return CheckEntry(
      // cEntryType: cEntryType ?? this.cEntryType,
      cEntryTypeGuid: cEntryTypeGuid ?? this.cEntryTypeGuid,
      cEntryGuid: cEntryGuid ?? this.cEntryGuid,
      cEntryDate: cEntryDate ?? this.cEntryDate,
      cEntryPostDate: cEntryPostDate ?? this.cEntryPostDate,
      cEntryDebit: cEntryDebit ?? this.cEntryDebit,
      cEntryCredit: cEntryCredit ?? this.cEntryCredit,
      cEntryNote: cEntryNote ?? this.cEntryNote,
      // cEntryCurrencyGuid: cEntryCurrencyGuid ?? this.cEntryCurrencyGuid,
      // cEntryCurrencyVal: cEntryCurrencyVal ?? this.cEntryCurrencyVal,
      // cEntryIsPosted: cEntryIsPosted ?? this.cEntryIsPosted,
      // cEntryState: cEntryState ?? this.cEntryState,
      // cEntrySecurity: cEntrySecurity ?? this.cEntrySecurity,
      // cEntryBranch: cEntryBranch ?? this.cEntryBranch,
      cEntryNumber: cEntryNumber ?? this.cEntryNumber,
      payItems: payItems ?? this.payItems,
    );
  }
}