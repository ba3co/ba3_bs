import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/i_controllers/i_bill_controller.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';

void showEInvoiceDialog(IBillController billController, String billId) {
  final year = DateTime.now().year;
  final url = 'https://ba3-bs.firebaseapp.com/?id=$billId&year=$year';

  Get.defaultDialog(
    title: "فاتورتك الرقمية",
    content: SizedBox(
      height: Get.height / 1.8,
      width: Get.height / 1.8,
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          Center(
            child: QrImageView(
              data: url,
              version: QrVersions.auto,
              size: Get.height / 2.5,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "مشاركة عبر",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Text("البريد الألكتروني:"),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomTextFieldWithoutIcon(
                  textEditingController: TextEditingController(),
                  onSubmitted: (recipientEmail) =>
                      billController.sendBillToEmail(recipientEmail: recipientEmail, url: url),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                },
                // backgroundColor: Colors.grey,
                icon: const Icon(
                  Icons.copy,
                  color: Colors.grey,
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
