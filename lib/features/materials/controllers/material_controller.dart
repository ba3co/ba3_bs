import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/core/services/local_database/implementations/repos/local_datasource_repo.dart';
import 'package:ba3_bs/features/materials/service/material_from_handler.dart';
import 'package:ba3_bs/features/materials/service/material_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/services/firebase/implementations/services/firestore_uploader.dart';
import '../../../core/services/json_file_operations/implementations/import_export_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/material_model.dart';

class MaterialController extends GetxController with AppNavigator {
  final ImportExportRepository<MaterialModel> _jsonImportExportRepo;
  final LocalDatasourceRepository<MaterialModel> _materialsHiveRepo;

  MaterialController(this._jsonImportExportRepo, this._materialsHiveRepo);

  List<MaterialModel> materials = [];
  MaterialModel? selectedMaterial;

  late  MaterialFromHandler _materialFromHandler;
  late  MaterialService _materialService;


  @override
  onInit(){
    super.onInit();

    _initializer();
  }

  _initializer(){
    _materialFromHandler=MaterialFromHandler();
    _materialService=MaterialService();

  }

  bool isLoading = false;

  Rx<RequestState> saveAllMaterialsRequestState = RequestState.initial.obs;

  Future<void> fetchMaterials() async {
    try {
      final result = await _materialsHiveRepo.getAll();
      materials.assignAll(result);
      update();
    } catch (e) {
      debugPrint("Error fetching materials: $e");
    }
  }

  Future<void> reloadMaterialsIfEmpty() async {
    if (materials.isEmpty) {
      log('Fetching materials started...');
      await fetchMaterials();
      log('Fetching materials ended...');
    }
  }

  Future<void> fetchAllMaterialFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = _jsonImportExportRepo.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedMaterial) => _handelFetchAllMaterialFromLocalSuccess(fetchedMaterial),
      );
    }
  }

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

  _handelFetchAllMaterialFromLocalSuccess(List<MaterialModel> fetchedMaterial) async {
    log('fetchedMaterial length ${fetchedMaterial.length}');
    log('fetchedMaterial first ${fetchedMaterial.first.toJson()}');

    saveAllMaterialsRequestState.value = RequestState.loading;

    materials.assignAll(fetchedMaterial);

    // Show progress in the UI
    FirestoreUploader firestoreUploader = FirestoreUploader();
    await firestoreUploader.sequentially(
      data: materials.map((item) => {...item.toJson(), 'docId': item.id}).toList(),
      collectionPath: ApiConstants.materials,
      onProgress: (progress) {
        uploadProgress.value = progress; // Update progress
        log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      },
    );

    saveAllMaterialsRequestState.value = RequestState.success;
  }

  void navigateToAllMaterialScreen() {
    to(AppRoutes.showAllMaterialsScreen);
  }

  Future<List<MaterialModel>> searchOfProductByText(query) async {
    await reloadMaterialsIfEmpty();

    List<MaterialModel> searchedMaterials = [];

    query = replaceArabicNumbersWithEnglish(query);

    String query2 = '';
    String query3 = '';

    if (query.contains(" ")) {
      query3 = query.split(" ")[0];
      query2 = query.split(" ")[1];
    } else {
      query3 = query;
      query2 = query;
    }

    searchedMaterials = materials.where((item) {
      bool prodName = item.matName.toString().toLowerCase().contains(query3.toLowerCase()) &&
          item.matName.toString().toLowerCase().contains(query2.toLowerCase());
      bool prodCode = item.matCode.toString().toLowerCase().contains(query.toLowerCase());
      bool prodBarcode = item.matBarCode != null ? item.matBarCode!.toLowerCase().contains(query.toLowerCase()) : false;
      return (prodName || prodCode || prodBarcode);
    }).toList();

    return searchedMaterials;
  }

  String? getMaterialNameById(String? id) {
    if (id == null || id.isEmpty) return '';
    return materials.firstWhereOrNull((material) => material.id == id)?.matName ?? "not fond this material";
  }

  String getMaterialBarcodeById(String? id) {
    if (id == null || id.isEmpty) return '0';

    reloadMaterialsIfEmpty();

    final String matBarCode = materials.firstWhere((material) => material.id == id, orElse: () => MaterialModel()).matBarCode ?? '0';

    return matBarCode;
  }

  MaterialModel? getMaterialById(String id) {
    return materials.firstWhereOrNull((material) => material.id == id);
  }

  MaterialModel? getMaterialByName(name) {
    if (name != null && name != " " && name != "") {
      return materials.where((element) => (element.matName!.toLowerCase().contains(name.toLowerCase()))).firstOrNull;
    }
    return null;
  }

  String replaceArabicNumbersWithEnglish(String input) {
    return input.replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }

  void saveOrUpdateMaterial() {


  }
}
