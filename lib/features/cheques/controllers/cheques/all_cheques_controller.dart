import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import 'package:ba3_bs/features/cheques/ui/screens/all_cheques_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/app_navigator.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/implementations/import_export_repo.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../bill/services/bill/bills_count_service.dart';
import '../../data/models/cheques_model.dart';
import '../../service/cheques_local_storage_service.dart';
import '../../service/cheques_utils.dart';
import '../../service/floating_cheques_details_launcher.dart';
import '../../ui/screens/cheques_details.dart';
import 'cheques_details_controller.dart';
import 'cheques_search_controller.dart';

class AllChequesController extends FloatingChequesDetailsLauncher
    with EntryBondsGenerator, AppNavigator, FirestoreSequentialNumbers {
  final CompoundDatasourceRepository<ChequesModel, ChequesType>
      _chequesFirebaseRepo;
  final ImportExportRepository<ChequesModel> _jsonImportExportRepo;

  late bool isDebitOrCredit;
  List<ChequesModel> chequesList = [];
  Map<ChequesType, List<ChequesModel>> nestedCheques = {};

  bool isLoading = true;

  Rx<RequestState> allChequesRequestState = RequestState.initial.obs;

  final allChequesCountsByType = <ChequesType, int>{};

  AllChequesController(this._chequesFirebaseRepo, this._jsonImportExportRepo);

  // Services
  late final ChequesUtils _chequesUtils;
  late final ChequesLocalStorageService _chequesLocalStorageService;

  // Initializer
  void _initializeServices() async {
    _chequesUtils = ChequesUtils();
    _chequesLocalStorageService = ChequesLocalStorageService();
    await fetchAllChequesCountsByTypes(ChequesType.values);
  }

  int allChequesCounts(ChequesType chequesTypeModel) {
    return allChequesCountsByType[chequesTypeModel] ?? 0;
  }

  Future<void> fetchAllChequesCountsByTypes(
      List<ChequesType> fetchedChequesTypes) async {
    allChequesRequestState.value = RequestState.loading;
    final List<Future<void>> fetchTasks = [];
    final errors = <String>[];

    for (final chequesTypeModel in fetchedChequesTypes) {
      fetchTasks.add(
        _chequesFirebaseRepo.count(itemIdentifier: chequesTypeModel).then(
          (result) {
            result.fold(
              (failure) => errors.add(
                'Failed to fetch count for ${chequesTypeModel.label}: ${failure.message}',
              ),
              (count) {
                allChequesCountsByType[chequesTypeModel] = count;
              },
            );
          },
        ),
      );
    }

    await Future.wait(fetchTasks);
    allChequesRequestState.value = RequestState.success;
    update();
    if (errors.isNotEmpty) {
      AppUIUtils.onFailure(
        'Some counts failed to fetch: ${errors.join(', ')}',
      );
    }
  }

  Future<void> refreshChequesTypes() async {
    await fetchAllChequesCountsByTypes(ChequesType.values);
  }

  Future<void> fetchAllChequesByTypeForListView(
    ChequesType chequesType,
    BuildContext context, {
    required bool onlyDues,
  }) async {
    isLoading = true;
    update();

    final result = await _chequesFirebaseRepo.getAll(chequesType);

    result.fold(
      (failure) => AppUIUtils.onFailure(
        'لا يوجد شيكات في ${chequesType.value}',
      ),
      (fetchedCheques) => chequesList = fetchedCheques,
    );

    isLoading = false;
    update();

    if (!context.mounted) return;
    launchFloatingWindow(
      context: context,
      floatingScreen: AllCheques(onlyDues: onlyDues),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    saveAllChequesIfConnected();
  }

  Future<void> saveAllChequesIfConnected() async {
    final hasData = await _chequesLocalStorageService.hasData();
    log('hasData $hasData');
    if (hasData) return;

    // Check if the device is connected to the internet
    final hasConnection = await hasInternetConnection();

    // If connected, proceed to save the cheques to Firebase
    if (hasConnection) {
      try {
        await fetchAllNestedCheques();
        // Save cheques locally
        await _chequesLocalStorageService.saveNestedCheques(nestedCheques);

        AppUIUtils.onSuccess('Cheques saved locally.');
      } catch (e) {
        AppUIUtils.onFailure('An error occurred while saving cheques locally: $e');
      }
    }
  }
  Future<void> fetchAllNestedCheques() async {
    // getAllNestedBondsRequestState.value = RequestState.loading;

    final result = await _chequesFirebaseRepo.fetchAllNested(ChequesType.values);

    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message, ),
          (fetchedNestedBonds) => nestedCheques.assignAll(fetchedNestedBonds),
    );





    log("allNestedBonds is ${nestedCheques.length}");

    // getAllNestedBondsRequestState.value = RequestState.success;
  }

  ChequesModel getChequesById(String chequesId) =>
      chequesList.firstWhere((cheques) => cheques.chequesGuid == chequesId);

  Future<void> fetchAllChequesLocal(BuildContext context) async {
    log('fetchAllChequesLocal');

    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _jsonImportExportRepo.importXmlFile(file);

      result.fold(
            (failure) => AppUIUtils.onFailure(
          failure.message,
        ),
            (fetchedChequesFromNetwork) async {
          final fetchedCheques = fetchedChequesFromNetwork;

          log('chequesList.length ${fetchedCheques.length}');
          // log('chequesList.firstOrNull ${chequesList.firstOrNull?.toJson()}');

          chequesList.assignAll(fetchedCheques);
          if (chequesList.isNotEmpty) {
            await _chequesFirebaseRepo.saveAllNested(
                items: chequesList, itemIdentifiers: ChequesType.values);
            if (!context.mounted) return;
            final now = DateTime.now();
            final startOfYear = DateTime(now.year, 4, 24);
            await createAndStoreEntryBonds(
              sourceModels:chequesList.where((cheque) {
                final rawDate = AppServiceUtils.parseFlexibleDate(cheque.chequesDate!);

                // إزالة الوقت
                final date = DateTime(rawDate.year, rawDate.month, rawDate.day);

                return !date.isBefore(startOfYear);
              })
                  .toList(),
              context: context,
              sourceNumbers:
              chequesList.where((cheque) {
                final rawDate = AppServiceUtils.parseFlexibleDate(cheque.chequesDate!);

                // إزالة الوقت
                final date = DateTime(rawDate.year, rawDate.month, rawDate.day);

                return !date.isBefore(startOfYear);
              })
                  .toList().select((cheque) => cheque.chequesNumber).toList(),
            );
          }
        },
      );
    }

    isLoading = false;
    update();
  }

  Future<void> fetchAllChequesByType(ChequesType itemTypeModel,) async {
    log('fetchCheques');
    final result = await _chequesFirebaseRepo.getAll(itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message, ),
      (fetchedCheques) => chequesList = fetchedCheques,
    );

    isLoading = false;
    update();
  }

  Future<List<ChequesModel>> fetchChequesByType(
      ChequesType itemTypeModel, ) async {
    log('fetchCheques');

    List<ChequesModel> fetchedChequesList = [];
    final result = await _chequesFirebaseRepo.getAll(itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message, ),
      (fetchedCheques) => fetchedChequesList = fetchedCheques,
    );

    isLoading = false;
    update();
    return fetchedChequesList;
  }

  Future<void> openFloatingChequesDetails(
      BuildContext context, ChequesType chequesTypeModel,
      {ChequesModel? chequesModel, required bool withFetched}) async {
    if (withFetched) await fetchAllChequesByType(chequesTypeModel,);

    if (!context.mounted) return;

    final ChequesModel lastChequesModel = chequesModel ??
        _chequesUtils.appendEmptyChequesModel(chequesList, chequesTypeModel);

    _openChequesDetailsFloatingWindow(
      context: context,
      modifiedCheques: chequesList,
      lastChequesModel: lastChequesModel,
      chequesType: chequesTypeModel,
    );
  }

  // Opens the 'Cheques Details' floating window.
  void _openChequesDetailsFloatingWindow({
    required BuildContext context,
    required List<ChequesModel> modifiedCheques,
    required ChequesModel lastChequesModel,
    required ChequesType chequesType,
  }) {
    final String controllerTag =
        AppServiceUtils.generateUniqueTag('ChequesController');

    final Map<String, GetxController> controllers = setupControllers(
      params: {
        'tag': controllerTag,
        'chequesType': chequesType,
        'chequesFirebaseRepo': _chequesFirebaseRepo,
        'chequesSearchController': ChequesSearchController(),
      },
    );

    final chequesDetailsController =
        controllers['chequesDetailsController'] as ChequesDetailsController;
    final chequesSearchController =
        controllers['chequesSearchController'] as ChequesSearchController;

    initializeChequesSearch(
      currentCheques: lastChequesModel,
      allCheques: modifiedCheques,
      chequesDetailsController: chequesDetailsController,
      chequesSearchController: chequesSearchController,
    );

    launchFloatingWindow(
      context: context,
      defaultHeight: 300,
      defaultWidth: 800,
      enableResizing: false,
      minimizedTitle:
          ChequesType.byTypeGuide(lastChequesModel.chequesTypeGuid!).value,
      floatingScreen: ChequesDetailsScreen(
        tag: controllerTag,
        chequesTypeModel: chequesType,
        // fromChequesById: false,
        chequesDetailsController: chequesDetailsController,
        chequesSearchController: chequesSearchController,
      ),
    );
  }

  void initializeChequesSearch({
    required ChequesModel currentCheques,
    required List<ChequesModel> allCheques,
    required ChequesSearchController chequesSearchController,
    required ChequesDetailsController chequesDetailsController,
  }) {
    chequesSearchController.initialize(
      cheques: currentCheques,
      chequesByCategory: allCheques,
      chequesDetailsController: chequesDetailsController,
    );
  }

  void navigateToChequesScreen(
          {required bool onlyDues, required BuildContext context}) =>
      launchFloatingWindow(
          context: context, floatingScreen: AllCheques(onlyDues: onlyDues));

  void navigateToChequesScreenByList(
      {required List<ChequesModel> chequesListItems,
      required BuildContext context}) {
    chequesList.assignAll(chequesListItems);
    launchFloatingWindow(
        context: context, floatingScreen: AllCheques(onlyDues: true));
  }

  void openChequesDetailsById(
      String chequesId, BuildContext context, ChequesType itemTypeModel) async {
    final ChequesModel chequesModel =
        await fetchChequesById(chequesId, itemTypeModel,);
    if (!context.mounted) return;

    openFloatingChequesDetails(
        context, ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!),
        chequesModel: chequesModel, withFetched: false);
  }

  Future<ChequesModel> fetchChequesById(
      String chequesId, ChequesType itemTypeModel, ) async {
    late ChequesModel chequesModel;

    final result = await _chequesFirebaseRepo.getById(
        id: chequesId, itemIdentifier: itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message, ),
      (fetchedCheques) => chequesModel = fetchedCheques,
    );
    return chequesModel;
  }

  /// يقارن تسلسل Firestore مع أقصى [ChequesModel.chequesNumber] لكل نمط،
  /// ثم يضبط `lastNumber` ليطابق البيانات الفعلية (ما لم تكن هناك أرقام مكررة).
  Future<void> verifyChequesSequentialNumbers(BuildContext context) async {
    Get.dialog(
      Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(AppStrings.verifyChequesSequentialRunning.tr),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    final errorLines = <String>[];
    final fixLines = <String>[];

    try {
      for (final type in ChequesType.values) {
        final result = await _chequesFirebaseRepo.getAll(type);
        await result.fold(
          (failure) async {
            errorLines.add(
              '${type.value}: فشل قراءة الشيكات (${failure.message})',
            );
          },
          (list) async {
            final numbers =
                list.map((e) => e.chequesNumber).whereType<int>().toList();
            final maxInData = numbers.isEmpty
                ? 0
                : numbers.reduce((a, b) => a > b ? a : b);
            final sequentialLast = await getLastNumber(
              category: ApiConstants.cheques,
              entityType: type.typeGuide,
            );
            final dupes = _duplicateChequeNumbers(numbers);
            if (dupes.isNotEmpty) {
              errorLines.add(
                '${type.value}: أرقام شيكات مكررة: ${dupes.join('، ')} — لم يُضبط التسلسل لهذا النمط',
              );
              return;
            }
            if (maxInData == sequentialLast) return;

            try {
              await setLastUsedNumber(
                ApiConstants.cheques,
                type.typeGuide,
                maxInData,
              );
              fixLines.add(
                '${type.value}: ضُبط التسلسل من $sequentialLast إلى $maxInData',
              );
            } catch (e, st) {
              log('setLastUsedNumber cheques ${type.label}: $e',
                  stackTrace: st);
              errorLines.add(
                '${type.value}: فشل حفظ التسلسل على السيرفر ($e)',
              );
            }
          },
        );
      }
    } finally {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }

    if (!context.mounted) return;

    if (errorLines.isNotEmpty) {
      final parts = <String>[
        if (fixLines.isNotEmpty) ...[
          'تم ضبط التسلسل حسب البيانات:',
          ...fixLines,
          '',
        ],
        ...errorLines,
      ];
      AppUIUtils.onFailure(parts.join('\n').trim());
    } else if (fixLines.isNotEmpty) {
      AppUIUtils.onSuccess(
        '${AppStrings.chequesSequentialNumbersVerified.tr}\n${fixLines.join('\n')}',
      );
    } else {
      AppUIUtils.onSuccess(AppStrings.chequesSequentialNumbersVerified.tr);
    }
  }

/*  generateEntryChequessFromAllChequess({required List<ChequesModel> cheques}) {
    final entryChequess = generateEntryChequess(cheques);

    for (final entryCheques in entryChequess) {
      entryChequesController.saveEntryChequesModel(entryChequesModel: entryCheques);
    }
  }*/
}

List<int> _duplicateChequeNumbers(List<int> numbers) {
  final counts = <int, int>{};
  for (final n in numbers) {
    counts[n] = (counts[n] ?? 0) + 1;
  }
  final dupes =
      counts.entries.where((e) => e.value > 1).map((e) => e.key).toList()
        ..sort();
  return dupes;
}