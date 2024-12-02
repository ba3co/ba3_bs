import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/bill/ui/widgets/bill_shared/custom_Text_field.dart';
import '../widgets/pluto_grid_with_app_bar_.dart';

class SearchProductTextDialog extends StatelessWidget {
  final List<MaterialModel> searchedMaterials;
  final Function(PlutoGridOnSelectedEvent onSelectedEvent) onRowSelected;
  final VoidCallback onCloseTap;
  final void Function(String) onSubmitted;
  final TextEditingController productTextController;

  const SearchProductTextDialog({
    super.key,
    required this.searchedMaterials,
    required this.onRowSelected,
    required this.onCloseTap,
    required this.productTextController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (1.sh - .7.sh) / 2,
      left: (1.sw - .8.sw) / 2,
      child: Material(
        color: Colors.black.withOpacity(0.4), // Background overlay color
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Container(
            height: .7.sh,
            width: .8.sw,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: GetBuilder<MaterialController>(
              builder: (materialController) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(15),
                          child: PlutoGridWithAppBar(
                            title: 'اختيار مادة',
                            icon: Icons.close,
                            onIconPressed: onCloseTap,
                            tableSourceModels: searchedMaterials,
                            onLoaded: (PlutoGridOnLoadedEvent onLoadedEvent) {},
                            onSelected: onRowSelected,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextFieldWithIcon(
                          controller: productTextController,
                          onSubmitted: onSubmitted,
                          onIconPressed: () {},
                        ),
                      ),
                      const VerticalSpace(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
