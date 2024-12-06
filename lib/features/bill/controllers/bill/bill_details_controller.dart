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

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/router/app_routes.dart';
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

  final FirebaseRepositoryWithResultImpl<BillModel> _billsFirebaseRepo;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;

  BillDetailsController(
    this._billsFirebaseRepo, {
    required this.billDetailsPlutoController,
    required this.billSearchController,
  });

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
    _billService = BillService(billDetailsPlutoController);
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

  Future<void> deleteBill(BillModel billModel, {bool fromBillById = false}) async {
    final result = await _billsFirebaseRepo.delete(billModel.billId!);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => _handleDeleteSuccess(billModel, fromBillById),
    );
  }

  Future<void> _handleDeleteSuccess(BillModel billModel, [fromBillById]) async {
    // Only fetchBills if open bill details by bill id from AllBillsScreen
    if (fromBillById) {
      await Get.find<AllBillsController>().fetchBills();
      Get.back();
    } else {
      billSearchController.removeBill(billModel);
    }

    AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!');
  }

  Future<void> saveBill(BillTypeModel billTypeModel) async {
    await _saveOrUpdateBill(billTypeModel: billTypeModel);
  }

  Future<void> updateBill({required BillTypeModel billTypeModel, required BillModel billModel}) async {
    await _saveOrUpdateBill(billTypeModel: billTypeModel, existingBillModel: billModel);
  }

  Future<void> _saveOrUpdateBill({required BillTypeModel billTypeModel, BillModel? existingBillModel}) async {
    // Validate the form first
    if (!validateForm()) return;

    // Create the bill model from the provided data
    final updatedBillModel = _createBillModelFromBillData(billTypeModel, existingBillModel);

    // Handle null bill model
    if (updatedBillModel == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل واسم البائع!');
      return;
    }

    // Ensure there are bill items
    if (!hasBillItems(updatedBillModel.items.itemList)) return;

    // Save the bill to Firestore
    final result = await _billsFirebaseRepo.save(updatedBillModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (billModel) {
        if (existingBillModel != null) {
          _handleUpdateSuccess(billModel);
        } else {
          _handleSaveSuccess(billModel);
        }
      },
    );
  }

  bool _validateCustomerAccount() {
    if (selectedCustomerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل!');
      return false;
    }
    return true;
  }

  bool _validateSellerAccount(SellerController sellerController) {
    if (sellerController.selectedSellerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم البائع!');
      return false;
    }
    return true;
  }

  Future<void> _handleSaveSuccess(BillModel billModel) async {
    AppUIUtils.onSuccess('تم حفظ الفاتورة بنجاح!');

    generateAndSendBillPdf(
      recipientEmail: AppStrings.recipientEmail,
      billModel: billModel,
      fileName: AppStrings.bill,
      logoSrc: AppAssets.ba3Logo,
      fontSrc: AppAssets.notoSansArabicRegular,
    );
  }

  void _handleUpdateSuccess(BillModel billModel) {
    AppUIUtils.onSuccess('تم تعديل الفاتورة بنجاح!');

    billSearchController.updateBill(billModel);

    generateAndSendBillPdf(
      recipientEmail: AppStrings.recipientEmail,
      billModel: billModel,
      fileName: AppStrings.bill,
      logoSrc: AppAssets.ba3Logo,
      fontSrc: AppAssets.notoSansArabicRegular,
    );
  }

  BillModel? _createBillModelFromBillData(BillTypeModel billTypeModel, [BillModel? billModel]) {
    final updatedBillTypeModel = _updateBillTypeAccounts(billTypeModel) ?? billTypeModel;
    final sellerController = Get.find<SellerController>();

    // Validate customer and seller accounts
    if (!_validateCustomerAccount() || !_validateSellerAccount(sellerController)) {
      return null;
    }

    // Create and return the bill model
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

  void navigateToAddBillScreen(BillTypeModel billTypeModel, AddBillPlutoController addBillPlutoController,
      {bool fromBillDetails = false, bool fromBillById = false}) {
    Get.put(AddBillController(
      _billsFirebaseRepo,
      addBillPlutoController: addBillPlutoController,
    )).initCustomerAccount(billTypeModel.accounts?[BillAccounts.caches]);

    Get.toNamed(AppRoutes.addBillScreen,
        arguments: {'billTypeModel': billTypeModel, 'fromBillDetails': fromBillDetails, 'fromBillById': fromBillById});
  }

  void createNewFloatingAddBillScreen(
    BillTypeModel billTypeModel,
    BuildContext context, {
    bool fromBillDetails = false,
    bool fromBillById = false,
  }) {
    final String tag = _generateUniqueTag();

    // Initialize the AddBillPlutoController
    AddBillPlutoController addBillPlutoController = _initializeAddBillPlutoController(tag);

    // Initialize the AddBillController
    AddBillController addBillController = _initializeAddBillController(billTypeModel, addBillPlutoController, tag);

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

  String _generateUniqueTag() => 'AddBillController_${UniqueKey().toString()}';

  AddBillController _initializeAddBillController(
      BillTypeModel billTypeModel, AddBillPlutoController addBillPlutoController, String tag) {
    // Create the AddBillController using Get
    return Get.put<AddBillController>(
      AddBillController(_billsFirebaseRepo, addBillPlutoController: addBillPlutoController),
      tag: tag,
    )..initCustomerAccount(billTypeModel.accounts?[BillAccounts.caches]);
  }

  AddBillPlutoController _initializeAddBillPlutoController(String tag) =>
      Get.put<AddBillPlutoController>(AddBillPlutoController(), tag: tag);

  prepareBillRecords(BillItems billItems, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareBillMaterialsRows(billItems.getMaterialRecords);

  prepareAdditionsDiscountsRecords(BillModel billModel, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareAdditionsDiscountsRows(billModel.getAdditionsDiscountsRecords);

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

  void initSellerAccount(String? billSellerId) => Get.find<SellerController>().initSellerAccount(billSellerId, this);

  void updateBillDetailsOnScreen(BillModel bill, BillDetailsPlutoController billPlutoController) {
    onPayTypeChanged(InvPayType.fromIndex(bill.billDetails.billPayType!));

    setBillDate(bill.billDetails.billDate!.toDate!);

    initBillNumberController(bill.billDetails.billNumber);

    initCustomerAccount(bill.billTypeModel.accounts?[BillAccounts.caches]);

    initSellerAccount(bill.billDetails.billSellerId);

    prepareBillRecords(bill.items, billPlutoController);
    prepareAdditionsDiscountsRecords(bill, billPlutoController);

    billPlutoController.update();
  }
}

// 300 - 193
