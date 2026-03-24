
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/floating_window/services/overlay_service.dart';

class EInvoiceDialogContent extends StatelessWidget {
  const EInvoiceDialogContent({
    super.key,
    required this.billDetailsController,
    required this.billId,
    required this.billModel,
  });

  final BillDetailsController billDetailsController;
  final BillModel billModel;
  final String billId;



  @override
  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== Header (Gradient) =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      color.primary.withOpacity(.15),
                      color.secondary.withOpacity(.12),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.primary.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_rounded, color: color.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.eInvoice,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.savePdfLocal, // سطر وصفي خفيف
                            style: theme.textTheme.bodySmall?.copyWith(color: color.onSurface.withOpacity(.6)),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Clipboard.setData(
                        ClipboardData(text: "$billId (${billModel.billDetails.billNumber!})"),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 16, color: color.onSecondaryContainer),
                            const SizedBox(width: 6),
                            Text(
                              '#${billModel.billDetails.billNumber!}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: color.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Body =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ----- Card: Send via Email -----
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.surfaceVariant.withOpacity(.24),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.outline.withOpacity(.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.send_rounded, color: color.primary),
                              const SizedBox(width: 8),
                              Text(AppStrings.sendViaEmail, style: AppTextStyles.headLineStyle3),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Form(
                            key: formKey,
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextFieldWithoutIcon(
                                    filedColor: Colors.white,
                                    textEditingController: emailCtrl,
                                    validator: (v) {
                                      final s = (v ?? '').trim();
                                      final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                      if (s.isEmpty) return 'Email is required';
                                      if (!re.hasMatch(s)) return 'Invalid email';
                                      return null;
                                    },
                                    onSubmitted: (_) {
                                      if (formKey.currentState!.validate()) {
                                        _sendEmail(context, emailCtrl.text);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      _sendEmail(context, emailCtrl.text);
                                    }
                                  },
                                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                                  label: Text(AppStrings.send),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ----- Card: Save PDF -----
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.surfaceVariant.withOpacity(.24),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.outline.withOpacity(.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.save_alt_rounded, color: color.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppStrings.weWillSavePdfLocal,
                              style: AppTextStyles.headLineStyle3.copyWith(
                                color: color.onSurface.withOpacity(.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _savePdf(context),
                            icon: const Icon(Icons.download_rounded),
                            label: Text(AppStrings.save),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // ===== Footer (Actions) =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: OverlayService.back,
                        icon: const Icon(Icons.close_outlined),
                        label:  Text(AppStrings.close),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers (Stateless-friendly) =====
  Future<void> _withProgress(BuildContext context, Future<void> Function() task) async {
    OverlayService.showDialog(context: context, content: Center(
      child: CircularProgressIndicator(),
    ));

    String? error;
    try {
      await task();
    } catch (e) {
      error = e.toString();
    } finally {
      OverlayService.back(); // اغلق المؤشر
    }
    if (error != null) {
      if(!context.mounted)return;
      _toast(context, 'Operation failed: $error', error: true);
    }
  }

  void _toast(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRe.hasMatch(email.trim())) {
      _toast(context, 'Invalid email', error: true);
      return;
    }
    await _withProgress(context, () async {
      billDetailsController.generateAndSendBillPdfToEmail(
        billModel,
        context,
        recipientEmail: email.trim(),
      );
      _toast(context, 'Email sent');
    });
  }

  Future<void> _savePdf(BuildContext context) async {
    await _withProgress(context, () async {

      await billDetailsController.generateAndSaveBillPdf(billModel, context);
      if (!context.mounted) return;
      _toast(context, 'PDF saved successfully');
    });
  }
}