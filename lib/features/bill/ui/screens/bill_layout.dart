import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../widgets/bill_layout/bills_info_widget.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final allBillsController = read<AllBillsController>();
    return Obx(() {
      final progress = allBillsController.uploadProgress.value;

      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leadingWidth: 300,
              actions: [
                /*    if (RoleItemType.administrator.hasAdminPermission)
                 Padding(
                    padding: EdgeInsets.all(8),
                    child: AppButton(
                      title: "asd",
                      onPressed: () {
                        allBillsController.runFixDuplicates();
                      },
                    ),
                  ),*/
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RefreshIndicator(
                onRefresh: allBillsController.refreshBillsTypes,
                child: ListView(
                  children: [
                    BillsInfoWidget(allBillsController: allBillsController),
                    VerticalSpace(),
                    // BillReportWidget(allBillsController: allBillsController),
                  ],
                ),
              ),
            ),
            floatingActionButton: RoleItemType.administrator.hasAdminPermission
                ? FloatingActionButton(
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      // allBillsController.fetchAllNestedBills();
                      // allBillsController.saveXmlToFile();
                      // read< MaterialsStatementController>().setupAllMaterials();
                      // read<MaterialsStatementController>().setupOneMaterials("e7103aec-14c5-4123-893d-9a4851d0d478");
                      // read<MaterialController>().updateAllMaterialWithDecodeProblematic();
                    },
                    child: Icon(
                      Icons.ac_unit_rounded,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          LoadingDialog(
            isLoading: allBillsController.saveAllBillsRequestState.value ==
                RequestState.loading,
            message:
                '${(progress * 100).toStringAsFixed(2)}% ${AppStrings.from.tr} ${AppStrings.bills.tr}',
            fontSize: 14.sp,
          ),
          LoadingDialog(
            isLoading: allBillsController.saveAllBillsBondRequestState.value ==
                RequestState.loading,
            message:
                '${(progress * 100).toStringAsFixed(2)}% ${AppStrings.from.tr} ${AppStrings.bonds.tr} ${AppStrings.bills.tr}',
            fontSize: 14.sp,
          ),
        ],
      );
    });
  }
}
