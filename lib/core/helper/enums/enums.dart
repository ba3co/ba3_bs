import 'package:ba3_bs/features/accounts/data/models/account_model.dart';

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

enum InvoiceType {
  purchase(label: 'شراء', value: 'purchase'),
  sales(label: 'مبيع', value: 'sales'),
  buyReturn(label: 'مرتجع شراء', value: 'purchaseReturn'),
  salesReturn(label: 'مرتجع بيع', value: 'salesReturn'),
  add(label: 'تسوية إدخال', value: 'adjustmentEntry'),
  remove(label: 'تسوية إخراج', value: 'outputAdjustment');

  final String label;
  final String value;

  const InvoiceType({
    required this.label,
    required this.value,
  });
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

enum BillType {
  sales(
    label: 'sales',
    value: 'قاتورة مبيعات',
    typeGuide: "6ed3786c-08c6-453b-afeb-a0e9075dd26d",
  ),
  purchase(
    label: 'purchase',
    value: 'قاتورة مشتريات',
    typeGuide: "eb10653a-a43f-44e5-889d-41ce68c43ec4",
  ),
  salesReturn(
    label: 'salesReturn',
    value: 'قاتورة مرتجع مبيع',
    typeGuide: "2373523c-9f23-4ce7-a6a2-6277757fc381",
  ),
  purchaseReturn(
    label: 'purchaseReturn',
    value: 'قاتورة مرتجع شراء',
    typeGuide: "507f9e7d-e44e-4c4e-9761-bb3cd4fc1e0d",
  ),
  adjustmentEntry(
    label: 'adjustmentEntry',
    value: 'قاتورة تسوية ادخال',
    typeGuide: "06f0e6ea-3493-480c-9e0c-573baf049605",
  ),
  outputAdjustment(
    label: 'outputAdjustment',
    value: 'قاتورة تسوية اخراج',
    typeGuide: "563af9aa-5d7e-470b-8c3c-fee784da810a",
  ),
  firstPeriodInventory(
    label: 'firstPeriodInventory',
    value: 'بضاعة أول المدة',
    typeGuide: "5a9e7782-cde5-41db-886a-ac89732feda7",
  ),
  transferIn(
    label: 'transferIn',
    value: 'إد.عملية مناقلة',
    typeGuide: "f0f2a5db-53ed-4e53-9686-d6a809911327",
  ),
  transferOut(
    label: 'transferOut',
    value: 'إخ.عملية مناقلة',
    typeGuide: "1e90ef6a-f7ef-484e-9035-0ab761371545",
  );

  final String label;

  final String value;

  final String typeGuide;

  const BillType({
    required this.label,
    required this.value,
    required this.typeGuide,
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
}

enum BondItemType {
  creditor('الدائن'),
  debtor('مدين');

  final String label;

  const BondItemType(this.label);
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
  cashCustomer('زبون كاش'),
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
