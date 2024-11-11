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
  buy(label: 'شراء', value: 'invoiceTypeBuy'),
  sales(label: 'مبيع', value: 'invoiceTypeSales'),
  buyReturn(label: 'مرتجع شراء', value: 'buyReturn'),
  salesReturn(label: 'مرتجع بيع', value: 'salesReturn'),
  add(label: 'إدخال', value: 'inputSettlement'),
  remove(label: 'إخراج', value: 'outputSettlement');

  final String label;
  final String value;

  const InvoiceType({
    required this.label,
    required this.value,
  });
}

enum RequestState { initial, loading, error, success }

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
  sales(label: 'sales', value: 'قاتورة مبيعات'),
  purchase(label: 'purchase', value: 'قاتورة مشتريات'),
  salesReturn(label: 'salesReturn', value: 'قاتورة مرتجع مبيع'),
  purchaseReturn(label: 'purchaseReturn', value: 'قاتورة مرتجع شراء'),
  adjustmentEntry(label: 'adjustmentEntry', value: 'قاتورة تسوية ادخال'),
  outputAdjustment(label: 'outputAdjustment', value: 'قاتورة تسوية اخراج'),
  firstPeriodInventory(label: 'firstPeriodInventory', value: 'بضاعة أول المدة'),
  transferIn(label: 'transferIn', value: 'إد.عملية مناقلة'),
  transferOut(label: 'transferOut', value: 'إخ.عملية مناقلة');

  final String label;

  final String value;

  const BillType({
    required this.label,
    required this.value,
  });

  // Factory constructor with error handling for unmatched labels
  factory BillType.byLabel(String label) {
    return BillType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching BillType for label: $label'),
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
