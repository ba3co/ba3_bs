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
  buy("شراء"),
  sales("مبيع"),
  buyReturn("مرتجع شراء"),
  salesReturn("مرتجع بيع"),
  add("إدخال"),
  remove("إخراج");

  final String label;

  const InvoiceType(this.label);
}

enum RequestState { initial, loading, error, success }
