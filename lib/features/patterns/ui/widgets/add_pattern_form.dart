import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../controllers/pattern_controller.dart';
import 'add_pattern_type.dart';

class AddPatternForm extends StatelessWidget {
  const AddPatternForm({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: patternController.formKey,
      child: Wrap(spacing: 20, alignment: WrapAlignment.spaceBetween, runSpacing: 10, children: [
        SizedBox(
          width: Get.width * 0.45,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text('الاختصار')),
              Expanded(
                child: CustomTextFieldWithoutIcon(
                  controller: patternController.shortNameController,
                  validator: (shortName) => patternController.validator(shortName, 'الاختصار'),
                  onChanged: (value) {
                    // patternController.editPatternModel?.copyWith(patName: value);
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
                  validator: (fullName) => patternController.validator(fullName, 'الاسم'),
                  onChanged: (value) {
                    // patternController.editPatternModel?.copyWith(patFullName: value);
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
                  controller: patternController.latinShortNameController,
                  validator: (latinShortName) => patternController.validator(latinShortName, 'اختصار لاتيني'),
                  onChanged: (value) {
                    //    patternController.editPatternModel?.copyWith(patName: value);
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
                  controller: patternController.latinFullNameController,
                  validator: (latinFullName) => patternController.validator(latinFullName, 'الاسم لاتيني'),
                  onChanged: (value) {
                    //   patternController.editPatternModel?.copyWith(patFullName: value);
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
                  controller: patternController.materialsController,
                  validator: (materials) => patternController.validator(materials, 'المواد'),
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
                  controller: patternController.discountsController,
                  validator: (discounts) => patternController.validator(discounts, 'الحسميات'),
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
                  controller: patternController.additionsController,
                  validator: (additions) => patternController.validator(additions, 'الاضافات'),
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
                  controller: patternController.cachesController,
                  validator: (cashes) => patternController.validator(cashes, 'النقديات'),
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
              const SizedBox(width: 100, child: Text('الهدايا')),
              Expanded(
                child: CustomTextFieldWithIcon(
                  controller: patternController.giftsController,
                  validator: (gifts) => patternController.validator(gifts, 'الهدايا'),
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
                  controller: patternController.exchangeForGiftsController,
                  validator: (exchangeForGifts) => patternController.validator(exchangeForGifts, 'مقابل الهدايا'),
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
        SizedBox(
          width: Get.width * 0.45,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text('المستودع')),
              Expanded(
                child: CustomTextFieldWithIcon(
                  controller: patternController.storeController,
                  validator: (store) => patternController.validator(store, 'المستودع'),
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
      ]),
    );
  }
}
