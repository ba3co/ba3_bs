import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import '../../../controllers/bonds/bond_type_controller.dart';


class ColorsPicker extends StatelessWidget {
  const ColorsPicker({super.key, required this.bondTypeController});

  final BondTypeController bondTypeController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialColorPicker(
          allowShades: false,

          onMainColorChange: (ColorSwatch? color) {
            // ignore: deprecated_member_use
            bondTypeController.bondTypeFormHandler
                .onMainColorChanged(color?.value);
          },
          selectedColor: bondTypeController.bondTypeFormHandler.colorController.text.isNotEmpty? Color(int.parse(bondTypeController.bondTypeFormHandler.colorController.text)):null),
    );
  }
  
  
}
