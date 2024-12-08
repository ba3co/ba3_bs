import 'dart:developer';

import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import 'package:ba3_bs/features/bill/ui/screens/bill_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/firebase/implementations/firebase_repo_with_result_impl.dart';
import '../../../../core/services/firebase/implementations/firebase_repo_without_result_impl.dart';
import '../../../../core/services/json_file_operations/implementations/export/json_export_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../floating_window/services/floating_window_service.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';
import '../../services/bill/bill_utils.dart';
import '../pluto/add_bill_pluto_controller.dart';
import 'bill_search_controller.dart';

class AllBillsController extends GetxController {
  // Repositories
  final FirebaseRepositoryWithoutResultImpl<BillTypeModel> _patternsFirebaseRepo;
  final FirebaseRepositoryWithResultImpl<BillModel> _billsFirebaseRepo;
  final JsonExportRepository<BillModel> _jsonExportRepo;

  AllBillsController(this._patternsFirebaseRepo, this._billsFirebaseRepo, this._jsonExportRepo);

  // Services
  late final BillUtils _billUtils;

  List<BillTypeModel> billsTypes = [];
  List<BillModel> bills = [];
  bool isLoading = true;

  // Initializer
  void _initializeServices() {
    _billUtils = BillUtils();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    getAllBillTypes();
  }

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  Future<void> fetchBills() async {
    log('fetchBills');
    final result = await _billsFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBills) => bills.assignAll(fetchedBills),
    );

    isLoading = false;
    update();
  }

  Future<void> getAllAccountBills(String accId) async {
    log('fetchAccount $accId Bills');
    final result = await _billsFirebaseRepo.getById(accId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBills) => bills.add(fetchedBills),
    );

    isLoading = false;
    update();
  }

  Future<void> getAllBillTypes() async {
    final result = await _patternsFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBillTypes) => billsTypes.assignAll(fetchedBillTypes),
    );

    update();
  }

  Future<void> exportBillsJsonFile() async {
    if (bills.isEmpty) {
      AppUIUtils.onFailure('لا توجد فواتير للتصدير');
      return;
    }

    final result = await _jsonExportRepo.exportJsonFile(bills);

    result.fold(
      (failure) => AppUIUtils.onFailure('فشل في تصدير الملف [${failure.message}]'),
      (filePath) => _billUtils.showExportSuccessDialog(filePath),
    );
  }

  void navigateToAllBillsScreen() => Get.toNamed(AppRoutes.showAllBillsScreen);

  List<BillModel> getBillsByType(String billTypeId) =>
      bills.where((bill) => bill.billTypeModel.billTypeId == billTypeId).toList();

  void openBillDetailsById(String billId) {
    final BillModel billModel = getBillById(billId);

    List<BillModel> billsByCategory = getBillsByType(billModel.billTypeModel.billTypeId!);

    _navigateToBillDetailsWithModel(billModel, billsByCategory, fromBillById: true);
  }

  Future<void> openLastBillDetails(BillTypeModel billTypeModel, AddBillPlutoController addBillPlutoController) async {
    await fetchBills();

    List<BillModel> billsByCategory = getBillsByType(billTypeModel.billTypeId!);

    if (billsByCategory.isEmpty) {
      _navigateToAddBill(billTypeModel, addBillPlutoController);
      return;
    }

    final BillModel lastBillModel = _billUtils.appendEmptyBillModel(billsByCategory, billTypeModel);

    _navigateToBillDetailsWithModel(lastBillModel, billsByCategory);
  }

  Future<void> openFloatingBillDetails(BuildContext context, BillTypeModel billTypeModel) async {
    await fetchBills();

    if (!context.mounted) return;

    List<BillModel> billsByCategory = getBillsByType(billTypeModel.billTypeId!);
    final String tag = _generateUniqueTag();
    final controllers = _initializeControllers(tag);

    final BillModel lastBillModel = _billUtils.appendEmptyBillModel(billsByCategory, billTypeModel);

    _openBillDetailsFloatingWindow(
      context: context,
      modifiedBills: billsByCategory,
      lastBillModel: lastBillModel,
      tag: tag,
      controllers: controllers,
    );
  }

  // Opens the 'Bill Details' floating window.
  void _openBillDetailsFloatingWindow({
    required BuildContext context,
    required List<BillModel> modifiedBills,
    required BillModel lastBillModel,
    required String tag,
    required ({
      BillDetailsController billDetailsController,
      BillDetailsPlutoController billDetailsPlutoController,
      BillSearchController billSearchController
    }) controllers,
  }) {
    controllers.billDetailsController.updateBillDetailsOnScreen(lastBillModel, controllers.billDetailsPlutoController);

    initializeBillSearch(
      currentBill: lastBillModel,
      allBills: modifiedBills,
      billSearchController: controllers.billSearchController,
      billDetailsController: controllers.billDetailsController,
      billDetailsPlutoController: controllers.billDetailsPlutoController,
    );

    createNewFloatingAddBillScreen(
      context: context,
      tag: tag,
      billDetailsController: controllers.billDetailsController,
      billDetailsPlutoController: controllers.billDetailsPlutoController,
      billSearchController: controllers.billSearchController,
    );
  }

  // Generates a unique tag for identifying controllers.
  String _generateUniqueTag() => 'BillDetailsController_${UniqueKey().toString()}';

  // Initializes all necessary controllers for bill details handling.
  ({
    BillDetailsController billDetailsController,
    BillDetailsPlutoController billDetailsPlutoController,
    BillSearchController billSearchController
  }) _initializeControllers(String tag) {
    final billDetailsPlutoController = _initializeBillDetailsPlutoController(tag);
    final billSearchController = _initializeBillSearchController(tag);
    final billDetailsController =
        _initializeBillDetailsController(tag, billDetailsPlutoController, billSearchController);

    return (
      billDetailsController: billDetailsController,
      billDetailsPlutoController: billDetailsPlutoController,
      billSearchController: billSearchController,
    );
  }

  void createNewFloatingAddBillScreen({
    required BuildContext context,
    required String tag,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
    required BillSearchController billSearchController,
    bool fromBillById = false,
  }) {
    // Launch the floating window with the AddBillScreen
    FloatingWindowService.launchFloatingWindow(
      context: context,
      onCloseContentControllerCallback: () {
        Get.delete<BillDetailsController>(tag: tag, force: true);
        Get.delete<BillDetailsPlutoController>(tag: tag, force: true);
        Get.delete<BillSearchController>(tag: tag, force: true);
      },
      floatingWindowContent: BillDetailsScreen(
        fromBillById: fromBillById,
        billDetailsController: billDetailsController,
        billDetailsPlutoController: billDetailsPlutoController,
        billSearchController: billSearchController,
        tag: tag,
      ),
    );
  }

  BillDetailsController _initializeBillDetailsController(
    String tag,
    BillDetailsPlutoController billDetailsPlutoController,
    BillSearchController billSearchController,
  ) =>
      Get.put<BillDetailsController>(
        BillDetailsController(_billsFirebaseRepo,
            billDetailsPlutoController: billDetailsPlutoController, billSearchController: billSearchController),
        tag: tag,
      );

  BillDetailsPlutoController _initializeBillDetailsPlutoController(String tag) =>
      Get.put<BillDetailsPlutoController>(BillDetailsPlutoController(), tag: tag);

  BillSearchController _initializeBillSearchController(String tag) =>
      Get.put<BillSearchController>(BillSearchController(), tag: tag);

  void _navigateToAddBill(BillTypeModel billTypeModel, AddBillPlutoController addBillPlutoController) {
    Get.find<BillDetailsController>().navigateToAddBillScreen(billTypeModel, addBillPlutoController);
  }

  void _navigateToBillDetailsWithModel(
    BillModel billModel,
    List<BillModel> allBills, {
    bool fromBillById = false,
  }) {
    final tag = 'AddBillController_${UniqueKey().toString()}';

    // Initialize the BillDetailsPlutoController
    BillDetailsPlutoController billDetailsPlutoController = _initializeBillDetailsPlutoController(tag);

    // Initialize the BillSearchController
    BillSearchController billSearchController = _initializeBillSearchController(tag);

    // Initialize the BillDetailsController
    BillDetailsController billDetailsController =
        _initializeBillDetailsController(tag, billDetailsPlutoController, billSearchController);

    billDetailsController.updateBillDetailsOnScreen(billModel, billDetailsPlutoController);

    initializeBillSearch(
      currentBill: billModel,
      allBills: allBills,
      billSearchController: billSearchController,
      billDetailsController: billDetailsController,
      billDetailsPlutoController: billDetailsPlutoController,
    );

    Get.toNamed(AppRoutes.billDetailsScreen, arguments: {
      'fromBillById': fromBillById,
      'billDetailsController': billDetailsController,
      'billDetailsPlutoController': billDetailsPlutoController,
      'billSearchController': billSearchController,
      'tag': tag,
    });
  }

  void initializeBillSearch({
    required BillModel currentBill,
    required List<BillModel> allBills,
    required BillSearchController billSearchController,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
  }) {
    billSearchController.initialize(
      bill: currentBill,
      billsByCategory: allBills,
      billDetailsController: billDetailsController,
      billDetailsPlutoController: billDetailsPlutoController,
    );
  }
}
