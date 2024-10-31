import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/new_pluto.dart';
import '../../controllers/accounts_controller.dart';

class AllAccountScreen extends StatelessWidget {
  const AllAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountsController>(builder: (controller) {
      return CustomPlutoGridWithAppBar(
        title: 'جميع الحسابات',
        onLoaded: (e) {},
        onSelected: (p0) {},
        isLoading: controller.isLoading,
        tableSourceModels: controller.accounts,
      );
    });
  }
}
