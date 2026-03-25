import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:ba3_bs/core/services/json_file_operations/interfaces/import/i_import_repository.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_group.dart';
import 'package:ba3_bs/features/materials/ui/screens/all_materials_group_screen.dart';
import 'package:ba3_bs/features/materials/ui/widgets/material_group_editor_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/services/firebase/implementations/services/firestore_uploader.dart';
import '../../../core/utils/app_service_utils.dart';
import '../../../core/utils/app_ui_utils.dart';

class MaterialGroupController extends GetxController
    with AppNavigator, FloatingLauncher {
  final IImportRepository<MaterialGroupModel> _importRepository;

  final RemoteDataSourceRepository<MaterialGroupModel> _dataSourceRepository;

  MaterialGroupController(this._importRepository, this._dataSourceRepository);

  List<MaterialGroupModel> materialGroups = [];

  bool isLoading = false;

  Future<void> getAllGroups() async {
    final result = await _dataSourceRepository.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message, ),
      (fetchedMaterialGroupGroup) {
        materialGroups.assignAll(fetchedMaterialGroupGroup);
        update();
      },
    );
  }

  Future<bool> saveMaterialGroup(MaterialGroupModel model) async {
    final result = await _dataSourceRepository.save(model);
    return result.fold<Future<bool>>(
      (failure) async {
        AppUIUtils.onFailure(failure.message);
        return false;
      },
      (_) async {
        await getAllGroups();
        AppUIUtils.onSuccess(AppStrings.materialGroupSaved.tr);
        return true;
      },
    );
  }

  void openMaterialGroupEditor(BuildContext context, {MaterialGroupModel? existing}) {
    final size = MediaQuery.sizeOf(context);
    OverlayService.showDialog(
      context: context,
      title: (existing == null ? AppStrings.addMaterialGroup : AppStrings.editMaterialGroup).tr,
      dialogAlignment: Alignment.center,
      width: (size.width * 0.9).clamp(360.0, 480.0),
      height: (size.height * 0.72).clamp(420.0, 640.0),
      content: MaterialGroupEditorContent(existing: existing),
    );
  }

  // Map<String, List<MaterialModel>> get groupMapping => {
  //       for (var group in materialGroups)
  //         group.matGroupGuid: read<MaterialController>().materials.where((product) => product.matGroupGuid == group.matGroupGuid).toList(),
  //     };

  @override
  void onInit() {
    super.onInit();

    getAllGroups();

    log('MaterialGroupController onInit');
  }

  void navigateToAllMaterialGroupScreen({required BuildContext context}) {
    launchFloatingWindow(
        context: context,
        minimizedTitle: ApiConstants.materials.tr,
        floatingScreen: AllMaterialsGroupScreen());

    // to(AppRoutes.showAllMaterialsGroupScreen);
  }

  Future<void> fetchAllMaterialGroupFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _importRepository.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message, ),
        (fetchedMaterialGroupGroup) =>
            _handelFetchAllMaterialGroupGroupFromLocalSuccess(
                fetchedMaterialGroupGroup),
      );
    }
  }

  Future<List<MaterialGroupModel>> searchGroupProductByText(String query) async{
    if (materialGroups.isEmpty) {
     await getAllGroups();
      log('Materials list is empty');
    }
    log(materialGroups.length.toString());
    query = AppServiceUtils.replaceArabicNumbersWithEnglish(query);
    String lowerQuery = query.toLowerCase().trim();

    List<String> searchParts = lowerQuery.split(RegExp(r'\s+'));

    // Check for exact match first
    var exactMatch = materialGroups.where((item) =>
        item.groupName.toLowerCase() == lowerQuery ||
        item.groupCode.toString().toLowerCase() == lowerQuery);

    if (exactMatch.length == 1) {
      return [exactMatch.first];
    } else if (exactMatch.length > 1) {
      return exactMatch.toList();
    }

    // Check for matches where name, code, barcode, or serial numbers start with the query
    var startsWithMatches = materialGroups
        .where(
          (item) =>
              searchParts.every(
                  (part) => item.groupName.toLowerCase().startsWith(part)) ||
              searchParts.every((part) =>
                  item.groupCode.toString().toLowerCase().startsWith(part)),
        )
        .toList();

    if (startsWithMatches.isNotEmpty) {
      return startsWithMatches;
    }

    // Check for matches where name, code, barcode, or serial numbers contain the query
    return materialGroups
        .where((item) =>
            searchParts.every((part) =>
                item.groupName.toString().toLowerCase().contains(part)) ||
            searchParts.every((part) =>
                item.groupCode.toString().toLowerCase().contains(part)))
        .toList();
  }

  void _handelFetchAllMaterialGroupGroupFromLocalSuccess(
      List<MaterialGroupModel> fetchedMaterialGroupGroupFromNetwork) async {
    final fetchedMaterialGroup = fetchedMaterialGroupGroupFromNetwork;
    log('fetchedMaterialGroup length ${fetchedMaterialGroup.length}');

    materialGroups.addAll(fetchedMaterialGroup);

    // Show progress in the UI
    FirestoreUploader firestoreUploader = FirestoreUploader();
    await firestoreUploader.sequentially(
      data: materialGroups
          .map((item) => {...item.toJson(), 'docId': item.matGroupGuid})
          .toList(),
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
        ) ??
        MaterialGroupModel(
            matGroupGuid: id,
            groupCode: id,
            groupName: id,
            groupLatinName: id,
            parentGuid: id,
            groupNotes: id,
            groupSecurity: 0,
            groupType: 0,
            groupVat: 0,
            groupNumber: 0,
            groupBranchMask: 0,
            isCarGroup: false);
  }
}