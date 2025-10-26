import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:get/get.dart';
import '../../../../core/services/firebase/implementations/repos/cheque_type_repository.dart';
import '../../data/models/cheque_type.dart';


class ChequeTypeController extends GetxController {
  final ChequeTypeRepository _repository;

  ChequeTypeController(this._repository);

  final List<ChequeType> cheques = [];

  Future<List<ChequeType>> getAllCheques(bool hasConnection) async {
    if (hasConnection) {
      final result = await _repository.getAll();

      result.fold(
            (failure) => AppUIUtils.onFailure(failure.message),
            (fetchedCheques) => cheques.assignAll(fetchedCheques),
      );
    } else {
      // no offline fallback, just clear or leave empty
      cheques.clear();
    }

    return cheques;
  }
}
