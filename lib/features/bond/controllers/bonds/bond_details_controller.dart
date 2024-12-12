import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/bond/controllers/pluto/bond_details_pluto_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/validators/app_validator.dart';
import '../../../../core/services/firebase/implementations/datasource_repo_with_result.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../service/bond/Bond_service.dart';
import '../../service/bond/bond_utils.dart';
import 'bond_search_controller.dart';

class BondDetailsController extends GetxController   with AppValidator {
  BondDetailsController(
      this._bondsFirebaseRepo, {
        required this.bondDetailsPlutoController,
        required this.bondSearchController,
        required this.bondType
      });

  // Repositories

  final DataSourceRepositoryWithResult<BondModel> _bondsFirebaseRepo;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final BondSearchController bondSearchController;



  // Services
  late final BondService _bondService;
  late final BondUtils _bondUtils;

  final formKey = GlobalKey<FormState>();
  final TextEditingController bondNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController firstPayController = TextEditingController();
  final TextEditingController invReturnDateController = TextEditingController();
  final TextEditingController invReturnCodeController = TextEditingController();

  late String bondDate;
  BondType bondType = BondType.journalVoucher;
  bool isLoading = true;


  RxBool isBondSaved = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    setBondDate(DateTime.now());
  }

  // Initializer
  void _initializeServices() {
    _bondService = BondService(bondDetailsPlutoController, this);
    _bondUtils = BondUtils();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void updateBondType(String bondTypeLabel) => bondType = BondType.byLabel(bondTypeLabel);

  void setBondDate(DateTime newDate) {
    bondDate = newDate.toString().split(" ")[0];
    update();
  }





  Future<void> deleteBond(BondModel bondModel, {bool fromBondById = false}) async {
    final result = await _bondsFirebaseRepo.delete(bondModel.payGuid!);

    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (success) => _bondService.handleDeleteSuccess(bondModel, bondSearchController, fromBondById),
    );
  }

  Future<void> saveBond(BondType bondType) async {
    await _saveOrUpdateBond(bondType: bondType);
  }

  Future<void> updateBond({required BondType bondType, required BondModel bondModel}) async {
    await _saveOrUpdateBond(bondType: bondType, existingBondModel: bondModel);
  }

  Future<void> _saveOrUpdateBond({required BondType bondType, BondModel? existingBondModel}) async {
    // Validate the form first
    if (!validateForm()) return;

    // Create the bond model from the provided data
    final updatedBondModel = _createBondModelFromBondData(bondType, existingBondModel);

    // Handle null bond model
    if (updatedBondModel == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل واسم البائع!');
      return;
    }

    // Ensure there are bond items
    if (updatedBondModel.payItems.isEmpty) return;

    // Save the bond to Firestore
    final result = await _bondsFirebaseRepo.save(updatedBondModel);

    // Handle the result (success or failure)
    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (bondModel) {
        if (existingBondModel != null) {
          _bondService.handleUpdateSuccess(bondModel, bondSearchController);
        } else {
          _bondService.handleSaveSuccess(bondModel, this);
        }
      },
    );
  }

  updateIsBondSaved(bool newValue) {
    isBondSaved.value = newValue;
  }

  BondModel? _createBondModelFromBondData(BondType bondType, [BondModel? bondModel]) {
    // Create and return the bond model
    return _bondService.createBondModel(
      bondModel: bondModel,
      bondType: updatedBondType,
      bondDate: bondDate,
      bondCustomerId: selectedCustomerAccount!.id!,
      bondSellerId: sellerController.selectedSellerAccount!.costGuid!,
      bondPayType: selectedPayType.index,
    );
  }

  void navigateToAddBondScreen(BondType bondType, AddBondPlutoController addBondPlutoController,
      {bool fromBondDetails = false, bool fromBondById = false}) {
    Get.put(AddBondController(
      _bondsFirebaseRepo,
      addBondPlutoController: addBondPlutoController,
    )).initCustomerAccount(bondType.accounts?[BondAccounts.caches]);

    Get.toNamed(AppRoutes.addBondScreen,
        arguments: {'bondType': bondType, 'fromBondDetails': fromBondDetails, 'fromBondById': fromBondById});
  }

  void createNewFloatingAddBondScreen(
      BondType bondType,
      BuildContext context, {
        bool fromBondDetails = false,
        bool fromBondById = false,
      }) {
    final String tag = _generateUniqueTag();

    // Initialize the AddBondPlutoController
    AddBondPlutoController addBondPlutoController = _initializeAddBondPlutoController(tag);

    // Initialize the AddBondController
    AddBondController addBondController = _initializeAddBondController(bondType, addBondPlutoController, tag);

    // Launch the floating window with the AddBondScreen
    FloatingWindowService.launchFloatingWindow(
      context: context,
      onCloseCallback: () {
        Get.delete<AddBondController>(tag: tag, force: true);
        Get.delete<AddBondPlutoController>(tag: tag, force: true);
      },
      floatingScreen: AddBondScreen(
        bondType: bondType,
        fromBondDetails: fromBondDetails,
        fromBondById: fromBondById,
        addBondController: addBondController,
        addBondPlutoController: addBondPlutoController,
        tag: tag,
      ),
    );
  }

  String _generateUniqueTag() => 'AddBondController_${UniqueKey().toString()}';

  AddBondController _initializeAddBondController(
      BondType bondType, AddBondPlutoController addBondPlutoController, String tag) {
    // Create the AddBondController using Get
    return Get.put<AddBondController>(
      AddBondController(_bondsFirebaseRepo, addBondPlutoController: addBondPlutoController),
      tag: tag,
    )..initCustomerAccount(bondType.accounts?[BondAccounts.caches]);
  }

  AddBondPlutoController _initializeAddBondPlutoController(String tag) =>
      Get.put<AddBondPlutoController>(AddBondPlutoController(), tag: tag);

  prepareBondRecords(BondItems bondItems, BondDetailsPlutoController bondDetailsPlutoController) =>
      bondDetailsPlutoController.prepareBondMaterialsRows(bondItems.getMaterialRecords);

  prepareAdditionsDiscountsRecords(BondModel bondModel, BondDetailsPlutoController bondDetailsPlutoController) =>
      bondDetailsPlutoController.prepareAdditionsDiscountsRows(bondModel.getAdditionsDiscountsRecords);

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  initBondNumberController(int? bondNumber) {
    if (bondNumber != null) {
      bondNumberController.text = bondNumber.toString();
    } else {
      bondNumberController.text = '';
    }
  }

  void initSellerAccount(String? bondSellerId) => Get.find<SellerController>().initSellerAccount(bondSellerId, this);

  void updateBondDetailsOnScreen(BondModel bond, BondDetailsPlutoController bondPlutoController) {
    onPayTypeChanged(InvPayType.fromIndex(bond.bondDetails.bondPayType!));

    setBondDate(bond.bondDetails.bondDate!.toDate!);

    initBondNumberController(bond.bondDetails.bondNumber);

    initCustomerAccount(bond.bondType.accounts?[BondAccounts.caches]);

    initSellerAccount(bond.bondDetails.bondSellerId);

    prepareBondRecords(bond.items, bondPlutoController);
    prepareAdditionsDiscountsRecords(bond, bondPlutoController);

    bondPlutoController.update();
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setBondDate(DateTime.now());
    clearControllers();
  }


  clearControllers(){

    accountController.clear();
    noteController.clear();
  }


  final formKey = GlobalKey<FormState>();
  late String bondDate;
  ///controller
  TextEditingController accountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late bool isDebitOrCredit;

  late BondType bondType;

  void setBondType(BondType bondType) {
    this.bondType = bondType;
  }

  void setIsDebitOrCredit() {
    if (bondType == BondType.journalVoucher||bondType == BondType.openingEntry) {
      isDebitOrCredit = false;
    } else {
      isDebitOrCredit = true;
    }
    update();
  }



  String getLastBondCode() {
    return "00";
  }

  void setBondDate(DateTime newDate) {
    bondDate = newDate.toString().split(" ")[0];
    update();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  void updateBondDetailsOnScreen(BondModel currentBond, BondDetailsPlutoController bondDetailsPlutoController) {


  }
}
