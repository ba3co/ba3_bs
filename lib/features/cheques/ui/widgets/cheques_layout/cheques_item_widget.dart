import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_layout/body_cheques_layout_shimmer_widget.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_layout/body_cheques_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';

class ChequesItemWidget extends StatelessWidget {
  const ChequesItemWidget({
    super.key,
    required this.onNewTap,
    required this.chequesType,
    required this.chequesController,
  });

  final VoidCallback onNewTap;
  final ChequesType chequesType;
  final AllChequesController chequesController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: 67.w,
      height: 170.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 0.2,
          color: AppColors.grayColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chequesType.value,
                  style: AppTextStyles.headLineStyle2,
                  textDirection: TextDirection.rtl,
                ),
              ),
              Image.asset(
                chequesType.icon,
                width: 0.035.sw,
                height: 0.035.sh,
              ),
            ],
          ),
          Spacer(),
          Obx(() {
            return chequesController.allChequesRequestState.value ==
                    RequestState.loading
                ? BodyChequesLayoutShimmerWidget()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          chequesController.fetchAllChequesByTypeForListView(
                            chequesType,
                            context,
                            onlyDues: false,
                          );
                        },
                        child: BodyChequesLayoutWidget(
                          firstText:
                              "${AppStrings.from.tr}  ${chequesType.from}",
                          secondText:
                              "${AppStrings.to.tr}  ${chequesController.allChequesCounts(chequesType)}",
                        ),
                      ),
                      SizedBox(height: 6.h),
                      GestureDetector(
                        onTap: () {
                          chequesController.fetchAllChequesByTypeForListView(
                            chequesType,
                            context,
                            onlyDues: true,
                          );
                        },
                        child: Text(
                          AppStrings.chequesDues.tr,
                          style: AppTextStyles.headLineStyle3.copyWith(
                            color: AppColors.lightBlueColor,
                            decoration: TextDecoration.underline,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  );
          }),
          Spacer(),
          AppButton(
            title: AppStrings.newS.tr,
            onPressed: onNewTap,
            iconData: Icons.add,
            color: Color(int.parse("0xff${chequesType.color}")).withAlpha(220),
          ),
        ],
      ),
    );
  }
}
