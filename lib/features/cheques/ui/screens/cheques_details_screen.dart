import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_details/cheques_details_app_bar.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_details/cheques_details_body.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_details/cheques_details_buttons.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_details/cheques_details_calculations.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_details/cheques_details_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cheques/cheques_details_controller.dart';
import '../../controllers/cheques/cheques_search_controller.dart';

class ChequesDetailsScreen extends StatelessWidget {
  const ChequesDetailsScreen({
    super.key,
    required this.fromChequesById,
    required this.chequesDetailsController,
    required this.chequesSearchController,
    required this.tag,
  });

  final bool fromChequesById;
  final ChequesDetailsController chequesDetailsController;
  final ChequesSearchController chequesSearchController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChequesSearchController>(
        tag: tag,
        builder: (_) {
          final ChequesModel currentCheques = chequesSearchController.getCurrentCheques;

          return GetBuilder<ChequesDetailsController>(
              tag: tag,
              builder: (_) {
                return Scaffold(
                  appBar: ChequesDetailsAppBar(
                      chequesDetailsController: chequesDetailsController,
                      chequesSearchController: chequesSearchController,
                      chequesTypeModel: ChequesType.byTypeGuide(currentCheques.checkTypeGuid!)),
                  body: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ChequesDetailsHeader(
                            chequesDetailsController: chequesDetailsController,
                          ),
                          ChequesDetailsBody(
                            chequesTypeModel: ChequesType.byTypeGuide(currentCheques.checkTypeGuid!),
                          ),
                          ChequesDetailsCalculations(
                            tag: tag,
                          ),
                          ChequesDetailsButtons(
                            chequesDetailsController: chequesDetailsController,
                            chequesModel: currentCheques,
                            fromChequesById: fromChequesById,
                            chequesSearchController: chequesSearchController,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
