import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppButton extends StatelessWidget {
  const AppButton(
      {super.key, required this.title, required this.onPressed, required this.iconData, this.color, this.width = 100});

  final String title;
  final Color? color;
  final IconData iconData;
  final VoidCallback onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(color),
            shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))))),
        onPressed: onPressed,
        child: SizedBox(
          width: width,
          height: AppConstants.constHeightTextField,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // const Spacer(),
                Icon(
                  iconData,
                  size: 22,
                ),
              ],
            ),
          ),
        ));
  }
}
