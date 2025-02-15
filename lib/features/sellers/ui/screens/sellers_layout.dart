import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';
import '../../../users_management/data/models/role_model.dart';

class SellersLayout extends StatelessWidget {
  const SellersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerSalesController sellerSalesController = read<SellerSalesController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.sellers),
        actions: [
          if (RoleItemType.administrator.hasReadPermission)
            Padding(
              padding: EdgeInsets.all(5),
              child: AppButton(
                  title: '${AppStrings.download} ${AppStrings.sellers}', onPressed: () => read<SellersController>().fetchAllSellersFromLocal()),
            )
        ],
      ),
      body: Column(
        children: [
          AppMenuItem(
              text: '${AppStrings.add} ${AppStrings.sellers}',
              onTap: () {
                sellerSalesController.navigateToAddSellerScreen();
              }),
          AppMenuItem(
              text: '${AppStrings.view} ${AppStrings.sellers}',
              onTap: () {
                sellerSalesController.navigateToAllSellersScreen();
              }),
        ],
      ),
    );
  }
}
