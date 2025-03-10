import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/all_sellers_sales_pie_chart.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/chart_summary_section.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/dash_board_account_view_widget.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/date_filter_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/widgets/tow_field_row.dart';
import '../../../sellers/ui/widgets/date_range_picker.dart';
import '../../../user_time/ui/screens/all_attendance_screen.dart';
import '../../controller/dashboard_layout_controller.dart';
import '../widgets/all_sellers_sales_bar_chart.dart';
import '../widgets/box_organize_widget.dart';

class DashBoardLayout extends StatelessWidget {
  const DashBoardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DashboardLayoutController>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            // spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  DashBoardAccountViewWidget(
                    controller: controller,
                  ),
                  Spacer(),
                  BoxOrganizeWidget(
                    primaryColor: Color(0xFF9C27B0),
                    secondaryColor: Color(0xFFE040FB),
                    titleText: 'الموظفين',
                    childWidget: ListView(
                      children: [
                        TowFieldRow(
                          firstItem: AppStrings.all.tr,
                          secondItem: '${controller.allUsersLength}',
                        ),
                        TowFieldRow(
                          firstItem: AppStrings.allUsersMustOnline.tr,
                          secondItem: '${controller.usersMustWorkingNowLength}',
                        ),
                        TowFieldRow(
                          firstItem: AppStrings.available.tr,
                          secondItem: '${controller.onlineUsersLength}',
                        ),
                      ],
                    ),
                  ),
                  BoxOrganizeWidget(
                    primaryColor: Color(0xFF2DD400),
                    secondaryColor: Color(0xFF2DD480),
                    titleText: AppStrings.chequesDues.tr,
                    childWidget: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TowFieldRow(
                          firstItem: AppStrings.all.tr,
                          secondItem: '${controller.allChequesLength}',
                        ),
                        TowFieldRow(
                          firstItem: AppStrings.thisMonth.tr,
                          secondItem: '${controller.allChequesDuesThisMonthLength}',
                        ),
                        TowFieldRow(
                          firstItem: AppStrings.lastTenDays.tr,
                          secondItem: '${controller.allChequesDuesLastTenLength}',
                        ),
                        TowFieldRow(
                          firstItem: AppStrings.today.tr,
                          secondItem: '${controller.allChequesDuesTodayLength}',
                        ),
                      ],
                    ),
                  ),
                  BoxOrganizeWidget(
                    primaryColor: Color(0xFF4196DB),
                    secondaryColor: Color(0xFF1CECe5),
                    titleText: AppStrings.bills.tr,
                    childWidget: ListView(
                      children: [
                        TowFieldRow(
                          firstItem: AppStrings.allBills.tr,
                          secondItem: '${controller.allChequesLength}',
                        ),
                        TowFieldRow(
                          firstItem: AppStrings.allBillsDues.tr,
                          secondItem: '${controller.allChequesDuesLength}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              VerticalSpace(),
              OrganizedWidget(
                  titleWidget: Center(
                      child: Text(
                    AppStrings.userAdministration,
                    style: AppTextStyles.headLineStyle1,
                  )),
                  bodyWidget: AllAttendanceScreen()),
              VerticalSpace(),
              AllSellersSalesBarChart(controller: controller),
              VerticalSpace(),
              AllSellersSalesPieChart(controller: controller),


            ],
          ),
        );
      }),
    );
  }
}

class ChartBoxWidget extends StatelessWidget {
  const ChartBoxWidget({
    super.key,
    required this.color,
    required this.text,
    required this.totals,
  });

  final String text;
  final String totals;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HorizontalSpace(20),
        Container(
          height: 13,
          width: 13,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
        ),
        SizedBox(
          width: 18.w,
          child: Text(
            totals.formatNumber(),
            style: AppTextStyles.headLineStyle3,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          text,
          style: AppTextStyles.headLineStyle3,
        ),
      ],
    );
  }
}