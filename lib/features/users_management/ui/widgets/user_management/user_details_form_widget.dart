import 'dart:developer';

import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../sellers/controllers/sellers_controller.dart';
import '../../../controllers/user_management_controller.dart';

class UserDetailsForm extends StatelessWidget {
  const UserDetailsForm({
    super.key,
    required this.userDetailsController,
    required this.sellerController,
  });

  final UserDetailsController userDetailsController;
  final SellersController sellerController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
            child: Text(
              AppStrings.userInformation.tr,
          style: AppTextStyles.headLineStyle2,
        )),
        bodyWidget: Form(
          key: userDetailsController.userFormHandler.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [
              FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: AppStrings.userName.tr,
                  height: 70,
                  child: CustomTextFieldWithoutIcon(
                    height: 70,
                    filedColor: AppColors.backGroundColor,
                    validator: (value) => userDetailsController.userFormHandler.defaultValidator(value, 'اسم الحساب'),
                    textEditingController: userDetailsController.userFormHandler.userNameController,
                    suffixIcon: const SizedBox.shrink(),
                  ),
                ),
                secondItem: TextAndExpandedChildField(
                  label: AppStrings.password.tr,
                  height: 70,
                  child: CustomTextFieldWithoutIcon(
                    height: 70,
                    filedColor: AppColors.backGroundColor,
                    validator: (value) => userDetailsController.userFormHandler.passwordValidator(value, 'كلمة السر'),
                    textEditingController: userDetailsController.userFormHandler.passController,
                    suffixIcon: const SizedBox.shrink(),
                    maxLength: 6,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                ),
              ),
              FormFieldRow(

                  firstItem: TextAndExpandedChildField(
                    label: AppStrings.roles.tr,
                    height: 50,
                    child: Obx(() {
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.backGroundColor,
                        ),
                        child: DropdownButton<String>(
                          hint:  Text(AppStrings.roles.tr),
                          icon: const SizedBox(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          value: userDetailsController.userFormHandler.selectedRoleId.value,
                          items: read<UserManagementController>().allRoles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role.roleId,
                                  child: Text(role.roleName!),
                                ),
                              )
                              .toList(),
                          onChanged: (role) {
                            log('selectedRoleId $role');
                            userDetailsController.userFormHandler.setRoleId = role;
                          },
                        ),
                      );
                    }),
                  ),
                  secondItem: TextAndExpandedChildField(
                    label: 'البائع',
                    height: 50,
                    child: Obx(() {
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.backGroundColor,
                        ),
                        child: DropdownButton<String>(
                          hint: const Text('البائع'),
                          icon: const SizedBox(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          value: userDetailsController.userFormHandler.selectedSellerId.value,
                          items: sellerController.sellers
                              .map(
                                (seller) => DropdownMenuItem(
                                  value: seller.costGuid,
                                  child: Text(seller.costName ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (sellerId) {
                            log('selectedSellerId $sellerId');
                            userDetailsController.userFormHandler.setSellerId = sellerId;
                          },
                        ),
                      );
                    }),
                  )),
              InkWell(
                onTap: (){
                  userDetailsController.userFormHandler.changeUserState();

                },
                child: AnimatedContainer(
                  duration: Durations.medium2,
                  height: 30,
                  width: 120,
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: userDetailsController.userFormHandler.isUserActive.value ? Colors.green : AppColors.grayColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child:   Text(
                    userDetailsController.userFormHandler.userActiveStatus.value.label,
                    style: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
