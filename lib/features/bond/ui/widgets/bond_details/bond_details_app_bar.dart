import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../floating_window/services/overlay_service.dart';
import '../../../controllers/bonds/bond_details_controller.dart';
import '../../../controllers/bonds/bond_search_controller.dart';

class BondDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BondDetailsAppBar({
    super.key,
    required this.bondDetailsController,
    required this.bondSearchController,
    required this.bondTypeModel,
  });

  final BondDetailsController bondDetailsController;
  final BondSearchController bondSearchController;
  final BondType bondTypeModel;

  // kToolbarHeight: default AppBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(centerTitle: true, title: Text(bondDetailsController.bondType.value), leading: const BackButton(), actions: [
      IconButton(
          onPressed: () {
            // bondController.bondNextOrPrev(widget.bondType, true);
            // setState(() {});
          },
          icon: const Icon(Icons.keyboard_double_arrow_right)),
      SizedBox(
        width: 100,
        child: CustomTextFieldWithoutIcon(
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) {
            // controller.getBondByCode(widget.bondType, _);
          },
          textEditingController: TextEditingController(),
        ),
      ),
      IconButton(
          onPressed: () {
            // bondController.bondNextOrPrev(widget.bondType, false);
          },
          icon: const Icon(Icons.keyboard_double_arrow_left)),
    ]);
  }
}
