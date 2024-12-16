import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/validators/app_validator.dart';
import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../service/cheques/cheques_service.dart';
import 'cheques_search_controller.dart';

class ChequesDetailsController extends GetxController with AppValidator {
  ChequesDetailsController(
    this._chequesFirebaseRepo, {
    required this.chequesSearchController,
    required this.chequesType,
  });

  // Repositories

  final DataSourceRepository<ChequesModel> _chequesFirebaseRepo;
  final ChequesSearchController chequesSearchController;

  // Services
  late final ChequesService _chequesService;

  final formKey = GlobalKey<FormState>();

  ///controller
  final TextEditingController accountController = TextEditingController();
  final TextEditingController chequesNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  AccountModel? selectedAccount;

  RxString chequesDate = DateTime.now().toString().split(" ")[0].obs;
  bool isLoading = true;
  RxBool isChequesSaved = false.obs;

  late ChequesType chequesType;

  late bool isDebitOrCredit;

  void setAccount(AccountModel setAccount) {
    selectedAccount = setAccount;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }


  // Initializer
  void _initializeServices() {
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void setChequesDate(DateTime newDate) {
    chequesDate.value = newDate.toString().split(" ")[0];
    update();
  }

  Future<void> deleteCheques(ChequesModel chequesModel, {bool fromChequesById = false}) async {
    final result = await _chequesFirebaseRepo.delete(chequesModel.checkGuid!);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => _chequesService.handleDeleteSuccess(chequesModel, chequesSearchController, fromChequesById),
    );
  }

  Future<void> saveCheques(ChequesType chequesType) async {
    await _saveOrUpdateCheques(chequesType: chequesType);
  }

  Future<void> updateCheques({required ChequesType chequesType, required ChequesModel chequesModel}) async {
    await _saveOrUpdateCheques(chequesType: chequesType, existingChequesModel: chequesModel);
  }

  Future<void> _saveOrUpdateCheques({required ChequesType chequesType, ChequesModel? existingChequesModel}) async {
    // Validate the form first
    if (!validateForm()) return;



    // Create the cheques model from the provided data
    final updatedChequesModel = _createChequesModelFromChequesData(chequesType, existingChequesModel);

    // Handle null cheques model
    if (updatedChequesModel == null) {
      AppUIUtils.onFailure('من فضلك يرجى اضافة الحساب!');
      return;
    }



    // Save the cheques to Firestore
    final result = await _chequesFirebaseRepo.save(updatedChequesModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (chequesModel) {
        if (existingChequesModel != null) {
          _chequesService.handleUpdateSuccess(chequesModel, chequesSearchController);
        } else {
          _chequesService.handleSaveSuccess(chequesModel, this);
        }
      },
    );
  }

  updateIsChequesSaved(bool newValue) {
    isChequesSaved.value = newValue;
  }

  ChequesModel? _createChequesModelFromChequesData(ChequesType chequesType, [ChequesModel? chequesModel]) {
    // Validate customer accounts
    if (chequesSearchController.chequesDetailsController.isDebitOrCredit) {
      if (!_chequesService.validateAccount(selectedAccount)) {
        return null;
      }
    }
    // Create and return the cheques model
    return _chequesService.createChequesModel(
        chequesModel: chequesModel,
        chequesType: chequesType,
        payDate: chequesDate.value,
        payAccountGuid: selectedAccount!.id!,
        note: noteController.text);
  }


  initChequesNumberController(int? chequesNumber) {
    if (chequesNumber != null) {
      chequesNumberController.text = chequesNumber.toString();
    } else {
      chequesNumberController.text = '';
    }
  }

  void updateChequesDetailsOnScreen(ChequesModel cheques,) {
    setChequesDate(cheques.checkDate!.toDate!);

    initChequesNumberController(cheques.checkNumber);




  }

}
