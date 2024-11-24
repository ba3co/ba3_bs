import 'dart:developer';

import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/firebase/implementations/firebase_repo_with_result_impl.dart';
import '../../../../core/services/firebase/implementations/firebase_repo_without_result_impl.dart';
import '../../../../core/services/json_file_operations/implementations/export/json_export_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';
import '../../services/bill/bill_utils.dart';
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
    _navigateToBillDetailsWithModel(billModel, fromBillById: true);
  }

  Future<void> openLastBillDetails(BillTypeModel billTypeModel) async {
    await fetchBills();

    List<BillModel> billsByCategory = getBillsByType(billTypeModel.billTypeId!);

    if (billsByCategory.isEmpty) {
      _navigateToAddBill(billTypeModel);
      return;
    }

    BillModel lastBillModel = billsByCategory.last;

    _navigateToBillDetailsWithModel(lastBillModel);
  }

  void _navigateToAddBill(BillTypeModel billTypeModel) {
    Get.find<BillDetailsController>().navigateToAddBillScreen(billTypeModel);
  }

  void _navigateToBillDetailsWithModel(BillModel billModel, {bool fromBillById = false}) {
    Get.find<BillDetailsController>().refreshScreenWithCurrentBillModel(billModel);

    initializeBillSearch(billModel);

    Get.toNamed(AppRoutes.billDetailsScreen, arguments: fromBillById);
  }

  void initializeBillSearch(BillModel bill) {
    List<BillModel> billsByCategory = getBillsByType(bill.billTypeModel.billTypeId!);

    Get.find<BillSearchController>().initializeBillSearch(billsByCategory: billsByCategory, bill: bill);
  }
}
