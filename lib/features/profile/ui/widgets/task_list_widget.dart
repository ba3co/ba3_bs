import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/features/user_task/data/model/user_task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styling/app_text_style.dart';

class TaskListWidget extends StatelessWidget {
  final List<UserTaskModel> taskList;
  final Function(UserTaskModel) onTap;
  final String title;

  const TaskListWidget({
    super.key,
    required this.taskList,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 2),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
                ),
                Spacer(),
                Text(taskList.length.toString(),style: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),)
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];
                return ListTile(
                  onTap: () => onTap(task),
                  title: Text(
                    task.title!,
                    style: AppTextStyles.headLineStyle3,
                  ),
                  subtitle: Text(
                    "اخر تاريخ للمهمة ${task.dueDate!.dayMonthYear}",
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: Column(
                    children: [
                      Text(task.taskType!.label),
                      Text(
                        task.status!.value,
                        style: AppTextStyles.headLineStyle4.copyWith(
                            color: task.status.isFailed
                                ? Colors.red
                                : task.status.isInProgress
                                    ? Colors.green
                                    : AppColors.mobileSaleColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}