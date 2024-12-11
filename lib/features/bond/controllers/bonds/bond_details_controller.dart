import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/bond/controllers/pluto/bond_record_pluto_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../ui/screens/bond_details_view.dart';

class BondDetailsController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setBondDate(DateTime.now());
    clearControllers();
  }


  clearControllers(){
    print("object");
    accountController.clear();
    noteController.clear();
  }


  final formKey = GlobalKey<FormState>();
  late String bondDate;
  ///controller
  TextEditingController accountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late bool isDebitOrCredit;

  late BondType bondType;

  void setBondType(BondType bondType) {
    this.bondType = bondType;
  }

  void setIsDebitOrCredit() {
    if (bondType == BondType.daily) {
      isDebitOrCredit = false;
    } else {
      isDebitOrCredit = true;
    }
    update();
  }

  navigateToBondDetails() {
    Get.lazyPut(() => BondRecordPlutoController(this, bondType), fenix: true);

    Get.to(() => const BondDetailsView());
  }

  String getLastBondCode() {
    return "00";
  }

  void setBondDate(DateTime newDate) {
    bondDate = newDate.toString().split(" ")[0];
    update();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;
}
