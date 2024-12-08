import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../sellers/data/models/seller_model.dart';
import '../../data/models/bill_model.dart';

class BillUtils {
  BillModel appendEmptyBillModel(List<BillModel> bills, BillTypeModel billTypeModel) {
    final int lastBillNumber = bills.isNotEmpty ? bills.last.billDetails.billNumber! : 0;

    final emptyBillModel = BillModel.empty(billTypeModel: billTypeModel, lastBillNumber: lastBillNumber);

    bills.add(emptyBillModel);
    return emptyBillModel;
  }

  void showExportSuccessDialog(String filePath) {
    AppUIUtils.onSuccess('تم تصدير الفواتير بنجاح!');
    Get.defaultDialog(
      title: 'تم تصدير الملف إلى:',
      radius: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      content: Column(
        children: [
          Text(filePath),
          const VerticalSpace(16),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('نسخ المسار'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              AppUIUtils.onSuccess('تم نسخ المسار إلى الحافظة');
            },
          ),
        ],
      ),
    );
  }

  bool validateCustomerAccount(AccountModel? customerAccount) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل!');
      return false;
    }
    return true;
  }

  bool validateSellerAccount(SellerModel? sellerAccount) {
    if (sellerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم البائع!');
      return false;
    }
    return true;
  }
}
