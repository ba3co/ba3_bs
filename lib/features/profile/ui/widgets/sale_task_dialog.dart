import 'package:ba3_bs/features/user_task/data/model/user_task_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../floating_window/services/overlay_service.dart';

class SaleTaskDialog extends StatelessWidget {
  final UserTaskModel task;
  const SaleTaskDialog({super.key,required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400,
          color: Colors.white,
          alignment: Alignment.center,
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: task.materialTask!.length,
            itemBuilder: (context, materialIndex) {
              return ListTile(
                title: Text(
                  task.materialTask![materialIndex].materialName!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    "${AppStrings.identificationNumber.tr}: ${task.materialTask![materialIndex].docId}",
                    style: TextStyle(color: Colors.grey)),
                leading: Icon(Icons.inventory),
                trailing: Text(
                  " ${AppStrings.quantity.tr} \n ${task.materialTask![materialIndex].quantity}",
                  style: AppTextStyles.headLineStyle4,
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
        if (task.taskType != TaskType.saleTask)
          AppButton(
            title: AppStrings.save.tr,
            onPressed: () {
              if (task.status == TaskStatus.initial) {
                task.status = TaskStatus.inProgress;
              } else {
                task.status = TaskStatus.done;
              }
              OverlayService.back();
            },
          )
      ],
    );
  }
}