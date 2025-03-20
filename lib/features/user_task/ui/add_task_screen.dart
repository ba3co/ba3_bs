import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/user_task/ui/widgets/add_task_header.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../controller/all_task_controller.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllTaskController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
          AppStrings.addNewTask.tr,
          style: AppTextStyles.headLineStyle3,
        )),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.taskFormHandler.formKey,
            child: ListView(
              // spacing: 15,
              children: [
                AddTaskHeader(controller: controller)
                /*      TextAndExpandedChildField(
                  label: AppStrings.taskTitle.tr,
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: controller.taskFormHandler.titleTextEditingController,
                    validator: (value) => controller.taskFormHandler.validator(value, 'يرجى إدخال العنوان'),
                  ),
                ),
                TextAndExpandedChildField(
                  label: AppStrings.materials.tr,
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: controller.taskFormHandler.materialTextController,
                    onSubmitted: (_) async {
                      controller.addMaterialToList(context);
                    },
                  ),
                ),
                FormFieldRow(
                  firstItem: Obx(() {
                    return TextAndExpandedChildField(
                      label: AppStrings.status.tr,
                      child: OverlayService.showDropdown<TaskStatus>(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        items: TaskStatus.values,
                        onChanged: (value) {
                          controller.taskFormHandler.setTaskStatus(value);
                        },
                        value: controller.taskFormHandler.selectedStatus.value,
                        itemLabelBuilder: (TaskStatus item) => item.value,
                      ),
                    );
                  }),
                  secondItem: Obx(() {
                    return TextAndExpandedChildField(
                      label: AppStrings.taskType.tr,
                      child: OverlayService.showDropdown<TaskType>(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        items: TaskType.values,
                        onChanged: (value) {
                          controller.taskFormHandler.setTaskType(value);
                        },
                        value: controller.taskFormHandler.selectedTaskType.value,
                        itemLabelBuilder: (TaskType item) => item.label,
                      ),
                    );
                  }),
                ),
                VerticalSpace(15),
                FormFieldRow(
                  firstItem: TextAndExpandedChildField(
                    label: AppStrings.lastDateTodo.tr,
                    child: Obx(() {
                      return DatePicker(
                        initDate: controller.taskFormHandler.dueDate.value.dayMonthYear,
                        onDateSelected: (date) {
                          controller.taskFormHandler.setDueDate(date);
                          // billDetailsController.setBillDate = date;
                        },
                      );
                    }),
                  ),
                  secondItem: TextAndExpandedChildField(
                    label: AppStrings.createdDate.tr,
                    child: Obx(() {
                      return DatePicker(
                        initDate: controller.taskFormHandler.createDate.value.dayMonthYear,
                        onDateSelected: (date) {
                          controller.taskFormHandler.setCreateDate(date);
                        },
                      );
                    }),
                  ),
                )*/
                ,
                FormFieldRow(
                    firstItem: Column(
                      children: [
                        Container(
                          height: 450,
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          alignment: Alignment.center,
                          child: ListView.separated(
                            separatorBuilder: (context, index) => VerticalSpace(),
                            itemCount: controller.userList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(controller.userList[index].userName!, style: TextStyle(fontSize: 16)),
                                subtitle: Text("${AppStrings.identificationNumber.tr}: ${controller.userList[index].userId}",
                                    style: TextStyle(color: Colors.grey)),
                                trailing: Checkbox(
                                  value: controller.checkUserStatus(controller.userList[index].userId!),
                                  onChanged: (bool? value) {
                                    controller.updatedSelectedUsers(controller.userList[index].userId!, value!);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        VerticalSpace(5),
                        Row(
                          children: [
                            Text('تم تحديد ${controller.taskFormHandler.selectedUsers.length} من المستخدمين'),
                            Spacer(),
                            Row(
                              children: [
                                Text(controller.taskFormHandler.selectedUsers.isEmpty ? 'تحديد الكل' : 'الغاء الكل'),
                                HorizontalSpace(10),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints.loose(Size(30, 30)),
                                    onPressed: () {
                                      controller.selectOrDeselectAllUsers();
                                    },
                                    icon: Icon(
                                      controller.taskFormHandler.selectedUsers.isEmpty
                                          ? Icons.check_box_outline_blank_rounded
                                          : Icons.check_box_rounded,
                                      size: 18,
                                    )),
                              ],
                            ),
                            HorizontalSpace(10)
                          ],
                        )
                      ],
                    ),
                    secondItem: Container(
                      height: 450,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      alignment: Alignment.center,
                      child: ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: controller.taskFormHandler.materialTaskList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              controller.taskFormHandler.materialTaskList[index].materialName!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "${AppStrings.identificationNumber.tr}: ${controller.taskFormHandler.materialTaskList[index].docId}",
                                style: TextStyle(color: Colors.grey)),
                            leading: InkWell(
                                onTap: () {
                                  controller.removeMaterialFromList(index);
                                },
                                child: Icon(Icons.inventory)),
                            trailing: Text(
                              " ${AppStrings.quantity.tr} \n ${controller.taskFormHandler.materialTaskList[index].quantity}",
                              style: AppTextStyles.headLineStyle4,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    )),
                Divider(),
                VerticalSpace(),
                Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!controller.isNewTask)
                      AppButton(
                        title: AppStrings.delete.tr,
                        color: Colors.red,
                        onPressed: () {
                          controller.deleteTask();
                        },
                        iconData: FontAwesomeIcons.deleteLeft,
                      ),
                    AppButton(
                      title: controller.isNewTask ? AppStrings.save.tr : AppStrings.edit.tr,
                      color: controller.isNewTask ? null : Colors.green,
                      onPressed: () {
                        controller.saveOrUpdateTask();
                      },
                      iconData: controller.isNewTask ? FontAwesomeIcons.plusSquare : FontAwesomeIcons.edit,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
