
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/utils/app_service_utils.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../../users_management/controllers/user_management_controller.dart';

class AllHolidaysWidget extends StatelessWidget {
  const AllHolidaysWidget({
    super.key,
    required this.userManagementController,
  });

  final UserManagementController userManagementController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
          titleWidget: Center(
              child: Text(
            'ايام العطل',
            style: AppTextStyles.headLineStyle2,
          )),
          bodyWidget: Column(
            children: [
              ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: userManagementController.userFormHandler.userHolidaysLength,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userManagementController.userFormHandler.userHolidays.elementAt(index),
                      style: AppTextStyles.headLineStyle3,
                    ),
                    Text(
                      AppServiceUtils.getDayNameAndMonthName(userManagementController.userFormHandler.userHolidays.elementAt(index)),
                      style: AppTextStyles.headLineStyle3,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

