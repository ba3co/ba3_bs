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
              : RoleItemType.viewBill.hasAdminPermission
                  ? patternController.billsTypes
                      .map(
                        (billTypeModel) => BillTypeItemWidget(
                          text: read<TranslationController>().currentLocaleIsRtl ? billTypeModel.fullName! : billTypeModel.latinFullName!,
                          color: Color(billTypeModel.color!),
                          onTap: () => allBillsController.openFloatingBillDetails(context, billTypeModel),
                          onAllBillsPressed: ()=>allBillsController.fetchNunPendingBills(billTypeModel),
                          pendingBillsCounts: allBillsController.pendingBillsCounts(billTypeModel),
                          allBillsCounts: allBillsController.allBillsCounts(billTypeModel),
                          onPendingBillsPressed: () => allBillsController.fetchPendingBills(billTypeModel),
                        ),
                      )
                      .toList()
                  : [
                      BillTypeItemWidget(
                        text: read<TranslationController>().currentLocaleIsRtl
                            ? patternController.billsTypeSales.fullName!
                            : patternController.billsTypeSales.latinFullName!,
                        color: Color(patternController.billsTypeSales.color!),
                        onTap: () => allBillsController.openFloatingBillDetails(context, patternController.billsTypeSales),
                        onAllBillsPressed: () => allBillsController.fetchNunPendingBills( patternController.billsTypeSales),
                        pendingBillsCounts: allBillsController.pendingBillsCounts(patternController.billsTypeSales),
                        allBillsCounts: allBillsController.allBillsCounts(patternController.billsTypeSales),
                        onPendingBillsPressed: () => allBillsController.fetchPendingBills(patternController.billsTypeSales),
                      )
                    ],
        );
      },
    );
  }
}