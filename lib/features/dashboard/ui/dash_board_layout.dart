
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/dialogs/account_dashboard_dialog.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utils/app_ui_utils.dart';
import '../../user_time/ui/screens/all_attendance_screen.dart';
import '../controller/dashboard_layout_controller.dart';

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
                  Obx(() {
                    return SizedBox(
                      // color: Colors.green,
                      height: 120.h,
                      width: 110.w,
                      child: controller.fetchDashBoardAccountsRequest.value == RequestState.loading
                          ? SingleChildScrollView(
                              child: Wrap(
                                spacing: 2.w,
                                runSpacing: 6.h,
                                children: List.generate(
                                10,
                                  (index) => DashBoardAccountShimmerWidget(),

                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Wrap(
                                spacing: 2.w,
                                runSpacing: 6.h,
                                children: List.generate(
                                  controller.dashBoardAccounts.length,
                                  (index)
                                    => GestureDetector(
                                      onSecondaryTap: () => controller.deleteDashboardAccount(index,context),
                                      child: DashBoardAccountWidget(
                                        name: controller.dashboardAccount(index).name.toString(),
                                        balance: AppUIUtils.formatDecimalNumberWithCommas(
                                            double.parse(controller.dashboardAccount(index).balance.toString())),
                                      ),
                                    )

                                ),
                              ),
                            ),
                    );
                  }),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: [
                        AppButton(
                          title: AppStrings.refresh.tr,
                          iconData: FontAwesomeIcons.refresh,
                          onPressed: () {
                            controller.refreshDashBoardAccounts();
                          },
                        ),
                        AppButton(
                          title: AppStrings.add.tr,
                          iconData: FontAwesomeIcons.add,
                          onPressed: () {
                            showDialog<String>(
                                context: Get.context!, builder: (BuildContext context) => showDashboardAccountDialog(context));
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
              OrganizedWidget(
                  titleWidget: Center(
                      child: Text(
                    'لوحة تحكم المستخدمين',
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

class BoxOrganizeWidget extends StatelessWidget {
  const BoxOrganizeWidget(
      {super.key, required this.titleText, required this.subTitleText, required this.primaryColor, required this.secondaryColor});


  final String titleText;
  final String subTitleText;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55.w,
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -15.w,
            child: Container(
              width: 35.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    secondaryColor,
                    primaryColor,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.topLeft,
                ),
                // color: Color(0xFF9C27B0),
              ),
            ),
          ),
          Positioned(
            top: -40.h,
            left: -30.w,
            child: Container(
              width: 70.w,
              height: 170.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(30),
              ),
            ),
          ),
          Positioned(
            bottom: 30.h,
            right: -12.w,
            child: Container(
              width: 25.w,
              height: 45.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(40),
              ),
            ),
          ),
          Positioned(
            bottom: -30.h,
            right: -15.w,
            child: Container(
              width: 35.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(40),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: AppTextStyles.headLineStyle1.copyWith(color: Colors.white),
                ),
                VerticalSpace(),
                Text(
                  subTitleText,
                  style: AppTextStyles.headLineStyle2.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashBoardAccountWidget extends StatelessWidget {
  const DashBoardAccountWidget({super.key, required this.name, required this.balance});

  final String name;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.w,
      height: 35.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      alignment: Alignment.center,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: AppColors.blueColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 3,
        children: [
          Expanded(
              child: Text(
            name,
            style: AppTextStyles.headLineStyle4,
          )),
          Text(
            balance,
            style: AppTextStyles.headLineStyle4,
          ),
        ],
      ),
    );
  }
}

class DashBoardAccountShimmerWidget extends StatelessWidget {
  const DashBoardAccountShimmerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 35.w,
        height: 35.h,
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        alignment: Alignment.center,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(8),
                color: Colors.green.withAlpha(150),
                border: Border.all(color: AppColors.whiteColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 3,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Text(
                            'name',
                            style: AppTextStyles.headLineStyle4,
                          ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Text(
                'balance',
                style: AppTextStyles.headLineStyle4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}