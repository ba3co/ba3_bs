import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_layout/cheques_item_widget.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_layout/cheques_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ChequeLayout extends StatelessWidget {
  const ChequeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<AllChequesController>(builder: (controller) {
        return Scaffold(
          appBar: chequesLayoutAppBar(context),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrganizedWidget(
              titleWidget: Row(
                children: [
                  Align(
                    child: Text(
                      AppStrings.cheques.tr,
                      style: AppTextStyles.headLineStyle2
                          .copyWith(color: AppColors.blueColor),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    tooltip: AppStrings.refresh.tr,
                    icon: Icon(
                      FontAwesomeIcons.refresh,
                      color: AppColors.lightBlueColor,
                    ),
                    onPressed: controller.refreshChequesTypes,
                  ),
                ],
              ),
              bodyWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ChequesType.values.map(
                      (chequesType) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChequesItemWidget(
                            chequesController: controller,
                            onNewTap: () {
                              controller.openFloatingChequesDetails(
                                context,
                                chequesType,
                                withFetched: true,
                              );
                            },
                            chequesType: chequesType,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
