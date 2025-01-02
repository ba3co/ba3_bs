import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';

import '../../constants/app_assets.dart';

enum EnvType { debug, release }

enum UserManagementStatus { first, login, block, auth }

enum RecordType {
  bond,
  invoice,
  product,
  account,
  pattern,
  undefined,
  store,
  cheque,
  costCenter,
  sellers,
  user,
  role,
  task,
  inventory,
  entryBond,
  accCustomer,
  warrantyInv,
  changes,
  fProduct
}

enum BillType {
  sales(
      label: 'sales',
      value: 'فاتورة مبيعات',
      typeGuide: "6ed3786c-08c6-453b-afeb-a0e9075dd26d",
      color: 4282339765,
      accounts: {
        BillAccounts.store: AccountModel(accName: "المستودع الرئيسي", id: '6d9836d1-fccd-4006-804f-81709eecde57'),
        BillAccounts.additions: AccountModel(accName: "ايرادات مختلفة", id: "1a1416bb-426b-4348-98cf-f1b026cc6c7d"),
        BillAccounts.discounts: AccountModel(accName: "الحسم الممنوح", id: "e903d658-f30f-46c8-82c0-fee86256a511"),
        BillAccounts.materials: AccountModel(accName: "المبيعات", id: "b1e9e80b-0d23-414d-b3be-bd0aec386002"),
        BillAccounts.caches: AccountModel(accName: "الصندوق", id: "5b36c82d-9105-4177-a5c3-0f90e5857e3c"),
        BillAccounts.gifts: AccountModel(accName: "هدايا البيع", id: "9d04d1f1-23f3-466e-8edb-5c16074e44ad"),
        BillAccounts.exchangeForGifts: AccountModel(accName: "تسويات", id: "201046d2-7ca0-4ac4-a55d-b1dbf4e54dde"),
      }),
  purchase(
    label: 'purchase',
    value: 'فاتورة مشتريات',
    typeGuide: "eb10653a-a43f-44e5-889d-41ce68c43ec4",
    color: 4284513675,
    accounts: {
      BillAccounts.store: AccountModel(accName: "المستودع الرئيسي", id: '6d9836d1-fccd-4006-804f-81709eecde57'),
      BillAccounts.additions: AccountModel(accName: "مصاريف نقل المشتريات", id: "c5cdd2bc-85c2-4f7c-a4c8-13c847794211"),
      BillAccounts.discounts: AccountModel(accName: "الحسم المكتسب", id: "7102c69a-50f6-4489-a3e5-811bef04f26d"),
      BillAccounts.materials: AccountModel(accName: "المشتريات", id: "4fd556cc-6408-4fe7-809a-0d35bc399c11"),
      BillAccounts.caches: AccountModel(accName: "الصندوق", id: "5b36c82d-9105-4177-a5c3-0f90e5857e3c"),
      BillAccounts.gifts: AccountModel(accName: "إكراميات وهدايا", id: "220e1101-08a3-45a8-bd66-b244a1674d36"),
      BillAccounts.exchangeForGifts: AccountModel(accName: "تسويات", id: "201046d2-7ca0-4ac4-a55d-b1dbf4e54dde"),
    },
  ),
  salesReturn(
    label: 'salesReturn',
    value: 'فاتورة مرتجع مبيع',
    typeGuide: "2373523c-9f23-4ce7-a6a2-6277757fc381",
    color: 4278228616,
    accounts: {},
  ),
  purchaseReturn(
    label: 'purchaseReturn',
    value: 'قاتورة مرتجع شراء',
    typeGuide: "507f9e7d-e44e-4c4e-9761-bb3cd4fc1e0d",
    color: 4278228616,
    accounts: {},
  ),
  adjustmentEntry(
    label: 'adjustmentEntry',
    value: 'فاتورة تسوية ادخال',
    typeGuide: "06f0e6ea-3493-480c-9e0c-573baf049605",
    color: 4278228616,
    accounts: {},
  ),
  outputAdjustment(
    label: 'outputAdjustment',
    value: 'فاتورة تسوية اخراج',
    typeGuide: "563af9aa-5d7e-470b-8c3c-fee784da810a",
    color: 4278228616,
    accounts: {},
  ),
  firstPeriodInventory(
      label: 'firstPeriodInventory',
      value: 'بضاعة أول المدة',
      typeGuide: "5a9e7782-cde5-41db-886a-ac89732feda7",
      color: 4287349578,
      accounts: {}),
  transferIn(
      label: 'transferIn',
      value: 'إد.عملية مناقلة',
      typeGuide: "f0f2a5db-53ed-4e53-9686-d6a809911327",
      color: 4278228616,
      accounts: {}),
  transferOut(
    label: 'transferOut',
    value: 'إخ.عملية مناقلة',
    typeGuide: "1e90ef6a-f7ef-484e-9035-0ab761371545",
    color: 4278228616,
    accounts: {},
  );

  final String label;

  final String value;

  final String typeGuide;
  final int color;
  final Map<Account, AccountModel> accounts;

  const BillType({
    required this.label,
    required this.value,
    required this.typeGuide,
    required this.color,
    required this.accounts,
  });

  // Factory constructor with error handling for unmatched labels
  factory BillType.byLabel(String label) {
    return BillType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching BillType for label: $label'),
    );
  }

  factory BillType.byTypeGuide(String typeGuide) {
    return BillType.values.firstWhere(
      (type) => type.typeGuide == typeGuide,
      orElse: () => throw ArgumentError('No matching BillType for guide: $typeGuide'),
    );
  }

  BillTypeModel get billTypeModel => BillTypeModel(billTypeId: typeGuide, billTypeLabel: label);
}

enum BillPatternType {
  purchase(label: 'شراء', value: 'purchase'),
  sales(label: 'مبيع', value: 'sales'),
  buyReturn(label: 'مرتجع شراء', value: 'purchaseReturn'),
  salesReturn(label: 'مرتجع بيع', value: 'salesReturn'),
  add(label: 'تسوية إدخال', value: 'adjustmentEntry'),
  remove(label: 'تسوية إخراج', value: 'outputAdjustment'),
  firstPeriodInventory(label: 'بضاعة اول مدة', value: 'firstPeriodInventory'),
  transferOut(
    value: 'transferOut',
    label: 'إخ.عملية مناقلة',
  ),
  transferIn(
    value: 'transferIn',
    label: 'إد.عملية مناقلة',
  );

  final String label;
  final String value;

  const BillPatternType({
    required this.label,
    required this.value,
  });

  // Factory constructor with error handling for unmatched labels
  factory BillPatternType.byValue(String value) {
    return BillPatternType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('No matching BillPatternType for value: $value'),
    );
  }

  // Factory constructor with error handling for unmatched labels
  factory BillPatternType.byLabel(String label) {
    return BillPatternType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching BillPatternType for label: $label'),
    );
  }
}

enum RequestState { initial, loading, error, success }

enum NotificationStatus { success, error, info }

enum InvPayType {
  cash('نقدي'),
  due('اجل');

  // Custom value for each enum case
  final String label;

  const InvPayType(this.label);

  factory InvPayType.fromIndex(int index) {
    return InvPayType.values.firstWhere(
      (type) => type.index == index,
      orElse: () => throw ArgumentError('No matching BillType for label: $index'),
    );
  }
}

enum Status {
  approved('approved'),
  canceled('canceled'),
  pending('pending');

  final String value;

  const Status(this.value);

  // Factory constructor to handle conversion from string to BillStatus
  factory Status.byValue(String value) {
    return Status.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('No matching Status for value: $value'),
    );
  }
}

enum BondType {
  openingEntry(
    label: "Opening Entry",
    value: "القيد الافتتاحي",
    typeGuide: "ea69ba80-662d-4fa4-90ee-4d2e1988a8ea",
    from: 1,
    to: 1,
    taxType: 0,
    icon: AppAssets.openingEntryIcon,
    // color: 15132399,
    color: "E6E6EF",
  ),
  receiptVoucher(
    label: "Receipt Voucher",
    value: "سند قبض",
    typeGuide: "3dbab874-6002-413b-9a6b-9a216f338097",
    from: 1,
    to: 602,
    taxType: 2,
    icon: AppAssets.receiptVoucherIcon,
    // color: 7193225,
    color: "6DC289",
  ),
  paymentVoucher(
    label: "Payment Voucher",
    value: "سند دفع",
    typeGuide: '5085dc23-1444-4e9a-9d8f-1794da9e7f96',
    from: 1,
    to: 5051,
    taxType: 1,
    icon: AppAssets.paymentVoucherIcon,
    // color: 12741997,
    color: "C26D6D",
  ),
  journalVoucher(
    label: "Journal Voucher",
    value: "سند يومية",
    typeGuide: "2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de",
    from: 1,
    to: 489,
    taxType: 1,
    icon: AppAssets.journalVoucherIcon,
    color: "6D7DC2",
  );

  final int from, to, taxType;

  final String label;
  final String color;

  final String value;

  final String typeGuide;
  final String icon;

  const BondType({
    required this.label,
    required this.value,
    required this.typeGuide,
    required this.from,
    required this.to,
    required this.taxType,
    required this.icon,
    required this.color,
  });

  // Factory constructor with error handling for unmatched labels
  factory BondType.byLabel(String label) {
    return BondType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching BondType for label: $label'),
    );
  }

  factory BondType.byTypeGuide(String typeGuide) {
    return BondType.values.firstWhere(
      (type) => type.typeGuide == typeGuide,
      orElse: () => throw ArgumentError('No matching BondType for guide: $typeGuide'),
    );
  }
}

enum ChequesType {
  paidChecks(
    label: "Paid checks",
    value: "شيكات مدفوعة",
    typeGuide: "fc3fe7b6-dbb4-4007-b8a4-fc3533dccd18",
    from: 1,
    to: 277,
  ),
  insuranceChecks(
    label: "Insurance checks",
    value: "شيكات تأمين",
    typeGuide: 'c27c5972-2b40-47df-8e3e-6ee29c4d5838',
    from: 2,
    to: 3,
  );

  final int from, to;

  final String label;

  final String value;

  final String typeGuide;

  const ChequesType({
    required this.label,
    required this.value,
    required this.typeGuide,
    required this.from,
    required this.to,
  });

  // Factory constructor with error handling for unmatched labels
  factory ChequesType.byLabel(String label) {
    return ChequesType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching ChequesType for label: $label'),
    );
  }

  factory ChequesType.byTypeGuide(String typeGuide) {
    return ChequesType.values.firstWhere(
      (type) => type.typeGuide == typeGuide,
      orElse: () => throw ArgumentError('No matching ChequesType for guide: $typeGuide'),
    );
  }
}

enum EntryBondType {
  bond('bond'),
  bill('bill'),
  cheque('cheque');

  final String label;

  const EntryBondType(this.label);

  // Factory constructor with error handling for unmatched labels
  factory EntryBondType.byLabel(String label) {
    return EntryBondType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching EntryBondType for label: $label'),
    );
  }
}

enum BondItemType {
  creditor('الدائن'),
  debtor('مدين');

  final String label;

  const BondItemType(this.label);

  // Factory constructor with error handling for unmatched labels
  factory BondItemType.byLabel(String label) {
    return BondItemType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching BondItemType for label: $label'),
    );
  }
}

enum ChequesStatus {
  paid('مدفوع'),
  notPaid('غير مدفوع');

  final String label;

  const ChequesStatus(this.label);

  // Factory constructor with error handling for unmatched labels
  factory ChequesStatus.byLabel(String label) {
    return ChequesStatus.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching ChequesStatus for label: $label'),
    );
  }
}

abstract class Account {
  String get label;
}

enum BillAccounts implements Account {
  materials('المواد'),
  discounts('الحسميات'),
  additions('الاضافات'),
  caches('النقديات'),
  gifts('الهدايا'),
  exchangeForGifts('مقابل الهدايا'),
  store('المستودع');

  @override
  final String label;

  const BillAccounts(this.label);

  // Factory constructor with error handling for unmatched labels
  factory BillAccounts.byLabel(String label) {
    return BillAccounts.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching BillType for label: $label'),
    );
  }
}

enum SalesAccounts implements Account {
  sales('مبيعات'),
  cashBox('الصندوق'),
  vat('الضريبة'),
  grantedDiscount('حسم ممنوح'),
  differentRevenues('ايرادات مختلفه'),
  settlements('تسويات'),
  salesGifts('هدايا مبيع');

  @override
  final String label;

  const SalesAccounts(this.label);
}

enum BuyAccounts implements Account {
  purchases('مشتريات'),
  cashBox('الصندوق'),
  vat('الضريبة'),
  earnedDiscount('حسم مكتسب'),
  differentExpenses('مصاريف مختلفه'),
  settlements('تسويات'),
  purchaseGifts('هدايا شراء');

  @override
  final String label;

  const BuyAccounts(this.label);
}

enum CustomerAccount implements Account {
  cashBox('الصندوق'),
  cashCustomer("زبون كاش"),
  provider('المورد');

  @override
  final String label;

  const CustomerAccount(this.label);
}

enum PriceType {
  consumer('سعر المستهلك'),
  bulk('سعر الجملة'),
  retail('سعر المفرق');

  final String label;

  const PriceType(this.label);
}

enum UserStatus {
  online('داخل العمل'),
  away('خارج العمل');

  final String label;

  const UserStatus(this.label);

  // Factory constructor with error handling for unmatched labels
  factory UserStatus.byLabel(String label) {
    return UserStatus.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching TimeType for label: $label'),
    );
  }
}

enum StoreAccount {
  main(
    label: 'mainStore',
    value: 'المستودع الرئيسي',
    typeGuide: "6d9836d1-fccd-4006-804f-81709eecde57",
  );

  final String label;

  final String value;

  final String typeGuide;

  const StoreAccount({
    required this.label,
    required this.value,
    required this.typeGuide,
  });

  // Factory constructor with error handling for unmatched labels
  factory StoreAccount.byLabel(String label) {
    return StoreAccount.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching StoreAccount for label: $label'),
    );
  }

  factory StoreAccount.byTypeGuide(String typeGuide) {
    return StoreAccount.values.firstWhere(
      (type) => type.typeGuide == typeGuide,
      orElse: () => throw ArgumentError('No matching StoreAccount for guide: $typeGuide'),
    );
  }

  AccountModel get toStoreAccountModel => AccountModel(
        id: typeGuide,
        accName: value,
      );
}

// enum TaxType {
//   withTax('1234-guid-with-tax'),
//   withoutTax('5678-guid-without-tax');
//
//   final String vatGuid;
//
//   const TaxType(this.vatGuid);
//
//   factory TaxType.byGuid(String guid) {
//     return TaxType.values.firstWhere(
//           (type) => type.vatGuid == guid,
//       orElse: () => throw ArgumentError('No matching VatEnums for guid: $guid'),
//     );
//   }
// }
