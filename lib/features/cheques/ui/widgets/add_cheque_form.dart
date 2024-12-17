import 'package:ba3_bs/features/cheques/ui/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/date_picker.dart';



class AddChequeForm extends StatefulWidget {
  const AddChequeForm(
      {super.key,
      required this.secondaryController,
      required this.numberController,
      required this.codeController,
      required this.allAmountController,
      required this.bankController,
      required this.chequeType,
      required this.primaryController});

  final TextEditingController secondaryController;
  final TextEditingController numberController;
  final TextEditingController codeController;
  final TextEditingController allAmountController;
  final TextEditingController bankController;
  final String chequeType;
  final TextEditingController primaryController;

  @override
  State<AddChequeForm> createState() => _AddChequeFormState();
}

class _AddChequeFormState extends State<AddChequeForm> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 20,
      children: [
        SizedBox(
          width: Get.width * .45,
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text("تاريخ التحرير"),
              ),
              Expanded(
                child: DatePicker(
                  initDate:DateTime.now().toIso8601String(),
               onDateSelected: (dateTime ) {  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: Get.width * .45,
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text("تاريخ الاستحقاق"),
              ),
              Expanded(
                child: DatePicker(
                  initDate: DateTime.now().toIso8601String(),
                 onDateSelected: (dateTime ) {  },
                ),
              ),
            ],
          ),
        ),
        TextForm(text: "رقم الشيك", controller: widget.numberController, onChanged: (_) {}),
        TextForm(
            text: "قيمة الشيك",
            controller: widget.allAmountController,
            onChanged: (_) {

            }),
        TextForm(
          text: "الحساب",
          controller: widget.primaryController,
          onFieldSubmitted: (value) async {},
        ),
        TextForm(
          text: "دفع إلى",
          controller: widget.secondaryController,
          onFieldSubmitted: (value) async {},
        ),
        TextForm(
          text: "حساب البنك",
          controller: widget.bankController,
          onFieldSubmitted: (value) async {},
        ),
      ],
    );
  }
}
