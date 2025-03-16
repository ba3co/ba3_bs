import 'dart:developer';

import 'package:ba3_bs/features/userTask/data/model/user_task_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../users_management/data/models/user_model.dart';

class AddTaskController extends GetxController {
  final formKey = GlobalKey<FormState>();
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();
  Rx<DateTime> dueDate = DateTime.now().obs;
  Rx<DateTime> updateDate = DateTime.now().obs;
  Rx<DateTime> createDate = DateTime.now().obs;
  Rx<String> assignedTo = ''.obs;
  Rx<TaskStatus> selectedStatus = TaskStatus.initial.obs;
  Rx<TaskType> selectedTaskType = TaskType.generalTask.obs;


  List<MaterialTaskModel> materialTaskList = [];

  final _userManagementController = read<UserManagementController>();

  List<UserModel> get userList => _userManagementController.allUsers;
  List<String> selectedUsers = [];

  void updatedSelectedUsers(String userId, bool value) {
    if (selectedUsers.contains(userId)) {
      selectedUsers.remove(userId);
    } else {
      selectedUsers.add(userId);
    }
    update();
    print(selectedUsers);
  }

  bool checkUserStatus(String userId) {
    if (selectedUsers.contains(userId)) {
      return true;
    } else {
      return false;
    }
  }

  void selectOrDeselectAllUsers() {
    if (selectedUsers.isEmpty) {
      selectedUsers.addAll(userList.map((e) => e.userId!));
    } else {
      selectedUsers.clear();
    }
    update();
  }
}