import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../login/controllers/user_management_controller.dart';
import '../../../sellers/controllers/sellers_controller.dart';

class AddEditUserForm extends StatelessWidget {
  const AddEditUserForm({
    super.key,
    required this.userManagementController,
    required this.sellerController,
  });

  final UserManagementController userManagementController;
  final SellerController sellerController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 300,
          child: Row(
            children: [
              const SizedBox(width: 70, child: Text('اسم الحساب')),
              const SizedBox(
                width: 30,
              ),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                  controller: userManagementController.nameController,
                  onChanged: (newValue) {
                    userManagementController.initAddUserModel?.userName = newValue;
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 300,
          child: Row(
            children: [
              const SizedBox(width: 70, child: Text('كلمة السر')),
              const SizedBox(
                width: 30,
              ),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                  controller: userManagementController.pinController,
                  onChanged: (newValue) {
                    userManagementController.initAddUserModel?.userPin = newValue;
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 300,
          child: Row(
            children: [
              const SizedBox(width: 70, child: Text('الصلاحيات')),
              const SizedBox(
                width: 30,
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: DropdownButton<String>(
                    icon: const SizedBox(),
                    value: userManagementController.initAddUserModel?.userRole,
                    items: userManagementController.roles
                        .map((role) => DropdownMenuItem(value: role.roleId, child: Text(role.roleName!)))
                        .toList(),
                    onChanged: (newValue) {
                      userManagementController.initAddUserModel?.userRole = newValue;
                      userManagementController.update();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 300,
          child: Row(
            children: [
              const SizedBox(width: 70, child: Text('البائع')),
              const SizedBox(
                width: 30,
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: DropdownButton<String>(
                    icon: const SizedBox(),
                    value: userManagementController.initAddUserModel?.userSellerId,
                    items: sellerController.sellers
                        .map(
                          (seller) => DropdownMenuItem(
                            value: seller.costGuid,
                            child: Text(seller.costName ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      userManagementController.initAddUserModel?.userSellerId = newValue;
                      userManagementController.update();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
