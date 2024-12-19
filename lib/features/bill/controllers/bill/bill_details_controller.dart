import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/interfaces/i_store_selection_handler.dart';
import 'package:ba3_bs/core/services/firebase/implementations/datasource_repo.dart';
import 'package:ba3_bs/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/bill/services/bill/bill_utils.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
import '../../services/bill/account_handler.dart';
import '../../services/bill/bill_pdf_generator.dart';
import '../../services/bill/bill_service.dart';
import '../../ui/screens/add_bill_screen.dart';
import '../pluto/add_bill_pluto_controller.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillDetailsController extends IBillController with AppValidator implements IStoreSelectionHandler {
  // Repositories

  final DataSourceRepository<BillModel> _billsFirebaseRepo;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;

  BillDetailsController(
    this._billsFirebaseRepo, {
    required this.billDetailsPlutoController,
    required this.billSearchController,
  });

  // Services
  late final BillService _billService;
  late final BillUtils _billUtils;
  late final AccountHandler _accountHandler;

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

  AccountModel? selectedCustomerAccount;

  RxString billDate = DateTime.now().toString().split(" ")[0].obs;

  Rx<InvPayType> selectedPayType = InvPayType.cash.obs;

  BillType billType = BillType.sales;
  bool isLoading = true;

  Map<Account, AccountModel> selectedAdditionsDiscountAccounts = {};

  RxBool isBillSaved = false.obs;

  @override
  updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value) =>
      selectedAdditionsDiscountAccounts[key] = value;

  @override
  Rx<StoreAccount> selectedStore = StoreAccount.main.obs;

  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) {
      selectedStore.value = newStore;
    }
  }

  @override
  void updateCustomerAccount(AccountModel? newAccount) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
    }
  }

  @override
  Future<void> sendToEmail(
      {required String recipientEmail, String? url, String? subject, String? body, List<String>? attachments}) async {
    _billService.sendToEmail(
        recipientEmail: recipientEmail, url: url, subject: subject, body: body, attachments: attachments);
  }

  @override
  set updateIsBillSaved(bool newValue) {
    isBillSaved.value = newValue;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _billService = BillService(billDetailsPlutoController, this);
    _billUtils = BillUtils();
    _accountHandler = AccountHandler();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void updateBillType(String billTypeLabel) => billType = BillType.byLabel(billTypeLabel);

  set setBillDate(DateTime newDate) {
    billDate.value = newDate.toString().split(" ")[0];
    //   update();
  }

  void onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType.value = payType;
      // update();
      log('onPayTypeChanged');
    }
  }

  Future<void> printBill({required int billNumber, required List<InvoiceRecordModel> invRecords}) async {
    await Get.find<PrintingController>()
        .startPrinting(invRecords: invRecords, billNumber: billNumber, invDate: billDate.value);
  }

  void createBond(BillModel billModel, BuildContext context) {
    if (!validateForm()) return;

    _billService.createBond(
      context: context,
      billModel: billModel,
      discountsAndAdditions: billDetailsPlutoController.generateDiscountsAndAdditions,
    );
  }

  Future<void> deleteBill(BillModel billModel, {bool fromBillById = false}) async {
    final result = await _billsFirebaseRepo.delete(billModel.billId!);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => _billService.handleDeleteSuccess(
        billModel: billModel,
        billSearchController: billSearchController,
        fromBillById: fromBillById,
      ),
    );
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
    if (!_billService.hasModelItems(updatedBillModel.items.itemList)) return;

    // Save the bill to Firestore
    final result = await _billsFirebaseRepo.save(updatedBillModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (billModel) {
        _billService.handleSaveOrUpdateSuccess(
          billModel: billModel,
          discountsAndAdditions: billDetailsPlutoController.generateDiscountsAndAdditions,
          billSearchController: billSearchController,
          isSave: existingBillModel == null,
        );
      },
    );
  }

  BillModel? _createBillModelFromBillData(BillTypeModel billTypeModel, [BillModel? billModel]) {
    final sellerController = Get.find<SellerController>();

    // Validate customer and seller accounts
    if (!_billUtils.validateCustomerAccount(selectedCustomerAccount) ||
        !_billUtils.validateSellerAccount(sellerController.selectedSellerAccount)) {
      return null;
    }
    final updatedBillTypeModel = _accountHandler.updateBillTypeAccounts(
            billTypeModel, selectedAdditionsDiscountAccounts, selectedCustomerAccount, selectedStore.value) ??
        billTypeModel;

    // Create and return the bill model
    return _billService.createBillModel(
      billModel: billModel,
      billTypeModel: updatedBillTypeModel,
      billDate: billDate.value,
      billCustomerId: selectedCustomerAccount!.id!,
      billSellerId: sellerController.selectedSellerAccount!.costGuid!,
      billPayType: selectedPayType.value.index,
    );
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
      onCloseCallback: () {
        Get.delete<AddBillController>(tag: tag, force: true);
        Get.delete<AddBillPlutoController>(tag: tag, force: true);
      },
      floatingScreen: AddBillScreen(
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

    setBillDate = bill.billDetails.billDate!.toDate!;

    initBillNumberController(bill.billDetails.billNumber);

    initCustomerAccount(bill.billTypeModel.accounts?[BillAccounts.caches]);

    initSellerAccount(bill.billDetails.billSellerId);

    prepareBillRecords(bill.items, billPlutoController);
    prepareAdditionsDiscountsRecords(bill, billPlutoController);

    billPlutoController.update();
  }

  generateAndSendBillPdf(BillModel billModel) {
    _billService.generateAndSendPdf(
      fileName: AppStrings.bill,
      itemModel: billModel,
      itemModelId: billModel.billId,
      items: billModel.items.itemList,
      pdfGenerator: BillPdfGenerator(),
    );
  }

  showEInvoiceDialog(BillModel billModel, BuildContext context) {
    _billService.showEInvoiceDialog(billModel, context);
  }
}

// 300 - 193
