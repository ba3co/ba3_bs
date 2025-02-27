import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/users_management/controllers/user_details_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';

class UserTotalDelay extends StatelessWidget {
  const UserTotalDelay({
    super.key,
    required this.userDetailsController,
  });

  final UserDetailsController userDetailsController;

  @override
  Widget build(BuildContext context) {
    return OrganizedWidget(
      titleWidget: Center(
        child: Text(
          AppStrings.totalDelay.tr,
          style: AppTextStyles.headLineStyle2,
        ),
      ),
      bodyWidget: _buildDayHeader(userDetailsController.userFormHandler.userTimeModelWithTotalDelayAndEarlierAtMonth!),
    );
  }

  Widget _buildDayHeader(UserTimeModel userTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        Text("الشهر : ", style: AppTextStyles.headLineStyle2),
        Text(int.parse(userTime.dayName!).toString(), style: AppTextStyles.headLineStyle2),
        Spacer(),
        Text("التأخير : ", style: AppTextStyles.headLineStyle2),
        Text(AppServiceUtils.convertMinutesAndFormat(userTime.totalLogInDelay!), style: AppTextStyles.headLineStyle2),
        Spacer(),
        Text("الخروج المبكر : ", style: AppTextStyles.headLineStyle2),
        Text(AppServiceUtils.convertMinutesAndFormat(userTime.totalOutEarlier!), style: AppTextStyles.headLineStyle2),
        Spacer(),
      ],
    );
  }
}