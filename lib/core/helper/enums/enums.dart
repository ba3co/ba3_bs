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
}

enum BondItemType {
  creditor('الدائن'),
  debtor('مدين');

  final String label;

  const BondItemType(this.label);
}

enum SalesCashAccounts implements SalesAccount {
  sales('مبيعات'),
  cashBox('الصندوق'),
  grantedDiscount('حسم ممنوح'),
  settlements('تسويات'),
  salesGifts('هدايا مبيع');

  @override
  final String label;

  const SalesCashAccounts(this.label);
}

enum SalesDueAccounts implements SalesAccount {
  sales('مبيعات'),
  customer('الزبون'),
  grantedDiscount('حسم ممنوح'),
  settlements('تسويات'),
  salesGifts('هدايا مبيع');

  @override
  final String label;

  const SalesDueAccounts(this.label);
}
