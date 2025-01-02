import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/json_file_operations/implementations/json_import_export_repo.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import 'package:ba3_bs/features/bill/ui/screens/bill_details_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';
import '../../services/bill/bill_utils.dart';
import '../../services/bill/floating_bill_details_launcher.dart';
import 'bill_search_controller.dart';

class AllBillsController extends FloatingBillDetailsLauncher with AppNavigator {
  // Repositories
  final DataSourceRepository<BillTypeModel> _patternsFirebaseRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;
  final JsonImportExportRepository<BillModel> _jsonImportExportRepo;

  AllBillsController(this._patternsFirebaseRepo, this._billsFirebaseRepo, this._jsonImportExportRepo);

  // Services
  late final BillUtils _billUtils;

  List<BillTypeModel> billsTypes = [];

  List<BillModel> bills = [];
  List<BillModel> pendingBills = [];

  bool plutoGridIsLoading = true;

  Rx<RequestState> getBillsRequestState = RequestState.initial.obs;
  bool isPendingBillsLoading = true;

  // Initializer
  void _initializeBillUtilities() {
    _billUtils = BillUtils();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeBillUtilities();

    fetchBillTypes();
  }

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  Future<void> fetchAllBillsByType(BillTypeModel billTypeModel) async {
    log('fetchBills');
    final result = await _billsFirebaseRepo.getAll(billTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBills) => bills.assignAll(fetchedBills),
    );

    plutoGridIsLoading = false;
    update();
  }

  Future<void> fetchAllBillsFromLocal() async {
    log('fetchAllBillsFromLocal');
    // getBillsRequestState.value=RequestState.loading;

    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = _jsonImportExportRepo.importJsonFileXml(file);
      // '/Users/alidabol/Library/Containers/com.ba3bs.ba3Bs/Data/Documents/free_start.json'
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedBills) {
          log("fetchedBills length ${fetchedBills.length}");

          getBillsRequestState.value = RequestState.success;
          bills.assignAll(fetchedBills);
        },
      );
    } else {
      // User canceled the picker
    }

    plutoGridIsLoading = false;
    update();
  }

  Future<void> fetchPendingBills(BillTypeModel billTypeModel) async {
    final result = await _billsFirebaseRepo.fetchWhere(
        itemTypeModel: billTypeModel, field: ApiConstants.status, value: Status.pending.value);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedPendingBills) => pendingBills.assignAll(fetchedPendingBills),
    );

    isPendingBillsLoading = false;
    update();
  }

  Future<void> fetchBillTypes() async {
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

    final result = await _jsonImportExportRepo.exportJsonFile(bills);

    result.fold(
      (failure) => AppUIUtils.onFailure('فشل في تصدير الملف [${failure.message}]'),
      (filePath) => AppUIUtils.showExportSuccessDialog(filePath, 'تم تصدير الفواتير بنجاح!', 'تم تصدير الملف إلى:'),
    );
  }

  void navigateToAllBillsScreen() => to(AppRoutes.showAllBillsScreen);

  void navigateToPendingBillsScreen() => to(AppRoutes.showPendingBillsScreen);

  List<BillModel> getBillsByType(String billTypeId) =>
      bills.where((bill) => bill.billTypeModel.billTypeId == billTypeId).toList();

  void openFloatingBillDetailsById(String billId, BuildContext context) async {
    // final BillModel billModel = await fetchBillById(billId);
    final BillModel billModel = await fetchBillByIdFromLocal(billId);

    if (!context.mounted) return;

    openFloatingBillDetails(context, billModel.billTypeModel, billModel: billModel);
  }

  Future<void> openFloatingBillDetails(
    BuildContext context,
    BillTypeModel billTypeModel, {
    BillModel? billModel,
  }) async {
    plutoGridIsLoading = false;
    await fetchAllBillsByType(billTypeModel);

    if (!context.mounted) return;

    final BillModel lastBillModel = billModel ?? _billUtils.appendEmptyBillModel(bills, billTypeModel);

    _openBillDetailsFloatingWindow(
      context: context,
      modifiedBills: bills,
      lastBillModel: lastBillModel,
    );
  }

  // Opens the 'Bill Details' floating window.
  void _openBillDetailsFloatingWindow({
    required BuildContext context,
    required List<BillModel> modifiedBills,
    required BillModel lastBillModel,
  }) {
    final String controllerTag = AppServiceUtils.generateUniqueTag('BillDetailsController');

    final Map<String, GetxController> controllers = setupControllers(
      params: {
        'tag': controllerTag,
        'billsFirebaseRepo': _billsFirebaseRepo,
        'billDetailsPlutoController': BillDetailsPlutoController(billTypeModel: lastBillModel.billTypeModel),
        'billSearchController': BillSearchController(),
      },
    );

    final billDetailsController = controllers['billDetailsController'] as BillDetailsController;
    final billDetailsPlutoController = controllers['billDetailsPlutoController'] as BillDetailsPlutoController;
    final billSearchController = controllers['billSearchController'] as BillSearchController;

    initializeBillSearch(
      currentBill: lastBillModel,
      allBills: modifiedBills,
      billSearchController: billSearchController,
      billDetailsController: billDetailsController,
      billDetailsPlutoController: billDetailsPlutoController,
    );

    launchFloatingWindow(
      context: context,
      minimizedTitle: BillType.byLabel(lastBillModel.billTypeModel.billTypeLabel!).value,
      floatingScreen: BillDetailsScreen(
        fromBillById: false,
        billDetailsController: billDetailsController,
        billDetailsPlutoController: billDetailsPlutoController,
        billSearchController: billSearchController,
        tag: controllerTag,
      ),
    );
  }

  void initializeBillSearch({
    required BillModel currentBill,
    required List<BillModel> allBills,
    required BillSearchController billSearchController,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
  }) {
    billSearchController.initialize(
      currentBill: currentBill,
      allBills: allBills,
      billDetailsController: billDetailsController,
      billDetailsPlutoController: billDetailsPlutoController,
    );
  }

  Future<BillModel> fetchBillById(String billId, BillTypeModel billTypeModel) async {
    late BillModel billModel;

    final result = await _billsFirebaseRepo.getById(id: billId, itemTypeModel: billTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBill) => billModel = fetchedBill,
    );
    return billModel;
  }

  Future<BillModel> fetchBillByIdFromLocal(String billId) async {
    return bills.firstWhere(
      (bill) => bill.billId == billId,
    );
  }
}
