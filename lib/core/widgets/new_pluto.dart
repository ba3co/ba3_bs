import 'dart:developer';

import 'package:ba3_bs/features/patterns/controllers/pattern_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/patterns/controllers/pluto_controller.dart';

class CustomPlutoGridWithAppBar extends StatelessWidget {
  const CustomPlutoGridWithAppBar(
      {super.key,
      required this.onLoaded,
      required this.onSelected,
      this.onRowDoubleTap,
      required this.title,
      this.type,
      this.isLoading = false});

  final Function(PlutoGridOnLoadedEvent) onLoaded;

  final Function(PlutoGridOnRowDoubleTapEvent)? onRowDoubleTap;
  final Function(PlutoGridOnSelectedEvent) onSelected;

  final String title;
  final String? type;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    var patternController = Get.find<PatternController>();
    log('lengtf ${patternController.billsTypes.length}');
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: GetBuilder<PlutoController>(builder: (controller) {
              return Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text(title),
                    actions: [
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('عدد العناصر المتأثرة: ${patternController.billsTypes.length}')),
                    ],
                  ),
                  body: isLoading
                      ? const SizedBox()
                      : PlutoGrid(
                          key: controller.plutoKey,
                          onLoaded: (event) {
                            log('onLoaded');
                            event.stateManager.setShowColumnFilter(true);
                          },
                          onSelected: onSelected,
                          columns: controller.getColumns(patternController.billsTypes, type: type),
                          rows: controller.getRows(patternController.billsTypes, type: type),
                          mode: PlutoGridMode.selectWithOneTap,
                          configuration: PlutoGridConfiguration(
                            shortcut: const PlutoGridShortcut(),
                            style: PlutoGridStyleConfig(
                              enableRowColorAnimation: true,
                              evenRowColor: Colors.blueAccent.withOpacity(0.5),
                              columnTextStyle:
                                  const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                              activatedColor: Colors.white.withOpacity(0.5),
                              cellTextStyle:
                                  const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              gridPopupBorderRadius: const BorderRadius.all(Radius.circular(15)),
                              gridBorderRadius: const BorderRadius.all(Radius.circular(15)),
                              // gridBorderColor: Colors.transparent,
                            ),
                            localeText: const PlutoGridLocaleText.arabic(),
                          ),
                          createFooter: (stateManager) {
                            stateManager.setPageSize(100, notify: false); // default 40

                            return PlutoPagination(stateManager);
                          },
                        ));
            }),
          ),
        ),
      ],
    );
  }
}
