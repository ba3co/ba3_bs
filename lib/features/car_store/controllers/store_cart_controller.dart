import 'package:ba3_bs/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/car_store/data/model/store_cart.dart';
import 'package:get/get.dart';

class StoreCartController extends GetxController {
  final RemoteDataSourceRepository<StoreCartModel> _dataSourceRepository;

  List<StoreCartModel> storeCartModels = [];

  StoreCartController(this._dataSourceRepository);

  void fetchAllStoreCart() async {
    final result = await _dataSourceRepository.getAll();
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedStoreCard) => storeCartModels.assignAll(fetchedStoreCard),
    );
  }
}
