import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../ui/screens/bond_details_view.dart';

class BondDetailsController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setBillDate(DateTime.now());
  }

  final formKey = GlobalKey<FormState>();
  late String billDate;
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
    Get.to(() => const BondDetailsView());
  }

  void setBillDate(DateTime newDate) {
    billDate = newDate.toString().split(" ")[0];
    update();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;
}
