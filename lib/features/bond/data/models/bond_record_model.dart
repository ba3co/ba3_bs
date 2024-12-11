import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';

class BondItemModel implements PlutoAdaptable {
  final BondItemType? bondItemType;
  final double? amount;
  final AccountModel? account, oppositeAccount;
  final String? note;

  BondItemModel({
    this.bondItemType,
    this.amount,
    this.account,
    this.oppositeAccount,
    this.note,
  });

  factory BondItemModel.fromJson(Map<String, dynamic> json) {
    return BondItemModel(
      bondItemType: BondItemType.values.firstWhere(
        (e) => e.label == json['bondItemType'],
        // orElse: () => null,
      ),
      amount: (json['amount'] as num?)?.toDouble(),
      account: json['account'] != null ? AppServiceUtils.getAccountModelFromLabel(json['account']) : null,
      oppositeAccount:
          json['oppositeAccount'] != null ? AppServiceUtils.getAccountModelFromLabel(json['oppositeAccount']) : null,
      note: json['note'],
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat() {
    return {
      PlutoColumn(
        title: AppConstants.bondRecordBondItemType,
        type: PlutoColumnType.text(),
        field: AppConstants.bondRecordBondItemType,
      ): bondItemType,
      PlutoColumn(
        title: AppConstants.bondRecordAccount,
        type: PlutoColumnType.text(),
        field: AppConstants.bondRecordAccount,
      ): amount,
      PlutoColumn(
        title: "account",
        type: PlutoColumnType.text(),
        field: 'account',
      ): account,
      PlutoColumn(
        title: "note",
        type: PlutoColumnType.text(),
        field: 'note',
      ): note,
    };
  }

  Map<PlutoColumn, dynamic> toPlutoGridFormatWithType(BondType bondType) {
    if (bondType == BondType.daily) {
      return {
        PlutoColumn(
          title: "debit",
          type: PlutoColumnType.text(),
          field: 'debit',
        ): bondItemType == BondItemType.debtor ? 0 : amount,
        PlutoColumn(
          title: "credit",
          type: PlutoColumnType.text(),
          field: 'credit',
        ): amount,
        PlutoColumn(
          title: "account",
          type: PlutoColumnType.text(),
          field: 'account',
        ): bondItemType == BondItemType.creditor ? 0 : amount,
        PlutoColumn(
          title: "note",
          type: PlutoColumnType.text(),
          field: 'note',
        ): note,
      };
    } else {
      return {
        if (bondType == BondType.credit)
          PlutoColumn(
            title: "credit",
            type: PlutoColumnType.text(),
            field: 'credit',
          ): amount
        else
          PlutoColumn(
            title: "debit",
            type: PlutoColumnType.text(),
            field: 'debit',
          ): amount,
        PlutoColumn(
          title: "account",
          type: PlutoColumnType.text(),
          field: 'account',
        ): account,
        PlutoColumn(
          title: "note",
          type: PlutoColumnType.text(),
          field: 'note',
        ): note,
      };
    }
  }

  factory BondItemModel.fromJsonPluto({
    required String account,
    required String note,
    required BondItemType bondType,
    required double amount,
  }) {
    return BondItemModel(
      amount: amount,
      account: AppServiceUtils.getAccountModelFromLabel(account),
      bondItemType: bondType,
      note: note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bondItemType': bondItemType!.label, // تحويل enum إلى نص
      'amount': amount,
      'account': account?.accName, // تأكد أن AccountModel يدعم toJson
      'oppositeAccount': oppositeAccount?.accName,
      'note': note,
    };
  }
}

class EntryBondModel {
  final Map<AccountModel, List<BondItemModel>> bonds;

  EntryBondModel({
    required this.bonds,
  });
}

class BondModel {
  final List<BondItemModel> bonds;

  String? bondId;
  BondType? bondType;
  String? bondCode;

  int? bondNumber;

  BondModel({
    required this.bonds,
    this.bondId,
    this.bondCode,
    this.bondType,
    this.bondNumber,
  });

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'bonds': bonds.map((bond) => bond.toJson()).toList(),
      'bondId': bondId,
      'bondType': bondType.toString(), // تأكد من أن BondType يمكن تحويله إلى نص
      'bondCode': bondCode,
      'bondNumber': bondNumber,
    };
  }

  // تحويل JSON إلى BondModel
  factory BondModel.fromJson(Map<String, dynamic> json) {
    return BondModel(
      bonds: (json['bonds'] as List).map((bondJson) => BondItemModel.fromJson(bondJson)).toList(),
      bondId: json['bondId'],
      bondType: BondType.values.firstWhere(
        (e) => e.toString() == json['bondType'],
        // orElse: () => null,
      ),
      bondCode: json['bondCode'],
      bondNumber: json['bondNumber'],
    );
  }

  BondModel copyWith({
    List<BondItemModel>? bonds,
    String? bondId,
    BondType? bondType,
    String? bondCode,
    int? bondNumber,
  }) {
    return BondModel(
      bonds: bonds ?? this.bonds,
      bondId: bondId ?? this.bondId,
      bondType: bondType ?? this.bondType,
      bondCode: bondCode ?? this.bondCode,
      bondNumber: bondNumber ?? this.bondNumber,
    );
  }
}
