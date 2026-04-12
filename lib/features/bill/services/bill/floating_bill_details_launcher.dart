import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_search_controller.dart';
import 'package:ba3_bs/features/bond/controllers/pluto/bond_details_pluto_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_type.dart';
import 'package:ba3_bs/features/bond/data/models/bond_type_model.dart';
import 'package:ba3_bs/features/bond/service/bond/floating_bond_details_launcher.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/controller_initializer.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/bill_details_controller.dart';
import '../../controllers/bill/bill_search_controller.dart';
import '../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../data/models/bill_model.dart';

/// Manages and initializes controllers for the Bill Details screen with floating window capabilities.
class FloatingBillDetailsLauncher extends GetxController
    with FloatingLauncher, ControllerInitializer {
  /// Initializes all required controllers for the Bill Details screen.
  Future<Map<String, GetxController>> setupControllers(
      {required Map<String, dynamic> params,
      required CompoundDatasourceRepository<BondModel, BondTypeModel>
          bondsFirebaseRepo}) async {
    final tag = requireParam<String>(params, key: 'tag');

    final billTypeModel =
        requireParam<BillTypeModel>(params, key: 'billTypeModel');

    final billsFirebaseRepo =
        requireParam<CompoundDatasourceRepository<BillModel, BillTypeModel>>(
            params,
            key: 'billsFirebaseRepo');

    final serialNumbersRepo =
        requireParam<QueryableSavableRepository<SerialNumberModel>>(params,
            key: 'serialNumbersRepo');

    final billSearchControllerWithTag = createController<BillSearchController>(
        tag,
        controller: BillSearchController());

    final billDetailsPlutoControllerWithTag =
        createController<BillDetailsPlutoController>(tag,
            controller: BillDetailsPlutoController(billTypeModel));

    final String controllerTag =
        AppServiceUtils.generateUniqueTag('BondController');

    FloatingBondDetailsLauncher floatingBondDetailsLauncher =
        FloatingBondDetailsLauncher();

    final BondTypeModel bondType = BondTypeModel.fromJson({
      'label': BondType.paymentVoucher.label,
      'value': BondType.paymentVoucher.value,
      'typeGuide': BondType.paymentVoucher.typeGuide,
      'from': BondType.paymentVoucher.from,
      'to': BondType.paymentVoucher.to,
      'taxType': BondType.paymentVoucher.taxType,
      'color': BondType.paymentVoucher.color,
      'type': BondType.paymentVoucher.label,
    });
    final Map<String, GetxController> controllers =
        floatingBondDetailsLauncher.setupControllers(
      params: {
        'tag': controllerTag,
        'bondType': bondType,
        'bondsFirebaseRepo': bondsFirebaseRepo,
        'bondDetailsPlutoController': BondDetailsPlutoController(bondType),
        'bondSearchController': BondSearchController(),
      },
    );

    final bondDetailsController =
        controllers['bondDetailsController'] as BondDetailsController;
    final bondDetailsPlutoController =
        controllers['bondDetailsPlutoController'] as BondDetailsPlutoController;
    final bondSearchController =
        controllers['bondSearchController'] as BondSearchController;
    final AllBondsController allBondsController = read<AllBondsController>();
    final bonds = await allBondsController.bondsCountByType(bondType);

    bondSearchController.initialize(
      currentBond: bonds.last,
      lastBondNumber: bonds.last.payNumber!,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );

    final billDetailsControllerWithTag =
        createController<BillDetailsController>(
      tag,
      controller: BillDetailsController(billsFirebaseRepo, serialNumbersRepo,
          billDetailsPlutoController: billDetailsPlutoControllerWithTag,
          billSearchController: billSearchControllerWithTag,
          bondDetailsController: bondDetailsController),
    );

    return {
      'billDetailsController': billDetailsControllerWithTag,
      'billDetailsPlutoController': billDetailsPlutoControllerWithTag,
      'billSearchController': billSearchControllerWithTag,
    };
  }
}
