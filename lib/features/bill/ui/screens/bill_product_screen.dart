import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class BillProductsScreen extends StatelessWidget {
  const BillProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.billProductView),
      ),
      body: Center(
        child: Text('Bill Product View'),
      ),
    );
  }
}