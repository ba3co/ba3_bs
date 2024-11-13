import 'dart:developer';

import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_ui_utils.dart';
import '../../patterns/ui/widgets/account_selection_dialog.dart';
import '../data/models/seller_model.dart';
import '../data/repositories/sellers_repository.dart';

class SellerController extends GetxController {
  final SellersRepository _sellersRepository;

  SellerController(this._sellersRepository);

  List<SellerModel> sellers = [];
  bool isLoading = true;

  SellerModel? selectedSellerAccount;

  @override
  void onInit() {
    super.onInit();
    fetchSellers();
  }

  // Fetch sellers from the repository
  void fetchSellers() {
    try {
      sellers = _sellersRepository.getAllSellers();
    } catch (e) {
      debugPrint('Error in fetchSellers: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Navigation to the screen displaying all sellers
  void navigateToAllSellersScreen() {
    Get.toNamed(AppRoutes.showAllSellersScreen);
  }

  // Search for sellers by text query

  List<SellerModel> searchSellersByNameOrCode(text) {
    if (sellers.isEmpty) {
      log('Accounts isEmpty');
      fetchSellers();
    }
    return sellers
        .where((item) =>
            item.costName!.toLowerCase().contains(text.toLowerCase()) || item.costCode.toString().contains(text))
        .toList();
  }

  List<String> getSellersNames(String query) {
    return searchSellersByNameOrCode(query).map((seller) => seller.costName!).toList();
  }

  List<SellerModel> getSellersAccounts(String query) => searchSellersByNameOrCode(query);

  // Get seller name by ID
  String getSellerNameById(String? id) {
    if (id == null || id.isEmpty) return '';
    return sellers.firstWhere((seller) => seller.costGuid == id).costName ?? '';
  }

  // Get seller  by ID
  SellerModel getSellerById(String id) {
    return sellers.firstWhere((seller) => seller.costGuid == id);
  }

  // Replace Arabic numerals with English numerals
  String replaceArabicNumbersWithEnglish(String input) {
    return input.replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }

  updateSellerAccount(SellerModel? newAccount) {
    if (newAccount != null) {
      selectedSellerAccount = newAccount;
    }
  }

  void initSellerAccount(String billSellerId) {
    final SellerModel sellerAcc = getSellerById(billSellerId);

    updateSellerAccount(sellerAcc);

    Get.find<InvoiceController>().sellerAccountController.text = sellerAcc.costName!;
  }

  Future<void> openSellerSelectionDialog(
      {required String query, required TextEditingController textEditingController}) async {
    List<SellerModel> searchedSellersAccounts = getSellersAccounts(query);

    if (searchedSellersAccounts.isNotEmpty) {
      SellerModel? selectedSeller = await Get.defaultDialog<SellerModel>(
        title: 'Choose Account',
        content: SellerSelectionDialog(sellers: searchedSellersAccounts),
      );

      if (selectedSeller != null) {
        textEditingController.text = selectedSeller.costName!;

        selectedSellerAccount = selectedSeller;
        update();
      }
    } else {
      AppUIUtils.showSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
    }
  }
}
