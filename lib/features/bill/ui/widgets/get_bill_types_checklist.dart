import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_checklist.dart';
import '../../../patterns/controllers/pattern_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';

class BillTypesChecklist extends StatelessWidget {
  BillTypesChecklist({
    super.key,
    required this.onItemSelected,
    required this.onItemDeselected,
  });

  final PatternController controller = Get.find<PatternController>();


  final void Function(String item) onItemSelected;
  final void Function(String item) onItemDeselected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BillTypeModel>>(
      future: controller.getAllBillTypes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No bill types found"));
        }

        final billTypes = snapshot.data!;

        return CustomChecklist(
          items: billTypes
              .where((e) => e.fullName != null && e.fullName!.isNotEmpty) // keep only valid names
              .map((e) => e.fullName!) // safe unwrap
              .toList(),
          onItemSelected: onItemSelected,
          onItemDeselected: onItemDeselected,
        );
      },
    );
  }
}
