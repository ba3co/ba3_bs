import 'dart:developer';

import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/models/material_model.dart';
import '../data/repositories/materials_repository.dart';

class MaterialController extends GetxController {
  final MaterialRepository _materialRepository;

  MaterialController(this._materialRepository);

  List<MaterialModel> materials = [];

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchMaterials();
  }

  // Fetch materials from the repository
  void fetchMaterials() {
    try {
      materials = _materialRepository.getAllMaterials();
    } catch (e) {
      debugPrint('error in fetchMaterials($e)');
    } finally {
      isLoading = false;
      update();
    }
  }

  void navigateToAllMaterialScreen() {
    Get.toNamed(AppRoutes.showAllMaterialsScreen);
  }

  List<MaterialModel> searchOfProductByText(query) {
    if (materials.isEmpty) {
      log('materials.isEmpty');
      fetchMaterials();
    }

    log('materials ${materials.length}');
    List<MaterialModel> searchedMaterials = [];
    query = replaceArabicNumbersWithEnglish(query);
    String query2 = '';
    String query3 = '';

    if (query.contains(" ")) {
      query3 = query.split(" ")[0];
      query2 = query.split(" ")[1];
    } else {
      query3 = query;
      query2 = query;
    }
    searchedMaterials = materials.where((item) {
      bool prodName = item.matName.toString().toLowerCase().contains(query3.toLowerCase()) &&
          item.matName.toString().toLowerCase().contains(query2.toLowerCase());
      bool prodCode = item.matCode.toString().toLowerCase().contains(query.toLowerCase());
      bool prodBarcode = item.matBarCode.toString().toLowerCase().contains(query.toLowerCase());
      return (prodName || prodCode || prodBarcode);
    }).toList();

    return searchedMaterials;
  }

  String getMaterialNameFromId(String? id) {
    if (id == null || id.isEmpty) return '';
    return materials.firstWhere((material) => material.id == id).matName ?? '';
  }

  MaterialModel getMaterialFromId(String id) {
    return materials.firstWhere((material) => material.id == id);
  }

  MaterialModel? getMaterialFromName(name) {
    if (name != null && name != " " && name != "") {
      return materials.where((element) => (element.matName!.toLowerCase().contains(name.toLowerCase()))).firstOrNull;
    }
    return null;
  }

  String replaceArabicNumbersWithEnglish(String input) {
    return input.replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }
}
