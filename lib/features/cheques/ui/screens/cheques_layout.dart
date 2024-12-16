import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_layout/cheques_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../controllers/cheques/all_cheques_controller.dart';
import '../widgets/cheques_layout/cheques_type_item_widget.dart';


class ChequesLayout extends StatelessWidget {
  const ChequesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: chequesLayoutAppBar(),
      body: GetBuilder<AllChequesController>(builder: (controller) {
        return ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            ...ChequesType.values.toList().map(
              (chequesType) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChequesTypeItemWidget(
                    onPressed: () {
                      controller.openFloatingChequesDetails(context, chequesType);
                    },
                    cheques: chequesType,
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
