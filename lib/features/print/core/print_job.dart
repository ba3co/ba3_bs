

import '../../bill/data/models/invoice_record_model.dart';

class PrintJob {
  final int billNumber;
  final String invoiceDate;
  final String sellerName;
  final String customerNumber;
  final String nots;
  final String buyer;
  final List<InvoiceRecordModel> items;


  const PrintJob({
    required this.billNumber,
    required this.invoiceDate,
    required this.sellerName,
    required this.customerNumber,
    required this.items,
    required this.nots,
    required this.buyer,
  });
}