import 'dart:developer';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/app_navigator.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/services/firebase/implementations/repos/bond_type_repository.dart';
import '../../../bill/services/bill/bills_count_service.dart';
import '../../data/models/bond_type.dart';
import '../../service/bond/bond_type_form_handler.dart';
import '../../ui/screens/add_bond_type_screen.dart';
/// Controller responsible for managing Bond Types
class BondTypeController extends GetxController with AppNavigator, FloatingLauncher {
  final BondTypeRepository _repository;

  BondTypeController(this._repository);

  final List<BondTypeModel> bondTypes = [];

  late final BondTypeFormHandler bondTypeFormHandler;

  BondType? get selectedBondType => bondTypeFormHandler.selectedBondType.value;

  int? selectedColorValue;

  Rx<RequestState> addOrUpdateBondTypeRequestState = RequestState.initial.obs;


  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    fetchBondTypes();
  }

  void _initializeServices() {
    bondTypeFormHandler = BondTypeFormHandler();
  }

  Future<void> fetchBondTypes() async {
    final hasConnection = await hasInternetConnection();
    getAllBondTypes(hasConnection);
  }

  Future<List<BondTypeModel>> getAllBondTypes(bool hasConnection) async {
    if (hasConnection) {
      final result = await _repository.getAll();

      result.fold(
            (failure) => AppUIUtils.onFailure(failure.message),
            (fetchedBondTypes) => bondTypes.assignAll(fetchedBondTypes),
      );
    } else {
      // no offline fallback for now
      bondTypes.clear();
    }
    return bondTypes;
  }

  void navigateToAddBondTypeScreen({
    BondTypeModel? bondType,
    required BuildContext context,
  }) {
    bondTypeFormHandler.init(bondType);
    launchFloatingWindow(
      context: context,
      minimizedTitle: ApiConstants.bonds.tr,
      floatingScreen: const AddBondTypeScreen(),
    );
  }

  Future<void> addOrUpdateBondType(BuildContext context) async {


    if (!bondTypeFormHandler.validate()) {
      AppUIUtils.onFailure('Please fill all required fields.');
      return;
    }

    if (bondTypeFormHandler.selectedBondType.value == null) {
      AppUIUtils.onFailure('Please select a bond type.');
      return;
    }
    addOrUpdateBondTypeRequestState.value = RequestState.loading;


    final bondTypeModel = _createBondTypeModel();

    final result = await _repository.save(bondTypeModel);

    result.fold(
          (failure) {
            addOrUpdateBondTypeRequestState.value = RequestState.error;
            return AppUIUtils.onFailure(failure.message);

          },
          (_) {
        AppUIUtils.onSuccess('Bond type saved successfully!');
        addOrUpdateBondTypeRequestState.value = RequestState.success;
        getAllBondTypes(true); // Refresh list
      },
    );
  }

  BondTypeModel _createBondTypeModel() {
    final selectedBondTypeModel = bondTypeFormHandler.selectedBondTypeModel;
    final newModel = bondTypeFormHandler.toModel();

    log(newModel.toJson().toString(), name: 'BondTypeModel');

    if (selectedBondTypeModel != null) {
      // Edit existing
      return BondTypeModel(
        label: newModel.label,
        value: newModel.value,
        typeGuide: newModel.typeGuide,
        from: newModel.from,
        to: newModel.to,
        taxType: newModel.taxType,
        color: newModel.color,
        type: newModel.type,
      );
    } else {
      // New model
      return newModel;
    }
  }

}
