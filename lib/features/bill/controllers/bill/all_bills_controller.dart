import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/firebase/abstract/i_firebase_repo.dart';
import '../../../../core/services/json_file_operations/implementations/export/json_export_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';
import '../../services/bill/bill_utils.dart';
import 'bill_search_controller.dart';

class AllBillsController extends GetxController {
  // Repositories
  final IFirebaseRepository<BillTypeModel> _patternsFirebaseRepo;
  final IFirebaseRepository<BillModel> _billsFirebaseRepo;
  final JsonExportRepository<BillModel> _jsonExportRepo;

  AllBillsController(this._patternsFirebaseRepo, this._billsFirebaseRepo, this._jsonExportRepo);

  // Services
  late final InvoiceUtils _invoiceUtils;

  List<BillTypeModel> billsTypes = [];
  List<BillModel> bills = [];
  bool isLoading = true;

  // Initializer
  void _initializeServices() {
    _invoiceUtils = InvoiceUtils();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    getAllBillTypes();
  }

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  Future<void> fetchBills() async {
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
      (filePath) => _invoiceUtils.showExportSuccessDialog(filePath),
    );
  }

  void navigateToAllBillsScreen() => Get.toNamed(AppRoutes.showAllBillsScreen);

  List<BillModel> getBillsByType(String billTypeId) =>
      bills.where((bill) => bill.billTypeModel.billTypeId == billTypeId).toList();

  void openBillDetailsById(String billId) {
    final BillModel billModel = getBillById(billId);
    _navigateToBillDetailsWithModel(billModel);
  }

  Future<void> openLastBillDetails(String billTypeId, [bool offRoute = false]) async {
    await fetchBills();

    List<BillModel> billsByCategory = getBillsByType(billTypeId);

    if (billsByCategory.isEmpty) return;

    BillModel lastBillModel = billsByCategory.last;

    _navigateToBillDetailsWithModel(lastBillModel, offRoute);
  }

  void _navigateToBillDetailsWithModel(BillModel billModel, [bool offRoute = false]) {
    Get.find<BillDetailsController>().updateScreenWithBillData(billModel);

    initializeBillSearch(billModel);

    if (offRoute) {
      Get.until(ModalRoute.withName(AppRoutes.billDetailsScreen));
    } else {
      Get.toNamed(AppRoutes.billDetailsScreen);
    }
  }

  void initializeBillSearch(BillModel bill) {
    List<BillModel> billsByCategory = getBillsByType(bill.billTypeModel.billTypeId!);

    Get.putIfAbsent(BillSearchController()).initSearchControllerBill(billsByCategory: billsByCategory, bill: bill);
  }
}
