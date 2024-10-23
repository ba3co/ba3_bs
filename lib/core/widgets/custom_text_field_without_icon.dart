import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

class CustomTextFieldWithoutIcon extends StatefulWidget {
  const CustomTextFieldWithoutIcon({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.keyboardType,
    this.onIconPressed,
    this.onChanged,
    this.inputFormatters,
    this.isNumeric = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final void Function(String)? onSubmitted;
  final Function()? onIconPressed;
  final void Function(String _)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool isNumeric, enabled;

  @override
  _CustomTextFieldWithoutIconState createState() => _CustomTextFieldWithoutIconState();
}

class _CustomTextFieldWithoutIconState extends State<CustomTextFieldWithoutIcon> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(convertArabicNumbersToEnglish);
  }

  @override
  void dispose() {
    widget.controller.removeListener(convertArabicNumbersToEnglish);
    super.dispose();
  }

  void convertArabicNumbersToEnglish() {
    if (widget.isNumeric) {
      final text = widget.controller.text;
      final convertedText = text.replaceAllMapped(
        RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 0x660).toString(),
      );

      if (text != convertedText) {
        widget.controller.value = widget.controller.value.copyWith(
          text: convertedText,
          selection: TextSelection.collapsed(offset: convertedText.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.constHeightTextField,
      child: TextFormField(
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        onFieldSubmitted: widget.onSubmitted,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        scrollPadding: EdgeInsets.zero,

        cursorHeight: 15,
        onTap: () =>
            widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length),
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: UnderlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black, // Change the border color
              width: 2.0, // Change the border width
            ),
            borderRadius: BorderRadius.circular(5.0), // Adjust border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.blue, // Change the border color when focused
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0), // Center the text vertically
        ),
        textAlign: TextAlign.center,
        // Center the text horizontally
      ),
    );
  }
}
