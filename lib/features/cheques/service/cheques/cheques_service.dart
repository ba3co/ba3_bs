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

  ChequesService(this.chequesController);

  ChequesModel? createChequesModel({
    ChequesModel? chequesModel,
    required ChequesType chequesType,
    required String chequesTypeGuid,
    required int chequesNum,
    required String chequesDate,
    required String chequesDueDate,
    required String chequesNote,
    required double chequesVal,
    required String chequesAccount2Guid,
  }) {
    return ChequesModel.fromChequesData(
      chequesModel: chequesModel,
      chequesType: chequesType,
      chequesNote: chequesNote,
      chequesVal: chequesVal,
      chequesNum: chequesNum,
      chequesDueDate: chequesDueDate,
      chequesAccount2Guid: chequesAccount2Guid,
      chequesTypeGuid: chequesTypeGuid,
      chequesDate: chequesDate,
    );
  }

  Future<void> handleDeleteSuccess(ChequesModel chequesModel, ChequesSearchController chequesSearchController, [fromChequesById]) async {
    // Only fetchCheques if open cheques details by cheques id from AllChequesScreen
    if (fromChequesById) {
      await Get.find<AllChequesController>().fetchAllCheques();
      Get.back();
    } else {
      chequesSearchController.removeCheques(chequesModel);
    }

    AppUIUtils.onSuccess('تم حذف الشيك بنجاح!');
  }

  Future<void> handleSaveSuccess(ChequesModel chequesModel, ChequesDetailsController chequesDetailsController) async {
    AppUIUtils.onSuccess('تم حفظ الشيك بنجاح!');

    chequesDetailsController.updateIsChequesSaved(true);
  }

  void handleUpdateSuccess(ChequesModel chequesModel, ChequesSearchController chequesSearchController) {
    AppUIUtils.onSuccess('تم تعديل الشيك بنجاح!');

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
