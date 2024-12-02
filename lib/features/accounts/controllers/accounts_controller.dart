import 'dart:developer';

import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../../core/widgets/account_selection_dialog.dart';
import '../../floating_window/services/overlay_entry_with_priority.dart';
import '../../patterns/controllers/pattern_controller.dart';
import '../data/models/account_model.dart';
import '../data/repositories/accounts_repository.dart';

class AccountsController extends GetxController {
  final AccountsRepository _accountsRepository;

  AccountsController(this._accountsRepository);

  List<AccountModel> accounts = [];

  bool isLoading = true;

  Map<Account, AccountModel> selectedAccounts = {};

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  // Fetch materials from the repository
  void fetchAccounts() {
    try {
      accounts = _accountsRepository.getAllAccounts();
    } catch (e) {
      debugPrint('Error in fetchAccounts($e)');
    } finally {
      isLoading = false;
      update();
    }
  }

  void navigateToAllAccountsScreen() {
    Get.toNamed(AppRoutes.showAllAccountsScreen);
  }

  List<AccountModel> searchAccountsByNameOrCode(text) {
    if (accounts.isEmpty) {
      log('Accounts isEmpty');
      fetchAccounts();
    }
    return accounts
        .where((item) => item.accName!.toLowerCase().contains(text.toLowerCase()) || item.accCode!.contains(text))
        .toList();
  }

  Map<String, AccountModel> mapAccountsByName(String query) {
    final resultMap = <String, AccountModel>{};
    for (var account in searchAccountsByNameOrCode(query)) {
      resultMap[account.accName!] = AccountModel(id: account.id, accName: account.accName);
    }
    return resultMap;
  }

  String getAccountNameById(String? accountId) {
    if (accountId == null || accountId.isEmpty) return '';
    return accounts.where((account) => account.id == accountId).firstOrNull?.accName ?? '';
  }

  String getAccountIdByName(String? accountName) {
    if (accountName == null || accountName.isEmpty) return '';
    return accounts.where((account) => account.accName == accountName).firstOrNull?.id ?? '';
  }

  List<AccountModel> getAccounts(String query) => searchAccountsByNameOrCode(query);

  List<String> getAccountChildren(String? accountId) {
    if (accountId == null || accountId.isEmpty) return [];

    return accounts.where((account) => account.accParentGuid == accountId).map((child) => child.accName ?? '').toList();
  }

  AccountModel? openAccountSelectionDialog({
    required String query,
    required BuildContext context,
    TextEditingController? textEditingController,
    bool fromAddBill = false,
    bool isCustomerAccount = false,
    IBillController? billController,
  }) {
    List<AccountModel> searchedAccounts = getAccounts(query);
    AccountModel? selectedAccountModel;

    if (searchedAccounts.length == 1) {
      // Single match
      selectedAccountModel = searchedAccounts.first;

      if (textEditingController != null) {
        final BillAccounts? billAccounts =
            Get.find<PatternController>().controllerToBillAccountsMap[textEditingController];

        if (billAccounts != null) {
          selectedAccounts[billAccounts] = selectedAccountModel;
        }

        if (isCustomerAccount) {
          if (fromAddBill) {
            log('fromAddBill');
            billController!.updateCustomerAccount(selectedAccountModel);
          } else {
            log('BillDetailsController');
            billController!.updateCustomerAccount(selectedAccountModel);
          }
        }

        textEditingController.text = selectedAccountModel.accName!;
      }
      return selectedAccountModel;
    } else if (searchedAccounts.isNotEmpty) {
      // Multiple matches, show search dialog

      // Create an overlay entry to show the dialog on top of everything
      final overlay = Overlay.of(context);

      late OverlayEntry overlayEntry;

      OverlayEntryWithPriorityManager entryWithPriorityInstance = OverlayEntryWithPriorityManager.instance;

      late OverlayEntryWithPriority overlayEntryWithPriority;

      overlayEntry = OverlayEntry(
        builder: (context) {
          return AccountSelectionDialog(
            accounts: searchedAccounts,
            onCloseTap: () {
              overlayEntry.remove();
              entryWithPriorityInstance.remove(overlayEntryWithPriority);
            },
            onAccountTap: (selectedAccount) {
              // Remove the overlay entry when account is selected
              overlayEntry.remove();
              entryWithPriorityInstance.remove(overlayEntryWithPriority);

              // Set the selected account to the model
              selectedAccountModel = selectedAccount;

              // Callback for parent function with selected account
              if (selectedAccountModel != null && textEditingController != null) {
                final BillAccounts? billAccounts =
                    Get.find<PatternController>().controllerToBillAccountsMap[textEditingController];

                if (billAccounts != null) {
                  selectedAccounts[billAccounts] = selectedAccountModel!;
                }

                if (isCustomerAccount) {
                  if (fromAddBill) {
                    log('fromAddBill');
                    billController!.updateCustomerAccount(selectedAccountModel);
                  } else {
                    log('InvoiceController');
                    billController!.updateCustomerAccount(selectedAccountModel);
                  }
                }

                textEditingController.text = selectedAccountModel!.accName!;
              }
            },
          );
        },
      );

      overlayEntryWithPriority = OverlayEntryWithPriority(overlayEntry: overlayEntry, priority: 0);

      // Insert the overlay entry above all other widgets
      overlay.insert(overlayEntry);
      entryWithPriorityInstance.add(overlayEntryWithPriority);

      // Wait for the dialog to return a result (if needed)
      return selectedAccountModel;
    } else {
      // No matches
      AppUIUtils.showSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
      return null;
    }
  }

// Future<AccountModel?> openAccountSelectionDialog({
//   required String query,
//   TextEditingController? textEditingController,
//   bool isCustomerAccount = false,
//   bool fromAddBill = false,
// }) async {
//   List<AccountModel> searchedAccounts = getAccounts(query);
//
//   if (searchedAccounts.isNotEmpty) {
//     AccountModel? selectedAccountModel = await Get.defaultDialog<AccountModel>(
//       title: 'Choose Account',
//       content: AccountSelectionDialog(accounts: searchedAccounts),
//     );
//
//     if (selectedAccountModel != null && textEditingController != null) {
//       // Infer `billTypeAccounts` from the controller
//       final BillAccounts? billAccounts =
//           Get.find<PatternController>().controllerToBillAccountsMap[textEditingController];
//
//       if (billAccounts != null) {
//         selectedAccounts[billAccounts] = selectedAccountModel;
//       }
//
//       // Assign selectedCustomerAccount only if the controller matches customerAccountController
//       if (isCustomerAccount) {
//         if (fromAddBill) {
//           log('fromAddBill');
//           Get.find<AddBillController>().updateCustomerAccount(selectedAccountModel);
//         } else {
//           log('InvoiceController');
//           Get.find<BillDetailsController>().updateCustomerAccount(selectedAccountModel);
//         }
//       }
//
//       textEditingController.text = selectedAccountModel.accName!;
//       update();
//     }
//     return selectedAccountModel;
//   } else {
//     AppUIUtils.showSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
//     return null;
//   }
// }
}
