import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/widgets/store_dropdown.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/customer/data/models/customer_model.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../accounts/data/models/account_model.dart';
import '../../../../floating_window/services/overlay_service.dart';
import '../../../../sellers/controllers/sellers_controller.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../data/models/bill_model.dart';
import '../bill_shared/bill_header_field.dart';
import '../bill_shared/form_field_row.dart';

class BillDetailsHeader extends StatelessWidget {
  const BillDetailsHeader({
    super.key,
    required this.billDetailsController,
    required this.billModel,
  });

  final BillDetailsController billDetailsController;
  final BillModel billModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: billDetailsController.formKey,
        child: Column(
          spacing: 5,
          children: [
            if (billModel.billTypeModel.latinShortName == 'Sales Delivery')
              FormFieldRow(
                firstItem: Obx(() {
                  return SearchableAccountField(
                    label: AppStrings.account.tr,
                    readOnly: billDetailsController.isAccountReadOnly.value,
                    textEditingController:
                        billDetailsController.billAccountController,
                    validator: (value) => billDetailsController.validator(
                        value, AppStrings.account.tr),
                    onSubmitted: (text) async {
                      AccountModel? accountModel =
                          await read<AccountsController>()
                              .openAccountSelectionDialog(
                        query: text,
                        context: context,
                      );
                      if (accountModel != null) {
                        billDetailsController.updateBillAccount(accountModel);
                      }
                    },
                  );
                }),
                secondItem: TextAndExpandedChildField(
                  label: AppStrings.status.tr,
                  child: Obx(() {
                    return OverlayService.showDropdown<Status>(
                      value: billDetailsController.selectedStatus.value,
                      items: billDetailsController
                              .selectedStatus.value.nextStatuses.isEmpty
                          ? [billModel.status]
                          : billModel.status.nextStatuses,
                      itemLabelBuilder: (status) {
                        switch (status) {
                          case Status.pending:
                            return 'قيد المعالجة';

                          case Status.deliveredToCourier:
                            return 'تم تسليم لشركة التوصيل';

                          case Status.deliveredToCustomer:
                            return 'تم التسليم للعميل';

                          case Status.canceled:
                            return 'تم رفض الطلب من قبل العميل';

                          case Status.returnedToStore:
                            return 'تم الإرجاع للمحل';

                          case Status.approved:
                            return 'منتهية';
                        }
                      },
                      onChanged: (selectedStatus) {
                        billDetailsController.updateStatus(
                            selectedStatus, context);
                      },
                      textStyle: const TextStyle(fontSize: 14),
                      height: AppConstants.constHeightDropDown,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onCloseCallback: () {},
                    );
                  }),
                ),
              ),
            if (billModel.billTypeModel.latinShortName != 'Sales Delivery')
              Obx(() {
                return SearchableAccountField(
                  label: AppStrings.account.tr,
                  readOnly: billDetailsController.isAccountReadOnly.value,
                  textEditingController:
                      billDetailsController.billAccountController,
                  validator: (value) => billDetailsController.validator(
                      value, AppStrings.account.tr),
                  onSubmitted: (text) async {
                    AccountModel? accountModel =
                        await read<AccountsController>()
                            .openAccountSelectionDialog(
                      query: text,
                      context: context,
                    );
                    if (accountModel != null) {
                      billDetailsController.updateBillAccount(accountModel);
                    }
                  },
                );
              }),
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: AppStrings.billType.tr,
                child: Obx(() {
                  final items =
                      billModel.billTypeModel.latinShortName == 'Sales Delivery'
                          ? InvPayType.values.where((type) {
                              return type != InvPayType.due &&
                                  type != InvPayType.cash;
                            }).toList()
                          : InvPayType.values.where((type) {
                              return type != InvPayType.dueDelivery &&
                                  type != InvPayType.bankTransferDelivery;
                            }).toList();
                  return OverlayService.showDropdown<InvPayType>(
                    value: billDetailsController.selectedPayType.value,
                    items: items,
                    itemLabelBuilder: (type) => type.label.tr,
                    onChanged: (selectedType) {
                      if (billModel.billTypeModel.billPatternType
                              ?.hasCashesAccount ??
                          true) {
                        billDetailsController.onPayTypeChanged(selectedType);
                      }
                    },
                    textStyle: const TextStyle(fontSize: 14),
                    height: AppConstants.constHeightDropDown,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onCloseCallback: () {},
                  );
                }),
              ),
              secondItem:
                  StoreDropdown(storeSelectionHandler: billDetailsController),
            ),
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: AppStrings.billDate.tr,
                child: Obx(() {
                  return DatePicker(
                    canEditeDate: false,
                    initDate: billDetailsController.billDate.value.dayMonthYear,
                    onDateSelected: (date) {
                      billDetailsController.setBillDate = date;
                    },
                  );
                }),
              ),
              secondItem: SearchableAccountField(
                label: AppStrings.customerAccount.tr,
                textEditingController:
                    billDetailsController.customerAccountController,
                // validator: (value) => billDetailsController.validator(value, AppStrings.customerAccount.tr),
                onSubmitted: (text) async {
                  CustomerModel? customerModel =
                      await read<AccountsController>()
                          .openCustomerSelectionDialog(
                    accountId: billDetailsController.selectedBillAccount?.id!,
                    query: text,
                    context: context,
                  );
                  if (customerModel != null) {
                    billDetailsController.updateCustomerAccount(
                        customerModel, billModel.billTypeModel);
                  }
                },
              ),
            ),
            FormFieldRow(
              firstItem: SearchableAccountField(
                label: AppStrings.seller.tr,
                readOnly: false,
                textEditingController:
                    billDetailsController.sellerAccountController,
                onSubmitted: (text) async {
                  SellerModel? sellerModel =
                      await read<SellersController>().openSellerSelectionDialog(
                    query: text,
                    context: context,
                  );
                  if (sellerModel != null) {
                    billDetailsController.updateSellerAccount(sellerModel);
                  }
                },
              ),
              secondItem: TextAndExpandedChildField(
                label: AppStrings.illustration.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.noteController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
            ),
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: AppStrings.phoneNumber.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController:
                      billDetailsController.customerPhoneController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
              secondItem: TextAndExpandedChildField(
                label: AppStrings.orderNumber.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController:
                      billDetailsController.orderNumberController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
            ),
            if (billModel.billTypeModel.latinShortName == 'Sales Delivery')
              Obx(() {
                return Column(children: [
                  if (billModel.billTypeModel.latinShortName ==
                          'Sales Delivery' &&
                      billDetailsController.scenario.value !=
                          VoucherScenario.none)
                    FormFieldRow(
                      firstItem: Obx(() {
                        final account = billDetailsController.fromAccount.value;

                        billDetailsController.fromAccountController.text =
                            account?.accName ?? '';

                        return SearchableAccountField(
                          label: "حساب الدائن",
                          readOnly: false,
                          textEditingController:
                              billDetailsController.fromAccountController,
                          onSubmitted: (text) async {
                            final acc = await read<AccountsController>()
                                .openAccountSelectionDialog(
                              query: text,
                              context: context,
                            );

                            if (acc != null) {
                              billDetailsController.fromAccount.value = acc;
                            }
                          },
                        );
                      }),
                      secondItem: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Obx(() {
                              final account =
                                  billDetailsController.toAccount1.value;

                              billDetailsController.toAccount1Controller.text =
                                  account?.accName ?? '';

                              return SearchableAccountField(
                                label: " حساب المدين الأول / المبلغ",
                                readOnly: false,
                                textEditingController:
                                    billDetailsController.toAccount1Controller,
                                onSubmitted: (text) async {
                                  final acc = await read<AccountsController>()
                                      .openAccountSelectionDialog(
                                    query: text,
                                    context: context,
                                  );

                                  if (acc != null) {
                                    billDetailsController.toAccount1.value =
                                        acc;
                                  }
                                },
                              );
                            }),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CustomTextFieldWithoutIcon(
                              textEditingController:
                                  billDetailsController.amount1Controller,
                              hint: Text('المبلغ'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 8),
                  if (billModel.billTypeModel.latinShortName ==
                          'Sales Delivery' &&
                      billDetailsController.scenario.value ==
                          VoucherScenario.approvedDueDelivery)
                    FormFieldRow(
                      firstItem: SizedBox(),
                      secondItem: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Obx(() {
                              final account =
                                  billDetailsController.toAccount2.value;

                              billDetailsController.toAccount2Controller.text =
                                  account?.accName ?? '';

                              return SearchableAccountField(
                                label: " حساب المدين الثاني / المبلغ",
                                readOnly: false,
                                textEditingController:
                                    billDetailsController.toAccount2Controller,
                                onSubmitted: (text) async {
                                  final acc = await read<AccountsController>()
                                      .openAccountSelectionDialog(
                                    query: text,
                                    context: context,
                                  );

                                  if (acc != null) {
                                    billDetailsController.toAccount2.value =
                                        acc;
                                  }
                                },
                              );
                            }),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CustomTextFieldWithoutIcon(
                              textEditingController:
                                  billDetailsController.amount2Controller,
                              hint: Text('المبلغ'),
                            ),
                          ),
                        ],
                      ),
                    )
                ]);
              })
          ],
        ),
      ),
    );
  }
}

extension StatusFlow on Status {
  List<Status> get nextStatuses {
    switch (this) {
      case Status.pending:
        return [Status.deliveredToCourier];

      case Status.deliveredToCourier:
        return [Status.deliveredToCustomer, Status.canceled];

      case Status.deliveredToCustomer:
        return [Status.approved];

      case Status.canceled:
        return [Status.returnedToStore];

      case Status.returnedToStore:
        return [Status.approved];

      case Status.approved:
        return [];
    }
  }
}
