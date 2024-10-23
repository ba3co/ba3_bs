import 'package:ba3_bs/features/patterns/ui/widgets/partner_ratio_commission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../controllers/pattern_controller.dart';
import 'add_pattern_type.dart';

class AddPatternForm extends StatelessWidget {
  const AddPatternForm({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 20, alignment: WrapAlignment.spaceBetween, runSpacing: 10, children: [
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('الاختصار')),
            Expanded(
              child: CustomTextFieldWithoutIcon(
                controller: patternController.nameController,
                onChanged: (value) {
                  patternController.editPatternModel?.patName = value;
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('الاسم')),
            Expanded(
              child: CustomTextFieldWithoutIcon(
                controller: patternController.fullNameController,
                onChanged: (value) {
                  patternController.editPatternModel?.patFullName = value;
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('اختصار لاتيني')),
            Expanded(
              child: CustomTextFieldWithoutIcon(
                controller: patternController.nameController,
                onChanged: (value) {
                  patternController.editPatternModel?.patName = value;
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('الاسم لاتيني')),
            Expanded(
              child: CustomTextFieldWithoutIcon(
                controller: patternController.fullNameController,
                onChanged: (value) {
                  patternController.editPatternModel?.patFullName = value;
                },
              ),
            ),
          ],
        ),
      ),
      PatternType(patternController: patternController),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('المواد')),
            Expanded(
              child: CustomTextFieldWithIcon(
                controller: patternController.secondaryController,
                onSubmitted: (text) async {
                  // var account = await getAccountComplete(text);
                  // patternController.update();
                  // if (account.isNotEmpty) {
                  //   patternController.editPatternModel?.patSecondary = account;
                  //   patternController.secondaryController.text = account;
                  //   patternController.update();
                  // }
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('الحسميات')),
            Expanded(
              child: CustomTextFieldWithIcon(
                controller: patternController.secondaryController,
                onSubmitted: (text) async {
                  // var account = await getAccountComplete(text);
                  // patternController.update();
                  // if (account.isNotEmpty) {
                  //   patternController.editPatternModel?.patSecondary = account;
                  //   patternController.secondaryController.text = account;
                  //   patternController.update();
                  // }
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('الاضافات')),
            Expanded(
              child: CustomTextFieldWithIcon(
                controller: patternController.secondaryController,
                onSubmitted: (text) async {
                  // var account = await getAccountComplete(text);
                  // patternController.update();
                  // if (account.isNotEmpty) {
                  //   patternController.editPatternModel?.patSecondary = account;
                  //   patternController.secondaryController.text = account;
                  //   patternController.update();
                  // }
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('النقديات')),
            Expanded(
              child: CustomTextFieldWithIcon(
                controller: patternController.secondaryController,
                onSubmitted: (text) async {
                  // var account = await getAccountComplete(text);
                  // patternController.update();
                  // if (account.isNotEmpty) {
                  //   patternController.editPatternModel?.patSecondary = account;
                  //   patternController.secondaryController.text = account;
                  //   patternController.update();
                  // }
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('الرقم')),
            Expanded(
              child: CustomTextFieldWithoutIcon(
                controller: patternController.codeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  patternController.editPatternModel?.patCode = value;
                },
              ),
            ),
          ],
        ),
      ),
      if (patternController.editPatternModel?.patType == AppConstants.invoiceTypeChange)
        SizedBox(
          width: Get.width * 0.45,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text('المستودع الجديد')),
              Expanded(
                child: CustomTextFieldWithIcon(
                  controller: patternController.storeNewController,
                  onSubmitted: (text) async {
                    // var store = await patternController.getStoreComplete(text);
                    // if (store.isNotEmpty) {
                    //   patternController.editPatternModel?.patNewStore = store;
                    //   patternController.storeNewController.text = store;
                    //   patternController.update();
                    // }
                  },
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      if (patternController.editPatternModel?.patType != AppConstants.invoiceTypeChange) ...[
        SizedBox(
          width: Get.width * 0.45,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text('الهدايا')),
              Expanded(
                child: CustomTextFieldWithIcon(
                  controller: patternController.giftAccountController,
                  onSubmitted: (text) async {
                    //   var a = await getAccountComplete(text);
                    //   patternController.update();
                    //   if (a.isNotEmpty) {
                    //     patternController.editPatternModel?.patGiftAccount = a;
                    //     patternController.giftAccountController.text = a;
                    //     patternController.update();
                    //   }
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: Get.width * 0.45,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text('مقابل الهدايا')),
              Expanded(
                child: CustomTextFieldWithIcon(
                  controller: patternController.secgiftAccountController,
                  onSubmitted: (text) async {
                    // var a = await getAccountComplete(text);
                    // patternController.update();
                    // if (a.isNotEmpty) {
                    //   patternController.editPatternModel?.patSecGiftAccount = a;
                    //   patternController.secgiftAccountController.text = a;
                    //   patternController.update();
                    // }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
      SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            const SizedBox(width: 100, child: Text('المستودع')),
            Expanded(
              child: CustomTextFieldWithIcon(
                controller: patternController.storeEditController,
                onSubmitted: (text) async {
                  // var a = await patternController.getStoreComplete(text);
                  // if (a.isNotEmpty) {
                  //   patternController.editPatternModel?.patStore = a;
                  //   patternController.storeEditController.text = a;
                  //   patternController.update();
                  // }
                },
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
      if (patternController.editPatternModel?.patType == AppConstants.invoiceTypeSalesWithPartner) ...[
        SizedBox(
          width: (Get.width * 0.45),
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text('حساب مرابح الشريك')),
              Expanded(
                child: CustomTextFieldWithIcon(
                  controller: patternController.patPartnerAccountFee,
                  onSubmitted: (text) async {
                    // var a = await Utils.getAccountComplete(text);
                    //
                    // patternController.update();
                    // if (a.isNotEmpty) {
                    //   patternController.editPatternModel?.patPartnerFeeAccount = a;
                    //   patternController.patPartnerAccountFee.text = a;
                    //   patternController.update();
                    // }
                  },
                ),
              ),
            ],
          ),
        ),
        PartnerRatioCommission(patternController: patternController),
      ],
    ]);
  }
}
