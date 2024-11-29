import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';
import '../interfaces/i_store_selection_handler.dart';

class StoreDropdown extends StatelessWidget {
  const StoreDropdown({super.key, required this.storeSelectionHandler, this.width});

  final IStoreSelectionHandler storeSelectionHandler;

  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? Get.width * 0.45,
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('المستودع')),
          Expanded(
            child: Container(
                width: (Get.width * 0.45) - 100,
                height: AppConstants.constHeightTextField,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: DropdownButton(
                  dropdownColor: Colors.white,
                  focusColor: Colors.white,
                  alignment: Alignment.center,
                  underline: const SizedBox(),
                  isExpanded: true,
                  value: storeSelectionHandler.selectedStore,
                  items: StoreAccount.values.map((StoreAccount store) {
                    return DropdownMenuItem<StoreAccount>(
                      value: store,
                      child: Center(
                        child: Text(store.value, textDirection: TextDirection.rtl),
                      ),
                    );
                  }).toList(),
                  onChanged: storeSelectionHandler.onSelectedStoreChanged,
                )),
          ),
        ],
      ),
    );
  }
}
