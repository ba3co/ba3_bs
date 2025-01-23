import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:ba3_bs/core/services/json_file_operations/interfaces/import/i_import_repository.dart';
import 'package:ba3_bs/features/materials/data/models/material_group.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/services/firebase/implementations/services/firestore_uploader.dart';
import '../../../core/utils/app_ui_utils.dart';

class MaterialGroupController extends GetxController {
  final IImportRepository<MaterialGroupModel> _importRepository;

  final RemoteDataSourceRepository<MaterialGroupModel> _dataSourceRepository;

  MaterialGroupController(this._importRepository, this._dataSourceRepository);

  List<MaterialGroupModel> materialGroups = [];

  getAllGroups() async {
    final result = await _dataSourceRepository.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedMaterialGroupGroup) => materialGroups.assignAll(fetchedMaterialGroupGroup),
    );
  }

  @override
  void onInit() {
    super.onInit();

    getAllGroups();

    log('MaterialGroupController onInit');
  }

  Future<void> fetchAllMaterialGroupGroupFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = _importRepository.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedMaterialGroupGroup) => _handelFetchAllMaterialGroupGroupFromLocalSuccess(fetchedMaterialGroupGroup),
      );
    }
  }

  _handelFetchAllMaterialGroupGroupFromLocalSuccess(Future<List<MaterialGroupModel>> fetchedMaterialGroupGroupFromNetwork) async {
    final fetchedMaterialGroup = await fetchedMaterialGroupGroupFromNetwork;
    log('fetchedMaterialGroup length ${fetchedMaterialGroup.length}');

    materialGroups.addAll(fetchedMaterialGroup);

    // Show progress in the UI
    FirestoreUploader firestoreUploader = FirestoreUploader();
    await firestoreUploader.sequentially(
      data: materialGroups.map((item) => {...item.toJson(), 'docId': item.matGroupGuid}).toList(),
      collectionPath: ApiConstants.materialGroup,
      onProgress: (progress) {
        log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      },
    );
  }

  MaterialGroupModel? getMaterialGroupById(String? id) {
    if (id == null || id == '') return null;
    return materialGroups.firstWhereOrNull(
      (matGroup) => matGroup.matGroupGuid == id,
    );
  }
}
