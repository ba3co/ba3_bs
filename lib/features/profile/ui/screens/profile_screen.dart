import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/profile/ui/widgets/profile_info_row_shimmer_widget.dart';
import 'package:ba3_bs/features/profile/ui/widgets/profile_info_row_widget.dart';
import 'package:ba3_bs/core/widgets/user_target_shimmer_widget.dart';
import 'package:ba3_bs/features/profile/ui/widgets/task_list_widget.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/user_target.dart';
import '../../../user_task/data/model/user_task_model.dart';
import '../widgets/profile_footer.dart';
import '../../controller/user_time_controller.dart';
import '../widgets/user_time_details_widgets/add_time_widget.dart';
import '../widgets/user_time_details_widgets/holidays_widget.dart';
import '../widgets/user_time_details_widgets/user_daily_time_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = read<UserManagementController>().loggedInUserModel!;
    List<UserTaskModel> currentUserTasks = read<UserManagementController>().allTaskList;
    List<UserTaskModel> currentUserTasksEnded = read<UserManagementController>().allTaskListDone;
    read<UserManagementController>().fetchAllUserTask();
    final salesController = read<SellerSalesController>();
/*    salesController.onSelectSeller(sellerId: read<UserManagementController>().loggedInUserModel?.userSellerId).then(
          (value) => salesController.calculateTotalAccessoriesMobiles(),
        );*/
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(child: Obx(() {
              return salesController.profileScreenState.value == RequestState.loading
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
                      child: Column(
                        spacing: 10,
                        children: [
                          ProfileInfoRowWidget(
                            label: AppStrings.userName.tr,
                            value: currentUser.userName.toString(),
                          ),
                          ProfileInfoRowWidget(
                            label: AppStrings.password.tr,
                            value: currentUser.userPassword.toString(),
                          ),
                          ProfileInfoRowWidget(
                            label: AppStrings.totalSales.tr,
                            value: (salesController.totalAccessoriesSales + salesController.totalMobilesSales).toString(),
                          ),
                          AddTimeWidget(
                            userTimeController: read<UserTimeController>(),
                          ),
                          HolidaysWidget(
                            userTimeController: read<UserTimeController>(),
                          ),
                          UserDailyTimeWidget(
                            userModel: read<UserTimeController>().getUserById()!,
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: TaskListWidget(
                                  taskList: currentUserTasks,
                                  onTap: (p0) {},
                                  title: AppStrings.tasksTodo.tr,
                                ),

                              ),
                              Expanded(
                                child: TaskListWidget(
                                  taskList: currentUserTasksEnded,
                                  onTap: (p0) {},
                                  title: AppStrings.tasksEnded.tr,
                                ),
                              ),
                            ],
                          ),
                          const ProfileFooter(),
                        ],
                      ),
                    );
            })),
            SizedBox(
                width: 700,
                child: Obx(() {
                  return salesController.profileScreenState.value == RequestState.loading
                      ? UserTargetShimmerWidget()
                      : UserTargets(
                          salesController: salesController,
                          height: 500,
                        );
                })),
          ],
        ),
      ),
    );
  }
}