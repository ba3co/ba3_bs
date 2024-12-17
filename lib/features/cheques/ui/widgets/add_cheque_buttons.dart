
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_button.dart';



class AddChequeButtons extends StatelessWidget {
  const AddChequeButtons({
    super.key,
    required this.secondaryController,
    required this.numberController,
    required this.codeController,
    required this.allAmountController,
    required this.bankController,
    required this.chequeType,
    required this.primaryController,
  });

  final TextEditingController secondaryController;
  final TextEditingController numberController;
  final TextEditingController codeController;
  final TextEditingController allAmountController;
  final TextEditingController bankController;
  final String chequeType;
  final TextEditingController primaryController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          onPressed: () async {

              }
            ,
          title:"إضافة",
          iconData:  Icons.add,
        ),

          const SizedBox(
            width: 50,
          ),
          AppButton(
            onPressed: () {

            },
            title: "حذف",
            iconData: Icons.delete_outline,
            color: Colors.red,
          ),
          const SizedBox(
            width: 50,
          ),
          AppButton(
            onPressed: () {


            },
            title: "السند",
            iconData: Icons.view_list_outlined,
          ),
          const SizedBox(
            width: 50,
          ),
          AppButton(
            onPressed: () async {

            },
            title: "دفع",
            color:Colors.black,
            iconData: Icons.paid,
          ),
          const SizedBox(
            width: 50,
          ),
          AppButton(
            onPressed: () {

            },
            title: "سند الدفع",
            iconData: Icons.view_list_outlined,
          ),
        ]

    );
  }
}
