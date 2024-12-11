import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_layout/bond_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/bond_layout/bond_type_item_widget.dart';

class BondLayout extends StatelessWidget {
  const BondLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: bondLayoutAppBar(),
        body: ListView(
              padding: const EdgeInsets.all(15.0),
              children: [

                ...BondType.values.toList().map((bondType) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BondTypeItemWidget(
                      onPressed: () {
                        Get.lazyPut(() => BondDetailsController(), fenix: true);

                        Get.find<BondDetailsController>()..setBondType(bondType)..setIsDebitOrCredit()..navigateToBondDetails();
                      },
                      bond: bondType,
                    ),
                  );
                },),

              ],
            ),
      ),
    );
  }
}
