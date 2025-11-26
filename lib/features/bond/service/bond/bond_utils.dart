import 'package:flutter/cupertino.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../sellers/data/models/seller_model.dart';
import '../../data/models/bond_type_model.dart';

class BondUtils {
  BondModel appendEmptyBondModel(List<BondModel> bonds, String typeGuide) {
    final int lastBondNumber = bonds.isNotEmpty ? bonds.last.payNumber! : 0;

    final emptyBondModel = BondModel.empty(
      typeGuide: typeGuide,
      lastBondNumber: lastBondNumber,
    );

    bonds.add(emptyBondModel);
    return emptyBondModel;
  }

  List<BondModel> appendEmptyBondModelNew(
      String typeGuide, int lastBondNumber) {
    final List<BondModel> bonds = [];
    final emptyBillModel =
        BondModel.empty(typeGuide:typeGuide, lastBondNumber: lastBondNumber);

    bonds.add(emptyBillModel);
    return bonds;
  }

  bool validateCustomerAccount(AccountModel? customerAccount,BuildContext context) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل!', );
      return false;
    }
    return true;
  }

  bool validateSellerAccount(SellerModel? sellerAccount,BuildContext context) {
    if (sellerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم البائع!', );
      return false;
    }
    return true;
  }
}