import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../widgets/bill_layout/all_bills_types_list.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final progress = read<AllBillsController>().uploadProgress.value;

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                actions: [
                  Padding(padding: EdgeInsets.all(8),
                    child: AppButton(title: "تحميل الفواتيير", onPressed: () => read<AllBillsController>().fetchAllBillsFromLocal(),),
                  )
                ],
              ),
              body: Obx(
                    () =>
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: OrganizedWidget(
                              titleWidget: Align(
                                child: Text(
                                  'الفواتير',
                                  style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
                                ),
                              ),
                              bodyWidget: GetBuilder<AllBillsController>(
                                builder: (controller) =>
                                    Column(
                                      spacing: 10,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        AllBillsTypesList(allBillsController: controller),
                                        //    if (RoleItemType.viewBill.hasAdminPermission) billLayoutAppBar(),
                                      ],
                                    ),
                              ),
                            ),
                          ),
                        ),
                        LoadingDialog(
                          isLoading: read<AllBillsController>().getBillsTypesRequestState.value == RequestState.loading,
                          message: 'أنواع الفواتير',
                          fontSize: 14.sp,
                        )
                      ],
                    ),
              ),
            ),
            LoadingDialog(
              isLoading: read<AllBillsController>().saveAllBillsRequestState.value == RequestState.loading,
              message: '${(progress * 100).toStringAsFixed(2)}% من الفواتير',
              fontSize: 14.sp,
            )
          ],
        );
      }),
    );
  }
}
