import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/users_management/controllers/user_details_controller.dart';
import 'package:ba3_bs/features/users_management/ui/widgets/user_management/user_all_holidays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../widgets/user_management/user_all_working_hours.dart';
import '../../widgets/user_management/user_details_form_widget.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SellersController sellersController = read<SellersController>();

    return GetBuilder<UserDetailsController>(builder: (controller) {
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
                userDetailsController: controller,
                sellerController: sellersController,
              ),
              UserAllWorkingHour(controller: controller),
              UserAllHolidays(controller: controller),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    title: controller.selectedUserModel?.userId == null ? 'إضافة' : 'تعديل',
                    onPressed: () {
                      controller.saveOrUpdateUser();
                    },
                    iconData:  controller.selectedUserModel?.userId == null ? Icons.add : Icons.edit,
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
