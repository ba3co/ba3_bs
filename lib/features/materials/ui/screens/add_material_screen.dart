import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/widgets/searchable_material_field.dart';
import 'package:ba3_bs/core/widgets/tax_dropdown.dart';
import 'package:ba3_bs/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/controllers/mats_statement_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../widgets/add_material/add_material_form.dart';

Widget _materialImagePlaceholder() {
  return Container(
    height: 140,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.backGroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey.shade600),
        const SizedBox(height: 8),
        Text(
          AppStrings.noMaterialImageYet.tr,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
      ],
    ),
  );
}

void _openMaterialImageOverlay(BuildContext context, MaterialController c) {
  if (!c.hasId) {
    AppUIUtils.onFailure(AppStrings.saveMaterialBeforeImageUpload.tr);
    return;
  }
  final size = MediaQuery.sizeOf(context);
  OverlayService.showDialog(
    context: context,
    title: AppStrings.materialImageSheetTitle.tr,
    dialogAlignment: Alignment.center,
    width: math.min(460, size.width * 0.92),
    height: math.min(520, size.height * 0.58),
    content: _MaterialImageOverlayBody(controller: c),
  );
}

class _MaterialImageOverlayBody extends StatelessWidget {
  final MaterialController controller;

  const _MaterialImageOverlayBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Obx(() {
            final url = controller.materialImageUrl.value;
            if (url != null && url.isNotEmpty) {
              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _materialImagePlaceholder(),
                    ),
                  ),
                ),
              );
            }
            return Center(child: _materialImagePlaceholder());
          }),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  final loading = controller.materialImageUploadState.value == RequestState.loading;
                  final hasUrl = (controller.materialImageUrl.value ?? '').isNotEmpty;
                  return AppButton(
                    width: w,
                    title: hasUrl ? AppStrings.changeMaterialImage.tr : AppStrings.pickImageFromGallery.tr,
                    iconData: Icons.photo_library_outlined,
                    isLoading: loading,
                    onPressed: () => controller.pickAndUploadMaterialImage(),
                  );
                }),
                const SizedBox(height: 10),
                AppButton(
                  width: w,
                  title: AppStrings.close.tr,
                  onPressed: OverlayService.back,
                  color: Colors.grey,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class AddMaterialScreen extends StatelessWidget {
  const AddMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: [
              Expanded(
                child: Text(controller.selectedMaterial?.matName ?? AppStrings.newMaterial.tr),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: AppStrings.materialImageSheetTitle.tr,
              onPressed: () => _openMaterialImageOverlay(context, controller),
              icon: Obx(() {
                final has = (controller.materialImageUrl.value ?? '').isNotEmpty;
                final loading = controller.materialImageUploadState.value == RequestState.loading;
                if (loading) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      has ? Icons.photo_library_outlined : Icons.add_photo_alternate_outlined,
                    ),
                    if (has)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.lightGreenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 20,
            children: [
              AddMaterialForm(
                controller: controller,
              ),
              FormFieldRow(
                firstItem: TaxDropdown(taxSelectionHandler: controller.materialFromHandler),
                secondItem: SearchableMaterialField(
                  label: AppStrings.group.tr,
                  textController: controller.materialFromHandler.parentController,
                  onSubmitted: (text) {
                    controller.openMaterialGroupSelectionDialog(
                      query: text,
                      context: context,
                    );
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    if (!controller.hasId)
                      Obx(() {
                        return AppButton(
                          isLoading: controller.saveMaterialRequestState.value == RequestState.loading,
                          title: AppStrings.add.tr,
                          onPressed: () => controller.saveOrUpdateMaterial(),
                          iconData: Icons.add,
                        );
                      })
                    else ...[
                      if (RoleItemType.viewProduct.hasAdminPermission) ...[
                        Obx(() {
                          return AppButton(
                            isLoading: controller.saveMaterialRequestState.value == RequestState.loading,
                            title: AppStrings.edit.tr,
                            onPressed: () => controller.saveOrUpdateMaterial(),
                            iconData: Icons.edit,
                            color: Colors.green,
                          );
                        }),
                        const SizedBox(width: 8),
                        Obx(() {
                          return AppButton(
                            isLoading: controller.deleteMaterialRequestState.value == RequestState.loading,
                            title: AppStrings.delete.tr,
                            onPressed: () async {
                              if (await AppUIUtils.confirmOverlay(context, canPop: true)) {
                                if (!context.mounted) return;
                                controller.deleteMaterial(context, true);
                              }
                            },
                            iconData: Icons.delete,
                            color: Colors.red,
                          );
                        }),
                        const SizedBox(width: 8),
                      ],

                      AppButton(
                        title: AppStrings.newS.tr,
                        onPressed: () {
                          controller.clearMaterialForm();
                        },
                        iconData: FontAwesomeIcons.filePen,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Obx(() {
                        return AppButton(
                          isLoading: controller.deleteMaterialRequestState.value == RequestState.loading,
                          title: AppStrings.repair.tr,
                          onPressed: () async {
                            if (controller.deleteMaterialRequestState.value != RequestState.loading) {
                              controller.deleteMaterialRequestState.value = RequestState.loading;
                              await read<MaterialsStatementController>()
                                  .setupOneMaterials(controller.selectedMaterial!.id!);
                              controller.deleteMaterialRequestState.value = RequestState.success;
                            }
                          },
                          iconData: Icons.home_repair_service_outlined,
                          color: Colors.orange,
                        );
                      }),
                      const SizedBox(width: 8),
                      AppButton(
                        title: AppStrings.print.tr,
                        onPressed: () async {
                          controller.creatMultiCopiesMatBarcode(
                            material: controller.selectedMaterial!,
                            context: context,
                          );
                        },
                        iconData: Icons.print_outlined,
                      ),
                    ],
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
