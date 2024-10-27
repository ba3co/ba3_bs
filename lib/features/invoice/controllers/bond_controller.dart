import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';

class BondController extends GetxController {
  void createSalesBond(InvPayType payType) {
    switch (payType) {
      case InvPayType.cash:
        handelSalesCash();
      case InvPayType.due:
        handelSalesDue();
    }
  }

  void handelSalesCash() {}

  void handelSalesDue() {}
}
