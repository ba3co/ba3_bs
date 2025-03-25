import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../features/migration/controllers/migration_controller.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_constants.dart';
import '../../services/mailer_messaging/implementations/gmail_messaging_service.dart';
import '../../services/mailer_messaging/implementations/mailer_messaging_repo.dart';
import '../../services/pdf_generator/implementations/pdf_generator_factory.dart';
import '../../services/pdf_generator/implementations/pdf_generator_repo.dart';
import '../../services/pdf_generator/interfaces/i_pdf_generator.dart';
import '../../utils/app_ui_utils.dart';
import '../extensions/getx_controller_extensions.dart';

mixin PdfBase {
  /// Sends the bill email with optional attachments
  Future<void> sendToEmail({
    required String recipientEmail,
    String? documentId,
    String? type,
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

    String? invoiceUrl = url;

    if (itemModel is BillModel && invoiceUrl == null) {
      invoiceUrl = generateInvoiceUrl(documentId: itemModel.billId!, type: itemModel.billTypeModel.billTypeLabel!);
    }

    await sendToEmail(
      recipientEmail: recipientEmail ?? AppConstants.recipientEmail,
      url: invoiceUrl,
      subject: subject,
      body: body,
      attachments: [pdfFilePath],
    );
  }

  /// Generates a PDF and sends it via WhatsAppI
  Future<void> sendBillToWhatsApp({required BillModel itemModel, required String recipientPhoneNumber}) async {
    final invoiceUrl = generateInvoiceUrl(documentId: itemModel.billId!, type: itemModel.billTypeModel.billTypeLabel!);

    await sendWhatsAppInvoiceLink(clientPhoneNumber: recipientPhoneNumber, invoiceUrl: invoiceUrl);
  }

  //ba3business@gmail.com
  //Ba3Alarab220011
  //+971568666411
  String get year {
    final MigrationController migrationController = read<MigrationController>();

    final currentVersion = migrationController.currentVersion;

    return currentVersion == AppConstants.defaultVersion || currentVersion.isEmpty ? '' : currentVersion;
  }

  String generateInvoiceUrl({required String documentId, required String type}) {
    final baseUrl = 'https://ba3-bs.web.app';
    final params = {
      'id': documentId,
      'type': type,
      if (year != '') 'year': year,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    return uri.toString();
  }

  Future<void> sendWhatsAppInvoiceLink({
    required String clientPhoneNumber,
    required String invoiceUrl,
  }) async {
    var url = Uri.parse('https://graph.facebook.com/v22.0/${ApiConstants.whatsappPhoneNumberID}/messages');

    var headers = {
      'Authorization': 'Bearer ${ApiConstants.whatsappAccessToken}',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode(
      {
        "messaging_product": "whatsapp",
        "to": clientPhoneNumber,
        "type": "template",
        "template": {
          "name": "e_invoice",
          "language": {"code": "en_US"},
          "components": [
            {
              "type": "body",
              "parameters": [
                {"type": "text", "text": invoiceUrl}
              ]
            }
          ]
        }
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      log('✅ تم إرسال رابط الفاتورة بنجاح!', name: 'SendWhatsAppInvoiceLink');
      AppUIUtils.onSuccess('✅ تم إرسال رابط الفاتورة بنجاح!');
    } else {
      log('⚠️ فشل في إرسال الرابط: ${response.body}', name: 'SendWhatsAppInvoiceLink');
    }
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
