import 'dart:developer';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';
import '../interfaces/i_store_selection_handler.dart';

class StoreDropdown extends StatelessWidget {
  const StoreDropdown({super.key, required this.storeSelectionHandler, this.width});

  final IStoreSelectionHandler storeSelectionHandler;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return TextAndExpandedChildField(
      label: AppStrings.store.tr,
      child: Obx(() {
        return OverlayService.showDropdown<StoreAccount>(
          value: storeSelectionHandler.selectedStore.value,
          items: StoreAccount.values,
          onChanged: storeSelectionHandler.onSelectedStoreChanged,
          itemLabelBuilder: (store) => store.value.tr,
          textStyle: const TextStyle(fontSize: 14),
          height: AppConstants.constHeightDropDown,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(5),
          ),
          onCloseCallback: () {
            log('StoreAccount Dropdown Overly Closed.');
          },
        );
      }),
    );
    /*  return SizedBox(
      width: width ?? Get.width * 0.45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
              width: 150,
              child: Text(
                AppStrings.store.tr,
              )),
          Expanded(
            child: Container(
              width: (Get.width * 0.45) - 100,
              height: AppConstants.constHeightDropDown,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Obx(() {
                return OverlayService.showDropdown<StoreAccount>(
                  value: storeSelectionHandler.selectedStore.value,
                  items: StoreAccount.values,
                  onChanged: storeSelectionHandler.onSelectedStoreChanged,
                  textStyle: const TextStyle(fontSize: 12),
                  itemLabelBuilder: (store) => store.value.tr,
                  height: AppConstants.constHeightTextField,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onCloseCallback: () {
                    log('StoreAccount Dropdown Overly Closed.');
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );*/
  }
}
