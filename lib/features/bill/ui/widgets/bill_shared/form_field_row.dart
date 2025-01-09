import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_spacer.dart';

class FormFieldRow extends StatelessWidget {
  const FormFieldRow({super.key, required this.firstItem, required this.secondItem, this.visible});

  final Widget firstItem;
  final Widget secondItem;

  final bool? visible;

  @override
  Widget build(BuildContext context) {
    return (visible ?? true)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: firstItem),
              const HorizontalSpace(20),
              Expanded(child: secondItem),
            ],
          )
        : SizedBox();
  }
}
