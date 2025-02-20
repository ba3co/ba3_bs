import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import 'package:get/get.dart';

import '../../../../core/helper/mixin/controller_initializer.dart';
import '../../controllers/bonds/bond_details_controller.dart';
import '../../controllers/bonds/bond_search_controller.dart';
import '../../controllers/pluto/bond_details_pluto_controller.dart';
import '../../data/models/bond_model.dart';

class FloatingBondDetailsLauncher extends GetxController with FloatingLauncher, ControllerInitializer {
  /// Initializes and manages controllers for the Bond Details screen with floating window capabilities.
  Map<String, GetxController> setupControllers({required Map<String, dynamic> params}) {
    final tag = requireParam<String>(params, key: 'tag');

    final bondType = requireParam<BondType>(params, key: 'bondType');

    final bondDetailsPlutoController = requireParam<BondDetailsPlutoController>(params, key: 'bondDetailsPlutoController');
    final bondSearchController = requireParam<BondSearchController>(params, key: 'bondSearchController');
    final bondsFirebaseRepo = requireParam<CompoundDatasourceRepository<BondModel, BondType>>(params, key: 'bondsFirebaseRepo');

    final bondDetailsPlutoControllerWithTag = createController<BondDetailsPlutoController>(tag, controller: bondDetailsPlutoController);

    final bondSearchControllerWithTag = createController<BondSearchController>(tag, controller: bondSearchController);

    final bondDetailsControllerWithTag = createController<BondDetailsController>(
      tag,
      controller: BondDetailsController(
        bondsFirebaseRepo,
        bondDetailsPlutoController: bondDetailsPlutoControllerWithTag,
        bondSearchController: bondSearchControllerWithTag,
        bondType: bondType,
      ),
    );

    return {
      'bondDetailsController': bondDetailsControllerWithTag,
      'bondDetailsPlutoController': bondDetailsPlutoControllerWithTag,
      'bondSearchController': bondSearchControllerWithTag,
    };
  }
}

// [GETX] "BondDetailsControllerBondController_[#5de9f]" onDelete() called
// [GETX] "BondDetailsControllerBondController_[#5de9f]" deleted from memory
// [GETX] "BondDetailsPlutoControllerBondController_[#5de9f]" onDelete() called
// [GETX] "BondDetailsPlutoControllerBondController_[#5de9f]" deleted from memory
// [GETX] "BondSearchControllerBondController_[#5de9f]" onDelete() called
// [GETX] "BondSearchControllerBondController_[#5de9f]" deleted from memory
// [GETX] "FloatingWindowController" deleted from memory
