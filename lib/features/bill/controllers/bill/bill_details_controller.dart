import 'package:ba3_bs/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/interfaces/i_store_selection_handler.dart';
import 'package:ba3_bs/core/services/firebase/implementations/firebase_repo_with_result_impl.dart';
import 'package:ba3_bs/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../floating_window/services/floating_window_service.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../print/controller/print_controller.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/invoice_record_model.dart';
import '../../services/bill/bill_service.dart';
import '../../ui/screens/add_bill_screen.dart';
import '../pluto/add_bill_pluto_controller.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillDetailsController extends IBillController with AppValidator implements IStoreSelectionHandler {
  // Repositories

  final FirebaseRepositoryWithResultImpl<BillModel> _billsFirebaseRepoWithResult;

  BillDetailsController(this._billsFirebaseRepoWithResult);

  // Services
  late final BillService _billService;

  final formKey = GlobalKey<FormState>();
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController firstPayController = TextEditingController();
  final TextEditingController invReturnDateController = TextEditingController();
  final TextEditingController invReturnCodeController = TextEditingController();

  late String billDate;
  AccountModel? selectedCustomerAccount;
  InvPayType selectedPayType = InvPayType.cash;
  BillType billType = BillType.sales;
  bool isLoading = true;

  Map<Account, AccountModel> selectedAdditionsDiscountAccounts = {};

  @override
  updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value) =>
      selectedAdditionsDiscountAccounts[key] = value;

  @override
  StoreAccount selectedStore = StoreAccount.main;

  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) {
      selectedStore = newStore;
      update();
    }
  }

  @override
  void updateCustomerAccount(AccountModel? newAccount) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    setBillDate(DateTime.now());
  }

  // Initializer
  void _initializeServices() {
    _billService = BillService(Get.find<BillDetailsPlutoController>());
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void updateBillType(String billTypeLabel) => billType = BillType.byLabel(billTypeLabel);

  void setBillDate(DateTime newDate) {
    billDate = newDate.toString().split(" ")[0];
    update();
  }

  void onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType = payType;
      update();
    }
  }

  Future<void> printBill({required int billNumber, required List<InvoiceRecordModel> invRecords}) async {
    await Get.find<PrintingController>()
        .startPrinting(invRecords: invRecords, billNumber: billNumber, invDate: billDate);
  }

  void createBond(BillTypeModel billTypeModel) {
    if (!validateForm()) return;

    _billService.createBond(billTypeModel: billTypeModel, customerAccount: selectedCustomerAccount!);
  }

  Future<void> deleteBill(String billId, {bool fromBillById = false}) async {
    final result = await _billsFirebaseRepoWithResult.delete(billId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => _handleDeleteSuccess(fromBillById),
    );
  }

  Future<void> _handleDeleteSuccess([fromBillById]) async {
    // Only fetchBills if open bill details by bill id from AllBillsScreen
    if (fromBillById) {
      await Get.find<AllBillsController>().fetchBills();
    }

    Get.back();
    AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!');
  }

  Future<void> updateBill({required BillTypeModel billTypeModel, required BillModel billModel}) async {
    if (!validateForm()) return;

    final updatedBillModel = _createBillModelFromInvoiceData(billModel, billTypeModel);

    if (updatedBillModel == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل واسم البائع!');
      return;
    }

    final result = await _billsFirebaseRepoWithResult.save(updatedBillModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (billModel) => _handleUpdateSuccess(billModel),
    );
  }

  void _handleUpdateSuccess(BillModel billModel) {
    AppUIUtils.onSuccess('تم تعديل الفاتورة بنجاح!');

    Get.find<BillSearchController>().updateBillInSearchResults(billModel);
  }

  BillModel? _createBillModelFromInvoiceData(BillModel billModel, BillTypeModel billTypeModel) {
    final updatedBillTypeModel = _updateBillTypeAccounts(billTypeModel) ?? billTypeModel;

    SellerController sellerController = Get.find<SellerController>();

    if (selectedCustomerAccount == null || sellerController.selectedSellerAccount == null) {
      return null;
    }

    return _billService.createBillModel(
      billModel: billModel,
      billTypeModel: updatedBillTypeModel,
      billDate: billDate,
      billCustomerId: selectedCustomerAccount!.id!,
      billSellerId: sellerController.selectedSellerAccount!.costGuid!,
      billPayType: selectedPayType.index,
    );
  }

  BillTypeModel? _updateBillTypeAccounts(BillTypeModel billTypeModel) {
    final selectedAccounts = selectedAdditionsDiscountAccounts;
    final updatedAccounts = {...billTypeModel.accounts ?? {}};

    if (_noUpdateNeeded(selectedAccounts, selectedCustomerAccount)) return null;

    _updateDiscountAndAdditionAccounts(selectedAccounts, updatedAccounts);

    _updateCachesAccount(selectedCustomerAccount, updatedAccounts);

    _updateStoreAccount(selectedStore, updatedAccounts);

    return billTypeModel.copyWith(accounts: updatedAccounts);
  }

  // Return null if there is Additions and Discounts Accounts not updated and no selected customer account
  bool _noUpdateNeeded(Map<Account, AccountModel> selectedAccounts, AccountModel? selectedCustomerAccount) =>
      selectedAccounts.isEmpty && selectedCustomerAccount == null;

  // Update discount and addition accounts
  void _updateDiscountAndAdditionAccounts(
      Map<Account, AccountModel> selectedAccounts, Map<Account, AccountModel> updatedAccounts) {
    if (selectedAccounts.isNotEmpty) {
      if (selectedAccounts.containsKey(BillAccounts.discounts)) {
        updatedAccounts[BillAccounts.discounts] = selectedAccounts[BillAccounts.discounts]!;
      }
      if (selectedAccounts.containsKey(BillAccounts.additions)) {
        updatedAccounts[BillAccounts.additions] = selectedAccounts[BillAccounts.additions]!;
      }
    }
  }

  // Update caches account if selectedCustomerAccount is not null and differs from the current cache
  void _updateCachesAccount(AccountModel? selectedCustomerAccount, Map<Account, AccountModel> updatedAccounts) {
    if (selectedCustomerAccount != null && updatedAccounts[BillAccounts.caches]?.id != selectedCustomerAccount.id) {
      updatedAccounts[BillAccounts.caches] = selectedCustomerAccount;
    }
  }

  // Update store account if selectedStore is not null and differs from the current store
  void _updateStoreAccount(StoreAccount? selectedStore, Map<Account, AccountModel> updatedAccounts) {
    if (selectedStore != null && updatedAccounts[BillAccounts.store]?.id != selectedStore.typeGuide) {
      updatedAccounts[BillAccounts.store] = selectedStore.toStoreAccountModel;
    }
  }

  void navigateToAddBillScreen(BillTypeModel billTypeModel, {bool fromBillDetails = false, bool fromBillById = false}) {
    // Get.put(AddBillController(_billsFirebaseRepoWithResult))
    //     .initCustomerAccount(billTypeModel.accounts?[BillAccounts.caches]);
    //
    // Get.toNamed(AppRoutes.addBillScreen,
    //     arguments: {'billTypeModel': billTypeModel, 'fromBillDetails': fromBillDetails, 'fromBillById': fromBillById});
  }

  void createNewFloatingAddBillScreen(
    BillTypeModel billTypeModel,
    BuildContext context, {
    bool fromBillDetails = false,
    bool fromBillById = false,
  }) {
    final tag = 'AddBillController_${UniqueKey().toString()}';

    // Initialize the AddBillController
    AddBillController addBillController = _initializeAddBillController(billTypeModel, tag);

    // Initialize the AddBillPlutoController
    AddBillPlutoController addBillPlutoController = _initializeAddBillPlutoController(tag);

    // Launch the floating window with the AddBillScreen
    FloatingWindowService.launchFloatingWindow(
      context: context,
      onCloseContentControllerCallback: () {
        Get.delete<AddBillController>(tag: tag, force: true);
        Get.delete<AddBillPlutoController>(tag: tag, force: true);
      },
      floatingWindowContent: AddBillScreen(
        billTypeModel: billTypeModel,
        fromBillDetails: fromBillDetails,
        fromBillById: fromBillById,
        addBillController: addBillController,
        addBillPlutoController: addBillPlutoController,
        tag: tag,
      ),
    );
  }

  AddBillController _initializeAddBillController(BillTypeModel billTypeModel, String tag) {
    // Create the AddBillController using Get
    return Get.put<AddBillController>(AddBillController(_billsFirebaseRepoWithResult), tag: tag)
      ..initCustomerAccount(billTypeModel.accounts?[BillAccounts.caches]);
  }

  AddBillPlutoController _initializeAddBillPlutoController(String tag) =>
      Get.put<AddBillPlutoController>(AddBillPlutoController(), tag: tag);

  prepareBillRecords(BillItems billItems, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareBillMaterialsRows(billItems.materialRecords);

  prepareAdditionsDiscountsRecords(BillModel billModel, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareAdditionsDiscountsRows(billModel.additionsDiscountsRecords);

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  initBillNumberController(int? billNumber) {
    if (billNumber != null) {
      billNumberController.text = billNumber.toString();
    } else {
      billNumberController.text = '';
    }
  }

  void initSellerAccount(String billSellerId) => Get.find<SellerController>().initSellerAccount(billSellerId);

  void refreshScreenWithCurrentBillModel(BillModel bill) {
    BillDetailsPlutoController billPlutoController = Get.find<BillDetailsPlutoController>();

    onPayTypeChanged(InvPayType.fromIndex(bill.billDetails.billPayType!));

    setBillDate(bill.billDetails.billDate!.toDate!);

    initBillNumberController(bill.billDetails.billNumber);

    initCustomerAccount(bill.billTypeModel.accounts?[BillAccounts.caches]);
    initSellerAccount(bill.billDetails.billSellerId!);

    prepareBillRecords(bill.items, billPlutoController);
    prepareAdditionsDiscountsRecords(bill, billPlutoController);

    billPlutoController.update();
  }
}

// 300 - 193
