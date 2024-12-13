import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:get/get.dart';

import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../controllers/bonds/bond_details_controller.dart';
import '../../controllers/bonds/bond_search_controller.dart';
import '../../controllers/pluto/bond_details_pluto_controller.dart';
import '../../data/models/bond_model.dart';


mixin BondDetailsScreenControllersInitializationMixin {
  Map<String, GetxController> initializeControllers({required Map<String, dynamic> params}) {
    final tag = getParam<String>(params, 'tag');
    final bondType = getParam<BondType>(params, 'bondType');
    final bondDetailsPlutoController = getParam<BondDetailsPlutoController>(params, 'bondDetailsPlutoController');
    final bondSearchController = getParam<BondSearchController>(params, 'bondSearchController');
    final bondsFirebaseRepo = getParam<DataSourceRepository<BondModel>>(params, 'bondsFirebaseRepo');

    return {
      'bondDetailsController': initializeController<BondDetailsController>(
        tag,
        () => BondDetailsController(
          bondsFirebaseRepo,
          bondDetailsPlutoController: bondDetailsPlutoController,
          bondSearchController: bondSearchController,
          bondType: bondType,
        ),
      ),
      'bondDetailsPlutoController': initializeController<BondDetailsPlutoController>(
        tag,
        () => bondDetailsPlutoController,
      ),
      'bondSearchController': initializeController<BondSearchController>(
        tag,
        () => bondSearchController,
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
