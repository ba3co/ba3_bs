
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/profile/ui/widgets/profile_info_row_shimmer_widget.dart';
import 'package:ba3_bs/features/profile/ui/widgets/profile_info_row_widget.dart';
import 'package:ba3_bs/core/widgets/user_target_shimmer_widget.dart';
import 'package:ba3_bs/features/profile/ui/widgets/task_list_widget.dart';
import 'package:ba3_bs/features/profile/ui/widgets/user_time_details_widgets/jetour_days_widget.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/user_target/user_target.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../user_time/controller/user_time_controller.dart';
import '../widgets/profile_footer.dart';
import '../widgets/task_dialog_strategy.dart';
import '../widgets/user_time_details_widgets/add_time_widget.dart';
import '../widgets/user_time_details_widgets/holidays_widget.dart';
import '../widgets/user_time_details_widgets/user_daily_time_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<SellerSalesController>(
            initState: (state) async {
          await    WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized;
          final salesController = read<SellerSalesController>();
          if(!context.mounted)return;
          await salesController.onSelectSeller(sellerId: read<UserManagementController>().loggedInUserModel!.userSellerId,context: context);
        }, builder: (salesController) {
          return Row(
            children: [
              Expanded(
                  child: salesController.profileScreenState == RequestState.loading
                      ? ListView(
                          children: List.generate(
                            10,
                            (index) => Column(
                              children: [
                                ProfileInfoRowShimmerWidget(),
                                VerticalSpace(),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: GetBuilder<UserManagementController>(builder: (controller) {
                            return Column(
                              spacing: 10,
                              children: [
                                ProfileInfoRowWidget(
                                  label: AppStrings.userName.tr,
                                  value: controller.loggedInUserModel!.userName.toString(),
                                ),
                                ProfileInfoRowWidget(
                                  label: AppStrings.password.tr,
                                  value:controller.isPasswordVisible.value? controller.loggedInUserModel!.userPassword.toString():"●"* 6,
                                  icon: IconButton(onPressed: (){
                                    controller.updatePasswordVisibility();

                                  }, icon: Icon(controller.isPasswordVisible.value?FontAwesomeIcons.eyeLowVision:FontAwesomeIcons.eye)),
                                ),
                                ProfileInfoRowWidget(
                                  label: AppStrings.totalSales.tr,
                                  value: (salesController.totalAccessoriesSales + salesController.totalMobilesSales).toStringAsFixed(2),
                                ),
                                ProfileInfoRowWidget(
                                  label: AppStrings.userSalary.tr,
                                  value: controller.loggedInUserModel!.userSalary??'0.0',
                                ),
                                ProfileInfoRowWidget(
                                  label: AppStrings.groupForTarget.tr,
                                  value: controller.loggedInUserModel!.groupForTarget?.groupName??'لا يوجد',
                                ),
                                ProfileInfoRowWidget(
                                  label: AppStrings.delayedEntry.tr,
                                  value: read<UserTimeController>().getTotalLoginDelayTime,
                                ),
                                ProfileInfoRowWidget(
                                  label: AppStrings.leaveEarly.tr,
                                  value: read<UserTimeController>().getTotalOutEarlierTime,
                                ),
                                AddTimeWidget(
                                  userTimeController: read<UserTimeController>(),
                                ),
                                HolidaysWidget(
                                  userTimeController: read<UserTimeController>(),
                                ),
                                JetourDaysWidget(
                                  userTimeController: read<UserTimeController>(),
                                ),
                                UserDailyTimeWidget(
                                  userModel: read<UserTimeController>().getUserById,
                                ),
                                Row(
                                  spacing: 10,
                                  children: [
                                    Expanded(
                                      child: TaskListWidget(
                                        taskList: controller.allTaskList,
                                        onTap: (task) {
                                          OverlayService.showDialog(
                                            height: 460,
                                            context: context,
                                            content: TaskDialogFactory.getStrategy(task.taskType!).buildDialog(task),
                                          );
                                        },
                                        title: AppStrings.tasksTodo.tr,
                                      ),
                                    ),
                                    Expanded(
                                      child: TaskListWidget(
                                        taskList: controller.allTaskListDone,
                                        onTap: (task) {
                                          OverlayService.showDialog(
                                            height: 460,
                                            context: context,
                                            content: TaskDialogFactory.getStrategy(task.taskType!).buildDialog(task),
                                          );
                                        },
                                        title: AppStrings.tasksEnded.tr,
                                      ),
                                    ),
                                  ],
                                ),
                                const ProfileFooter(),
                              ],
                            );
                          }),
                        )),
              SizedBox(
                  width: 700,
                  child: salesController.profileScreenState == RequestState.loading
                      ? UserTargetShimmerWidget()
                      : UserTargets(
                          salesController: salesController,
                          height: 500,
                        )),
            ],
          );
        }),
      ),
    );
  }
}