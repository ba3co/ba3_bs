import 'dart:developer';

import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/bond/controllers/pluto/bond_details_pluto_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';
import 'package:ba3_bs/features/bond/data/models/pay_item_model.dart';
import 'package:ba3_bs/features/bond/service/bond/bond_local_storage_service.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/validators/app_validator.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../service/bond/bond_details_service.dart';
import 'bond_search_controller.dart';

class BondDetailsController extends GetxController with AppValidator {
  BondDetailsController(
    this._bondsFirebaseRepo, {
    required this.bondDetailsPlutoController,
    required this.bondSearchController,
    required this.bondType,
  });

  // Repositories

  final CompoundDatasourceRepository<BondModel, BondType> _bondsFirebaseRepo;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final BondSearchController bondSearchController;

  // Services
  late final BondDetailsService _bondService;

  final formKey = GlobalKey<FormState>();

  ///controller
  final TextEditingController accountController = TextEditingController();
  final TextEditingController bondNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  AccountModel? selectedAccount;

  RxString bondDate = DateTime.now().dayMonthYear.obs;
  bool isLoading = true;
  RxBool isBondSaved = false.obs;

  late BondType bondType;

  late bool isDebitOrCredit;

  Rx<RequestState> saveBondRequestState = RequestState.initial.obs;

  Rx<RequestState> deleteBondRequestState = RequestState.initial.obs;

  void setAccount(AccountModel setAccount) {
    selectedAccount = setAccount;
    bondDetailsPlutoController.setAccountGuid = setAccount.id;
    accountController.text = setAccount.accName!;
    log(accountController.text, name: 'setAccount');
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    setIsDebitOrCredit();
  }

  void setIsDebitOrCredit() {
    if (bondType == BondType.journalVoucher || bondType == BondType.openingEntry) {
      isDebitOrCredit = false;
    } else {
      isDebitOrCredit = true;
    }
    update();
  }

  // Initializer
  void _initializeServices() {
    _bondService = BondDetailsService(bondDetailsPlutoController, this);
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void setBondDate(DateTime newDate) {
    bondDate.value = newDate.dayMonthYear;
    update();
  }

  Future<void> deleteBond(BondModel bondModel, BuildContext context, {bool fromBondById = false}) async {

    if(!RoleItemType.viewBond.hasDeletePermission)
      {
        AppUIUtils.onFailure( "no permissions");
        return;
      }
    deleteBondRequestState.value = RequestState.loading;

    final result = await _bondsFirebaseRepo.delete(bondModel);

    await result.fold(
      (failure) {
        deleteBondRequestState.value = RequestState.error;
        AppUIUtils.onFailure(
          failure.message,
        );
      },
      (success) async {
        await _bondService.handleDeleteSuccess(bondModel, bondSearchController, context, fromBondById);
        deleteBondRequestState.value = RequestState.success;
      },
    );
  }

  Future<void> saveBond(BondType bondType, BuildContext context) async {
    await _saveOrUpdateBond(bondType: bondType, context: context);
  }

  Future<void> updateBond({required BondType bondType, required BondModel bondModel, required BuildContext context}) async {
    if(RoleItemType.viewBond.hasUpdatePermission) {
      await _saveOrUpdateBond(bondType: bondType, existingBondModel: bondModel, context: context);
    }
    else{
      AppUIUtils.onFailure( 'no permissions');
    }
  }

  Future<void> _saveOrUpdateBond({required BondType bondType, BondModel? existingBondModel, required BuildContext context}) async {
    // Validate the form first
    if (!validateForm()) return;

    if (!bondDetailsPlutoController.checkIfBalancedBond()) {
      AppUIUtils.onFailure(
        'يجب موازنة السند من فضلك!',
      );
      return;
    }
    // Create the bond model from the provided data
    final updatedBondModel = _createBondModelFromBondData(bondType, existingBondModel);

    // Handle null bond model
    if (updatedBondModel == null) {
      AppUIUtils.onFailure(
        'من فضلك يرجى اضافة الحساب!',
      );
      return;
    }

    // Ensure there are bond items
    if (updatedBondModel.payItems.itemList.isEmpty) {
      AppUIUtils.onFailure(
        'من فضلك يرجى اضافة حقول للسند',
      );
      return;
    }

    saveBondRequestState.value = RequestState.loading;

    // Save the bond to Firestore
    final result = await _bondsFirebaseRepo.save(updatedBondModel);
    BondLocalStorageService().saveSingleBond(updatedBondModel);
    // Handle the result (success or failure)
    await result.fold(
      (failure) {
        saveBondRequestState.value = RequestState.error;
        return AppUIUtils.onFailure(
          failure.message,
        );
      },
      (bondModel) async {
        await _bondService.handleSaveOrUpdateSuccess(
          previousBond: existingBondModel,
          currentBond: bondModel,
          bondSearchController: bondSearchController,
          isSave: existingBondModel == null,
          bondDetailsController: this,
          context: context,
        );

        saveBondRequestState.value = RequestState.success;
      },
    );
  }

  void createEntryBond(BondModel bondModel, BuildContext context) {
    if (!validateForm()) return;

    _bondService.launchBondEntryBondScreen(
      bondModel: bondModel,
      context: context,
    );
  }

  updateIsBondSaved(bool newValue) {
    isBondSaved.value = newValue;
  }

  BondModel? _createBondModelFromBondData(BondType bondType, [BondModel? bondModel]) {
    // Validate customer accounts
    if (bondSearchController.bondDetailsController.isDebitOrCredit) {
      if (!_bondService.validateAccount(
        selectedAccount,
      )) {
        return null;
      }
    }
    // Create and return the bond model

    return _bondService.createBondModel(
      bondModel: bondModel,
      bondType: bondType,
      payDate: bondDate.value,
      payAccountGuid: selectedAccount?.id! ?? "00000000-0000-0000-0000-000000000000",
      note: noteController.text,
    );
  }

  prepareBondRecords(PayItems bondItems, BondDetailsPlutoController bondDetailsPlutoController) =>
      bondDetailsPlutoController.prepareBondRows(bondItems.itemList);

  initBondNumberController(int? bondNumber) {
    if (bondNumber != null) {
      bondNumberController.text = bondNumber.toString();
    } else {
      bondNumberController.text = '';
    }
  }

  void updateBondDetailsOnScreen(BondModel bond, BondDetailsPlutoController bondPlutoController) {
    setBondDate(bond.payDate!.toDate);
    isBondSaved.value = bond.payGuid != null;
    initBondNumberController(bond.payNumber);
    initBondNote(bond.payNote);

    if (AppServiceUtils.getAccountModelFromLabel(bond.payAccountGuid) != null) {
      setAccount(AppServiceUtils.getAccountModelFromLabel(bond.payAccountGuid)!);
      accountController.text = AppServiceUtils.getAccountModelFromLabel(bond.payAccountGuid)!.accName!;
    }

    prepareBondRecords(bond.payItems, bondPlutoController);

    bondPlutoController.update();
  }

  generateAndSendBondPdf(BondModel bondModel, BuildContext context) {
    if (!_bondService.hasModelId(bondModel.payGuid)) return;

    if (!_bondService.hasModelItems(bondModel.payItems.itemList)) return;

    _bondService.generatePdfAndSendToEmail(
      fileName: AppStrings.bond.tr,
      itemModel: bondModel,
      context: context,
    );
  }

  appendNewBill({required BondType bondType, required int lastBondNumber}) {
    BondModel newBond = BondModel.empty(bondType: bondType, lastBondNumber: lastBondNumber);

    bondSearchController.insertLastAndUpdate(newBond);
  }

  void initBondNote(String? payNote) {
    noteController.text = payNote ?? '';
  }
}