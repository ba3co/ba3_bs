import 'dart:convert';
import 'package:flutter/services.dart';

class ClipboardJsonService {
  // Copy any serializable model OR a list of models
  Future<void> copy(dynamic data) async {
    // Model → JSON map
    dynamic jsonData;

    if (data is List) {
      jsonData = data.map((e) => e.toJson()).toList();
    } else {
      jsonData = data.toJson();
    }

    // Wrap it so we know which type it is
    final wrapper = {
      "type": data.runtimeType.toString(),
      "data": jsonData,
    };

    final jsonString = jsonEncode(wrapper);

    await Clipboard.setData(ClipboardData(text: jsonString));
  }

  // Paste JSON from OS clipboard and just return the decoded map
  Future<Map<String, dynamic>?> paste() async {
    final clipboard = await Clipboard.getData('text/plain');
    if (clipboard == null || clipboard.text == null) return null;

    try {
      return jsonDecode(clipboard.text!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
