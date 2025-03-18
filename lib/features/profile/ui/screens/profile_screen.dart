import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/profile/ui/widgets/profile_info_row_shimmer_widget.dart';
import 'package:ba3_bs/features/profile/ui/widgets/profile_info_row_widget.dart';
import 'package:ba3_bs/core/widgets/user_target_shimmer_widget.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            Flexible(
                flex: 3,
                child: Obx(() {
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
                      : Column(
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
                            Container(
                              height: 250.h,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.all(16),
                              child: ListView.separated(
                                separatorBuilder: (context, index) => VerticalSpace(2),
                                itemCount: currentUserTasks.length,
                                itemBuilder: (context, index) => ListTile(
                                  onTap: () {
                                    if (currentUserTasks[index].materialTask != null && currentUserTasks[index].materialTask!.isNotEmpty) {
                                      OverlayService.showDialog(
                                          height: 460,
                                          context: context,
                                          content: Column(
                                            children: [
                                              Container(
                                                height: 400,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: ListView.separated(
                                                  separatorBuilder: (context, index) => Divider(),
                                                  itemCount: currentUserTasks[index].materialTask!.length,
                                                  itemBuilder: (context, materialIndex) {
                                                    return ListTile(
                                                      title: Text(
                                                        currentUserTasks[index].materialTask![materialIndex].materialName!,
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      subtitle: Text(
                                                          "${AppStrings.identificationNumber.tr}: ${currentUserTasks[index].materialTask![materialIndex].docId}",
                                                          style: TextStyle(color: Colors.grey)),
                                                      leading: InkWell(onTap: () {}, child: Icon(Icons.inventory)),
                                                      trailing: Text(
                                                        " ${AppStrings.quantity.tr} \n ${currentUserTasks[index].materialTask![materialIndex].quantity}",
                                                        style: AppTextStyles.headLineStyle4,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              AppButton(
                                                title: currentUserTasks[index].status == TaskStatus.initial
                                                    ? AppStrings.start.tr
                                                    : AppStrings.save.tr,
                                                onPressed: () {
                                                  if (currentUserTasks[index].status == TaskStatus.initial) {
                                                    currentUserTasks[index].status = TaskStatus.inProgress;
                                                  } else {
                                                    currentUserTasks[index].status = TaskStatus.done;
                                                  }
                                                  OverlayService.back();
                                                },
                                              )
                                            ],
                                          ));
                                    }
                                  },
                                  title: Text(
                                    currentUserTasks[index].title!,
                                    style: AppTextStyles.headLineStyle3,
                                  ),

                                  // subtitle: Text(currentUser.userTaskList![index].materialTask?.map((e) => "${e.materialName!}(${e.quantity})",).join(" ,")??''),
                                  subtitle: Text(
                                    "اخر تاريخ للمهمة ${currentUserTasks[index].dueDate!.dayMonthYear}",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  trailing: Text(currentUserTasks[index].status!.value),
                                  //ban
                                  //clock
                                ),
                              ),
                            ),
                            Spacer(),
                            const ProfileFooter(),
                          ],
                        );
                })),
            Flexible(
                flex: 2,
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