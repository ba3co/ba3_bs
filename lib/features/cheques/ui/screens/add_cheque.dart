
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_spacer.dart';
import '../widgets/add_cheque_buttons.dart';
import '../widgets/add_cheque_form.dart';



class ChequesDetailsScreen extends StatefulWidget {
  final String? modelKey;

  const ChequesDetailsScreen({super.key, this.modelKey});

  @override
  State<ChequesDetailsScreen> createState() => _ChequesDetailsScreenState();
}

class _ChequesDetailsScreenState extends State<ChequesDetailsScreen> {

  var nameController = TextEditingController();
  var numberController = TextEditingController();
  var codeController = TextEditingController();
  var allAmountController = TextEditingController();
  var primaryController = TextEditingController();
  var secondaryController = TextEditingController();
  var bankController = TextEditingController();


  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text( "شيك جديد"),
          toolbarHeight: 100,
          actions: [
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("الحالة: "),
                        SizedBox(
                          width: 20,
                        ),
                        Text("not paid"),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("الرمز التسلسلي:"),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SizedBox(
                      width: 80,
                      child: CustomTextFieldWithoutIcon(
                        onChanged: (_) {}, textEditingController: codeController,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                    width: 50,
                  ),
                  const Text("النوع: "),
                  StatefulBuilder(builder: (context, setstae) {
                    return DropdownButton<String>(
                      value:
                      '',
                      items: [],
                      onChanged: (value) {

                      },
                    );
                  }),
                ]),
                const SizedBox(
                  height: 20,
                ),
                AddChequeForm(

                    secondaryController: secondaryController,
                    numberController: numberController,
                    codeController: codeController,
                    allAmountController: allAmountController,
                    bankController: bankController,
                    chequeType:
                    '',
                    primaryController: primaryController),
                const VerticalSpace(20),
                const Divider(),
                const VerticalSpace(20),
                AddChequeButtons(
                    secondaryController: secondaryController,
                    numberController: numberController,
                    codeController: codeController,
                    allAmountController: allAmountController,
                    bankController: bankController,
                    chequeType: 'chequeType',
                    primaryController: primaryController,
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
