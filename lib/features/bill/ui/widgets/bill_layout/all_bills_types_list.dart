import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/services/translation/translation_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/patterns/controllers/pattern_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import 'bill_type_item_widget.dart';
import 'bill_type_shimmer_widget.dart';

class AllBillsTypesList extends StatelessWidget {
  const AllBillsTypesList({super.key, required this.allBillsController});

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    final patternController = read<PatternController>();
    return Obx(
      () {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: allBillsController.getBillsTypesRequestState.value == RequestState.loading
              ? List.generate(10, (index) => const BillTypeShimmerWidget()) // Show shimmer placeholders
              : RoleItemType.viewBill.hasWritePermission
                  ? patternController.billsTypes
                   /*   .where(
                        (type) =>
                            type.billTypeId != "06f0e6ea-3493-480c-9e0c-573baf049605" &&
                            type.billTypeId != "563af9aa-5d7e-470b-8c3c-fee784da810a" &&
                            type.billTypeId != "494fa945-3fe5-4fc3-86d6-7a9999b6c9e8" &&
                            type.billTypeId != "35c75331-1917-451e-84de-d26861134cd4" &&
                            type.billTypeId != "5a9e7782-cde5-41db-886a-ac89732feda7",
                      )*/
                      .map(
                        (billTypeModel) => BillTypeItemWidget(
                          text: read<TranslationController>().currentLocaleIsRtl ? billTypeModel.fullName! : billTypeModel.latinFullName!,
                          color: Color(billTypeModel.color!),
                          onTap: () => allBillsController.openFloatingBillDetails(context, billTypeModel),
                          onAllBillsPressed: () => allBillsController.fetchNunPendingBills(billTypeModel, context),
                          pendingBillsCounts: allBillsController.pendingBillsCounts(billTypeModel),
                          allBillsCounts: allBillsController.allBillsCounts(billTypeModel),
                          onPendingBillsPressed: () => allBillsController.fetchPendingBills(
                            billTypeModel,
                          ),
                          showSearchDialog: (searchType) {
                            allBillsController.showSearchDialog(context, searchType: searchType, billTypeModel: billTypeModel);
                          },
                          showDailiesReportsDialog: () => allBillsController.showDailiesReportsDialog(context, billTypeModel),
                        ),
                      )
                      .toList()
                  : [
                      BillTypeItemWidget(
                        showDailiesReportsDialog: () =>
                            allBillsController.showDailiesReportsDialog(context, patternController.billsTypeSales),
                        showSearchDialog: (searchType) {
                          allBillsController.showSearchDialog(context,
                              searchType: searchType, billTypeModel: patternController.billsTypeSales);
                        },
                        text: read<TranslationController>().currentLocaleIsRtl
                            ? patternController.billsTypeSales.fullName!
                            : patternController.billsTypeSales.latinFullName!,
                        color: Color(patternController.billsTypeSales.color!),
                        onTap: () => allBillsController.openFloatingBillDetails(context, patternController.billsTypeSales),
                        onAllBillsPressed: () => allBillsController.fetchNunPendingBills(patternController.billsTypeSales, context),
                        pendingBillsCounts: allBillsController.pendingBillsCounts(patternController.billsTypeSales),
                        allBillsCounts: allBillsController.allBillsCounts(patternController.billsTypeSales),
                        onPendingBillsPressed: () => allBillsController.fetchPendingBills(
                          patternController.billsTypeSales,
                        ),
                      )
                    ],
        );
      },
    );
  }
}