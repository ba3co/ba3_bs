import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:get/get.dart';

import '../../features/accounts/data/models/account_model.dart';
import '../../features/bill/data/models/bill_items.dart';
import '../../features/bill/services/bill/bill_pdf_generator.dart';
import '../helper/enums/enums.dart';
import '../services/mailer_messaging_service/implementations/gmail_messaging_service.dart';
import '../services/mailer_messaging_service/implementations/mailer_messaging_repo.dart';
import '../services/pdf_generator/implementations/pdf_generator_repo.dart';
import '../utils/app_ui_utils.dart';

abstract class IBillController extends GetxController {
  /// Updates the selected account additions or discounts
  void updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value);

  void updateCustomerAccount(AccountModel? newAccount);

  /// Sends the bill email with optional attachments
  Future<void> sendBillToEmail({
    required String recipientEmail,
    String? url,
    String? subject,
    String? body,
    List<String>? attachments,
  }) async {
    final mailerRepo = MailerMessagingRepository(GmailMessagingService());

    final result = await mailerRepo.sendMail(
      recipientEmail,
      url: url,
      subject: subject,
      body: body,
      attachments: attachments,
    );

    result.fold(
      (failure) => _onEmailSendFailure(failure.message),
      (_) => _onEmailSendSuccess(attachments),
    );
  }

  /// Handles the failure scenario during email sending
  void _onEmailSendFailure(String errorMessage) => AppUIUtils.onFailure(errorMessage);

  /// Handles the success scenario during email sending
  void _onEmailSendSuccess(List<String>? attachments) {
    AppUIUtils.onSuccess('تم إرسال البريد الإلكتروني بنجاح');
    if (attachments != null) {
      log('Attachments sent: ${attachments.first}');
      _deleteAttachments(attachments); // Optionally delete after sending
    } else {
      Get.back();
    }
  }

  /// Deletes attachments after email is sent successfully
  Future<void> _deleteAttachments(List<String> attachments) async {
    for (final filePath in attachments) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        log('Deleted file: $filePath');
      }
    }
  }

  /// Generates a PDF and sends it via email
  Future<void> generateAndSendBillPdf({
    required String recipientEmail,
    required BillModel billModel,
    required String fileName,
    String? logoSrc,
    String? fontSrc,
    String? url,
    String? subject,
    String? body,
  }) async {
    if (!hasBillId(billModel.billId)) return;

    if (!hasBillItems(billModel.items.itemList)) return;

    final pdfFilePath =
        await _generateBillPdf(billModel: billModel, fileName: fileName, logoSrc: logoSrc, fontSrc: fontSrc);

    await sendBillToEmail(
      recipientEmail: recipientEmail,
      url: url,
      subject: subject,
      body: body,
      attachments: [pdfFilePath],
    );
  }

  /// Generates the bill PDF and returns the file path
  Future<String> _generateBillPdf(
      {required BillModel billModel, required String fileName, String? logoSrc, String? fontSrc}) async {
    final pdfGeneratorRepo = PdfGeneratorRepository<BillModel>(pdfGenerator: BillPdfGenerator());

    return await pdfGeneratorRepo.savePdf(billModel, fileName, logoSrc: logoSrc, fontSrc: fontSrc);
  }

  bool hasBillItems(List<BillItem> items) {
    if (items.isEmpty) {
      AppUIUtils.onFailure('يرجى إضافة عنصر واحد على الأقل إلى الفاتورة!');
      return false;
    }
    return true;
  }

  bool hasBillId(String? billId) {
    if (billId == null) {
      AppUIUtils.onFailure('يرجى إضافة الفاتورة أولا قبل طباعتها!');
      return false;
    }
    return true;
  }
}
