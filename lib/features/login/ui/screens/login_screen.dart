import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../controllers/nfc_cards_controller.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/login_header_text.dart';
import '../widgets/pin_input_fields.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoginHeaderText(),
                Column(
                  children: [
                    const Center(
                      child: Text(
                        "ادخل الرقم السري الخاص بك",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const VerticalSpace(30),
                    SizedBox(
                      height: 75,
                      child: GetBuilder<UserManagementController>(
                        builder: (controller) {
                          return controller.userStatus != UserManagementStatus.login
                              ? Obx(() {
                                  final nfcController = Get.find<NfcCardsController>();
                                  return nfcController.isNfcAvailable.value
                                      ? const Text("يرجى تقريب بطاقة الدخول")
                                      : PinInputFields(controller: controller);
                                })
                              : const LoadingIndicator();
                        },
                      ),
                    ),
                    // GetBuilder<UserManagementController>(
                    //   builder: (controller) {
                    //     if (Get.isRegistered<GlobalController>()) {
                    //       GlobalController globalModel = Get.find<GlobalController>();
                    //       return Obx(
                    //         () => Text("${globalModel.count} / ${globalModel.allCountOfInvoice}"),
                    //       );
                    //     }
                    //     return const SizedBox();
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
