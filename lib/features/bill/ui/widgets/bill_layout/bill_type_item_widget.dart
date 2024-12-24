import 'dart:math';

import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class BillITypeItemWidget extends StatelessWidget {
  const BillITypeItemWidget({super.key, required this.onTap, required this.text, this.color = Colors.white});

  final VoidCallback onTap;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 350,
        child: Column(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 220,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style:AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Container(
              height: 100,
              width: 350,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12), topLeft: Radius.circular(12)),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        spacing: 5,
                        children: [
                          Text(
                            'كل الفواتير :',
                            style: AppTextStyles.headLineStyle3,
                          ),
                          Text(
                            '${Random().nextInt(500000)}',
                            style: AppTextStyles.headLineStyle3.copyWith(color: color),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Text(
                            ' فواتير اليوم :',
                            style: AppTextStyles.headLineStyle3,
                          ),
                          Text(
                            '${Random().nextInt(100)}',
                            style: AppTextStyles.headLineStyle3.copyWith(color: color),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton(
                    title: "جديد",
                    onPressed: onTap,
                    iconData: Icons.fiber_new_outlined,
                    color: color,
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
