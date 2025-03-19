import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            title,
            style: AppTextStyles.headLineStyle4,
          ),
        ),
        Container(
          height: 250.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
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
                    Text(task.status!.value),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}