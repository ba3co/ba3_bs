import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/dialogs/account_dashboard_dialog.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/custom_icon_button.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/language_switch_fa_icon.dart';
import '../../../user_time/ui/screens/all_attendance_screen.dart';
import '../../controller/dashboard_layout_controller.dart';
import '../widgets/box_organize_widget.dart';
import '../widgets/dashboard_accounts_list.dart';

class DashBoardLayout extends StatelessWidget {
  const DashBoardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DashboardLayoutController>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  DashBoardViewWidget(controller: controller,),
                  Spacer(),
                  BoxOrganizeWidget(
                    primaryColor: Color(0xFF9C27B0),
                    secondaryColor: Color(0xFFE040FB),
                    titleText: 'الموظفين داخل العمل',
                    subTitleText: '${controller.onlineUsersLength}/${controller.allUsersLength}',
                  ),
                  BoxOrganizeWidget(
                    primaryColor: Color(0xFF2DD400),
                    secondaryColor: Color(0xFF2DD480),
                    titleText: 'الشيكات المستحقة',
                    subTitleText: '35',
                  ),

                  BoxOrganizeWidget(
                    primaryColor: Color(0xFF4196DB),
                    secondaryColor: Color(0xFF1CECe5),
                    titleText: 'الفواتير المستحقة',
                    subTitleText: '3',
                  ),


                ],
              ),
              OrganizedWidget(
                  titleWidget: Center(
                      child: Text(
                    AppStrings.userAdministration,
                    style: AppTextStyles.headLineStyle1,
                  )),
                  bodyWidget: AllAttendanceScreen())
            ],
          ),
        );
      }),
    );
  }
}

class DashBoardViewWidget extends StatelessWidget {
  const DashBoardViewWidget({
    super.key,
    required this.controller
  });
 final DashboardLayoutController controller;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      width: 110.w,
      child: Column(
        children: [
          Row(
            children: [
              Spacer(),
              Text("الحسابات الرئيسية", style: AppTextStyles.headLineStyle3),
              Spacer(),
              CustomIconButton(
                disabled:false,
                onPressed: () {
                  controller.refreshDashBoardAccounts();
                },
                icon: LanguageSwitchFaIcon(
                  iconData: Icons.refresh,
                ),
              ),
              CustomIconButton(
                disabled:false,
                onPressed: () {
                  showDialog<String>(context: Get.context!, builder: (BuildContext context) => showDashboardAccountDialog(context));
                },
                icon: LanguageSwitchFaIcon(
                  iconData: Icons.add,
                ),
              ),

            ],
          ),
          Divider(),
          Expanded(

            child: DashboardAccountsList(controller: controller),
          ),
        ],
      ),
    );
  }
}