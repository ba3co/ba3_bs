import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';

class AddSellerScreen extends StatelessWidget {
  const AddSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('بائع جديد'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              read<SellersController>().fetchAllSellersFromLocal();
            },
            child: Text('Add new sellers')),
      ),
    );
  }
}
