import 'dart:convert';

import 'package:ba3_bs/features/sellers/data/datasources/local/sellers_json.dart';
import 'package:flutter/foundation.dart';

import '../models/seller_model.dart';

class SellersLocalRepository {
  List<SellerModel> getAllSellers() {
    try {
      return sellersJsonMapper();
    } on FormatException catch (e) {
      debugPrint("JSON format error: $e");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Parse JSON string to a list of MaterialModel objects
  List<SellerModel> sellersJsonMapper() {
    // Sanitize the JSON string to handle special characters
    // String sanitizedJson = sanitizeJsonString(jsonString);
    Map<String, dynamic> jsonMap = jsonDecode(sellersJson);

    List<SellerModel> sellers = (jsonMap['Cost1']['Q'] as List)
        .map((sellerJson) => SellerModel.fromLocalImport(sellerJson))
        .toList();

    return sellers;
  }

  // Function to sanitize JSON string by escaping problematic characters
  String sanitizeJsonString(String jsonString) {
    // ignore: unnecessary_string_escapes
    return jsonString.replaceAll('\"', '\\\"'); // Escape quotes
  }
}
