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
}

enum BillType {
  sales('invoiceTypeSales'),
  buy('invoiceTypeBuy'),
  salesReturn('salesReturn'),
  buyReturn('buyReturn'),
  inputSettlement('inputSettlement'),
  outputSettlement('outputSettlement'),
  salesWithPartner('invoiceTypeSalesWithPartner'),
  salesWithoutReceipt('salesWithoutReceipt');

  final String label;

  const BillType(this.label);

  // Factory constructor with error handling for unmatched labels
  factory BillType.fromLabel(String label) {
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
