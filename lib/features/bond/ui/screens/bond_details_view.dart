import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/core/widgets/pluto_with_edite.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/service/EnterActionShortCut.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_details/bond_details_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../core/widgets/get_products_by_enter_action.dart';
import '../../../../core/widgets/pluto_short_cut.dart';
import '../../controllers/pluto/bond_record_pluto_controller.dart';

class BondDetailsView extends StatelessWidget {
  const BondDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<BondDetailsController>(builder: (bondDetailsController) {
          return Scaffold(
            appBar: AppBar(centerTitle: true, title: Text("سند ${bondDetailsController.bondType.label}"), leading: const BackButton(), actions: [
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
                    BondDetailsHeader(bondDetailsController: bondDetailsController),
                    Expanded(child: GetBuilder<BondRecordPlutoController>(builder: (bondController) {
                      return PlutoWithEdite(
                        columns: bondController.mainTableColumns,
                        rows: bondController.mainTableRows,
                        onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {
                          bondController.onRowSecondaryTap(event, context);
                        },
                        onChanged: bondController.onMainTableStateManagerChanged,
                        onLoaded: bondController.onMainTableLoaded,
                        shortCut: customPlutoShortcut(const EnterAction()),
                        evenRowColor: bondController.color,
                      );

                    })),
                    const VerticalSpace(),
                    GetBuilder<BondRecordPlutoController>(builder: (bondRecordPlutoController) {
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
                                Container(width: 120, color: bondRecordPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red, padding: const EdgeInsets.all(5), child: Text(bondRecordPlutoController.calcDebitTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                                const SizedBox(width: 10),
                                Container(width: 120, color: bondRecordPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red, padding: const EdgeInsets.all(5), child: Text(bondRecordPlutoController.calcCreditTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
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
                                Container(width: 250, color: bondRecordPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red, padding: const EdgeInsets.all(5), child: Text(bondRecordPlutoController.getDefBetweenCreditAndDebt().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                              ],
                            ),
                          ),
                          const Divider(),
                          Wrap(
                            spacing: 10,
                            runSpacing: 20,
                            children: [
                              AppButton(
                                title: "إضافة",
                                // title: bondController.isNew ? "" : "تعديل",
                                onPressed: () {
                                  // bool isDebitBond = widget.bondType == AppConstants.bondTypeDebit;
                                  // bool isCreditBond = widget.bondType == AppConstants.bondTypeCredit;
                                  // bool isBalancedBond =
                                  // plutoBondController.checkIfBalancedBond(isDebit: isDebitBond ? true : (isCreditBond ? false : null));
                                  // bool hasValidAccount = getAccountIdFromText(controller.debitOrCreditController.text) != "";
                                  // bool isDateValid = DateTime.tryParse(bondController.dateController.text) != null;
                                  // bool isDebitOrCreditWithAccount = (isDebitOrCredit) && hasValidAccount;
                                  //
                                  // bool isValidBondForSave = (plutoBondController
                                  //     .handleSaveAll(
                                  //   isCredit: isDebitBond ? false : (isCreditBond ? true : null),
                                  //   account: controller.debitOrCreditController.text,
                                  // )
                                  //     .length >
                                  //     1) &&
                                  //     isDateValid;
                                  //
                                  // if ((isDebitOrCreditWithAccount && isValidBondForSave) ||
                                  //     (!isDebitOrCredit && isBalancedBond && isValidBondForSave)) {
                                  //   if (bondController.isNew) {
                                  //     hasPermissionForOperation(AppConstants.roleUserWrite, AppConstants.roleViewBond).then((value) async {
                                  //       if (value) {
                                  //         await globalController.addGlobalBond(GlobalModel(
                                  //             bondCode: controller.codeController.text,
                                  //             bondDate: bondController.dateController.text,
                                  //             bondRecord: plutoBondController.handleSaveAll(
                                  //               isCredit: widget.bondType == AppConstants.bondTypeCredit
                                  //                   ? true
                                  //                   : widget.bondType == AppConstants.bondTypeDebit
                                  //                   ? false
                                  //                   : null,
                                  //               account: controller.debitOrCreditController.text,
                                  //             ),
                                  //             entryBondRecord: plutoBondController.handleSaveAllForEntry(
                                  //               isCredit: widget.bondType == AppConstants.bondTypeCredit
                                  //                   ? true
                                  //                   : widget.bondType == AppConstants.bondTypeDebit
                                  //                   ? false
                                  //                   : null,
                                  //               account: controller.debitOrCreditController.text,
                                  //             ),
                                  //             bondDescription: bondController.noteController.text,
                                  //             bondType: widget.bondType,
                                  //             bondTotal: "0"));
                                  //         bondController.isNew = false;
                                  //         controller.isEdit = false;
                                  //       }
                                  //     });
                                  //   } else {
                                  //     hasPermissionForOperation(AppConstants.roleUserUpdate, AppConstants.roleViewBond).then((value) async {
                                  //       if (value) {
                                  //         bondController.isNew = false;
                                  //         controller.isEdit = false;
                                  //         GlobalModel newGlobal = GlobalModel(
                                  //             entryBondCode: controller.tempBondModel.entryBondCode,
                                  //             entryBondRecord: plutoBondController.handleSaveAllForEntry(
                                  //               isCredit: widget.bondType == AppConstants.bondTypeCredit
                                  //                   ? true
                                  //                   : widget.bondType == AppConstants.bondTypeDebit
                                  //                   ? false
                                  //                   : null,
                                  //               account: controller.debitOrCreditController.text,
                                  //             ),
                                  //             bondCode: controller.tempBondModel.bondCode,
                                  //             globalType: AppConstants.globalTypeBond,
                                  //             entryBondId: controller.tempBondModel.entryBondId,
                                  //             bondDate: bondController.dateController.text,
                                  //             bondRecord: plutoBondController.handleSaveAll(
                                  //               isCredit: widget.bondType == AppConstants.bondTypeCredit
                                  //                   ? true
                                  //                   : widget.bondType == AppConstants.bondTypeDebit
                                  //                   ? false
                                  //                   : null,
                                  //               account: controller.debitOrCreditController.text,
                                  //             ),
                                  //             bondId: controller.tempBondModel.bondId,
                                  //             bondDescription: bondController.noteController.text,
                                  //             bondType: widget.bondType,
                                  //             bondTotal: "0");
                                  //         sendEmailWithPdfAttachment(newGlobal, true, update: true, invoiceOld: controller.tempBondModel);
                                  //         await globalController.updateGlobalBond(newGlobal);
                                  //       }
                                  //     });
                                  //   }
                                  // } else {
                                  //   Get.snackbar("خطأ", "يرجى مراجعة السند", icon: const Icon(Icons.error_outline_outlined));
                                  // }


                                  print(bondRecordPlutoController.generateBondRecords.toJson());
                                },
                                // iconData: bondController.isNew ? Icons.add : Icons.edit,
                                iconData:Icons.add ,
                              ),
                              AppButton(
                                  title: "جديد",
                                  onPressed: () {
                                    // bondDetailsController.initPage();
                                  },
                                  iconData: Icons.new_label_outlined),
/*
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
*/
                            ],
                          ),
                        ],

                      );
                    }),

                  ],
                ),
              ),
            ),
          );
        }));
  }
}
