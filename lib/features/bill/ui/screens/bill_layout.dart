import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../widgets/bill_layout/all_bills_types_list.dart';

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
                if (RoleItemType.administrator.hasAdminPermission)
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: AppButton(
                      title: AppStrings.downloadBills.tr,
                      onPressed: () {
                        allBillsController.fetchAllBillsFromLocal(context);
                      },
                    ),
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RefreshIndicator(
                onRefresh: allBillsController.refreshBillsTypes,
                child: ListView(
                  children: [
                    OrganizedWidget(
                      titleWidget: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              AppStrings.bills.tr,
                              style: AppTextStyles.headLineStyle2
                                  .copyWith(color: AppColors.blueColor),
                            ),
                            Spacer(),
                            IconButton(
                              tooltip: AppStrings.refresh.tr,
                              icon: Icon(
                                FontAwesomeIcons.refresh,
                                color: AppColors.lightBlueColor,
                              ),
                              onPressed: allBillsController.refreshBillsTypes,
                            ),
                            PopupMenuButton<String>(
                              tooltip: AppStrings.options.tr,
                              onSelected: (value) {
                                if (value ==
                                    AppConstants.serialNumbersStatement) {
                                  _showSerialNumberDialog(
                                      context, allBillsController);
                                } else if (value ==
                                    AppConstants.searchByPhone) {
                                  _showSearchDialog(context, allBillsController,
                                      searchType: 'phone');
                                } else if (value ==
                                    AppConstants.searchByOrderNumber) {
                                  _showSearchDialog(context, allBillsController,
                                      searchType: 'order');
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: AppConstants.serialNumbersStatement,
                                  child: Row(
                                    children: [
                                      Icon(FontAwesomeIcons.file,
                                          color: Colors.black54),
                                      SizedBox(width: 8),
                                      Text(
                                          AppStrings.serialNumbersStatement.tr),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  child: PopupMenuButton<String>(
                                    child: Row(
                                      children: [
                                        Icon(FontAwesomeIcons.search,
                                            color: Colors.black54),
                                        SizedBox(width: 8),
                                        Text(AppStrings.searchBill.tr),
                                      ],
                                    ),
                                    onSelected: (value) {
                                      Navigator.pop(context);

                                      if (value == AppConstants.searchByPhone) {
                                        _showSearchDialog(
                                            context, allBillsController,
                                            searchType: 'phone');
                                      } else if (value ==
                                          AppConstants.searchByOrderNumber) {
                                        _showSearchDialog(
                                            context, allBillsController,
                                            searchType: 'order');
                                      }
                                    },
                                    itemBuilder: (context) =>
                                        <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        value: AppConstants.searchByPhone,
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone,
                                                color: Colors.black54),
                                            SizedBox(width: 8),
                                            Text(AppStrings.searchByPhone.tr),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: AppConstants.searchByOrderNumber,
                                        child: Row(
                                          children: [
                                            Icon(Icons.confirmation_number,
                                                color: Colors.black54),
                                            SizedBox(width: 8),
                                            Text(AppStrings
                                                .searchByOrderNumber.tr),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              icon: Icon(
                                FontAwesomeIcons.ellipsisVertical,
                                color: AppColors.lightBlueColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      bodyWidget: GetBuilder<AllBillsController>(
                        builder: (controller) => Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AllBillsTypesList(allBillsController: controller),
                            // if (RoleItemType.viewBill.hasAdminPermission) billLayoutAppBar(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: RoleItemType.administrator.hasAdminPermission
                ? FloatingActionButton(
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      // allBillsController.fetchAllNestedBills();
                      allBillsController.saveXmlToFile(context);
                      // read<MaterialsStatementController>().setupAllMaterials();
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

// Function to show serial number dialog
void _showSerialNumberDialog(
    BuildContext context, AllBillsController allBillsController) {
  String serialNumberInput = '';
  Get.dialog(
    AlertDialog(
      title: Text(AppStrings.enterSerialNumber.tr),
      content: StatefulBuilder(
        builder: (context, setState) {
          return TextField(
            decoration: InputDecoration(
              labelText: AppStrings.serialNumber.tr,
            ),
            onChanged: (value) {
              serialNumberInput = value;
            },
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppStrings.cancel.tr),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: Text(AppStrings.confirm.tr),
          onPressed: () {
            Get.back();
            if (serialNumberInput.isEmpty) return;
            allBillsController.getSerialNumberStatement(serialNumberInput,
                context: context);
          },
        ),
      ],
    ),
  );
}

// Function to show search input dialog
void _showSearchDialog(
    BuildContext context, AllBillsController allBillsController,
    {required String searchType}) {
  String searchInput = '';
  Get.dialog(
    AlertDialog(
      title: Text(searchType == 'phone'
          ? AppStrings.enterPhoneNumber.tr
          : AppStrings.enterOrderNumber.tr),
      content: StatefulBuilder(
        builder: (context, setState) {
          return TextField(
            keyboardType: searchType == 'phone'
                ? TextInputType.phone
                : TextInputType.number,
            decoration: InputDecoration(
              labelText: searchType == 'phone'
                  ? AppStrings.phoneNumber.tr
                  : AppStrings.orderNumber.tr,
            ),
            onChanged: (value) {
              searchInput = value;
            },
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppStrings.cancel.tr),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: Text(AppStrings.confirm.tr),
          onPressed: () {
            Get.back();
            if (searchInput.isEmpty) return;
            allBillsController.searchBill(
                searchInput: searchInput,
                searchType: searchType,
                context: context);
          },
        ),
      ],
    ),
  );
}