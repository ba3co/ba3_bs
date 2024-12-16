import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:flutter/material.dart';


class ChequesTypeItemWidget extends StatelessWidget {
  final ChequesType cheques;
  final VoidCallback onPressed;

  const ChequesTypeItemWidget({
    super.key,
    required this.cheques,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 3,
        foregroundColor: Colors.black,
        overlayColor: Colors.grey,
        padding: const EdgeInsets.all(30.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        cheques.value,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ),
    );
  }
}
