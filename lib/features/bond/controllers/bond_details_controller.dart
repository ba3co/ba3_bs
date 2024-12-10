import 'package:ba3_bs/features/bond/controllers/pluto/bond_record_pluto_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../ui/screens/bond_details_view.dart';

class BondDetailsController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setBondDate(DateTime.now());
  }

  final formKey = GlobalKey<FormState>();
  late String bondDate;
  TextEditingController accountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  bool isDebitOrCredit = false;

  void setIsDebitOrCredit(index) {
    if (index == 0) {
      isDebitOrCredit = false;
    } else {
      isDebitOrCredit = true;
    }
    update();
  }

  navigateToBondDetails(){
    Get.lazyPut(() => BondRecordPlutoController(this), fenix: true);

    Get.to(() => const BondDetailsView());
  }

  void setBondDate(DateTime newDate) {
    bondDate = newDate.toString().split(" ")[0];
    update();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;
}
