import 'package:ba3_bs/core/i_controllers/i_bond_controller.dart';
import 'package:ba3_bs/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bond/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bond/bond_search_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/entryBond/entry_bond_controller.dart';
import '../../../patterns/data/models/bond_type_model.dart';
import '../../controllers/bond/all_bonds_controller.dart';
import '../../controllers/bonds/bond_controller.dart';
import '../../controllers/bonds/bond_search_controller.dart';
import '../../data/models/bond_model.dart';

class BondService {
  final IPlutoController plutoController;
  final BondDetailsController bondController;

  BondService(this.plutoController, this.bondController);


  BondModel? createBondModel({
    BondModel? bondModel,
    required BondType bondType,
    required String bondCustomerId,
    required String bondSellerId,
    required int bondPayType,
    required String bondDate,
  }) {
    return BondModel.fromBondData(
      bondModel: bondModel,
      bondType: bondType,
      note: null,
      bondCustomerId: bondCustomerId,
      bondSellerId: bondSellerId,
      bondPayType: bondPayType,
      bondDate: bondDate,
      bondTotal: plutoController.calculateFinalTotal,
      bondVatTotal: plutoController.computeTotalVat,
      bondWithoutVatTotal: plutoController.computeBeforeVatTotal,
      bondGiftsTotal: plutoController.computeGifts,
      bondDiscountsTotal: plutoController.computeDiscounts,
      bondAdditionsTotal: plutoController.computeAdditions,
      bondRecordsItems: plutoController.generateBondRecords,
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

    AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!');
  }

  Future<void> handleSaveSuccess(BondModel bondModel, BondDetailsController bondDetailsController) async {
    AppUIUtils.onSuccess('تم حفظ الفاتورة بنجاح!');
    bondDetailsController.updateIsBondSaved(true);
  }
  void handleUpdateSuccess(BondModel bondModel, BondSearchController bondSearchController) {
    AppUIUtils.onSuccess('تم تعديل الفاتورة بنجاح!');

    bondSearchController.updateBond(bondModel);

  }
}
