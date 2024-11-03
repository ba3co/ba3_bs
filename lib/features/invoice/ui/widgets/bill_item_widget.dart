import 'package:flutter/material.dart';

import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/invoice_controller.dart';

class BillItemWidget extends StatelessWidget {
  final BillTypeModel bill;
  final InvoiceController invoiceController;
  final VoidCallback onPressed;

  const BillItemWidget({
    super.key,
    required this.bill,
    required this.invoiceController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        overlayColor: Colors.grey,
        padding: const EdgeInsets.all(30.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Color(bill.color ?? 0xFF000000).withOpacity(0.5), width: 1.0),
        ),
      ),
      child: Text(
        bill.fullName ?? "Error",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ),
    );
  }
}
