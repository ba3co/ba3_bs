import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';
import 'add_user_screen.dart';

class AllUserScreen extends StatelessWidget {
  const AllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: GetBuilder<UserManagementController>(
              builder: (controller) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('إدارة المستخدمين'),
                    actions: [
                      AppButton(
                          title: 'إضافة',
                          onPressed: () {
                            Get.find<UserManagementController>().initUser();
                            Get.to(() => const AddUserScreen());
                          },
                          iconData: Icons.add),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        children: List.generate(
                          controller.allUserList.values.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Get.find<UserManagementController>()
                                    .initUser(controller.allUserList.values.toList()[index].userId);
                                Get.to(() => const AddUserScreen());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                height: 140,
                                width: 140,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      controller.allUserList.values.toList()[index].userName ?? "",
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
