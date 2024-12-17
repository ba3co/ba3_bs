import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/cheques_search_controller.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_details/cheques_details_app_bar.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_details/cheques_details_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_spacer.dart';
import '../widgets/cheques_details/cheques_details_body_form.dart';
import '../widgets/cheques_details/cheques_details_buttons.dart';

class ChequesDetailsScreen extends StatelessWidget {
  final String tag;
  final ChequesType chequesTypeModel;
  final ChequesDetailsController chequesDetailsController;
  final ChequesSearchController chequesSearchController;

  const ChequesDetailsScreen({super.key, required this.tag, required this.chequesTypeModel, required this.chequesDetailsController, required this.chequesSearchController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChequesSearchController>(
        tag: tag,
        builder: (_) {
          return GetBuilder<ChequesDetailsController>(
              tag: tag,
              builder: (_) {
                return Scaffold(
                  appBar: ChequesDetailsAppBar(
                    chequesDetailsController: chequesDetailsController,
                    chequesSearchController: chequesSearchController,
                    chequesTypeModel: chequesTypeModel,
                  ),
                  body: Column(
                    children: [
                      const ChequesDetailsHeader(),
                      const VerticalSpace(),
                      AddChequeForm(
                        chequesDetailsController: chequesDetailsController,
                      ),
                      const VerticalSpace(),
                      const Divider(),
                      const VerticalSpace(),
                      const AddChequeButtons(),
                    ],
                  ),
                );
              });
        });
  }
}
