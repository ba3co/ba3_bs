import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/users_management/ui/widgets/user_management/user_all_holidays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';
import '../../widgets/user_management/user_all_working_hours.dart';
import '../../widgets/user_management/user_details_form_widget.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserManagementController userManagementController = read<UserManagementController>();
    SellersController sellersController = read<SellersController>();

    return GetBuilder<UserManagementController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(controller.selectedUserModel?.userName ?? 'مستخدم جديد'),
        ),
        body: Center(
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              UserDetailsForm(
                userManagementController: userManagementController,
                sellerController: sellersController,
              ),
              UserAllWorkingHour(
                controller: controller,
              ),
              UserAllHolidays(
                controller: controller,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    title: controller.selectedUserModel?.userId == null ? 'إضافة' : 'تعديل',
                    onPressed: () {
                      controller.saveOrUpdateUser();
                    },
                    iconData: controller.roleModel?.roleId == null ? Icons.add : Icons.edit,
                    color: controller.selectedUserModel?.userId == null ? null : Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
