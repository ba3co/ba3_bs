import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/account_model.dart';

class AccountStatementController extends GetxController {
  TextEditingController productForSearchController = TextEditingController();

  TextEditingController startDateController = TextEditingController()..text = DateTime.now().toString().split(" ")[0];

  TextEditingController endDateController = TextEditingController()..text = DateTime.now().toString().split(" ")[0];

  TextEditingController groupForSearchController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController storeForSearchController = TextEditingController();

  AccountsController accountsController = Get.find<AccountsController>();

  initController({String? accountForSearch}) {
    productForSearchController.clear();
    startDateController.text = DateTime.now().toString().split(" ")[0];
    endDateController.text = DateTime.now().toString().split(" ")[0];
    groupForSearchController.clear();
    accountForSearch == null ? accountNameController.clear() : accountNameController.text = accountForSearch;
    storeForSearchController.clear();
  }

  @override
  void onInit() {
    initController();
    super.onInit();
  }

  onAccountNameControllerSubmitted(String text, BuildContext context) {
    accountsController.openAccountSelectionDialog(
      query: text,
      context: context,
      textEditingController: accountNameController,
    );

    update();
  }

  onStartDateControllerSubmitted(String text) {
    startDateController.text = AppUIUtils.getDateFromString(text);
    update();
  }

  onEndDateControllerSubmitted(String text) {
    endDateController.text = AppUIUtils.getDateFromString(text);
    update();
  }

  navigateToAccountStatementScreen() {
    AccountModel? accountModel = accountsController.getAccountByName(accountNameController.text);

    if (accountModel != null) {
      List<String> listDate =
          AppUIUtils.getDatesBetween(DateTime.parse(startDateController.text), DateTime.parse(endDateController.text));

      Get.toNamed(AppRoutes.accountStatementScreen);

      // Get.to(() => AccountDetails(
      //       modelKey: accountModel.accChild.map((e) => e.toString()).toList() + [accountModel.id!],
      //       listDate: listDate,
      //     ));
    } else {
      Get.snackbar("خطأ ادخال", "يرجى ادخال اسم الحساب ", icon: const Icon(Icons.error_outline));
    }
  }
}
