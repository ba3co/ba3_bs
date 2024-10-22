import 'dart:io';
import 'package:ba3_bs/features/login/controllers/user_management_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../data/models/card_model.dart';

class NfcCardsController extends GetxController {
  Map<String, CardModel> allCards = {};
  RxBool isNfcAvailable = false.obs;

  NfcCardsController() {
    getAllCard();
  }

  @override
  void onInit() {
    super.onInit();
    checkNfcAvailability();
  }

  void getAllCard() {
    FirebaseFirestore.instance.collection("Cards").snapshots().listen((event) {
      allCards.clear();
      for (var element in event.docs) {
        allCards[element.id] = CardModel.fromJson(element.data());
      }
      update();
    });
  }

  checkNfcAvailability() {
    debugPrint('checkNfcAvailability');
    Future.sync(() async {
      isNfcAvailable.value = (Platform.isAndroid || Platform.isIOS) && await NfcManager.instance.isAvailable();
      if (isNfcAvailable.value) {
        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          List<int> idList = tag.data["ndef"]['identifier'];
          String id = '';
          for (var e in idList) {
            if (id == '') {
              id = e.toRadixString(16).padLeft(2, "0");
            } else {
              id = "$id:${e.toRadixString(16).padLeft(2, "0")}";
            }
          }
          var cardId = id.toUpperCase();
          UserManagementController userManagementController = Get.find<UserManagementController>();
          if (allCards.containsKey(cardId)) {
            userManagementController.cardNumber = cardId;
            userManagementController.checkUserStatus();
          } else {
            Get.snackbar("خطأ", "البطاقة غير موجودة");
          }
        });
      }
    });
  }
}
