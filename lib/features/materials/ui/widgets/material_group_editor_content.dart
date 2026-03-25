import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';

class MaterialGroupEditorContent extends StatefulWidget {
  final MaterialGroupModel? existing;

  const MaterialGroupEditorContent({
    super.key,
    required this.existing,
  });

  @override
  State<MaterialGroupEditorContent> createState() => _MaterialGroupEditorContentState();
}

class _MaterialGroupEditorContentState extends State<MaterialGroupEditorContent> {
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _latinController;
  late final TextEditingController _notesController;
  late final TextEditingController _parentGuidController;
  bool _isCarGroup = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codeController = TextEditingController(text: e?.groupCode ?? '');
    _nameController = TextEditingController(text: e?.groupName ?? '');
    _latinController = TextEditingController(text: e?.groupLatinName ?? '');
    _notesController = TextEditingController(text: e?.groupNotes ?? '');
    _parentGuidController = TextEditingController(text: e?.parentGuid ?? '');
    _isCarGroup = e?.isCarGroup ?? false;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _latinController.dispose();
    _notesController.dispose();
    _parentGuidController.dispose();
    super.dispose();
  }

  MaterialGroupModel _buildModel() {
    final e = widget.existing;
    final id = e?.matGroupGuid ?? 'mg${DateTime.now().microsecondsSinceEpoch}';
    return MaterialGroupModel(
      matGroupGuid: id,
      groupCode: _codeController.text.trim(),
      groupName: _nameController.text.trim(),
      groupLatinName: _latinController.text.trim(),
      parentGuid: _parentGuidController.text.trim(),
      groupNotes: _notesController.text.trim(),
      groupSecurity: e?.groupSecurity ?? 0,
      groupType: e?.groupType ?? 0,
      groupVat: e?.groupVat ?? 0,
      groupNumber: e?.groupNumber ?? 0,
      groupBranchMask: e?.groupBranchMask ?? 0,
      isCarGroup: _isCarGroup,
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _codeController.text.trim().isEmpty) {
      AppUIUtils.onFailure('أدخل رمز المجموعة واسمها');
      return;
    }
    setState(() => _saving = true);
    final ok = await read<MaterialGroupController>().saveMaterialGroup(_buildModel());
    if (mounted) setState(() => _saving = false);
    if (ok) OverlayService.back();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Text(AppStrings.groupCode.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                CustomTextFieldWithoutIcon(
                  filedColor: AppColors.backGroundColor,
                  textEditingController: _codeController,
                ),
                Text(AppStrings.materialName.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                CustomTextFieldWithoutIcon(
                  filedColor: AppColors.backGroundColor,
                  textEditingController: _nameController,
                ),
                Text(AppStrings.latinName.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                CustomTextFieldWithoutIcon(
                  filedColor: AppColors.backGroundColor,
                  textEditingController: _latinController,
                ),
                Text(AppStrings.parentGroupGuid.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                CustomTextFieldWithoutIcon(
                  filedColor: AppColors.backGroundColor,
                  textEditingController: _parentGuidController,
                ),
                Text(AppStrings.notes.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                CustomTextFieldWithoutIcon(
                  filedColor: AppColors.backGroundColor,
                  textEditingController: _notesController,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.isCarGroup.tr),
                  value: _isCarGroup,
                  onChanged: _saving
                      ? null
                      : (v) {
                          setState(() => _isCarGroup = v);
                        },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                width: double.infinity,
                title: AppStrings.close.tr,
                onPressed: _saving ? () {} : OverlayService.back,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                width: double.infinity,
                title: AppStrings.save.tr,
                isLoading: _saving,
                onPressed: _saving ? () {} : _submit,
                iconData: Icons.save_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
