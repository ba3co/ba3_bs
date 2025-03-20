import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/dashboard/controller/cheques_timeline_controller.dart';
import 'package:ba3_bs/features/dashboard/controller/seller_dashboard_controller.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/seller_sale_chart/all_sellers_sales_board.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/dash_board_accounts/dash_board_account_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../../../core/widgets/tow_field_row.dart';
import '../../../user_time/ui/screens/all_attendance_screen.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../controller/bill_profit_dashboard_controller.dart';
import '../../controller/dashboard_layout_controller.dart';
import '../widgets/cheques_chart/cheques_timeline_board.dart';
import '../widgets/profit_and_bill_chart/bill_profit_bord.dart';
import '../widgets/sheared/box_organize_widget.dart';

class DashBoardLayout extends StatelessWidget {
  const DashBoardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DashboardLayoutController>(builder: (dashboardLayoutController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            // spacing: 10,
            children: [
              DashboardAppBar(controller: dashboardLayoutController),
              VerticalSpace(),
              OrganizedWidget(
                  titleWidget: Row(
                    children: [
                      Spacer(),
                      Center(
                          child: Text(
                        AppStrings.userAdministration,
                        style: AppTextStyles.headLineStyle1,
                      )),
                      Spacer(),
                      IconButton(
                        tooltip: AppStrings.refresh.tr,
                        icon: Icon(
                          FontAwesomeIcons.refresh,
                          color: AppColors.lightBlueColor,
                        ),
                        onPressed: dashboardLayoutController.refreshDashBoardUser,
                      ),
                      HorizontalSpace(10),
                    ],
                  ),
                  bodyWidget: AllAttendanceScreen()),
              VerticalSpace(20),
              GetBuilder<ChequesTimelineController>(builder: (chequesTimelineController) {
                return ChequesTimelineBoard(
                  chequesTimelineController: chequesTimelineController,
                );
              }),
              VerticalSpace(),

              GetBuilder<SellerDashboardController>(builder: (sellerController) {
                return AllSellersSalesBoard(controller: sellerController);
              }),
              VerticalSpace(20),
              GetBuilder<BillProfitDashboardController>(builder: (billProfitDashboardController) {
                return BillProfitBord(billProfitDashboardController: billProfitDashboardController);
              }),
              VerticalSpace(20),
              GetBuilder<UserManagementController>(builder: (userManagementController) {
                return SizedBox(
                  height: 800,
                  child: PlutoGridWithAppBar(
                    title: AppStrings.allUsers.tr,
                    isLoading: userManagementController.isLoading,
                    rowHeight: 60,
                    // appBar: AppBar(
                    //
                    // ),
                    tableSourceModels: userManagementController.filteredAllUsersWithNunTime,
                    onLoaded: (event) {},
                    onSelected: (selectedRow) {
                      final userId = selectedRow.row?.cells[AppConstants.userIdFiled]?.value;
                      userManagementController.userNavigator.navigateToUserDetails(userId);
                    },
                  ),
                );
              })
              // BillProfitBord(billProfitDashboardController: controller)
            ],
          ),
        );
      }),
    );
  }
}

class DashboardAppBar extends StatelessWidget {
  final DashboardLayoutController controller;

  const DashboardAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        DashBoardAccountViewWidget(
          controller: controller,
        ),
        Spacer(),
        BoxOrganizeWidget(
          primaryColor: Color(0xFF9C27B0),
          secondaryColor: Color(0xFFE040FB),
          titleText: AppStrings.employees.tr,
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
        /*    BoxOrganizeWidget(
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
        ),*/
        BoxOrganizeWidget(
          primaryColor: Color(0xFF4196DB),
          secondaryColor: Color(0xFF1CECe5),
          titleText: AppStrings.bills.tr,
          childWidget: ListView(
            children: [
              TowFieldRow(
                firstItem: AppStrings.allBills.tr,
                secondItem: '${controller.allUsers.length}',
              ),
              TowFieldRow(
                firstItem: AppStrings.allBillsDues.tr,
                secondItem: '${controller.allUsers.length}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}