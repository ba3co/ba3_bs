import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/sellers/controllers/add_seller_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';

class AddSellerScreen extends StatelessWidget {
  const AddSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddSellerController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(controller.selectedSellerModel?.costName ?? 'جديد'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.width * 0.44,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AutofillHints.name),
                        HorizontalSpace(20),
                        Expanded(
                          child: CustomTextFieldWithoutIcon(
                            textEditingController: controller.nameController,
                            suffixIcon: const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.44,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppStrings().code),
                        HorizontalSpace(20),
                        Expanded(
                          child: CustomTextFieldWithoutIcon(
                            textEditingController: controller.codeController,
                            suffixIcon: const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: .15.sh),
                  child: AppButton(
                    title: controller.selectedSellerModel?.costGuid == null ? AppStrings().add : AppStrings().edit,
                    onPressed: () {
                      controller.saveOrUpdateSeller();
                    },
                    iconData: controller.selectedSellerModel?.costGuid == null ? Icons.add : Icons.edit,
                    color: controller.selectedSellerModel?.costGuid == null ? null : Colors.green,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
