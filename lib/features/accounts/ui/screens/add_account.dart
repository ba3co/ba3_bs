import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../core/widgets/pluto_with_edite.dart';
import '../../controllers/accounts_controller.dart';
import '../../controllers/customer_pluto_edit_contoller.dart';

class AddAccount extends StatelessWidget {
  AddAccount({super.key});

  final TextEditingController nameController = TextEditingController();

  late final String? accountType;

  final TextEditingController notesController = TextEditingController();

  final TextEditingController codeController = TextEditingController();

  final TextEditingController idController = TextEditingController();

  // TextEditingController accVatController = TextEditingController();
  late final String? accVat;

  final TextEditingController accParentId = TextEditingController();

  final bool accIsRoot = true;

  final AccountModel accountModel = AccountModel();

  final bool isNew = true;

  @override
  Widget build(BuildContext context) {
    CustomerPlutoEditController customerPlutoEditViewModel = Get.find<CustomerPlutoEditController>();

    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("بطاقة حساب"),
                actions: [
                  Container(
                    width: Get.width * 0.3,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const Flexible(flex: 3, child: Text("رمز الحساب: ")),
                        Flexible(flex: 3, child: CustomTextFieldWithoutIcon(textEditingController: codeController)),
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
                                Flexible(
                                    flex: 3, child: CustomTextFieldWithoutIcon(textEditingController: nameController)),
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
                                    child: StatefulBuilder(builder: (context, setstae) {
                                      return DropdownButton(
                                        value: accountType,
                                        items: AppConstants.accountTypeList
                                            .map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(getAccountTypeFromEnum(e)),
                                                ))
                                            .toList(),
                                        onChanged: (value) {},
                                      );
                                    })),
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
                          Flexible(flex: 3, child: CustomTextFieldWithoutIcon(textEditingController: notesController)),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("الحساب الاب"),
                          const SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                            width: 300,
                            child: IgnorePointer(
                              ignoring: accIsRoot,
                              child: SizedBox(
                                width: 300,
                                child: TextFormField(
                                  controller: accParentId,
                                  decoration: const InputDecoration(fillColor: Colors.white, filled: true),
                                  onFieldSubmitted: (_) async {},
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("حساب اب"),
                              const SizedBox(
                                width: 30,
                              ),
                              SizedBox(
                                width: 30,
                                height: 100,
                                child: Checkbox(
                                  value: accIsRoot,
                                  onChanged: (_) {},
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: GetBuilder<AccountsController>(builder: (accountController) {
                              return AppButton(
                                onPressed: () async {},
                                title: accountModel.id == null ? "إضافة " : "تعديل ",
                                iconData: accountModel.id == null ? Icons.add : Icons.edit,
                              );
                            }),
                          ),
                          if (accountModel.id != null)
                            Container(
                              alignment: Alignment.center,
                              child: GetBuilder<AccountsController>(builder: (accountController) {
                                return AppButton(
                                  onPressed: () async {},
                                  title: "الزبائن",
                                  iconData: Icons.person,
                                  color: Colors.green,
                                );
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        // flex: 3,
                        child: GetBuilder<CustomerPlutoEditController>(builder: (logic) {
                          return SizedBox(
                            height: 400,
                            width: Get.width,
                            child: PlutoWithEdite(
                              evenRowColor: Colors.green.shade200,
                              onChanged: (PlutoGridOnChangedEvent event) {},
                              onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {},
                              columns: customerPlutoEditViewModel.columns,
                              rows: customerPlutoEditViewModel.rows,
                              onLoaded: (PlutoGridOnLoadedEvent event) {},
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String getAccountTypeFromEnum(String type) {
  switch (type) {
    case AppConstants.accountTypeDefault:
      return "حساب عادي";
    case AppConstants.accountTypeFinalAccount:
      return "حساب ختامي";
    case AppConstants.accountTypeAggregateAccount:
      return "حساب تجميعي";
  }
  return "error";
}
