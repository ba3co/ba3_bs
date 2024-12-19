import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/pdf_base.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../controllers/cheques/all_cheques_controller.dart';
import '../../controllers/cheques/cheques_details_controller.dart';
import '../../controllers/cheques/cheques_search_controller.dart';
import '../../data/models/cheques_model.dart';
import 'cheques_bond_service.dart';

class ChequesService with PdfBase, ChequesBondService {
  ChequesService();

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
    required String accPtr,
    required String accPtrName,
    required String chequesAccount2Name,
  }) {
    return ChequesModel.fromChequesData(
      chequesAccount2Name: chequesAccount2Name,
      accPtrName: accPtrName,
      accPtr: accPtr,
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

  EntryBondController get bondController => Get.find<EntryBondController>();

  Future<void> handleDeleteSuccess(ChequesModel chequesModel, ChequesSearchController chequesSearchController,
      [fromChequesById]) async {
    // Only fetchCheques if open cheques details by cheques id from AllChequesScreen
    if (fromChequesById) {
      await Get.find<AllChequesController>().fetchAllCheques();
      Get.back();
    } else {
      chequesSearchController.removeCheques(chequesModel);
    }

    AppUIUtils.onSuccess('تم حذف الشيك بنجاح!');
  }

  Future<void> handleSaveOrUpdateSuccess({
    required ChequesModel chequesModel,
    required ChequesDetailsController chequesDetailsController,
    required ChequesSearchController chequesSearchController,
    required bool isSave,
  }) async {
    final successMessage = isSave ? 'تم حفظ الشيك بنجاح!' : 'تم تعديل الشيك بنجاح!';

    AppUIUtils.onSuccess(successMessage);

    if (isSave) {
      chequesDetailsController.updateIsChequesSaved(true);
    } else {
      chequesSearchController.updateCheques(chequesModel);
    }

    // generateAndSendPdf(
    //   fileName: AppStrings.bill,
    //   itemModel: billModel,
    //   itemModelId: billModel.billId,
    //   items: billModel.items.itemList,
    //   pdfGenerator: BillPdfGenerator(),
    // );

    bondController.saveEntryBondModel(
      entryBondModel: createEntryBondModel(
        originType: EntryBondType.cheque,
        chequesModel: chequesModel,
      ),
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
