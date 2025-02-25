import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
          child: Text(
            AppStrings.delayRecord.tr,
            style: AppTextStyles.headLineStyle2,
          ),
        ),
        bodyWidget: ListView.separated(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: userDetailsController.userTimeModelWithTotalDelayAndEarlierLength,
          separatorBuilder: (context, index) => VerticalSpace(),
          itemBuilder: (context, index) {
            final userTimeModel = userDetailsController.userTimeModelWithTotalDelayAndEarlier!.elementAt(index);

            return Column(
              children: [
                _buildDayHeader(userTimeModel),
                VerticalSpace(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayHeader(UserTimeModel userTime) {
    return Container(
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.red))),
      child: Row(
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
      ),
    );
  }
}