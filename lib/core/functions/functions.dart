import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:get/get.dart';

class Functions {
  static AccountModel? getAccountModelFromLabel(accLabel) => Get.find<AccountsController>()
      .accounts
      .where(
        (element) => element.accName == accLabel,
      )
      .firstOrNull;
}
