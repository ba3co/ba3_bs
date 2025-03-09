import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_assets.dart';
import '../../constants/app_constants.dart';
import '../../services/mailer_messaging/implementations/gmail_messaging_service.dart';
import '../../services/mailer_messaging/implementations/mailer_messaging_repo.dart';
import '../../services/pdf_generator/implementations/pdf_generator_factory.dart';
import '../../services/pdf_generator/implementations/pdf_generator_repo.dart';
import '../../services/pdf_generator/interfaces/i_pdf_generator.dart';
import '../../utils/app_ui_utils.dart';

mixin PdfBase {
  /// Sends the bill email with optional attachments
  Future<void> sendToEmail({
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

  //ba3business@gmail.com
  //Ba3Alarab220011
  //+971568666411

  Future<void> sendWhatsAppInvoice({required String clientPhoneNumber, required String pdfPath}) async {
    final file = File(pdfPath);
    if (!await file.exists()) {
      log('⚠️ الملف غير موجود', name: 'SendWhatsAppInvoice');
      return;
    }

    final bytes = await file.readAsBytes();
    final base64File = base64Encode(bytes);

    var url = Uri.parse("https://graph.facebook.com/v18.0/YOUR_PHONE_NUMBER_ID/messages");

    var headers = {
      "Authorization": "Bearer YOUR_ACCESS_TOKEN",
      "Content-Type": "application/json",
    };

    var body = jsonEncode({
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": clientPhoneNumber,
      "type": "document",
      "document": {"filename": "E-Invoice.pdf", "data": base64File}
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      log('✅ الفاتورة أُرسلت بنجاح!', name: 'SendWhatsAppInvoice');
    } else {
      log('⚠️ فشل في الإرسال: ${response.body}', name: 'SendWhatsAppInvoice');
    }
  }

  /// Generates a PDF and sends it via Email
  Future<void> generatePdfAndSendToEmail<T>({
    required T itemModel,
    required String fileName,
    String? recipientEmail,
    String logoSrc = AppAssets.ba3Logo,
    String fontSrc = AppAssets.notoSansArabicRegular,
    String? url,
    String? subject,
    String? body,
  }) async {
    final pdfFilePath = await _generatePdf(itemModel: itemModel, fileName: fileName, logoSrc: logoSrc, fontSrc: fontSrc);

    await sendToEmail(
      recipientEmail: recipientEmail ?? AppConstants.recipientEmail,
      url: url,
      subject: subject,
      body: body,
      attachments: [pdfFilePath],
    );
  }

  /// Generates a PDF and sends it via WhatsAppI
  Future<void> generatePdfAndSendToWhatsApp<T>({
    required T itemModel,
    required String fileName,
    String? recipientEmail,
    String logoSrc = AppAssets.ba3Logo,
    String fontSrc = AppAssets.notoSansArabicRegular,
    String? url,
    String? subject,
    String? body,
  }) async {
    final pdfFilePath = await _generatePdf(itemModel: itemModel, fileName: fileName, logoSrc: logoSrc, fontSrc: fontSrc);

    await sendWhatsAppInvoice(clientPhoneNumber: "+201234567890", pdfPath: pdfFilePath);
  }

  /// Generates the bill PDF and returns the file path
  Future<String> _generatePdf<T>({
    required T itemModel,
    required String fileName,
    String? logoSrc,
    String? fontSrc,
  }) async {
    final IPdfGenerator pdfGenerator = PdfGeneratorFactory.resolveGenerator(itemModel);

    final pdfGeneratorRepo = PdfGeneratorRepository(pdfGenerator: pdfGenerator);

    return await pdfGeneratorRepo.savePdf(itemModel, fileName, logoSrc: logoSrc, fontSrc: fontSrc);
  }

  bool hasModelItems(List items) {
    if (items.isEmpty) {
      AppUIUtils.onFailure('يرجى إضافة عنصر واحد على الأقل إلى الفاتورة!');
      return false;
    }
    return true;
  }

  bool hasModelId(String? itemId) {
    if (itemId == null) {
      AppUIUtils.onFailure('يرجى إضافة الفاتورة أولا!');
      return false;
    }
    return true;
  }
}
