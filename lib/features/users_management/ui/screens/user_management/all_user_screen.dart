import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';

class AllUserScreen extends StatelessWidget {
  const AllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title:  Text('${AppStrings.administration.tr} ${AppStrings.users.tr}'),
            actions: [
              AppButton(
                  title: AppStrings.add.tr,
                  onPressed: () {
                    controller. userNavigator.navigateToAddUserScreen();
                  },
                  iconData: Icons.add),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                children: List.generate(
                  controller.allUsers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        controller. userNavigator.navigateToAddUserScreen(controller.allUsers[index]);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        height: 140,
                        width: 140,
                        child: Text(
                          controller.allUsers[index].userName ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
