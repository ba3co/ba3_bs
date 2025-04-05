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
            title: Text(
              '${AppStrings.administration.tr} ${AppStrings.users.tr}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              AppButton(
                title: AppStrings.add.tr,
                onPressed: () {
                  controller.userNavigator.navigateToAddUserScreen();
                },
                iconData: Icons.add,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: controller.allUsers.isEmpty
                ? const Center(
              child: Text(
                'No users found.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : GridView.builder(
              itemCount: controller.allUsers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final user = controller.allUsers[index];
                return GestureDetector(
                  onTap: () {
                    controller.userNavigator.navigateToAddUserScreen(user);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              user.userName?.substring(0, 1).toUpperCase() ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.userName ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
