import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:ba3_bs/features/users_management/ui/widgets/user_management/user_all_holidays.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';
import '../../widgets/user_management/user_all_working_hours.dart';
import '../../widgets/user_management/user_details_form_widget.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserManagementController userManagementViewController = read<UserManagementController>();
    SellerController sellerViewController = read<SellerController>();
    return Column(
      children: [
        Expanded(
          child: GetBuilder<UserManagementController>(builder: (controller) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                title: Text(controller.selectedUserModel?.userName ?? 'مستخدم جديد'),
                actions: [
                  // if (controller.selectedUserModel?.userId != null)
                  //   ElevatedButton(
                  //       onPressed: () {
                  //         Get.to(() => TimeDetailsScreen(
                  //               oldKey: controller.loggedInUserModel!.userId!,
                  //               name: controller.loggedInUserModel!.userName!,
                  //             ));
                  //       },
                  //       child: const Text('البريك')),
                  // const SizedBox(
                  //   width: 20,
                  // ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    UserDetailsForm(
                      userManagementController: userManagementViewController,
                      sellerController: sellerViewController,
                    ),
                    UserAllWorkingHour(controller: controller,),
                    UserAllHolidays(controller: controller,),
                    Padding(
                      padding: EdgeInsets.only(bottom: .15.sh),
                      child: AppButton(
                        title: controller.selectedUserModel?.userId == null ? 'إضافة' : 'تعديل',
                        onPressed: () {
                          controller.saveOrUpdateUser();
                        },
                        iconData: controller.roleModel?.roleId == null ? Icons.add : Icons.edit,
                        color: controller.selectedUserModel?.userId == null ? null : Colors.green,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}




