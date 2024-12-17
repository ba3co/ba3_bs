import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../../pluto/data/models/pluto_adaptable.dart';

/// Represents a bond entry with associated details and items.
class EntryBondModel {
  /// List of bond items associated with this bond entry.
  final List<EntryBondItemModel>? items;

  /// Refers to the origin entity of the bond entry (e.g., billTypeId for invoices).
  final EntryBondOrigin? origin;

  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? id;

  EntryBondModel({
    this.items,
    this.origin,
    this.id,
  });

  /// Creates an instance from a JSON object.
  factory EntryBondModel.fromJson(Map<String, dynamic> json) {
    return EntryBondModel(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => EntryBondItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      origin: EntryBondOrigin.fromJson(json['origin']),
      id: json['id'] as String?,
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((item) => item.toJson()).toList(),
      'origin': origin?.toJson(),
      'id': id,
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondModel copyWith({
    List<EntryBondItemModel>? items,
    EntryBondOrigin? origin,
    String? id,
  }) {
    return EntryBondModel(
      items: items ?? this.items,
      origin: origin ?? this.origin,
      id: id ?? this.id,
    );
  }
}

/// Represents a single bond item within a bond entry.
class EntryBondItemModel implements PlutoAdaptable {
  /// Type of the bond item, defined by an enum.
  final BondItemType? bondItemType;

  /// The monetary amount associated with this bond item.
  final double? amount;

  /// The account related to this bond item.
  final String? accountId;

  /// The account related to this bond item.
  final String? accountName;

  /// Additional notes or comments for this bond item.
  final String? note;

  /// Refers to the bond entry ID that this item belongs to.
  final String? originId;

  final String? date;

  EntryBondItemModel({
    this.bondItemType,
    this.amount,
    this.accountId,
    this.accountName,
    this.note,
    this.originId,
    this.date,
  });

  /// Factory method to create an InvoiceRecordModel from a BillItem.

  // factory EntryBondItemModel.fromBillRecords(
  //   InvoiceRecordModel record,
  //   String? billId,
  //   BondItemType? bondItemType,
  //   String? accountName,
  //   String? accountId,
  //   String? note,
  //   String? date,
  // ) =>
  //     EntryBondItemModel(
  //       bondItemType: bondItemType,
  //       amount: record.invRecQuantity!,
  //       accountId: accountId,
  //       accountName: accountName,
  //       note: note,
  //       originId: billId,
  //       date: date,
  //     );

  /// Creates an instance from a JSON object.
  factory EntryBondItemModel.fromJson(Map<String, dynamic> json) {
    return EntryBondItemModel(
      bondItemType: BondItemType.byLabel(json['bondItemType']),
      amount: (json['amount'] as num?)?.toDouble(),
      accountId: json['accountId'] as String?,
      accountName: json['accountName'] as String?,
      note: json['note'] as String?,
      originId: json['originId'] as String?,
      date: json['date'] as String?,
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'bondItemType': bondItemType?.label,
      'amount': amount,
      'accountId': accountId,
      'accountName': accountName,
      'note': note,
      'originId': originId,
      'date': date,
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondItemModel copyWith({
    BondItemType? bondItemType,
    double? amount,
    String? accountId,
    String? accountName,
    String? note,
    String? originId,
    String? date,
  }) {
    return EntryBondItemModel(
      bondItemType: bondItemType ?? this.bondItemType,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      note: note ?? this.note,
      originId: originId ?? this.originId,
      date: date ?? this.date,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void _]) {
    final accountsController = Get.find<AccountsController>();
    return {
      PlutoColumn(title: 'originId', field: 'originId', type: PlutoColumnType.text()): originId ?? '',
      PlutoColumn(title: 'مدين', field: 'مدين', type: PlutoColumnType.text()):
          bondItemType == BondItemType.debtor ? amount : 0,
      PlutoColumn(title: 'دائن', field: 'دائن', type: PlutoColumnType.text()):
          bondItemType == BondItemType.creditor ? amount : 0,
      PlutoColumn(title: 'الحساب', field: 'الحساب', type: PlutoColumnType.text()):
          accountsController.getAccountNameById(accountId),
      PlutoColumn(title: 'التاريخ', field: 'التاريخ', type: PlutoColumnType.text()): date,
      PlutoColumn(title: 'البيان', field: 'البيان', type: PlutoColumnType.text()): note,
    };
  }
}

class EntryBondOrigin {
  final String? guide;
  final EntryBondType? type;

  EntryBondOrigin({
    this.guide,
    this.type,
  });

  factory EntryBondOrigin.fromJson(Map<String, dynamic> json) {
    return EntryBondOrigin(
      guide: json['guide'] as String?,
      type: EntryBondType.byLabel(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guide': guide,
      'type': type?.label,
    };
  }

  EntryBondOrigin copyWith({
    String? guide,
    EntryBondType? type,
  }) {
    return EntryBondOrigin(
      guide: guide ?? this.guide,
      type: type ?? this.type,
    );
  }
}

final entryBondModel = EntryBondModel(
    id: 'Up6WalSELBYhH4DZXPVJ',
    origin: EntryBondOrigin(
      type: EntryBondType.bill,
      guide: '6ed3786c-08c6-453b-afeb-a0e9075dd26d',
    ),
    items: [
      EntryBondItemModel(
        bondItemType: BondItemType.creditor,
        amount: 120,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: 'b1e9e80b-0d23-414d-b3be-bd0aec386002',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.debtor,
        amount: 6,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: '25403a98-0cd8-46d1-b92b-dbe540969fe5',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.debtor,
        amount: 5.04,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: '25403a98-0cd8-46d1-b92b-dbe540969fe5',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.debtor,
        amount: 120,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: '25403a98-0cd8-46d1-b92b-dbe540969fe5',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.creditor,
        amount: 12.60,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: '25403a98-0cd8-46d1-b92b-dbe540969fe5',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.creditor,
        amount: 380.95,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: '5b36c82d-9105-4177-a5c3-0f90e5857e3c',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.creditor,
        amount: 6,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: 'a5c04527-63e8-4373-92e8-68d8f88bdb16',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.debtor,
        amount: 12.60,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: 'e903d658-f30f-46c8-82c0-fee86256a511',
      ),
      EntryBondItemModel(
        bondItemType: BondItemType.creditor,
        amount: 5.04,
        note: '',
        originId: 'Up6WalSELBYhH4DZXPVJ',
        accountId: '1a1416bb-426b-4348-98cf-f1b026cc6c7d',
      ),
    ]);

// import '../../../../core/helper/enums/enums.dart';
// import '../../../accounts/data/models/account_model.dart';
//
// class EntryBondItemModel {
//   final BondItemType? bondItemType;
//   final double? amount;
//   final AccountModel? account, oppositeAccount;
//   final String? note;
//
//   EntryBondItemModel({
//     this.bondItemType,
//     this.amount,
//     this.account,
//     this.oppositeAccount,
//     this.note,
//   });
//
// /* factory EntryBondItemModel.fromJson(Map<String, dynamic> json) {
//     return EntryBondItemModel(
//       bondItemType: BondItemType.values.firstWhere(
//         (e) => e.label == json['bondItemType'],
//         // orElse: () => null,
//       ),
//       amount: (json['amount'] as num?)?.toDouble(),
//       account: json['account'] != null ? AppServiceUtils.getAccountModelFromLabel(json['account']) : null,
//       oppositeAccount:
//           json['oppositeAccount'] != null ? AppServiceUtils.getAccountModelFromLabel(json['oppositeAccount']) : null,
//       note: json['note'],
//     );
//   }
//
//
//
//   factory EntryBondItemModel.fromJsonPluto({
//     required String account,
//     required String note,
//     required BondItemType bondType,
//     required double amount,
//   }) {
//     return EntryBondItemModel(
//       amount: amount,
//       account: AppServiceUtils.getAccountModelFromLabel(account),
//       bondItemType: bondType,
//       note: note,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'bondItemType': bondItemType!.label, // تحويل enum إلى نص
//       'amount': amount,
//       'account': account?.accName, // تأكد أن AccountModel يدعم toJson
//       'oppositeAccount': oppositeAccount?.accName,
//       'note': note,
//     };
//   }*/
// }
//
// class EntryBondModel {
//   final Map<AccountModel, List<EntryBondItemModel>> bonds;
//
//   EntryBondModel({
//     required this.bonds,
//   });
// }
