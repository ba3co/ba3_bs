import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/utils.dart';
import '../data/models/card_model.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repo.dart';
import 'nfc_cards_controller.dart';

class UserManagementController extends GetxController {
  final UserManagementRepository _userRepository;

  UserManagementController(this._userRepository) {
    getAllRoles();
    initAllUser();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController pinController = TextEditingController();

  Map<String, RoleModel> allRoles = {};
  Map<String, UserModel> allUserList = {};

  UserManagementStatus? userStatus;

  String? userPin;
  String? cardNumber;
  UserModel? myUserModel;
  UserModel? initAddUserModel;

  initUser([String? userId]) {
    if (userId == null) {
      nameController.clear();
      pinController.clear();
      initAddUserModel = UserModel();
    } else {
      initAddUserModel = UserModel.fromJson(allUserList[userId]!.toJson());
      nameController.text = initAddUserModel?.userName ?? "";
      pinController.text = initAddUserModel?.userPin ?? "";
    }
  }

  // Fetch roles using the repository
  Future<void> getAllRoles() async {
    final result = await _userRepository.getAllRoles();
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (fetchedRoles) {
        allRoles = fetchedRoles;
      },
    );
    WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then(
          (value) => update(),
        );
  }

  void checkUserStatus() async {
    if (userPin != null) {
      debugPrint('userPin != null');
      await _checkUserByPin();
    } else if (cardNumber != null) {
      debugPrint('cardNumber != null');
      await _checkUserByCard();
    } else {
      debugPrint('_navigateToLogin');
      _navigateToLogin(true);
    }
  }

  Future<void> _checkUserByPin() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .where('userPin', isEqualTo: userPin)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      if (userStatus != UserManagementStatus.login) {
        myUserModel = UserModel.fromJson(querySnapshot.docs.first.data());
        userStatus = UserManagementStatus.login;
        _initializeControllers();
      }
    } else {
      await _handleNoMatch();
    }
  }

  Future<void> _checkUserByCard() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection("Cards").where('cardId', isEqualTo: cardNumber).get();

    if (querySnapshot.docs.isNotEmpty) {
      final cardData = querySnapshot.docs.first.data();
      if (cardData["isDisabled"]) {
        Get.snackbar("خطأ", "تم إلغاء تفعيل البطاقة");
        _navigateToLogin();
      } else {
        await _fetchUserByCard(cardData["userId"]);
      }
    } else {
      await _handleNoMatch();
    }
  }

  Future<void> _fetchUserByCard(String userId) async {
    final userSnapshot = await FirebaseFirestore.instance.collection(AppConstants.usersCollection).doc(userId).get();

    if (userSnapshot.exists) {
      myUserModel = UserModel.fromJson(userSnapshot.data()!);
      userStatus = UserManagementStatus.login;
      _initializeControllers();
    }
  }

  void _navigateToLogin([bool waitUntilFirstFrameRasterized = false]) {
    if (waitUntilFirstFrameRasterized) {
      WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((_) {
        userStatus = UserManagementStatus.first;
        Get.offAllNamed(AppRoutes.loginScreen);
      });
    } else {
      userStatus = UserManagementStatus.first;
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  Future<void> _handleNoMatch() async {
    userStatus = null; // Setting userStatus to null in case of no match
    if (Get.currentRoute != AppRoutes.loginScreen) {
      _navigateToLogin();
    } else {
      Get.snackbar("error", "not matched");
    }
    userPin = null;
    cardNumber = null;
  }

  void _initializeControllers() {
    // Get.put(GlobalController(), permanent: true);
    // Get.put(ChangesController(), permanent: true);
    update();
  }

  void initAllUser() {
    FirebaseFirestore.instance.collection(AppConstants.usersCollection).snapshots().listen((event) {
      allUserList.clear();
      for (var element in event.docs) {
        allUserList[element.id] = UserModel.fromJson(element.data());
      }
      update();
    });
  }

  void addUser() async {
    initAddUserModel?.userId ??= Utils.generateId(RecordType.user);
    initAddUserModel?.userStatus ??= AppConstants.userStatusOnline;
    final result = await _userRepository.saveUser(initAddUserModel!);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "User saved successfully!"),
    );
  }

  RoleModel? roleModel;

  void addRole() async {
    roleModel?.roleId ??= Utils.generateId(RecordType.role);
    final result = await _userRepository.saveRole(roleModel!);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "Role saved successfully!"),
    );
    update();
  }

  void startTimeReport({required String userId, DateTime? customDate}) async {
    final result = await _userRepository.startTimeReport(userId, customDate: customDate);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "Time report start successfully!"),
    );
  }

  void sendTimeReport({required String userId, int? customTime}) async {
    final result = await _userRepository.sendTimeReport(userId, customTime: customTime);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "Time report sent successfully!"),
    );
  }

  // Log login time
  Future<void> logInTime() async {
    if (myUserModel != null) {
      final result = await _userRepository.logLoginTime(myUserModel!.userId);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Login time logged successfully!"),
      );
    }
  }

  // Log logout time
  Future<void> logOutTime() async {
    if (myUserModel != null) {
      final result = await _userRepository.logLogoutTime(myUserModel!.userId);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Logout time logged successfully!"),
      );
    }
  }
}

getMyUserName() {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.myUserModel?.userName;
}

getCurrentUserSellerId() {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.myUserModel?.userSellerId;
}

getMyUserUserId() {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.myUserModel?.userId;
}

List? getMyUserFaceId() {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.myUserModel?.userFaceId;
}

getMyUserRole() {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.myUserModel?.userRole;
}

getUserNameById(id) {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.allUserList[id]?.userName;
}

UserModel getUserModelById(id) {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.allUserList[id]!;
}

bool checkPermission(role, page) {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  Map<String, List<String>>? userRole =
      userManagementViewController.allRoles[userManagementViewController.myUserModel?.userRole]?.roles;
  if (userRole?[page]?.contains(role) ?? false) {
    return true;
  } else {
    return false;
  }
}

bool checkMainPermission(role) {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  Map<String, List<String>>? userRole =
      userManagementViewController.allRoles[userManagementViewController.myUserModel?.userRole]?.roles;
  if (userRole?[role]?.isNotEmpty ?? false) {
    return true;
  } else {
    return false;
  }
}

Future<bool> hasPermissionForOperation(role, page) async {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  Map<String, List<String>>? userRole =
      userManagementViewController.allRoles[userManagementViewController.myUserModel?.userRole]?.roles;
  String error = "";
  // _ndefWrite();
  if (userRole?[page]?.contains(role) ?? false) {
    debugPrint("same");
    return true;
  } else {
    debugPrint("you need to evelotion");
    bool init = false;
    bool isNfcAvailable = (Platform.isAndroid || Platform.isIOS) && await NfcManager.instance.isAvailable();
    var a = await Get.defaultDialog(
        barrierDismissible: false,
        title:
            "احتاج الاذن\nل ${Utils.getRoleNameFromEnum(role.toString())}\nفي ${Utils.getPageNameFromEnum(page.toString())}",
        content: StatefulBuilder(builder: (context, setstate) {
          if (!init && isNfcAvailable) {
            init = true;
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
              NfcCardsController cardViewController = Get.find<NfcCardsController>();
              if (cardViewController.allCards.containsKey(cardId)) {
                CardModel cardModel = cardViewController.allCards[cardId]!;
                Map<String, List<String>>? newUserRole =
                    userManagementViewController.allRoles[getUserModelById(cardModel.userId).userRole]?.roles;
                if (newUserRole?[page]?.contains(role) ?? false) {
                  Get.back(result: true);
                  NfcManager.instance.stopSession();
                } else {
                  error = "هذا الحساب غير مصرح له بالقيام بهذه العملية";
                  setstate(() {});
                }
              } else {
                error = "البطاقة غير موجودة";
                setstate(() {});
              }
            });
          }
          return Column(
            children: [
              if (!isNfcAvailable)
                Column(
                  children: [
                    Pinput(
                      keyboardType: TextInputType.number,
                      defaultPinTheme: PinTheme(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8), color: Colors.blue.shade400.withOpacity(0.5))),
                      length: 6,
                      obscureText: true,
                      onCompleted: (inputPin) {
                        UserModel? user = userManagementViewController.allUserList.values
                            .toList()
                            .firstWhereOrNull((element) => element.userPin == inputPin);
                        if (user != null) {
                          Map<String, List<String>>? newUserRole =
                              userManagementViewController.allRoles[user.userRole]?.roles;
                          if (newUserRole?[page]?.contains(role) ?? false) {
                            Get.back(result: true);
                            NfcManager.instance.stopSession();
                          } else {
                            error = "هذا الحساب غير مصرح له بالقيام بهذه العملية";
                            setstate(() {});
                          }
                        } else {
                          error = "الحساب غير موجود";
                          setstate(() {});
                        }
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              Text(
                error,
                style: const TextStyle(fontSize: 22, color: Colors.red),
              ),
              if (error != "")
                const SizedBox(
                  height: 5,
                ),
              if (isNfcAvailable)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )
            ],
          );
        }),
        actions: [
          ElevatedButton(
              onPressed: () {
                Get.back(result: false);
              },
              child: const Text("cancel"))
        ]);

    debugPrint("a:$a");
    return a;
  }
}
