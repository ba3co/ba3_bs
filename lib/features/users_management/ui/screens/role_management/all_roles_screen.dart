import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';

class AllRolesScreen extends StatelessWidget {
  const AllRolesScreen({super.key});

  IconData _getIconForRole(String? roleName) {
    switch (roleName?.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'read only':
        return Icons.manage_accounts;
      case 'seller':
        return Icons.shopping_cart;
      case 'administrator':
        return Icons.account_balance_wallet;
      case 'cashier':
        return Icons.people_alt;
      default:
        return Icons.security; // fallback icon
    }
  }

  Color _getIconColor(String? roleName) {
    switch (roleName?.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'read only':
        return Colors.green;
      case 'seller':
        return Colors.orange;
      case 'administrator':
        return Colors.blue;
      case 'cashier':
        return Colors.purple;
      default:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppStrings.administration.tr} ${AppStrings.roles.tr}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AppButton(
            title: AppStrings.add.tr,
            onPressed: () {
              read<UserManagementController>().userNavigator.navigateToAddRoleScreen();
            },
            iconData: Icons.add,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: GetBuilder<UserManagementController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: controller.allRoles.isEmpty
                ? const Center(
                    child: Text(
                      'No roles found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    itemCount: controller.allRoles.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final role = controller.allRoles[index];
                      final icon = _getIconForRole(role.roleName);
                      final iconColor = _getIconColor(role.roleName);
                      return GestureDetector(
                        onTap: () {
                          controller.userNavigator.navigateToAddRoleScreen(role);
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
                                  backgroundColor: iconColor.withOpacity(0.1),
                                  child: Icon(icon, color: iconColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  role.roleName ?? '',
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
          );
        },
      ),
    );
  }
}
