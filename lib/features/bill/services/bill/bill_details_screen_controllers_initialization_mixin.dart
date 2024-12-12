import 'package:get/get.dart';

import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../controllers/bill/bill_details_controller.dart';
import '../../controllers/bill/bill_search_controller.dart';
import '../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../data/models/bill_model.dart';

mixin BillDetailsScreenControllersInitializationMixin {
  Map<String, GetxController> initializeControllers({required Map<String, dynamic> params}) {
    final tag = getParam<String>(params, 'tag');
    final billDetailsPlutoController = getParam<BillDetailsPlutoController>(params, 'billDetailsPlutoController');
    final billSearchController = getParam<BillSearchController>(params, 'billSearchController');
    final billsFirebaseRepo = getParam<DataSourceRepository<BillModel>>(params, 'billsFirebaseRepo');

    return {
      'billDetailsController': initializeController<BillDetailsController>(
        tag,
        () => BillDetailsController(
          billsFirebaseRepo,
          billDetailsPlutoController: billDetailsPlutoController,
          billSearchController: billSearchController,
        ),
      ),
      'billDetailsPlutoController': initializeController<BillDetailsPlutoController>(
        tag,
        () => billDetailsPlutoController,
      ),
      'billSearchController': initializeController<BillSearchController>(
        tag,
        () => billSearchController,
      ),
    };
  }

  T getParam<T>(Map<String, dynamic> params, String key) {
    final value = params[key];
    if (value is T) return value;
    throw ArgumentError('Expected parameter of type $T for key "$key", but got ${value.runtimeType}');
  }

  T initializeController<T extends GetxController>(String tag, T Function() controllerBuilder) {
    if (!Get.isRegistered<T>(tag: tag)) {
      Get.create<T>(controllerBuilder, permanent: false, tag: tag);
    }
    return Get.find<T>(tag: tag);
  }
}
