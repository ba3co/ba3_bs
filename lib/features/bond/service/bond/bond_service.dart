import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/data/models/pay_item_model.dart';
import 'package:ba3_bs/features/bond/service/bond/bond_pdf_generator.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/i_recodes_pluto_controller.dart';
import '../../../../core/i_controllers/pdf_base.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../controllers/bonds/all_bond_controller.dart';
import '../../controllers/bonds/bond_search_controller.dart';
import '../../data/models/bond_model.dart';

class BondService with PdfBase {
  final IRecodesPlutoController<PayItem> plutoController;
  final BondDetailsController bondController;

  BondService(this.plutoController, this.bondController);

  BondModel? createBondModel({
    BondModel? bondModel,
    required BondType bondType,
    required String payAccountGuid,
    required String payDate,
    String? note,
  }) {
    return BondModel.fromBondData(
      bondModel: bondModel,
      bondType: bondType,
      note: note,
      payAccountGuid: payAccountGuid,
      payDate: payDate,
      bondRecordsItems: plutoController.generateRecords,
    );
  }

  Future<void> handleDeleteSuccess(BondModel bondModel, BondSearchController bondSearchController,
      [fromBondById]) async {
    // Only fetchBonds if open bond details by bond id from AllBondsScreen
    if (fromBondById) {
      await Get.find<AllBondsController>().fetchAllBonds();
      Get.back();
    } else {
      bondSearchController.removeBond(bondModel);
    }

    AppUIUtils.onSuccess('تم حذف السند بنجاح!');
  }

  Future<void> handleSaveSuccess(BondModel bondModel, BondDetailsController bondDetailsController) async {
    AppUIUtils.onSuccess('تم حفظ السند بنجاح!');

    bondDetailsController.updateIsBondSaved(true);

    generateAndSendPdf(
      fileName: AppStrings.bond,
      itemModel: bondModel,
      itemModelId: bondModel.payGuid,
      items: bondModel.payItems.itemList,
      pdfGenerator: BondPdfGenerator(),
    );
  }

  void handleUpdateSuccess(BondModel bondModel, BondSearchController bondSearchController) {
    AppUIUtils.onSuccess('تم تعديل السند بنجاح!');

    bondSearchController.updateBond(bondModel);

    generateAndSendPdf(
      fileName: AppStrings.bond,
      itemModel: bondModel,
      itemModelId: bondModel.payGuid,
      items: bondModel.payItems.itemList,
      pdfGenerator: BondPdfGenerator(),
    );
  }

  bool validateAccount(AccountModel? customerAccount) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم الحساب!');
      return false;
    }
    return true;
  }
}
