import 'dart:developer';

import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/utils/utils.dart';
import '../../patterns/ui/widgets/account_selection_dialog.dart';
import '../data/models/seller_model.dart';
import '../data/repositories/sellers_repository.dart';

class SellerController extends GetxController {
  final SellersRepository _sellersRepository;

  SellerController(this._sellersRepository);

  List<SellerModel> sellers = [];
  bool isLoading = true;

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

  List<SellerModel> searchAccountsByNameOrCode(text) {
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
    return searchAccountsByNameOrCode(query).map((seller) => seller.costName!).toList();
  }

  // Get seller name by ID
  String getSellerNameFromId(String? id) {
    if (id == null || id.isEmpty) return '';
    return sellers.firstWhere((seller) => seller.costGuid == id).costName ?? '';
  }

  // Replace Arabic numerals with English numerals
  String replaceArabicNumbersWithEnglish(String input) {
    return input.replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }

  Future<void> openSellerSelectionDialog(
      {required String query, required TextEditingController textEditingController}) async {
    List<String> searchedSellersNames = getSellersNames(query);

    if (searchedSellersNames.isNotEmpty) {
      String? selectedSellerName = await Get.defaultDialog<String>(
        title: 'Choose Account',
        content: AccountSelectionDialog(accountNames: searchedSellersNames),
      );

      if (selectedSellerName != null) {
        textEditingController.text = selectedSellerName;
        update();
      }
    } else {
      Utils.showSnackBar('فحص الحسابات', 'هذا الحساب غير موجود');
    }
  }
}
