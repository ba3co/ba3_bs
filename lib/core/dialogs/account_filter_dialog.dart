import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styling/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/option_text_widget.dart';

class AccountFilterDialog extends StatelessWidget {
  const AccountFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(

        textDirection: TextDirection.rtl,
        child: GetBuilder<AccountStatementController>(builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,


              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.lightBlueColor,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text('خيارت العرض'),
                          const SizedBox(height: 15),
                          OptionTextWidget(
                              title: 'اسم الحساب :  ',
                              controller: controller.accountNameController,
                              onSubmitted: (text) {
                                controller.onAccountNameSubmitted(text, context);
                              }),
                          OptionTextWidget(
                            title: 'من تاريخ :  ',
                            controller: controller.startDateController,
                            onSubmitted: controller.onStartDateSubmitted,
                          ),
                          OptionTextWidget(
                            title: 'الى تاريخ :  ',
                            controller: controller.endDateController,
                            onSubmitted: controller.onEndDateSubmitted,
                          ),


                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Center(
                  child: AppButton(
                    title: 'موافق',
                    iconData: Icons.check,
                    onPressed: () {
                      controller
                        ..fetchAccountEntryBondItems()
                        ..navigateToAccountStatementScreen(context,);
                    },
                  ),
                ),
              ],

            ),
          );
        }),
      ),
    );
  }
}