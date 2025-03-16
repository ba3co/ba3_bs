import 'dart:developer';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:ba3_bs/features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/dialogs/product_selection_dialog_content.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../users_management/data/models/user_model.dart';
import '../data/model/user_task_model.dart';

class AddTaskController extends GetxController {
  final FilterableDataSourceRepository _dataSourceRepository;

  AddTaskController(this._dataSourceRepository);

  final formKey = GlobalKey<FormState>();
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController materialTextController = TextEditingController();
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

  void addMaterialToList(BuildContext context) async {
    TextEditingController materialTextEditingController = TextEditingController();

    List<MaterialModel> searchedMaterials = read<MaterialController>().searchOfProductByText(materialTextController.text);
    if (searchedMaterials.isEmpty) {
      AppUIUtils.onFailure('لا يوجد مواد بهذا الاسم');
      return;
    }

    if (searchedMaterials.length > 1) {
      await OverlayService.showDialog(
        context: context,
        height: .7.sh,
        width: .8.sw,
        content: ProductSelectionDialogContent(
          searchedMaterials: searchedMaterials,
          onRowSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
            final materialId = onSelectedEvent.row?.cells[AppConstants.materialIdFiled]?.value;
            searchedMaterials.add(read<MaterialController>().getMaterialById(materialId)!);
            OverlayService.back();
          },
          onSubmitted: (_) async {},
          productTextController: materialTextEditingController,
        ),
        onCloseCallback: () {
          log('Product Selection Dialog Closed.');
        },
      );
    }
    if (searchedMaterials.isEmpty) {
      AppUIUtils.onFailure('يرجى اختيار مادة');
      return;
    }

    if (!context.mounted) return;
    await OverlayService.showDialog(
        context: context,
        height: 150,
        color: AppColors.backGroundColor,
        content: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(searchedMaterials.first.matName!),
              VerticalSpace(),
              TextAndExpandedChildField(
                  label: AppStrings.quantity.tr,
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: materialTextEditingController,
                    onSubmitted: (_) {
                      OverlayService.back();
                    },
                  )),
              AppButton(
                title: AppStrings.add.tr,
                onPressed: () {
                  OverlayService.back();
                },
              )
            ],
          ),
        ));
    final quantity = materialTextEditingController.text.toInt;

    if (quantity == 0) {
      AppUIUtils.onFailure('يرجى ادخال الكمية');
      return;
    }
    final docId = searchedMaterials.first.id!;
    // البحث عن المادة في القائمة
    int index = materialTaskList.indexWhere((material) => material.docId == docId);

    if (index != -1) {
      // إذا كانت المادة موجودة، يتم تحديث الكمية فقط
      materialTaskList[index] = materialTaskList[index].copyWith(
        quantity: (materialTaskList[index].quantity ?? 0) + quantity,
      );
      log("🔹 تم تحديث الكمية للمادة ذات ID: $docId إلى ${materialTaskList[index].quantity}");
    } else {
      // إذا لم تكن المادة موجودة، يتم إضافتها إلى القائمة
      materialTaskList.add(MaterialTaskModel(docId: docId, quantity: quantity, materialName: searchedMaterials.first.matName));
      log("✅ تم إضافة مادة جديدة ذات ID: $docId بكمية: $quantity");
    }
    materialTextController.clear();
    update();

    log(materialTaskList.length.toString());
  }

  void removeMaterialFromList(int index) {
    materialTaskList.removeAt(index);
    update();
  }

  saveTask() async {
    await _dataSourceRepository.getAll();
  }
}