import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';
import '../../../print/controller/print_controller.dart';

class MaterialLayout extends StatelessWidget {
  const MaterialLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final progress = read<MaterialController>().uploadProgress.value;

        return Stack(
          children: [
            Scaffold(
              // backgroundColor: const Color(0xFFF4F6FA),
              backgroundColor: const Color(0xFFEDF3F8),
              appBar: AppBar(
                title: Text(AppStrings.materials.tr),
                actions: RoleItemType.viewProduct.hasAdminPermission
                    ? [
                        _buildAdminButton(AppStrings.downloadMaterials.tr, () {
                          read<MaterialController>().fetchAllMaterialFromLocal();
                        }),
                        _buildAdminButton(AppStrings.repairMaterials.tr, () async {
                          /*      read<MaterialsStatementController>().setupAllMaterials().then((value) {

                          },);*/
                          read<MaterialController>().deleteAllMaterialFromLocal();
                          read<MaterialController>().reloadMaterials();
                        }),
                        _buildAdminButton(AppStrings.downloadGroups.tr, () {
                          read<MaterialGroupController>().fetchAllMaterialGroupFromLocal();
                        }, width: 120),
                      ]
                    : [],
              ),

              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: Column(
                  children: [
                    buildAppMenuItem(
                      icon: Icons.list_alt,
                      title: AppStrings.viewMaterial.tr,
                      onTap: () {
                        read<MaterialController>()
                          ..reloadMaterials()
                          ..navigateToAllMaterialScreen(context: context);
                      },
                    ),
                    buildAppMenuItem(
                      icon: Icons.category,
                      title: AppStrings.viewMaterialGroups.tr,
                      onTap: () {
                        read<MaterialGroupController>().navigateToAllMaterialGroupScreen(context: context);
                      },
                    ),
                    if (RoleItemType.viewProduct.hasWritePermission)
                      buildAppMenuItem(
                        icon: Icons.add,
                        title: AppStrings.addMaterials.tr,
                        onTap: () {
                          read<MaterialController>().navigateToAddOrUpdateMaterialScreen(context: context);
                        },
                      ),
                    buildAppMenuItem(
                      icon: Icons.remove,
                      title: AppStrings.viewNegativeMaterial.tr,
                      onTap: () {
                        read<MaterialController>()
                          ..reloadMaterials()
                          ..navigateToAllMaterialScreen(context: context, onlyNegativeMaterial: true);
                      },
                    ),
                    buildAppMenuItem(
                      icon: Icons.compass_calibration_outlined,
                      title: AppStrings.printerCalibration.tr,
                      onTap: () {
                        read<PrintingController>().zebraCalibrateAndSetup(
                          printerName: AppConstants.labelPrinterName,
                          widthDots: 55 * 8,
                          // 400
                          heightDots: 30 * 8,
                          // 240
                          darkness: 18,
                          speed: 2,
                        );
                        return;
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButton: RoleItemType.administrator.hasAdminPermission
                  ? FloatingActionButton(
                      onPressed: () {
                        // read<MaterialsStatementController>().setupAllMaterials();
                        read<MaterialController>().resetMaterialQuantityAndPrice();
                      },
                      backgroundColor: Colors.blue.shade700,
                      child: const Icon(
                        Icons.lock_reset,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            LoadingDialog(
              isLoading: read<MaterialController>().saveAllMaterialsRequestState.value == RequestState.loading,
              message: '${(progress * 100).toStringAsFixed(2)}% ${AppStrings.from.tr} ${AppStrings.materials.tr}',
              fontSize: 14.sp,
            ),
            LoadingDialog(
              isLoading: read<MaterialController>().loadingMaterialsRequestState.value == RequestState.loading,
              message: 'جاري تحديث المواد',
              fontSize: 14.sp,
            )
          ],
        );
      }),
    );
  }

  Widget _buildAdminButton(String title, VoidCallback onPressed, {double? width}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: AppButton(
        title: title,
        width: width ?? 140,
        onPressed: onPressed,
      ),
    );
  }
}