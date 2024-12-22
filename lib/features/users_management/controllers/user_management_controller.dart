import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/features/login/data/models/role_model.dart';
import 'package:ba3_bs/features/users_management/services/role_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../../core/utils/generate_id.dart';
import '../../login/controllers/nfc_cards_controller.dart';
import '../../login/data/models/card_model.dart';
import '../../login/data/models/user_model.dart';
import '../../login/data/repositories/user_repo.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';

class UserManagementController extends GetxController with AppValidator {
  final UserManagementRepository _userRepository;

  final DataSourceRepository<RoleModel> _rolesFirebaseRepo;
  final DataSourceRepository<UserModel> _usersFirebaseRepo;

  UserManagementController(this._userRepository, this._rolesFirebaseRepo, this._usersFirebaseRepo);

  // Services
  late final RoleService _roleService;

  final userFormKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  Map<String, OldRoleModel> oldAllRoles = {};

  List<RoleModel> allRoles = [];
  List<UserModel> allUsers = [];

  RoleModel? roleModel;
  UserModel? userModel;

  Map<String, OldUserModel> allUserList = {};

  UserManagementStatus? userStatus;

  String? userPin;
  String? cardNumber;
  OldUserModel? myUserModel;
  OldUserModel? initAddUserModel;

  final bool isAdmin = true;

  Map<RoleItemType, List<RoleItem>> rolesMap = {};

  final roleFormKey = GlobalKey<FormState>();
  TextEditingController roleNameController = TextEditingController();

  RxnString selectedSellerId = RxnString();
  RxnString selectedRoleId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _roleService = RoleService();
  }

  bool validateRoleForm() => roleFormKey.currentState?.validate() ?? false;

  bool validateUserForm() => userFormKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  initUser(UserModel? user) {
    if (user != null) {
      userModel = user;

      selectedSellerId.value = user.userSellerId!;
      selectedRoleId.value = user.userRoleId!;

      userNameController.text = user.userName ?? '';
      passController.text = user.userPassword ?? '';
    } else {
      userModel = null;

      selectedSellerId.value = null; // Now valid with RxnString
      selectedRoleId.value = null; // Now valid with RxnString

      userNameController.clear();
      passController.clear();
    }
  }

  initRole(RoleModel? role) {
    if (role != null) {
      roleModel = role;
      rolesMap = role.roles;

      roleNameController.text = role.roleName ?? '';
    } else {
      roleModel = null;
      rolesMap = {};

      roleNameController.clear();
    }
  }

  RoleModel getRoleById(String id) => allRoles.firstWhere((role) => role.roleId == id);

  // Check if all roles are selected
  bool areAllRolesSelected() {
    return RoleItemType.values.every((type) => rolesMap[type]?.length == RoleItem.values.length);
  }

  // Check if all roles are selected for a specific RoleItemType
  bool areAllRolesSelectedForType(RoleItemType type) {
    return rolesMap[type]?.length == RoleItem.values.length;
  }

  // Select all roles
  void selectAllRoles() {
    for (final type in RoleItemType.values) {
      rolesMap[type] = RoleItem.values.toList();
    }
    update();
  }

  // Deselect all roles
  void deselectAllRoles() {
    rolesMap.clear();
    update();
  }

  // Select all roles for a specific RoleItemType
  void selectAllRolesForType(RoleItemType type) {
    rolesMap[type] = RoleItem.values.toList();
    update();
  }

  // Deselect all roles for a specific RoleItemType
  void deselectAllRolesForType(RoleItemType type) {
    rolesMap[type] = [];
    update();
  }

  // Fetch roles using the repository
  Future<void> getAllRoles() async {
    log('getAllRoles');
    final result = await _rolesFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedRoles) {
        allRoles = fetchedRoles;
      },
    );

    update();
  }

  // Fetch roles using the repository
  Future<void> getAllUsers() async {
    log('getAllUsers');
    final result = await _usersFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUsers) {
        allUsers = fetchedUsers;
      },
    );

    update();
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
        myUserModel = OldUserModel.fromJson(querySnapshot.docs.first.data());
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
      myUserModel = OldUserModel.fromJson(userSnapshot.data()!);
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

  void navigateToAddRoleScreen([RoleModel? roleModel]) {
    initRole(roleModel);
    Get.toNamed(AppRoutes.addRoleScreen);
  }

  void navigateToAddUserScreen([UserModel? userModel]) {
    initUser(userModel);
    Get.toNamed(AppRoutes.addUserScreen);
  }

  void navigateToLAllUsersScreen() {
    Get.toNamed(AppRoutes.showAllUsersScreen);
  }

  void navigateToLAllPermissionsScreen() {
    Get.toNamed(AppRoutes.showAllPermissionsScreen);
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
        allUserList[element.id] = OldUserModel.fromJson(element.data());
      }
      update();
    });
  }

  void addUser() async {
    initAddUserModel?.userId ??= generateId(RecordType.user);
    initAddUserModel?.userStatus ??= AppConstants.userStatusOnline;
    final result = await _userRepository.saveUser(initAddUserModel!);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "User saved successfully!"),
    );
  }

  OldRoleModel? oldRoleModel;

  void addRole() async {
    oldRoleModel?.roleId ??= generateId(RecordType.role);
    final result = await _userRepository.saveRole(oldRoleModel!);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "Role saved successfully!"),
    );
    update();
  }

  set setSellerId(String? sellerId) {
    selectedSellerId.value = sellerId;
  }

  set setRoleId(String? roleId) {
    selectedRoleId.value = roleId;
  }

  Future<void> saveOrUpdateRole({RoleModel? existingRoleModel}) async {
    // Validate the form first
    if (!validateRoleForm()) return;

    // Create the role model from the provided data
    final updatedRoleModel =
        _createRoleModel(existingRoleModel: existingRoleModel, roles: rolesMap, roleName: roleNameController.text);

    // Handle null role model
    if (updatedRoleModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات!');
      return;
    }

    // Save the role to Firestore
    final result = await _rolesFirebaseRepo.save(updatedRoleModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => AppUIUtils.onSuccess('تم الحفظ بنجاح'),
    );
  }

  RoleModel? _createRoleModel({
    required Map<RoleItemType, List<RoleItem>> roles,
    required String roleName,
    RoleModel? existingRoleModel,
  }) {
    if (rolesMap.isEmpty) {
      return null;
    }

    return _roleService.createRoleModel(
      roleModel: existingRoleModel,
      roles: roles,
      roleName: roleName,
    );
  }

  Future<void> saveOrUpdateUser({UserModel? existingUserModel}) async {
    // Validate the form first
    if (!validateUserForm()) return;

    // Create the role model from the provided data
    final updatedUserModel = _createUserModel(
      userModel: existingUserModel,
      userName: userNameController.text,
      userPassword: passController.text,
      userRoleId: selectedRoleId.value,
      userSellerId: selectedSellerId.value,
    );

    // Handle null role model
    if (updatedUserModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات و البائع!');
      return;
    }

    // Save the role to Firestore
    final result = await _usersFirebaseRepo.save(updatedUserModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => AppUIUtils.onSuccess('تم الحفظ بنجاح'),
    );
  }

  UserModel? _createUserModel({
    UserModel? userModel,
    required String userName,
    required String userPassword,
    String? userRoleId,
    String? userSellerId,
  }) {
    if (userRoleId == null || userSellerId == null) {
      return null;
    }

    return _roleService.createUserModel(
      userModel: userModel,
      userName: userName,
      userPassword: userPassword,
      userRoleId: userRoleId,
      userSellerId: userSellerId,
    );
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

OldUserModel getUserModelById(id) {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  return userManagementViewController.allUserList[id]!;
}

bool checkPermission(role, page) {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  Map<String, List<String>>? userRole =
      userManagementViewController.oldAllRoles[userManagementViewController.myUserModel?.userRole]?.roles;
  if (userRole?[page]?.contains(role) ?? false) {
    return true;
  } else {
    return false;
  }
}

bool checkMainPermission(role) {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  Map<String, List<String>>? userRole =
      userManagementViewController.oldAllRoles[userManagementViewController.myUserModel?.userRole]?.roles;
  if (userRole?[role]?.isNotEmpty ?? false) {
    return true;
  } else {
    return false;
  }
}

Future<bool> hasPermissionForOperation(role, page) async {
  UserManagementController userManagementViewController = Get.find<UserManagementController>();
  Map<String, List<String>>? userRole =
      userManagementViewController.oldAllRoles[userManagementViewController.myUserModel?.userRole]?.roles;
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
            "احتاج الاذن\nل ${AppUIUtils.getRoleNameFromEnum(role.toString())}\nفي ${AppUIUtils.getPageNameFromEnum(page.toString())}",
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
                    userManagementViewController.oldAllRoles[getUserModelById(cardModel.userId).userRole]?.roles;
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
                        OldUserModel? user = userManagementViewController.allUserList.values
                            .toList()
                            .firstWhereOrNull((element) => element.userPin == inputPin);
                        if (user != null) {
                          Map<String, List<String>>? newUserRole =
                              userManagementViewController.oldAllRoles[user.userRole]?.roles;
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
