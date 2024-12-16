import 'package:ba3_bs/features/accounts/data/models/account_model.dart';

import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/pdf_base.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../controllers/cheques/all_cheques_controller.dart';
import '../../controllers/cheques/cheques_details_controller.dart';
import '../../controllers/cheques/cheques_search_controller.dart';

import '../../data/models/cheques_model.dart';

class ChequesService with PdfBase {
  final ChequesDetailsController chequesController;

  ChequesService( this.chequesController);

  ChequesModel? createChequesModel({
    ChequesModel? chequesModel,
    required ChequesType chequesType,
    required String payAccountGuid,
    required String payDate,
    String? note,
  }) {
    return ChequesModel.fromChequesData(
      chequesModel: chequesModel,
      chequesType: chequesType,
      note: note,
      payAccountGuid: payAccountGuid,
      payDate: payDate,
    );
  }

  Future<void> handleDeleteSuccess(ChequesModel chequesModel, ChequesSearchController chequesSearchController, [fromChequesById]) async {
    // Only fetchCheques if open cheques details by cheques id from AllChequessScreen
    if (fromChequesById) {
      await Get.find<AllChequesController>().fetchAllCheques();
      Get.back();
    } else {
      chequesSearchController.removeCheques(chequesModel);
    }

    AppUIUtils.onSuccess('تم حذف السند بنجاح!');
  }

  Future<void> handleSaveSuccess(ChequesModel chequesModel, ChequesDetailsController chequesDetailsController) async {
    AppUIUtils.onSuccess('تم حفظ السند بنجاح!');

    chequesDetailsController.updateIsChequesSaved(true);


  }

  void handleUpdateSuccess(ChequesModel chequesModel, ChequesSearchController chequesSearchController) {
    AppUIUtils.onSuccess('تم تعديل السند بنجاح!');

    chequesSearchController.updateCheques(chequesModel);


  }

  bool validateAccount(AccountModel? customerAccount) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم الحساب!');
      return false;
    }
    return true;
  }
}
