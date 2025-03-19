import 'dart:io';

import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/user_task/controller/all_task_controller.dart';
import 'package:ba3_bs/features/user_task/data/model/user_task_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../floating_window/services/overlay_service.dart';

class GeneralTaskDialog extends StatelessWidget {
  final UserTaskModel task;

  const GeneralTaskDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(builder: (userManagementController) {
      return Column(
        children: [
          Container(
            height: 340,
            color: Colors.white,
            alignment: Alignment.center,
            child: userManagementController.image == null
                ? Text(AppStrings.uploadImage.tr, style: AppTextStyles.headLineStyle3)
                : GestureDetector(
                    onTap: () => AppUIUtils.showFullScreenNetworkImage(context, userManagementController.image!.path),
                    child: Image.file(
                      File(
                        userManagementController.image!.path,
                      ),
                      fit: BoxFit.contain,
                      height: 340,
                    )),
          ),
          VerticalSpace(),
          AppButton(
            title: AppStrings.uploadImage.tr,
            onPressed: userManagementController.pickImage,
          ),
          VerticalSpace(),
          AppButton(
            title: AppStrings.save.tr,
            onPressed: () {
              if (userManagementController.image != null) {
                read<AllTaskController>().uploadImageTask(task, userManagementController.image!.path);
              }
              userManagementController.image=null;
              OverlayService.back();
            },
          )
        ],
      );
    });
  }
}