import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../core/widgets/option_text_widget.dart';
import '../../../login/controllers/user_management_controller.dart';
import '../../controllers/invoice_controller.dart';

class BillButtons extends StatelessWidget {
  const BillButtons({
    super.key,
    required this.invoiceController,
  });

  final InvoiceController invoiceController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          AppButton(
              title: 'جديد',
              onPressed: () async {
                hasPermissionForOperation(AppConstants.roleUserWrite, AppConstants.roleViewInvoice).then((value) {
                  if (value) {}
                });
              },
              iconData: Icons.create_new_folder_outlined),
          AppButton(title: "إضافة", onPressed: () async {}, iconData: Icons.add_chart_outlined),
          AppButton(title: 'السند', onPressed: () async {}, iconData: Icons.file_open_outlined),
          AppButton(
            title: 'موافقة',
            onPressed: () async {},
            iconData: Icons.file_download_done_outlined,
            color: Colors.green,
          ),
          AppButton(title: "تعديل", onPressed: () async {}, iconData: Icons.edit_outlined),
          AppButton(
            title: "مبيعات",
            onPressed: () async {},
            iconData: Icons.done_all,
            color: Colors.green,
          ),
          ...[
            AppButton(
              iconData: Icons.print_outlined,
              title: 'طباعة',
              onPressed: () async {},
            ),
            AppButton(title: "E-Invoice", onPressed: () {}, iconData: Icons.link),
            AppButton(
              iconData: Icons.delete_outline,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {},
            )
          ],
          AppButton(
            iconData: Icons.more_horiz_outlined,
            title: 'المزيد',
            onPressed: () async {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  backgroundColor: AppColors.backGroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      height: 150,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Center(
                                child: Text(
                              'الخيارات',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            )),
                            const SizedBox(height: 15),
                            const Text('الدفعة الاولى '),
                            const SizedBox(height: 5),
                            Expanded(
                              child: CustomTextFieldWithoutIcon(
                                controller: invoiceController.firstPayController,
                                onChanged: (text) => invoiceController.firstPayController.text = text,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('موافق'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          AppButton(
            iconData: Icons.more_horiz_outlined,
            title: 'المزيد',
            onPressed: () async {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  backgroundColor: AppColors.backGroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'تفاصيل فاتورة المبيع المراد ارجاعها',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 15),
                          OptionTextWidget(
                            title: "رقم الفاتورة :",
                            controller: invoiceController.invReturnCodeController,
                            onSubmitted: (text) async {
                              invoiceController.invReturnCodeController.text = text;
                            },
                          ),
                          const SizedBox(height: 5),
                          OptionTextWidget(
                            title: "تاريخ الفاتورة:  ",
                            controller: invoiceController.invReturnDateController,
                            onSubmitted: (text) async {
                              invoiceController.invReturnDateController.text = Utils.getDateFromString(text);
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text('موافق'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
