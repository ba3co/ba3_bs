import '../../base_classes/sales_account.dart';

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
  buy('شراء'),
  sales('مبيع'),
  buyReturn('مرتجع شراء'),
  salesReturn('مرتجع بيع'),
  add('إدخال'),
  remove('إخراج');

  final String label;

  const InvoiceType(this.label);
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

enum SalesAccounts implements SalesAccount {
  sales('مبيعات'),
  cashBox('الصندوق'),
  vat('الضريبة'),
  grantedDiscount('حسم ممنوح'),
  settlements('تسويات'),
  salesGifts('هدايا مبيع');

  @override
  final String label;

  const SalesAccounts(this.label);
}

enum BuyAccounts implements SalesAccount {
  sales('مبيعات'),
  customer('الزبون'),
  grantedDiscount('حسم ممنوح'),
  settlements('تسويات'),
  salesGifts('هدايا مبيع');

  @override
  final String label;

  const BuyAccounts(this.label);
}

enum CustomerAccount implements SalesAccount {
  cashBox('الصندوق'),
  cashCustomer('زبون كاش');

  @override
  final String label;

  const CustomerAccount(this.label);
}
