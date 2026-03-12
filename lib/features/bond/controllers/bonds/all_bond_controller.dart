import 'dart:developer';
import 'dart:io';
import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:ba3_bs/core/services/export_excl/excel_export.dart';
import 'package:ba3_bs/features/bond/service/bond/floating_bond_details_launcher.dart';
import 'package:ba3_bs/features/bond/ui/screens/bond_details_screen.dart';
import 'package:ba3_bs/features/bond/use_cases/get_bond_types_models_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/implementations/import_export_repo.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../bill/services/bill/bills_count_service.dart';
import '../../data/models/bond_type_model.dart';
import '../../data/models/bond_type.dart';
import '../../service/bond/get_bond_types_models_service.dart';
import '../../use_cases/get_bond_type_by_guide_usecase.dart';
import '../../service/bond/bond_local_storage_service.dart';
import '../../service/bond/bond_utils.dart';
import '../pluto/bond_details_pluto_controller.dart';
import 'bond_details_controller.dart';
import 'bond_search_controller.dart';

class AllBondsController extends FloatingBondDetailsLauncher
    with
        EntryBondsGenerator,
        FirestoreSequentialNumbers,
        FloatingLauncher,
        AppNavigator {
  final CompoundDatasourceRepository<BondModel, BondTypeModel>
      _bondsFirebaseRepo;
  final ImportExportRepository<BondModel> _jsonImportExportRepo;

  late final BondTypeService _bondTypeService;

  late bool isDebitOrCredit;
  List<BondModel> bonds = [];
  Map<BondTypeModel, List<BondModel>> nestedBonds = {};
  Map<String, List<BondModel>> bondsByTypeGuid = {};
  List<BondModel> allNestedBonds = [];
  bool isLoading = true;

  Rx<RequestState> saveAllBondsRequestState = RequestState.initial.obs;
  Rx<RequestState> allBondsRequestState = RequestState.initial.obs;

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

  AllBondsController(this._bondsFirebaseRepo, this._jsonImportExportRepo);

  // Services
  late final BondUtils _bondUtils;
  late final BondLocalStorageService _bondLocalStorageService;

  // Initializer
  void _initializeServices() async {
    _bondUtils = BondUtils();
    _bondLocalStorageService = BondLocalStorageService();

    _bondTypeService = Get.find<BondTypeService>();
    // await _bondTypeService.initializeBondTypes();

    await fetchAllBondsCountsByTypes(_bondTypeService.getBondTypes());
  }

  Future<void> fetchAllNestedBonds() async {
    // Optionally mark as loading if needed later
    // getAllNestedBondsRequestState.value = RequestState.loading;

    try {
      final getAllBondTypesUseCase = Get.find<GetAllBondTypesUseCase>();
      final result = await getAllBondTypesUseCase();

      await result.fold(
        (failure) {
          AppUIUtils.onFailure(failure.message);
        },
        (bondTypeModels) async {
          final nestedResult =
              await _bondsFirebaseRepo.fetchAllNested(bondTypeModels);

          nestedResult.fold(
            (failure) => AppUIUtils.onFailure(failure.message),
            (fetchedNestedBonds) {
              // Assign all to reactive maps
              nestedBonds.assignAll(fetchedNestedBonds);

              // Create a map keyed by typeGuide for easier lookups
              bondsByTypeGuid.assignAll(
                nestedBonds.map(
                  (bondType, bonds) => MapEntry(bondType.typeGuide, bonds),
                ),
              );

              // Logging & flattening
              nestedBonds.forEach(
                (type, bonds) =>
                    log('Bond Type: ${type.label} has ${bonds.length} bonds'),
              );

              allNestedBonds.assignAll(
                nestedBonds.values.expand((bonds) => bonds).toList(),
              );

              log("All Nested Bonds Count: ${allNestedBonds.length}");
            },
          );
        },
      );
    } catch (e) {
      AppUIUtils.onFailure('Unexpected error: $e');
    }

    // getAllNestedBondsRequestState.value = RequestState.success;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    saveAllBondIfConnected();
  }

/*  Future<void> refreshBondsTypes() async =>
      await fetchAllBondsCountsByTypes(BondType.values); */
  Future<void> refreshBondsTypes() async {
    final nestedBonds = await _bondLocalStorageService.getNestedBonds();
    for (var a in nestedBonds.values) {
      log(a.first.toJson().toString());
    }
  }

  BondModel getBondById(String bondId) =>
      bonds.firstWhere((bond) => bond.payGuid == bondId);

  Future<void> fetchAllBondsByType(
    BondTypeModel itemTypeModel,
  ) async {
    log('fetchAllBondsByType');
    final result = await _bondsFirebaseRepo.getAll(itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (fetchedBonds) => bonds.assignAll(fetchedBonds),
    );

    isLoading = false;
    update();
  }

  Future<void> fetchAllBondsLocal(BuildContext context) async {
    log('fetchAllBondsLocal');

    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _jsonImportExportRepo.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(
          failure.message,
        ),
        (fetchedBonds) async {
          log('bonds.length ${fetchedBonds.length}');
          bonds.assignAll(fetchedBonds);
          if (bonds.isNotEmpty) {
            log('bonds.length ${fetchedBonds.last.toJson()}');

            saveAllBondsRequestState.value = RequestState.loading;

            await _bondsFirebaseRepo.saveAllNested(
                items: bonds, itemIdentifiers: _bondTypeService.getBondTypes());
            if (!context.mounted) return;

            await createAndStoreEntryBonds(
              sourceModels: bonds,
              context: context,
              sourceNumbers: bonds.select((bond) => bond.payNumber).toList(),
              onProgress: (progress) {
                uploadProgress.value = progress; // Update progress
                log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
              },
            );
          }
          saveAllBondsRequestState.value = RequestState.success;
          if (!context.mounted) return;

          AppUIUtils.onSuccess(
            'تم تحميل السندات بنجاح',
          );
        },
      );
    }

    isLoading = false;
    update();
  }

  Future<List<BondModel>> bondsCountByType(BondTypeModel bondType) async {
    int bondsCountByType = await getLastNumber(
      //   category:'${read<MigrationController>().currentVersion}${ApiConstants.bonds}',
      category: ApiConstants.bonds,
      entityType: bondType.label,
    );

    return _bondUtils.appendEmptyBondModelNew(
        bondType.typeGuide, bondsCountByType);
  }

  Future<void> openFloatingBondDetails(
      BuildContext context, BondTypeModel bondType,
      {BondModel? currentBondModel}) async {
    final bonds = await bondsCountByType(bondType);

    if (!context.mounted) return;

    _openBondDetailsFloatingWindow(
      context: context,
      bondType: bondType,
      lastBondNumber: bonds.last.payNumber!,
      currentBond: currentBondModel ?? bonds.last,
    );
  }

  void openBondDetailsById(
      String bondId, BuildContext context, BondTypeModel itemTypeModel) async {
    final BondModel bondModel = await fetchBondsById(
      bondId,
      itemTypeModel,
    );
    if (!context.mounted) return;

    final getBondTypeByGuideUseCase = Get.find<GetBondTypeByGuideUseCase>();
    final result = await getBondTypeByGuideUseCase(bondModel.payTypeGuid!);

    result.fold(
      (failure) {
        // Handle error gracefully
        Get.snackbar('Error', failure.message);
      },
      (bondTypeModel) {
        // Pass the resolved bondTypeModel to openFloatingBondDetails
        openFloatingBondDetails(
          context,
          bondTypeModel,
          currentBondModel: bondModel,
        );
      },
    );

    //openFloatingBondDetails(context, BondType.byTypeGuide(bondModel.payTypeGuid!), currentBondModel: bondModel);
  }

  Future<BondModel> fetchBondsById(
      String bondId, BondTypeModel itemTypeModel) async {
    late BondModel bondModel;

    final result = await _bondsFirebaseRepo.getById(
        id: bondId, itemIdentifier: itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (fetchedBonds) => bondModel = fetchedBonds,
    );
    return bondModel;
  }

  Future<Either<Failure, List<BondModel>>> fetchBondByNumber(
      {required BondTypeModel bondType, required int bondNumber}) async {
    final result = await _bondsFirebaseRepo.fetchWhere(
      itemIdentifier: bondType,
      field: ApiConstants.bondNumber,
      value: bondNumber,
    );
    return result;
  }

  // Opens the 'Bond Details' floating window.
  void _openBondDetailsFloatingWindow({
    required BuildContext context,
    required BondTypeModel bondType,
    required BondModel currentBond,
    required int lastBondNumber,
  }) {
    final String controllerTag =
        AppServiceUtils.generateUniqueTag('BondController');

    final Map<String, GetxController> controllers = setupControllers(
      params: {
        'tag': controllerTag,
        'bondType': bondType,
        'bondsFirebaseRepo': _bondsFirebaseRepo,
        'bondDetailsPlutoController': BondDetailsPlutoController(bondType),
        'bondSearchController': BondSearchController(),
      },
    );

    final bondDetailsController =
        controllers['bondDetailsController'] as BondDetailsController;
    final bondDetailsPlutoController =
        controllers['bondDetailsPlutoController'] as BondDetailsPlutoController;
    final bondSearchController =
        controllers['bondSearchController'] as BondSearchController;

    initializeBondSearch(
      currentBond: currentBond,
      lastBondNumber: lastBondNumber,
      bondSearchController: bondSearchController,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );

    launchFloatingWindow(
      context: context,
      minimizedTitle: bondType.label,
      floatingScreen: BondDetailsScreen(
        fromBondById: false,
        bondDetailsController: bondDetailsController,
        bondDetailsPlutoController: bondDetailsPlutoController,
        bondSearchController: bondSearchController,
        tag: controllerTag,
      ),
    );
  }

  void initializeBondSearch({
    required BondModel currentBond,
    required int lastBondNumber,
    required BondSearchController bondSearchController,
    required BondDetailsController bondDetailsController,
    required BondDetailsPlutoController bondDetailsPlutoController,
  }) {
    bondSearchController.initialize(
      currentBond: currentBond,
      lastBondNumber: lastBondNumber,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );
  }

  final allBondsCountsByType = <BondTypeModel, int>{};

  bool isBondsLoading = true;

  int allBondsCounts(BondTypeModel bondTypeModel) {
    return allBondsCountsByType[bondTypeModel] ?? 0;
  }

  Future<void> fetchAllBondsCountsByTypes(
      List<BondTypeModel> fetchedBondTypes) async {
    allBondsRequestState.value = RequestState.loading;
    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final bondTypeModel in fetchedBondTypes) {
      fetchTasks.add(
        _bondsFirebaseRepo.count(itemIdentifier: bondTypeModel).then((result) {
          result.fold(
            (failure) => errors.add(
                'Failed to fetch count for ${bondTypeModel.label}: ${failure.message}'),
            (count) {
              allBondsCountsByType[bondTypeModel] = count;
            },
          );
        }),
      );
    }

    // Wait for all tasks to complete.
    await Future.wait(fetchTasks);
    allBondsRequestState.value = RequestState.success;
    update();
    // Handle errors if any.
    if (errors.isNotEmpty) {
      AppUIUtils.onFailure(
        'Some counts failed to fetch: ${errors.join(', ')}',
      );
    }
  }

  void navigateToAllBondScreen() => to(AppRoutes.allBondsScreen);

  Future<void> fetchAllBondByType(
      BondTypeModel bondType, BuildContext context) async {
    isBondsLoading = true;
    update();

    navigateToAllBondScreen();
    final result = await _bondsFirebaseRepo.getAll(bondType);

    result.fold(
      (failure) => AppUIUtils.onFailure(
        'لا يوجد سندات  في ${bondType.value}',
      ),
      (fetchedPendingBonds) {
        bonds.assignAll(fetchedPendingBonds);
      },
    );

    isBondsLoading = false;
    update();
  }

  Future<void> saveAllBondIfConnected() async {
    final hasData = await _bondLocalStorageService.hasData();
    log('hasData $hasData');
    if (hasData) return;

    // Check if the device is connected to the internet
    final hasConnection = await hasInternetConnection();

    // If connected, proceed to save the bond to Firebase
    if (hasConnection) {
      try {
        await fetchAllNestedBonds();
        // Save bond locally
        await _bondLocalStorageService.saveNestedBonds(nestedBonds);

        AppUIUtils.onSuccess('Bonds saved locally.');
      } catch (e) {
        AppUIUtils.onFailure('An error occurred while saving bond locally: $e');
      }
    }
  }

  Future<List<BondModel>> fetchBondsByDate(
      BondTypeModel bondType, DateFilter dateFilter) async {
    List<BondModel> allBonds = [];
    //
    // allBills.addAll(
    //   localBills[billTypeModel.billTypeId.toString()]!.where(
    //         (element) {
    //       final date = element.billDetails.billDate!;
    //       return date.isAfter(dateFilter.range.start) && date.isBefore(dateFilter.range.end);
    //     },
    //   ),
    // );
    final result = await _bondsFirebaseRepo.fetchWhere(
        itemIdentifier: bondType,
        field: ApiConstants.bondDate,
        value: '2025-05-28');
    final result2 = await _bondsFirebaseRepo.fetchWhere(
        itemIdentifier: bondType,
        field: ApiConstants.bondDate,
        value: '2025-05-29');
    final result3 = await _bondsFirebaseRepo.fetchWhere(
        itemIdentifier: bondType,
        field: ApiConstants.bondDate,
        value: '2025-05-30');
    final result4 = await _bondsFirebaseRepo.fetchWhere(
        itemIdentifier: bondType,
        field: ApiConstants.bondDate,
        value: '2025-05-31');

    result.fold(
      // (failure) => AppUIUtils.onFailure(
      //   'لا يوجد فواتير في ${bondType.label} خلال الفترة: ${dateFilter.range.start} - ${dateFilter.range.end}',
      // ),
      (failure) => (),
      (fetchedBonds) => allBonds.addAll(fetchedBonds),
    );
    result4.fold(
      (failure) => (),
      (fetchedBonds) => allBonds.addAll(fetchedBonds),
    );
    result3.fold(
      (failure) => (),
      (fetchedBonds) => allBonds.addAll(fetchedBonds),
    );
    result2.fold(
      (failure) => (),
      (fetchedBonds) => allBonds.addAll(fetchedBonds),
    );

    return allBonds;
  }

  refreshController() {
    _initializeServices();
    saveAllBondIfConnected();
  }

  List<Map<String, dynamic>> buildBondRowsBetweenDates(
    List<BondModel> bonds, {
    required DateTime startDate,
    required DateTime endDate,
    required BondTypeModel bondType,
  }) {
    final List<Map<String, dynamic>> rows = [];

    for (final bond in bonds) {
      if (bond.payDate == null) continue;

      final bondDate = DateTime.parse(bond.payDate!);

      /// فلترة التاريخ
      if (bondDate.isBefore(startDate) || bondDate.isAfter(endDate)) {
        continue;
      }
      String firstAccount = '';
      if (bondType.type == BondType.receiptVoucher ||
          bondType.type == BondType.paymentVoucher) {
        firstAccount =
            AppServiceUtils.getAccountModelFromLabel(bond.payAccountGuid)!
                .accName!;
      }
      final length = ((bondType.type == BondType.receiptVoucher ||
              bondType.type == BondType.paymentVoucher)
          ? (bond.payItems.itemList.length / 2)
          : (bond.payItems.itemList.length));
      for (int i = 0; i < length; i++) {
        final item = bond.payItems.itemList[i];

        rows.add({
          "رقم السند": i == 0 ? bond.payNumber : "",
          "تاريخ السند": i == 0 ? bond.payDate : "",
          if (bondType.type == BondType.receiptVoucher ||
              bondType.type == BondType.paymentVoucher)
            "الحساب الأول": firstAccount,
          if (bondType.type == BondType.receiptVoucher ||
              bondType.type == BondType.paymentVoucher)
            "الحساب الثاني": item.entryAccountName ?? '',
          if (bondType.type == BondType.openingEntry ||
              bondType.type == BondType.journalVoucher)
            "الحساب": item.entryAccountName ?? '',
          if (bondType.type != BondType.receiptVoucher)
            "مدين": item.entryDebit ?? 0,
          if (bondType.type != BondType.paymentVoucher)
            "دائن": item.entryCredit ?? 0,
          "البيان": item.entryNote ?? '',
        });
      }

      rows.add({
        "رقم السند": "",
        "تاريخ السند": "",
        "الحساب الأول": "",
        "الحساب الثاني": '',
        if (bondType.type != BondType.receiptVoucher) "مدين": '',
        if (bondType.type != BondType.paymentVoucher) "دائن": '',
        "البيان": '',
      });
    }

    return rows;
  }

  Future<void> exportBondsBetweenDates({
    required BondTypeModel bondType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final res = await _bondsFirebaseRepo.getAll(bondType);

    res.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
      },
      (fetchedBonds) async {
        if (fetchedBonds.isEmpty) {
          AppUIUtils.onFailure("لا يوجد سندات");
          return;
        }

        await exportBondRangeToExcel(
          fetchedBonds,
          startDate: startDate,
          endDate: endDate,
          bondType: bondType,
        );
      },
    );
  }

  Future<void> exportBondRangeToExcel(
    List<BondModel> bonds, {
    required DateTime startDate,
    required DateTime endDate,
    required BondTypeModel bondType,
  }) async {
    final rows = buildBondRowsBetweenDates(
      bonds,
      startDate: startDate,
      endDate: endDate,
      bondType: bondType,
    );

    if (rows.isEmpty) {
      AppUIUtils.onFailure("لا يوجد سندات ضمن هذه الفترة");
      return;
    }

    await exportJsonToExcel(rows);
  }
}
