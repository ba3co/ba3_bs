import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/models/query_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'package:ba3_bs/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import 'package:ba3_bs/features/bill/ui/screens/bill_details_screen.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/service/mat_statement_generator.dart';
import 'package:ba3_bs/features/materials/ui/screens/serials_statement_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/app_navigator.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import '../../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';
import '../../services/bill/bill_utils.dart';
import '../../services/bill/floating_bill_details_launcher.dart';
import 'bill_search_controller.dart';

//
class AllBillsController extends FloatingBillDetailsLauncher
    with AppNavigator, EntryBondsGenerator, MatsStatementsGenerator, FirestoreSequentialNumbers {
  // Repositories
  final RemoteDataSourceRepository<BillTypeModel> _patternsFirebaseRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;
  final QueryableSavableRepository<SerialNumberModel> _serialNumbersRepo;
  final ImportExportRepository<BillModel> _jsonImportExportRepo;

  AllBillsController(this._patternsFirebaseRepo, this._billsFirebaseRepo, this._serialNumbersRepo, this._jsonImportExportRepo);

  // Services
  late final BillUtils _billUtils;

  List<BillTypeModel> billsTypes = [];

  List<BillModel> bills = [];
  Map<BillTypeModel, List<BillModel>> nestedBills = {};
  List<BillModel> allNestedBills = [];

  List<BillModel> pendingBills = [];

  final pendingBillsCountsByType = <BillTypeModel, int>{};
  final allBillsCountsByType = <BillTypeModel, int>{};

  bool plutoGridIsLoading = true;

  bool isPendingBillsLoading = true;

  Rx<RequestState> getBillsTypesRequestState = RequestState.initial.obs;

  Rx<RequestState> getAllNestedBillsRequestState = RequestState.initial.obs;

  Rx<RequestState> saveAllBillsRequestState = RequestState.initial.obs;
  Rx<RequestState> saveAllBillsBondRequestState = RequestState.initial.obs;

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

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

  Future<void> refreshBillsTypes() async {
    fetchBillsTypes();
  }

  int pendingBillsCounts(BillTypeModel billTypeModel) => pendingBillsCountsByType[billTypeModel] ?? 0;

  int allBillsCounts(BillTypeModel billTypeModel) => allBillsCountsByType[billTypeModel] ?? 0;

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  Future<void> fetchAllNestedBills() async {
    getAllNestedBillsRequestState.value = RequestState.loading;

    final result = await _billsFirebaseRepo.fetchAllNested(billsTypes);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedNestedBills) => nestedBills.assignAll(fetchedNestedBills),
    );

    nestedBills.forEach((k, v) => log('bill Type: ${k.billTypeLabel} has ${v.length} bills'));

    allNestedBills.assignAll(nestedBills.values.expand((bills) => bills).toList());

    log("allNestedBills is ${allNestedBills.length}");
    await createAndStoreMatsStatements(
      sourceModels: allNestedBills,
      onProgress: (progress) {
        uploadProgress.value = progress; // Update progress
        log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      },
    );
    getAllNestedBillsRequestState.value = RequestState.success;
  }

  Future<void> fetchAllBillsFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      //     saveAllBillsRequestState.value = RequestState.loading;
      final result = await _jsonImportExportRepo.importXmlFile(File(resultFile.files.single.path!));

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedBills) => _onFetchBillsFromLocalSuccess(fetchedBills),
      );
    }
  }

  void _onFetchBillsFromLocalSuccess(List<BillModel> fetchedBills) async {
    log("fetchedBills length ${fetchedBills.length}");

    bills.assignAll(fetchedBills);

    saveAllBillsRequestState.value = RequestState.loading;

    if (fetchedBills.isNotEmpty) {
      log("saveAllNested _billsFirebaseRepo Started......");
      await _billsFirebaseRepo.saveAllNested(
        items: fetchedBills,
        itemIdentifiers: billsTypes,
        onProgress: (progress) {
          uploadProgress.value = progress; // Update progress
          log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
      log("saveAllNested _billsFirebaseRepo Finished......");

      // await createAndStoreMatsStatements(
      //   sourceModels: fetchedBills,
      //   onProgress: (progress) {
      //     uploadProgress.value = progress; // Update progress
      //     log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      //   },
      // );
      //
      // await createAndStoreEntryBonds(
      //   sourceModels: fetchedBills,
      //   onProgress: (progress) {
      //     uploadProgress.value = progress; // Update progress
      //     log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      //   },
      // );
    }
    saveAllBillsRequestState.value = RequestState.success;

    AppUIUtils.onSuccess("تم تحميل الفواتير بنجاح");
  }

  Future<void> fetchPendingBills(BillTypeModel billTypeModel) async {
    final result = await _billsFirebaseRepo.fetchWhere(itemIdentifier: billTypeModel, field: ApiConstants.status, value: Status.pending.value);

    result.fold(
      (failure) => AppUIUtils.onFailure('لا يوجد فواتير معلقة في ${billTypeModel.fullName}'),
      (fetchedPendingBills) {
        pendingBills.assignAll(fetchedPendingBills);
        navigateToPendingBillsScreen();
      },
    );

    isPendingBillsLoading = false;
    update();
  }

  Future<Either<Failure, List<BillModel>>> fetchBillByNumber({required BillTypeModel billTypeModel, required int billNumber}) async {
    final result = await _billsFirebaseRepo.fetchWhere(itemIdentifier: billTypeModel, field: ApiConstants.billNumber, value: billNumber);

    return result;
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
          itemIdentifier: billTypeModel,
          countQueryFilter: QueryFilter(field: ApiConstants.status, value: Status.pending.value),
        )
            .then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (int count) => pendingBillsCountsByType[billTypeModel] = count,
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
        _billsFirebaseRepo.count(itemIdentifier: billTypeModel).then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (int count) => allBillsCountsByType[billTypeModel] = count,
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
    final BillModel? billModel = await fetchBillById(billId, bilTypeModel);

    if (billModel == null) return;

    if (!context.mounted) return;

    openFloatingBillDetails(context, billModel.billTypeModel, currentBill: billModel);
  }

  Future<List<BillModel>> billsCountByType(BillTypeModel billTypeModel) async {
    int billsCountByType = await getLastNumber(
      category: ApiConstants.bills,
      entityType: billTypeModel.billTypeLabel!,
    );

    return _billUtils.appendEmptyBillModelNew(billTypeModel, billsCountByType);
  }

  Future<void> openFloatingBillDetails(BuildContext context, BillTypeModel billTypeModel, {BillModel? currentBill}) async {
    final bills = await billsCountByType(billTypeModel);

    if (!context.mounted) return;

    _openBillDetailsFloatingWindow(
      context: context,
      lastBillNumber: bills.last.billDetails.billNumber!,
      currentBill: currentBill ?? bills.last,
    );
  }

  // Opens the 'Bill Details' floating window.

  Future<void> _openBillDetailsFloatingWindow({required BuildContext context, required int lastBillNumber, required BillModel currentBill}) async {
    final String controllerTag = AppServiceUtils.generateUniqueTag('BillDetailsController');

    final Map<String, GetxController> controllers = setupControllers(
      params: {
        'tag': controllerTag,
        'billsFirebaseRepo': _billsFirebaseRepo,
        'serialNumbersRepo': _serialNumbersRepo,
        'billDetailsPlutoController': BillDetailsPlutoController(billTypeModel: currentBill.billTypeModel),
        'billSearchController': BillSearchController(),
      },
    );

    final billDetailsController = controllers['billDetailsController'] as BillDetailsController;
    final billDetailsPlutoController = controllers['billDetailsPlutoController'] as BillDetailsPlutoController;
    final billSearchController = controllers['billSearchController'] as BillSearchController;

    await billSearchController.initialize(
      initialBill: currentBill,
      lastBillNumber: lastBillNumber,
      billDetailsController: billDetailsController,
      billDetailsPlutoController: billDetailsPlutoController,
    );

    if (!context.mounted) return;

    launchFloatingWindow(
      context: context,
      minimizedTitle: BillType.byLabel(currentBill.billTypeModel.billTypeLabel!).value,
      floatingScreen: BillDetailsScreen(
        billDetailsController: billDetailsController,
        billDetailsPlutoController: billDetailsPlutoController,
        billSearchController: billSearchController,
        tag: controllerTag,
      ),
    );
  }

  Future<BillModel?> fetchBillById(String billId, BillTypeModel billTypeModel) async {
    final result = await _billsFirebaseRepo.getById(id: billId, itemIdentifier: billTypeModel);

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
        return null;
      },
      (fetchedBill) => fetchedBill,
    );
  }

  Future<void> fetchAllBillsMetaDataByTypes(List<BillTypeModel> fetchedBillTypes) async {
    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final billTypeModel in fetchedBillTypes) {
      fetchTasks.add(
        _billsFirebaseRepo.getMetaData(id: billTypeModel.billTypeId!, itemIdentifier: billTypeModel).then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (double? count) => allBillsCountsByType[billTypeModel] = (count ?? 0).toInt(),
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

  Future<void> fetchXXXXXX() async {
    _billsFirebaseRepo.getMetaData(id: BillType.transferOut.typeGuide, itemIdentifier: BillType.transferOut.billTypeModel).then((result) {
      result.fold(
        (failure) => AppUIUtils.onFailure('Failed to fetch count for ${BillType.transferOut.label}: ${failure.message}'),
        (double? count) {
          log(count.toString());
        },
      );
    });
  }

  Future<void> getSerialNumberStatement(String serialNumberInput, {required BuildContext context}) async {
    final result = await _serialNumbersRepo.getById(serialNumberInput);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSerialNumberModel) {
        serialNumberStatements.assign(fetchedSerialNumberModel);

        launchFloatingWindow(
          context: context,
          floatingScreen: SerialsStatementScreenScreen(),
          minimizedTitle: serialNumbersStatementScreenTitle,
        );
      },
    );
  }

  bool isLoadingPlutoGrid = false;
  final List<SerialNumberModel> serialNumberStatements = [];

  String get serialNumbersStatementScreenTitle => AppStrings.serialNumbersStatement.tr;
}
