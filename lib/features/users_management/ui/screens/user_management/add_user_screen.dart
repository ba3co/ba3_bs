import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/users_management/ui/screens/user_management/time_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';
import '../../widgets/user_management/add_edit_user_form.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserManagementController userManagementViewController = Get.find<UserManagementController>();
    SellerController sellerViewController = Get.find<SellerController>();
    return Column(
      children: [
        Expanded(
          child: GetBuilder<UserManagementController>(builder: (controller) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: false,
                  title: Text(controller.initAddUserModel?.userName ?? "مستخدم جديد"),
                  actions: [
                    if (controller.initAddUserModel?.userId != null)
                      ElevatedButton(
                          onPressed: () {
                            Get.to(() => TimeDetailsScreen(
                                  oldKey: controller.initAddUserModel!.userId!,
                                  name: controller.initAddUserModel!.userName!,
                                ));
                          },
                          child: const Text('البريك')),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: AddEditUserForm(
                          userManagementController: userManagementViewController,
                          sellerController: sellerViewController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: .15.sh),
                        child: AppButton(
                          title: controller.roleModel?.roleId == null ? 'إضافة' : 'تعديل',
                          onPressed: () {
                            controller.saveOrUpdateUser(existingUserModel: controller.userModel);
                          },
                          iconData: controller.roleModel?.roleId == null ? Icons.add : Icons.edit,
                          color: controller.initAddUserModel?.userId == null ? null : Colors.green,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
