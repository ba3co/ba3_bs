import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/models/query_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import 'package:ba3_bs/features/bill/ui/screens/bill_details_screen.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';
import '../../services/bill/bill_utils.dart';
import '../../services/bill/floating_bill_details_launcher.dart';
import 'bill_search_controller.dart';

class AllBillsController extends FloatingBillDetailsLauncher with AppNavigator {
  // Repositories
  final RemoteDataSourceRepository<BillTypeModel> _patternsFirebaseRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;
  final ImportExportRepository<BillModel> _jsonImportExportRepo;

  AllBillsController(this._patternsFirebaseRepo, this._billsFirebaseRepo, this._jsonImportExportRepo);

  // Services
  late final BillUtils _billUtils;

  List<BillTypeModel> billsTypes = [];

  List<BillModel> bills = [];
  Map<BillTypeModel, List<BillModel>> nestedBills = {};

  List<BillModel> pendingBills = [];

  final pendingBillsCountsByType = <BillTypeModel, int>{};
  final allBillsCountsByType = <BillTypeModel, int>{};

  bool plutoGridIsLoading = true;

  Rx<RequestState> getBillsByTypeRequestState = RequestState.initial.obs;

  bool isPendingBillsLoading = true;

  Rx<RequestState> getBillsTypesRequestState = RequestState.initial.obs;

  Rx<RequestState> getAllNestedBillsRequestState = RequestState.initial.obs;

  // Initializer
  void _initializeServices() {
    _billUtils = BillUtils();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    fetchBillsTypes();

    read<MaterialController>().reloadMaterials();
  }

  int pendingBillsCounts(BillTypeModel billTypeModel) => pendingBillsCountsByType[billTypeModel] ?? 0;

  int allBillsCounts(BillTypeModel billTypeModel) => allBillsCountsByType[billTypeModel] ?? 0;

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

  Future<void> fetchAllNestedBills() async {
    getAllNestedBillsRequestState.value = RequestState.loading;

    final result = await _billsFirebaseRepo.fetchAllNested(billsTypes);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedNestedBills) => nestedBills.assignAll(fetchedNestedBills),
    );

    nestedBills.forEach((k, v) => log('bill Type: ${k.billTypeLabel} has ${v.length} bills'));
    getAllNestedBillsRequestState.value = RequestState.success;
  }

  Future<void> fetchAllBillsFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      final result = _jsonImportExportRepo.importXmlFile(File(resultFile.files.single.path!));

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedBills) => _onFetchBillsFromLocalSuccess(fetchedBills),
      );
    }

    plutoGridIsLoading = false;
    update();
  }

  void _onFetchBillsFromLocalSuccess(List<BillModel> fetchedBills) async {
    log("fetchedBills length ${fetchedBills.length}");

    bills.assignAll(
      fetchedBills.where((element) => element.billId != 'bf23c92d-a69d-419e-a000-1043b94d16c8').toList(),
    );
    if (bills.isNotEmpty) {
      await _billsFirebaseRepo.saveAllNested(bills, billsTypes);
      await read<EntryBondGeneratorRepo>().saveEntryBonds(bills);
    }
    AppUIUtils.onSuccess("تم تحميل الفواتير بنجاح");
  }

  Future<void> fetchPendingBills(BillTypeModel billTypeModel) async {
    final result =
        await _billsFirebaseRepo.fetchWhere(itemTypeModel: billTypeModel, field: ApiConstants.status, value: Status.pending.value);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedPendingBills) => pendingBills.assignAll(fetchedPendingBills),
    );

    isPendingBillsLoading = false;
    update();
  }

  Future<void> fetchBillsTypes() async {
    getBillsTypesRequestState.value = RequestState.loading;

    final result = await _patternsFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBillTypes) => _handleFetchBillTypesSuccess(fetchedBillTypes),
    );
  }

  Future<void> _handleFetchBillTypesSuccess(List<BillTypeModel> fetchedBillTypes) async {
    billsTypes.assignAll(fetchedBillTypes);

    await fetchPendingBillsCountsByTypes(fetchedBillTypes);
    await fetchAllBillsCountsByTypes(fetchedBillTypes);

    getBillsTypesRequestState.value = RequestState.success;
  }

  Future<void> fetchPendingBillsCountsByTypes(List<BillTypeModel> fetchedBillTypes) async {
    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final billTypeModel in fetchedBillTypes) {
      fetchTasks.add(
        _billsFirebaseRepo
            .count(
                itemTypeModel: billTypeModel,
                countQueryFilter: QueryFilter(
                  field: ApiConstants.status,
                  value: Status.pending.value,
                ))
            .then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (count) => pendingBillsCountsByType[billTypeModel] = count,
          );
        }),
      );
    }

    // Wait for all tasks to complete.
    await Future.wait(fetchTasks);

    // Handle errors if any.
    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some counts failed to fetch: ${errors.join(', ')}');
    }
  }

  Future<void> fetchAllBillsCountsByTypes(List<BillTypeModel> fetchedBillTypes) async {
    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final billTypeModel in fetchedBillTypes) {
      fetchTasks.add(
        _billsFirebaseRepo
            .count(
          itemTypeModel: billTypeModel,
        )
            .then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (count) => allBillsCountsByType[billTypeModel] = count,
          );
        }),
      );
    }

    // Wait for all tasks to complete.
    await Future.wait(fetchTasks);

    // Handle errors if any.
    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some counts failed to fetch: ${errors.join(', ')}');
    }
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

  List<BillModel> getBillsByType(String billTypeId) => bills.where((bill) => bill.billTypeModel.billTypeId == billTypeId).toList();

  void openFloatingBillDetailsById(String billId, BuildContext context, BillTypeModel bilTypeModel) async {
    // final BillModel billModel = await fetchBillById(billId);
    final BillModel billModel = await fetchBillById(billId, BillType.sales.billTypeModel);

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
}
