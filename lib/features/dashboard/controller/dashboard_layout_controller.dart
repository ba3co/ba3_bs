import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs/features/dashboard/data/model/dash_account_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/models/date_filter.dart';
import '../../../core/services/local_database/implementations/repos/local_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../accounts/controllers/account_statement_controller.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../accounts/data/models/account_model.dart';
import '../../patterns/controllers/pattern_controller.dart';
import '../../users_management/data/models/user_model.dart';

class DashboardLayoutController extends GetxController {
  final LocalDatasourceRepository<DashAccountModel> _datasourceRepository;

  List<DashAccountModel> dashBoardAccounts = [];
  TextEditingController accountNameController = TextEditingController();

  Rx<RequestState> fetchDashBoardAccountsRequest = RequestState.initial.obs;

  DashboardLayoutController(this._datasourceRepository);

  final now = DateTime.now();

  @override
  onInit() {
    getAllDashBoardAccounts();
    // getAllBillsThisMonth();
    super.onInit();
  }

  List<UserModel> get allUsers => read<UserManagementController>().allUsers;

  int get allUsersLength => allUsers.length;

  int get onlineUsersLength => allUsers
      .where(
        (user) => user.userWorkStatus == UserWorkStatus.online,
      )
      .length;

  int get usersMustWorkingNowLength => allUsers
      .where((user) {
        return user.userWorkingHours!.values.any((interval) {
          return now.isAfter(interval.enterTime!.toWorkingTime()) && now.isBefore(interval.outTime!.toWorkingTime());
        });
      })
      .toList()
      .length;

  List<ChequesModel> get allCheques => read<AllChequesController>().chequesList;

  int get allChequesLength => allCheques.length;

  int get allChequesDuesLength => allCheques
      .where(
        (user) => user.isPayed != true,
      )
      .length;

  /// this for cheques in this month
  List<ChequesModel> get allChequesDuesThisMonth => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now.add(Duration(days: 30))),
      )
      .toList();

  int get allChequesDuesThisMonthLength => allChequesDuesThisMonth.length;

  /// this for cheques Last 10 days
  List<ChequesModel> get allChequesDuesLastTen => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now.add(Duration(days: 10))),
      )
      .toList();

  int get allChequesDuesLastTenLength => allChequesDuesLastTen.length;

  /// this for cheques today
  List<ChequesModel> get allChequesDuesToday => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now),
      )
      .toList();

  int get allChequesDuesTodayLength => allChequesDuesToday.length;
  List<BillModel> allBillsThisMonth = [];

  getAllBillsThisMonth() async {
    allBillsThisMonth = await read<AllBillsController>().fetchBillsByDate(
      read<PatternController>().billsTypeSales,
      DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: DateTimeRange(start: now.subtract(Duration(days: 30)), end: now),
      ),
    );
  }

  getAllDashBoardAccounts() async {
    final result = await _datasourceRepository.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedDashBoardAccounts) {
        dashBoardAccounts.assignAll(fetchedDashBoardAccounts);
        update();
      },
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