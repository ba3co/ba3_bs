import 'package:ba3_bs/features/bond/controllers/bond_record_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';

class BondDetailsView extends StatelessWidget {
  const BondDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child:
         Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text(""),
              leading: const BackButton(),
              actions: [
                IconButton(
                    onPressed: () {
                      // bondController.bondNextOrPrev(widget.bondType, true);
                      // setState(() {});
                    },
                    icon: const Icon(Icons.keyboard_double_arrow_right)),
                SizedBox(
                  width: 100,
                  child: CustomTextFieldWithoutIcon(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) {
                      // controller.getBondByCode(widget.bondType, _);
                    },
                     textEditingController: TextEditingController(),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      // bondController.bondNextOrPrev(widget.bondType, false);
                    },
                    icon: const Icon(Icons.keyboard_double_arrow_left)),
              ]),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: Get.width,
                    child: Wrap(
                      spacing: 20,
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: Get.width * 0.45,
                          child: Row(
                            children: [
                              const SizedBox(width: 100, child: Text("البيان")),
                              Expanded(
                                child: CustomTextFieldWithoutIcon(textEditingController: TextEditingController(),),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.45,
                          child: Row(
                            children: [
                              const SizedBox(width: 100, child: Text("تاريخ السند : ", style: TextStyle())),
                              Expanded(
                                child: CustomTextFieldWithIcon(
                                  textEditingController: TextEditingController(),
                                  onSubmitted: (text) async {
                                    // controller.dateController.text = getDateFromString(text);
                                    // controller.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (true)
                          SizedBox(
                            width: Get.width * 0.45,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 100,
                                  child: Text(
                                    "الحساب : ",
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextFieldWithIcon(
                                    onSubmitted: (text) async {
                                      // controller.debitOrCreditController.text = await searchAccountTextDialog(text) ?? "";
                                      // invoiceController.getAccountComplete();
                                      // invoiceController.changeSecAccount();
                                    }, textEditingController: TextEditingController(),
                                  ),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Expanded(child: GetBuilder<BondRecordPlutoController>(builder: (controller) {
                  //   return CustomPlutoWithEdite(
                  //     controller: controller,
                  //     shortCut: customPlutoShortcut(GetAccountEnterPlutoGridAction(controller, "bondRecAccount")),
                  //     onRowSecondaryTap: (event) {
                  //       if (event.cell.column.field == "bondRecId") {
                  //         Get.defaultDialog(title: "تأكيد الحذف", content: const Text("هل انت متأكد من حذف هذا العنصر"), actions: [
                  //           AppButton(
                  //               title: "نعم",
                  //               onPressed: () {
                  //                 controller.clearRowIndex(event.rowIdx);
                  //               },
                  //               iconData: Icons.check),
                  //           AppButton(
                  //             title: "لا",
                  //             onPressed: () {
                  //               Get.back();
                  //             },
                  //             iconData: Icons.clear,
                  //             color: Colors.red,
                  //           ),
                  //         ]);
                  //       }
                  //     },
                  //     onChanged: (event) {
                  //       if (event.column.field == "bondRecDebitAmount") {
                  //         controller.updateCellValue(
                  //             "bondRecDebitAmount", extractNumbersAndCalculate(event.row.cells["bondRecDebitAmount"]?.value));
                  //         if (widget.bondType != AppConstants.bondTypeDebit && widget.bondType != AppConstants.bondTypeCredit) {
                  //           if ((double.tryParse(event.row.cells["bondRecCreditAmount"]?.value) ?? 0) > 0) {
                  //             controller.updateCellValue("bondRecCreditAmount", "");
                  //           }
                  //         }
                  //       } else if (event.column.field == "bondRecCreditAmount") {
                  //         controller.updateCellValue(
                  //             "bondRecCreditAmount", extractNumbersAndCalculate(event.row.cells["bondRecCreditAmount"]?.value));
                  //         if (widget.bondType != AppConstants.bondTypeDebit && widget.bondType != AppConstants.bondTypeCredit) {
                  //           if ((double.tryParse(event.row.cells["bondRecDebitAmount"]?.value) ?? 0) > 0) {
                  //             controller.updateCellValue("bondRecDebitAmount", "");
                  //           }
                  //         }
                  //       }
                  //     },
                  //   );
                  // })),
                  const SizedBox(
                    height: 10,
                  ),
               /*   GetBuilder<BondRecordPlutoViewModel>(builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 350,
                          child: Row(
                            children: [
                              const SizedBox(
                                  width: 100,
                                  child: Text(
                                    "المجموع",
                                  )),
                              Container(
                                  width: 120,
                                  color: controller.checkIfBalancedBond(
                                    isDebit: widget.bondType == AppConstants.bondTypeDebit
                                        ? true
                                        : widget.bondType == AppConstants.bondTypeCredit
                                        ? false
                                        : null,
                                  )
                                      ? Colors.green
                                      : Colors.red,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      controller
                                          .calcDebitTotal(
                                        isDebit: widget.bondType == AppConstants.bondTypeDebit
                                            ? true
                                            : widget.bondType == AppConstants.bondTypeCredit
                                            ? false
                                            : null,
                                      )
                                          .toStringAsFixed(2),
                                      style: const TextStyle(color: Colors.white, fontSize: 18))),
                              const SizedBox(width: 10),
                              Container(
                                  width: 120,
                                  color: controller.checkIfBalancedBond(
                                    isDebit: widget.bondType == AppConstants.bondTypeDebit
                                        ? true
                                        : widget.bondType == AppConstants.bondTypeCredit
                                        ? false
                                        : null,
                                  )
                                      ? Colors.green
                                      : Colors.red,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      controller
                                          .calcCreditTotal(
                                        isDebit: widget.bondType == AppConstants.bondTypeDebit
                                            ? true
                                            : widget.bondType == AppConstants.bondTypeCredit
                                            ? false
                                            : null,
                                      )
                                          .toStringAsFixed(2),
                                      style: const TextStyle(color: Colors.white, fontSize: 18))),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 350,
                          child: Row(
                            children: [
                              const SizedBox(width: 100, child: Text("الفرق")),
                              Container(
                                  width: 250,
                                  color: controller.checkIfBalancedBond(
                                    isDebit: widget.bondType == AppConstants.bondTypeDebit
                                        ? true
                                        : widget.bondType == AppConstants.bondTypeCredit
                                        ? false
                                        : null,
                                  )
                                      ? Colors.green
                                      : Colors.red,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      controller
                                          .getDefBetweenCreditAndDebt(
                                        isDebit: widget.bondType == AppConstants.bondTypeDebit
                                            ? true
                                            : widget.bondType == AppConstants.bondTypeCredit
                                            ? false
                                            : null,
                                      )
                                          .toStringAsFixed(2),
                                      style: const TextStyle(color: Colors.white, fontSize: 18))),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  const Divider(),
                  Wrap(
                    spacing: 10,
                    runSpacing: 20,
                    children: [
                      AppButton(
                          title: bondController.isNew ? "إضافة" : "تعديل",
                          onPressed: () {
                            bool isDebitBond = widget.bondType == AppConstants.bondTypeDebit;
                            bool isCreditBond = widget.bondType == AppConstants.bondTypeCredit;
                            bool isBalancedBond =
                            plutoBondController.checkIfBalancedBond(isDebit: isDebitBond ? true : (isCreditBond ? false : null));
                            bool hasValidAccount = getAccountIdFromText(controller.debitOrCreditController.text) != "";
                            bool isDateValid = DateTime.tryParse(bondController.dateController.text) != null;
                            bool isDebitOrCreditWithAccount = (isDebitOrCredit) && hasValidAccount;

                            bool isValidBondForSave = (plutoBondController
                                .handleSaveAll(
                              isCredit: isDebitBond ? false : (isCreditBond ? true : null),
                              account: controller.debitOrCreditController.text,
                            )
                                .length >
                                1) &&
                                isDateValid;

                            if ((isDebitOrCreditWithAccount && isValidBondForSave) ||
                                (!isDebitOrCredit && isBalancedBond && isValidBondForSave)) {
                              if (bondController.isNew) {
                                hasPermissionForOperation(AppConstants.roleUserWrite, AppConstants.roleViewBond).then((value) async {
                                  if (value) {
                                    await globalController.addGlobalBond(GlobalModel(
                                        bondCode: controller.codeController.text,
                                        bondDate: bondController.dateController.text,
                                        bondRecord: plutoBondController.handleSaveAll(
                                          isCredit: widget.bondType == AppConstants.bondTypeCredit
                                              ? true
                                              : widget.bondType == AppConstants.bondTypeDebit
                                              ? false
                                              : null,
                                          account: controller.debitOrCreditController.text,
                                        ),
                                        entryBondRecord: plutoBondController.handleSaveAllForEntry(
                                          isCredit: widget.bondType == AppConstants.bondTypeCredit
                                              ? true
                                              : widget.bondType == AppConstants.bondTypeDebit
                                              ? false
                                              : null,
                                          account: controller.debitOrCreditController.text,
                                        ),
                                        bondDescription: bondController.noteController.text,
                                        bondType: widget.bondType,
                                        bondTotal: "0"));
                                    bondController.isNew = false;
                                    controller.isEdit = false;
                                  }
                                });
                              } else {
                                hasPermissionForOperation(AppConstants.roleUserUpdate, AppConstants.roleViewBond).then((value) async {
                                  if (value) {
                                    bondController.isNew = false;
                                    controller.isEdit = false;
                                    GlobalModel newGlobal = GlobalModel(
                                        entryBondCode: controller.tempBondModel.entryBondCode,
                                        entryBondRecord: plutoBondController.handleSaveAllForEntry(
                                          isCredit: widget.bondType == AppConstants.bondTypeCredit
                                              ? true
                                              : widget.bondType == AppConstants.bondTypeDebit
                                              ? false
                                              : null,
                                          account: controller.debitOrCreditController.text,
                                        ),
                                        bondCode: controller.tempBondModel.bondCode,
                                        globalType: AppConstants.globalTypeBond,
                                        entryBondId: controller.tempBondModel.entryBondId,
                                        bondDate: bondController.dateController.text,
                                        bondRecord: plutoBondController.handleSaveAll(
                                          isCredit: widget.bondType == AppConstants.bondTypeCredit
                                              ? true
                                              : widget.bondType == AppConstants.bondTypeDebit
                                              ? false
                                              : null,
                                          account: controller.debitOrCreditController.text,
                                        ),
                                        bondId: controller.tempBondModel.bondId,
                                        bondDescription: bondController.noteController.text,
                                        bondType: widget.bondType,
                                        bondTotal: "0");
                                    sendEmailWithPdfAttachment(newGlobal, true, update: true, invoiceOld: controller.tempBondModel);
                                    await globalController.updateGlobalBond(newGlobal);
                                  }
                                });
                              }
                            } else {
                              Get.snackbar("خطأ", "يرجى مراجعة السند", icon: const Icon(Icons.error_outline_outlined));
                            }
                          },
                          iconData: bondController.isNew ? Icons.add : Icons.edit),
                      AppButton(
                          title: "جديد",
                          onPressed: () {
                            controller.initPage(type: widget.bondType);
                          },
                          iconData: Icons.new_label_outlined),
                      if (!bondController.isNew && controller.bondModel.originId == null) ...[
                        AppButton(
                          title: "حذف",
                          onPressed: () async {
                            confirmDeleteWidget().then((value) {
                              if (value) {
                                hasPermissionForOperation(AppConstants.roleUserDelete, AppConstants.roleViewBond).then((value) async {
                                  if (value) {
                                    globalController.deleteGlobal(bondController.tempBondModel);
                                    Get.back();
                                    controller.update();
                                  }
                                });
                              }
                            });
                          },
                          iconData: Icons.delete_outline,
                          color: Colors.red,
                        ),
                        AppButton(
                            title: "السند",
                            onPressed: () {
                              Get.to(() => EntryBondDetailsView(
                                oldId: controller.tempBondModel.entryBondId,
                              ));
                              // EntryBond
                            },
                            iconData: Icons.file_open_outlined)
                      ]
                    ],
                  ),*/
                ],
              ),
            ),
          ),
        )
    );
  }
}
