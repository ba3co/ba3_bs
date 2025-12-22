import 'dart:math';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_type_controller.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_layout/bond_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../widgets/bond_layout/body_bond_layout_shimmer_widget.dart';
import '../widgets/bond_layout/bond_type_widget.dart';

class BondLayout extends StatelessWidget {
  const BondLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = read<AllBondsController>().uploadProgress.value;

      return Stack(
        children: [
          GetBuilder<AllBondsController>(builder: (controller) {
            return Scaffold(
              appBar: bondLayoutAppBar(controller, context),
              body: Container(
                padding: EdgeInsets.all(8),
                width: 1.sw,
                child: Obx(() {
                  final bondTypeController = Get.find<BondTypeController>();
                  return RefreshIndicator(
                    onRefresh: () => bondTypeController.fetchBondTypes(),
                    child: OrganizedWidget(
                      titleWidget: Row(
                        children: [
                          Align(
                            child: Text(
                              AppStrings.bonds.tr,
                              style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            tooltip: AppStrings.refresh.tr,
                            icon: Icon(
                              FontAwesomeIcons.refresh,
                              color: AppColors.lightBlueColor,
                            ),
                            onPressed: controller.refreshBondsTypes,
                          ),
                        ],
                      ),
                      bodyWidget: bondTypeController.getBondsTypesRequestState.value == RequestState.loading
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: List.generate(
                              10,
                                  (index) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const BodyBondLayoutShimmerWidget(),
                              ),
                            ),
                          ),

                          VerticalSpace(),

                          Center(
                            child: Opacity(
                              opacity: 0.5, // Looks shimmer-like
                              child: Container(
                                width: max(45.w, 140),
                                height: 35.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : Column(
                              // padding: const EdgeInsets.all(15.0),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  children: bondTypeController.bondTypes.toList().map(
                                    (bondType) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: BondTypeWidget(
                                          bondsController: controller,
                                          onTap: () {
                                            /// this is the most important line in the whole thing
                                            controller.openFloatingBondDetails(context, bondType);
                                          },
                                          bondTypeModel: bondType,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                                VerticalSpace(),
                                Center(
                                  child: AppButton(
                                    title: AppStrings.addBondType.tr,
                                    fontSize: 13.sp,
                                    color: AppColors.grayColor,
                                    onPressed: () {
                                      bondTypeController.navigateToAddBondTypeScreen(context: context);
                                    },
                                    iconData: Icons.view_list_outlined,
                                    width: max(45.w, 140),
                                    // width: 40.w,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),
            );
          }),
          LoadingDialog(
            isLoading: read<AllBondsController>().saveAllBondsRequestState.value == RequestState.loading,
            message: '${(progress * 100).toStringAsFixed(2)}% ${AppStrings.from.tr} ${AppStrings.bonds.tr}',
            fontSize: 14.sp,
          )
        ],
      );
    });
  }
}
