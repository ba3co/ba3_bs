import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../controllers/sellers_controller.dart';

class AllSellersScreen extends StatelessWidget {
  const AllSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = read<SellersController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: Text(AppStrings.allSellers.tr),
        ),
        body: Obx(() {
          if (controller.sellers.isEmpty) {
            return Center(
              child: Text(
                AppStrings.thereAreNoSellersYet.tr,
                style: TextStyle(fontSize: 18.sp),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.sellers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: calculateResponsiveCrossAxisCount(1.sw),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final seller = controller.sellers[index];
              final initials = (seller.costName ?? '؟').isNotEmpty ? seller.costName![0].toUpperCase() : '?';

              return InkWell(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: () => read<SellerSalesController>().navigateToSellerSalesScreen(seller, context),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: const Color(0xFFFDFDFD),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade50,
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            seller.costName ?? '',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'كود: ${seller.costCode ?? '---'}',
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Obx(() {
                                  return IconButton(
                                    icon: Icon(Icons.delete,
                                        color: controller.deleteSellerRequestState.value == RequestState.loading
                                            ? Colors.grey
                                            : Colors.red.shade400),
                                    onPressed: controller.deleteSellerRequestState.value == RequestState.loading
                                        ? () {}
                                        : () async {
                                            if (await AppUIUtils.confirmOverlay(context)) {

                                              if(!context.mounted) return;
                                              controller.deleteSeller(seller.costGuid!,context);
                                            }
                                          },
                                  );
                                }),
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.solidPenToSquare,
                                    size: 16,
                                    color: AppColors.lightBlueColor,
                                  ),
                                  onPressed: () {
                                    read<SellerSalesController>().navigateToAddSellerScreen(
                                      seller: seller,
                                      context: context,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  int calculateResponsiveCrossAxisCount(double screenWidth, {double minItemWidth = 280}) => screenWidth ~/ minItemWidth;
}