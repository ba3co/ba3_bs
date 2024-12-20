import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../login/controllers/user_management_controller.dart';

class AllPermissionsScreen extends StatelessWidget {
  const AllPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text("إدارة الصلاحيات"),
                  actions: [
                    AppButton(
                        title: "إضافة",
                        onPressed: () {
                          Get.find<UserManagementController>().navigateToAddRoleScreen();
                        },
                        iconData: Icons.add),
                    const SizedBox(width: 10),
                  ],
                ),
                body: GetBuilder<UserManagementController>(builder: (controller) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        children: List.generate(
                          controller.roles.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                controller.navigateToAddRoleScreen(controller.roles[index]);
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
                                      controller.roles[index].roleName ?? "",
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
                  );
                  //       return ListView.builder(
                  //         itemCount: controller.allRole.length,
                  //         itemBuilder: (context,index){
                  //         return InkWell(onTap: (){
                  //           Get.to(()=>AddRoleView(oldKey:controller.allRole.keys.toList()[index] ,));
                  //         },child: Text(controller.allRole.values.toList()[index].roleName??"error"));
                  // },
                  // );
                })),
          ),
        ),
      ],
    );
  }
}
