import 'dart:developer';

import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/i_controllers/i_bill_controller.dart';

void showCustomEInvoiceOverlay(BuildContext context, IBillController billController, BillModel billModel) {
  log('billId ${billModel.billId}');
  log('billNumber ${billModel.billDetails.billNumber}');
  if (!billController.hasBillId(billModel.billId)) return;

  final year = DateTime.now().year;
  final url = 'https://ba3-bs.firebaseapp.com/?id=${billModel.billId}&year=$year';

  final OverlayState overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => GestureDetector(
      onTap: () {
        overlayEntry.remove();
      },
      child: Material(
        color: Colors.black54, // Semi-transparent background
        child: Center(
          child: Container(
            width: .3.sw,
            height: 0.5.sh,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.height * 0.25,
                ),
                const SizedBox(height: 20),
                const Text(
                  "مشاركة عبر",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("البريد الألكتروني:"),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter email",
                        ),
                        onSubmitted: (recipientEmail) {
                          billController.sendBillToEmail(
                            recipientEmail: recipientEmail,
                            url: url,
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                      },
                      icon: const Icon(Icons.copy, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    overlayEntry.remove();
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the overlay
  overlayState.insert(overlayEntry);
}
