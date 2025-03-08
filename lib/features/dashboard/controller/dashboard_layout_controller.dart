import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/dashboard/data/model/dash_account_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/local_database/implementations/repos/local_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../accounts/controllers/account_statement_controller.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../accounts/data/models/account_model.dart';

class DashboardLayoutController extends GetxController {
  final LocalDatasourceRepository<DashAccountModel> _datasourceRepository;

  List<DashAccountModel> dashBoardAccounts = [];
  TextEditingController accountNameController = TextEditingController();

  Rx<RequestState> fetchDashBoardAccountsRequest = RequestState.initial.obs;

  DashboardLayoutController(this._datasourceRepository);

  @override
  onInit() {
    getAllDashBoardAccounts();
    super.onInit();
  }

  int get onlineUsersLength => read<UserManagementController>()
      .allUsers
      .where(
        (user) => user.userWorkStatus == UserWorkStatus.online,
      )
      .length;

  int get allUsersLength => read<UserManagementController>().allUsers.length;

  getAllDashBoardAccounts() async {
    final result = await _datasourceRepository.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedDashBoardAccounts) => dashBoardAccounts.assignAll(fetchedDashBoardAccounts),
    );
  }

  refreshDashBoardAccounts() async {
    fetchDashBoardAccountsRequest.value = RequestState.loading;
    for (final account in dashBoardAccounts) {
      final AccountModel? accountModel = read<AccountsController>().getAccountModelById(account.id);

      final balance = await read<AccountStatementController>().getAccountBalance(accountModel!);
      account.balance = balance.toString();
      await _datasourceRepository.update(account);
    }
    fetchDashBoardAccountsRequest.value = RequestState.success;
    update();
  }

  DashAccountModel dashboardAccount(int index) {
    return dashBoardAccounts[index];
  }

  addDashBoardAccount() async {
    final AccountModel? accountModel = read<AccountsController>().getAccountModelByName(accountNameController.text);
    if (accountModel == null) {
      AppUIUtils.onFailure("يرجى إدخال اسم الحساب");
      return;
    }

    final balance = await read<AccountStatementController>().getAccountBalance(accountModel);
    final DashAccountModel dashAccountModel = DashAccountModel(
      id: accountModel.id,
      name: accountModel.accName,
      balance: balance.toString(),
    );
    final result = await _datasourceRepository.save(dashAccountModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedDashBoardAccounts) => AppUIUtils.onSuccess('تم حفظ الحساب بنجاح'),
    );
    getAllDashBoardAccounts();
    accountNameController.clear();
    update();
  }

  // Fetch bond items for the selected account
  Future<void> fetchAccountEntryBondItems() async {}

  // Event Handlers
  void onAccountNameSubmitted(String text, BuildContext context) async {
    final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);

    AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
      query: convertArabicNumbers,
      context: context,
    );
    if (accountModel != null) {
      accountNameController.text = accountModel.accName!;
    }
  }

  deleteDashboardAccount(int index, BuildContext context) async {
    if (await AppUIUtils.confirm(
      context,
      title: 'هل تريد حذف الحساب؟',
    )) {
      final DashAccountModel dashAccountModel = dashBoardAccounts[index];
      final result = await _datasourceRepository.delete(dashAccountModel, dashAccountModel.id!);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedDashBoardAccounts) => AppUIUtils.onSuccess('تم حذف الحساب بنجاح'),
      );
      getAllDashBoardAccounts();
      update();
    }
  }
}
