import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../login/controllers/user_management_controller.dart';
import '../../../data/models/role_model.dart';

class AddRoleScreen extends StatelessWidget {
  const AddRoleScreen({super.key, this.roleModel});

  final RoleModel? roleModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: GetBuilder<UserManagementController>(builder: (controller) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(controller.oldRoleModel?.roleName ?? "دور جديد"),
                  actions: [
                    AppButton(
                        title: controller.oldRoleModel?.roleId == null ? "إضافة" : "تعديل",
                        onPressed: () {
                          if (controller.oldRoleModel?.roleName?.isNotEmpty ?? false) {
                            controller.addRole();
                          }
                        },
                        iconData: controller.oldRoleModel?.roleId == null ? Icons.add : Icons.edit),
                    const SizedBox(width: 10),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ListView(
                    children: [
                      const Text(
                        "الاسم",
                        style: TextStyle(fontSize: 16),
                      ),
                      Container(
                        color: Colors.grey.shade200,
                        child: TextFormField(
                          controller: controller.roleNameController,
                        ),
                      ),
                      for (final role in RoleItemType.values)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.value,
                                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 50),
                                child: Column(
                                  children: [
                                    checkBoxWidget(role, RoleItem.userRead, controller),
                                    checkBoxWidget(role, RoleItem.userWrite, controller),
                                    checkBoxWidget(role, RoleItem.userUpdate, controller),
                                    checkBoxWidget(role, RoleItem.userDelete, controller),
                                    checkBoxWidget(role, RoleItem.userAdmin, controller),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget checkBoxWidget(RoleItemType key, RoleItem roleItem, UserManagementController controller) {
    return Row(
      children: [
        StatefulBuilder(builder: (context, setState) {
          return Checkbox(
              fillColor: WidgetStatePropertyAll(Colors.blue.shade800),
              checkColor: Colors.white,
              overlayColor: const WidgetStatePropertyAll(Colors.white),
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Colors.white)),
              value: (controller.rolesMap[key]?.contains(roleItem) ?? false),
              onChanged: (newValue) {
                if (newValue!) {
                  if (controller.rolesMap[key] == null) {
                    controller.rolesMap[key] = [roleItem];
                  } else {
                    controller.rolesMap[key]?.add(roleItem);
                  }
                } else {
                  controller.rolesMap[key]?.remove(roleItem);
                }

                setState(() {});
              });
        }),
        Text(
          roleItem.value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }
}
