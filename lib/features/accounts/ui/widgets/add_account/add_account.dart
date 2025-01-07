import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({super.key});

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بطاقة حساب"),
        actions: [
          Container(
            width: Get.width * 0.3,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Flexible(flex: 3, child: Text("رمز الحساب: ")),
                Flexible(flex: 3, child: CustomTextFieldWithoutIcon(textEditingController: TextEditingController(),)),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Flexible(flex: 2, child: Text("اسم الحساب :")),
                        Flexible(flex: 3, child: CustomTextFieldWithoutIcon(textEditingController: TextEditingController())),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Flexible(flex: 2, child: Text("نوع الحساب :")),
                        Flexible(
                            flex: 3,
                            child: DropdownButton(

                              items: AppConstants.accountTypeList
                                  .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text('e'),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {});

                              },
                            ),



                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Flexible(flex: 1, child: Text("ملاحظات:")),
                  Flexible(flex: 3, child: CustomTextFieldWithoutIcon(textEditingController: TextEditingController())),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("الحساب الاب"),
                  const SizedBox(
                    width: 30,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("حساب اب"),
                      const SizedBox(
                        width: 30,
                      ),

                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: AppButton(
                      onPressed: () async {


                      },
                      title: "تعديل ",
                      iconData: Icons.edit,
                    ),
                  ),

                ],
              ),


            ],
          ),
        ),
      ),
    );
  }



  }
