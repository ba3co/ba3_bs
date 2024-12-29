import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OrganizedWidget(
                          titleWidget: Center(
                            child: Text(
                              "دوام المستخدم",
                              style: AppTextStyles.headLineStyle2,
                            ),
                          ),
                          bodyWidget: Column(
                            children: [
                              UserAllWorkingHour(),
                              IconButton(
                                  onPressed: () {
                                    controller.addWorkingHour();
                                  },
                                  icon: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 12,
                                        color: AppColors.blueColor,
                                      ),
                                      Text(
                                        'اضافة',
                                        style: AppTextStyles.headLineStyle4.copyWith(fontSize: 12, color: AppColors.blueColor),
                                      )
                                    ],
                                  ))
                            ],
                          )),
                    ),
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

class UserAllWorkingHour extends StatelessWidget {
  const UserAllWorkingHour({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(builder: (controller) {
      return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) => WorkingHoursItem(

          onDelete: () => controller.deleteWorkingHour(key: index),
          onEnterTimeChange: (time) {


            controller.setEnterTime(index, time);
          },
          onOutTimeChange: (time) {

            controller.setOutTime(index,time);
          },
          userWorkingHours: controller.workingHours.values.elementAt(index),
        ),
        separatorBuilder: (context, index) => VerticalSpace(),
        itemCount: controller.workingHoursLength,
      );
    });
  }
}

class WorkingHoursItem extends StatelessWidget {
  const WorkingHoursItem({super.key, required this.userWorkingHours, required this.onEnterTimeChange, required this.onOutTimeChange, required this.onDelete});

  final UserWorkingHours userWorkingHours;
  final void Function(Time) onEnterTimeChange;
  final void Function(Time) onOutTimeChange;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(
              'توقيت الدخول',
              style: AppTextStyles.headLineStyle3,
            ),
            HorizontalSpace(),
            InkWell(
              onTap: () async {
                Navigator.of(context).push(
                  showPicker(

                    context: context,
                    value: Time(hour: 4, minute: 30),
                    sunrise: TimeOfDay(hour: 6, minute: 0),
                    sunset: TimeOfDay(hour: 18, minute: 0),
                    duskSpanInMinutes: 120,
                    onChange: onEnterTimeChange,
                  ),
                );
              },
              child: Container(
                height: 30,
                width: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey, width: 2)),
                child: Center(
                  child: Text(
                    userWorkingHours.enterTime ?? '',
                    style: AppTextStyles.headLineStyle3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'توقيت الخروج',
              style: AppTextStyles.headLineStyle3,
            ),
            HorizontalSpace(),
            InkWell(
              onTap: () async {
                Navigator.of(context).push(
                  showPicker(
                    context: context,
                    value: Time(hour: 4, minute: 30),
                    sunrise: TimeOfDay(hour: 6, minute: 0),
                    sunset: TimeOfDay(hour: 18, minute: 0),
                    duskSpanInMinutes: 120,
                    onChange: onOutTimeChange,
                  ),
                );
              },
              child: Container(
                height: 30,
                width: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey, width: 2)),
                child: Center(
                  child: Text(
                    userWorkingHours.outTime ?? '',
                    style: AppTextStyles.headLineStyle3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),

        IconButton(onPressed: onDelete, icon: Icon(Icons.delete))
      ],
    );
  }
}
