import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:ba3_bs/features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/widgets/date_picker.dart';
import '../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../controller/add_task_controller.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddTaskController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(title: Text('إضافة مهمة جديدة')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: ListView(
              // spacing: 15,
              children: [
                TextAndExpandedChildField(
                  label: AppStrings.taskTitle.tr,
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: controller.titleTextEditingController,
                    // decoration: InputDecoration(labelText: 'عنوان المهمة'),
                    validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال العنوان' : null,
                  ),
                ),
                TextAndExpandedChildField(
                  label: AppStrings.materials.tr,
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: controller.materialTextController,
                    onSubmitted: (_) async {
                      controller.addMaterialToList(context);
                    },
                    validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال الوصف' : null,
                  ),
                ),
                /*      TextAndExpandedChildField(
              label: AppStrings.status.tr,
              child: OverlayService.showDropdown<TaskStatus>(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(5),
                ),
                items: TaskStatus.values,
                onChanged: (value) {},
                value: controller.selectedStatus.value,
                itemLabelBuilder: (TaskStatus item) => item.value,
              ),
            ),
            VerticalSpace(15),*/
                FormFieldRow(
                  firstItem: TextAndExpandedChildField(
                    label: AppStrings.status.tr,
                    child: OverlayService.showDropdown<TaskStatus>(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      items: TaskStatus.values,
                      onChanged: (value) {},
                      value: controller.selectedStatus.value,
                      itemLabelBuilder: (TaskStatus item) => item.value,
                    ),
                  ),
                  secondItem: TextAndExpandedChildField(
                    label: AppStrings.taskType.tr,
                    child: OverlayService.showDropdown<TaskType>(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      items: TaskType.values,
                      onChanged: (value) {},
                      value: controller.selectedTaskType.value,
                      itemLabelBuilder: (TaskType item) => item.label,
                    ),
                  ),
                ),
                VerticalSpace(15),
                FormFieldRow(
                  firstItem: TextAndExpandedChildField(
                    label: AppStrings.lastDateTodo.tr,
                    child: Obx(() {
                      return DatePicker(
                        initDate: controller.dueDate.value.dayMonthYear,
                        onDateSelected: (date) {
                          // billDetailsController.setBillDate = date;
                        },
                      );
                    }),
                  ),
                  secondItem: TextAndExpandedChildField(
                    label: AppStrings.createdDate.tr,
                    child: Obx(() {
                      return DatePicker(
                        initDate: controller.createDate.value.dayMonthYear,
                        onDateSelected: (date) {
                          // billDetailsController.setBillDate = date;
                        },
                      );
                    }),
                  ),
                ),
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
                            Text('تم تحديد ${controller.selectedUsers.length} من المستخدمين'),
                            Spacer(),
                            Row(
                              children: [
                                Text(controller.selectedUsers.isEmpty ? 'تحديد الكل' : 'الغاء الكل'),
                                HorizontalSpace(10),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints.loose(Size(30, 30)),
                                    onPressed: () {
                                      controller.selectOrDeselectAllUsers();
                                    },
                                    icon: Icon(
                                      controller.selectedUsers.isEmpty ? Icons.check_box_outline_blank_rounded : Icons.check_box_rounded,
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
                        itemCount: controller.materialTaskList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              controller.materialTaskList[index].materialName!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("${AppStrings.identificationNumber.tr}: ${controller.materialTaskList[index].docId}",
                                style: TextStyle(color: Colors.grey)),
                            leading: InkWell(
                                onTap: () {
                                  controller.removeMaterialFromList(index);
                                },
                                child: Icon(Icons.inventory)),
                            trailing: Text(
                              " ${AppStrings.quantity.tr} \n ${controller.materialTaskList[index].quantity}",
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
                    AppButton(title: AppStrings.save.tr, onPressed: () {},iconData: Icons.save_alt_rounded,),

                    AppButton(title: AppStrings.newS.tr, onPressed: () {},iconData:Icons.new_releases_rounded,color: Colors.green,),
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