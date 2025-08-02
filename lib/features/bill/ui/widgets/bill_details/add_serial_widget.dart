import 'package:flutter/material.dart';

import '../../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../materials/data/models/materials/material_model.dart';
import '../../../data/models/bill_items.dart';

class AddSerialWidget extends StatefulWidget {
  final IPlutoController plutoController;
  final int serialCount;
  final MaterialModel materialModel;
  final BillItem billItem;

  const AddSerialWidget({
    super.key,
    required this.plutoController,
    required this.serialCount,
    required this.materialModel,
    required this.billItem,
  });

  @override
  State<AddSerialWidget> createState() => _AddSerialWidgetState();
}

class _AddSerialWidgetState extends State<AddSerialWidget> {
  late final List<TextEditingController> serialsControllers;
  late final List<FocusNode> serialsFocusNodes;

  @override
  void initState() {
    widget.plutoController.initSerialControllers(
      widget.materialModel,
      widget.serialCount,
      widget.billItem,
    );

    serialsControllers = widget
        .plutoController.buyMaterialsSerialsControllers[widget.materialModel]!;

    serialsFocusNodes = List.generate(
      widget.serialCount,
          (index) => FocusNode(),
    );

    super.initState();
  }

  @override
  void dispose() {
    for (final node in serialsFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Serials'),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: serialsControllers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: serialsControllers[index],
              focusNode: serialsFocusNodes[index],
              textInputAction: index < serialsControllers.length - 1
                  ? TextInputAction.next
                  : TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Serial ${index + 1}',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (index < serialsControllers.length - 1) {
                  serialsFocusNodes[index + 1].requestFocus();
                } else {
                  serialsFocusNodes[index].unfocus();
                }
              },
            ),
          );
        },
      ),
    );
  }
}